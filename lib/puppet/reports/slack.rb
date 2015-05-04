require 'puppet'
require 'yaml'
require 'faraday'
require 'json'
require 'uri'
require 'pp'

Puppet::Reports.register_report(:slack) do
  desc 'Send notification of puppet run reports to Slack Messaging.'

  def compose(message)
    JSON.generate(
      'channel'  => @config[:slack_channel],
      'username' => @config[:slack_botname],
      'icon_url' => @config[:slack_iconurl],
      'text'     => message
    )
  end

  def process

    # setup
    configfile = File.join(Puppet.settings[:confdir], 'slack.yaml')
    unless File.readable?(configfile)
      msg = "Slack report config file #{configfile} is not readable."
      raise(Puppet::ParseError, msg)
    end
    config = YAML.load_file(configfile)
    slack_uri = URI.parse(config[:slack_url])

    # debug
    our_report = self.pretty_inspect
    Puppet.warning "Got report object: #{our_report}"

    # filter
    return if self.status == 'unchanged'
    status_icon = ':sparkles:' if self.status == 'changed'
    status_icon = ':no_entry:' if self.status == 'failed'
    # Refer: https://slack.zendesk.com/hc/en-us/articles/202931348-Using-emoji-and-emoticons

    # construct message
    if config[:slack_puppetboard_url]
      message = "#{status_icon} Puppet run for <#{config[:slack_puppetboard_url]}/node/#{self.host}|#{self.host}> #{self.status} at #{Time.now.asctime}."
    else
      message = "#{status_icon} Puppet run for #{self.host} #{self.status} at #{Time.now.asctime}."
    end

    Puppet.warning "Sending status for #{self.host} to Slack."

    conn = Faraday.new(:url => slack_uri.scheme + '//' + slack_uri.host) do |faraday|
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end

    conn.post do |req|
      req.url slack_uri.path
      req.body = compose(message)
    end

  end
end
