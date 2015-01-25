require 'puppet'
require 'yaml'
require 'faraday'
require 'json'

# Helper class to handle interacting with the Slack API.
class SlackReporter
  def initialize
    configfile = File.join(Puppet.settings[:confdir], 'slack.yaml')
    unless File.readable?(configfile)
      msg = "Slack report config file #{@configfile} is not readable."
      fail(Puppet::ParseError, msg)
    end
    @config = YAML.load_file(configfile)
  end

  def build_json_request(text)
    request = {
      'channel' => @config[:slack_channel],
      'username' => @config[:slack_botname],
      'icon_url' => @config[:slack_iconurl],
      'text' => text
    }
    JSON.generate(request)
  end

  def report(message)
    conn = Faraday.new(url: "#{@config[:slack_url]}") do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    conn.post do |req|
      req.url "/services/hooks/incoming-webhook?token=#{@config[:slack_token]}"
      req.body = build_json_request(message)
    end
  end
end

Puppet::Reports.register_report(:slack) do
  desc 'Send notification of puppet run reports to Slack Messaging.'

  def process
    return unless status == 'failed' || status == 'changed'
    Puppet.debug "Sending status for #{host} to Slack."
    reporter = SlackReporter.new
    message = "Puppet run for #{host} `#{status}` at #{Time.now.asctime}"
    reporter.report(message)
  end
end
