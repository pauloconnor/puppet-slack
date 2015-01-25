require 'puppet'
require 'yaml'
require 'faraday'

Puppet::Reports.register_report(:slack) do
  desc 'Send notification of puppet run reports to Slack Messaging.'

  @configfile = File.join(File.dirname(Puppet.settings[:config]), 'slack.yaml')
  unless File.readable?(@configfile)
    msg = "Slack report config file #{@configfile} is not readable."
    fail(Puppet::ParseError, msg)
  end
  @config = YAML.load_file(@configfile)
  SLACK_TOKEN = @config[:slack_token]
  SLACK_CHANNEL = @config[:slack_channel]
  SLACK_BOTNAME = @config[:slack_botname]
  SLACK_ICONURL = @config[:slack_iconurl]
  SLACK_URL = @config[:slack_url]

  def process
    return unless status == 'failed' || status == 'changed'
    Puppet.debug "Sending status for #{host} to Slack."
    conn = Faraday.new(url: "#{SLACK_URL}") do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    conn.post do |req|
      req.url "/services/hooks/incoming-webhook?token=#{SLACK_TOKEN}"
      req.body = "{\"channel\":\"#{SLACK_CHANNEL}\",\"username\":\"#{SLACK_BOTNAME}\", \"icon_url\":\"#{SLACK_ICONURL}\",\"text\":\"> Puppet run for #{host} `#{status}` at #{Time.now.asctime}\"}"
    end
  end
end
