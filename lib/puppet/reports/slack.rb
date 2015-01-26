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

  # Compose a Slack API compatible JSON object containing +message+.
  def compose(message)
      JSON.generate({
        'channel'  => @config[:slack_channel],
        'username' => @config[:slack_botname],
        'icon_url' => @config[:slack_iconurl],
        'text'     => message
      })
  end

  # Send +message+ to Slack.
  def say(message)
    conn = Faraday.new(url: @config[:slack_url]) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    conn.post do |req|
      req.url "/services/hooks/incoming-webhook?token=#{@config[:slack_token]}"
      req.body = compose(message)
    end
  end
end

Puppet::Reports.register_report(:slack) do
  desc 'Send notification of puppet run reports to Slack Messaging.'

  def process
    case status
    when 'unchanged'
      return
    when 'changed'
      status_icon = ':sparkles:'
      # Refer: https://slack.zendesk.com/hc/en-us/articles/202931348-Using-emoji-and-emoticons
    when 'failed'
      status_icon = ':no_entry:'
    end

    Puppet.debug "Sending status for #{host} to Slack."
    puppetboard = 'http://puppetboard.in.n6.com.au'
    message = "#{status_icon} <#{puppetboard}/node/#{host}|#{host}> #{status}."
    SlackReporter.new.say(message)
  end
end
