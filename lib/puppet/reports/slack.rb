require 'puppet'
require 'yaml'
require 'faraday'
require 'json'
require 'uri'

# Helper class to handle interacting with the Slack API.
class SlackReporter
  def initialize
    configfile = File.join(Puppet.settings[:confdir], 'slack.yaml')
    unless File.readable?(configfile)
      msg = "Slack report config file #{@configfile} is not readable."
      fail(Puppet::ParseError, msg)
    end
    @config = YAML.load_file(configfile)
    @slack_uri = URI.parse(@config[:slack_url])
  end

  # Compose a Slack API compatible JSON object containing +message+.
  def compose(message)
    JSON.generate(
      'channel'  => @config[:slack_channel],
      'username' => @config[:slack_botname],
      'icon_url' => @config[:slack_iconurl],
      'text'     => message
    )
  end

  # Send +message+ to Slack.
  def say(message)
    conn = Faraday.new(url: @slack_uri.scheme + '//' + @slack_uri.host) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    conn.post do |req|
      req.url  = @slack_uri.path
      req.body = compose(message)
    end
  end
end

Puppet::Reports.register_report(:slack) do
  desc 'Send notification of puppet run reports to Slack Messaging.'

  def process
    return if status == 'unchanged'
    status_icon = ':sparkles:' if status == 'changed'
    status_icon = ':no_entry:' if status == 'failed'
    # Refer: https://slack.zendesk.com/hc/en-us/articles/202931348-Using-emoji-and-emoticons

    if @config[:slack_puppetboard_url]
      message = "#{status_icon} Puppet run for <#{config[:slack_puppetboard_url]}/node/#{host}|#{host}> #{status} at #{Time.now.asctime}."
    else
      message = "#{status_icon} Puppet run for #{host} #{status} at #{Time.now.asctime}."
    end

    Puppet.debug "Sending status for #{host} to Slack."
    SlackReporter.new.say(message)
  end
end
