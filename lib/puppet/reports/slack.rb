require 'puppet'
require 'json'
require 'net/https'
require 'open-uri'
require 'socket'
require 'uri'
require 'yaml'

Puppet::Reports.register_report(:slack) do
  desc 'Send notification of puppet run reports to Slack Messaging.'

  def process

    # setup
    configfile = File.join(Puppet.settings[:confdir], 'slack.yaml')
    unless File.readable?(configfile)
      msg = "Slack report config file #{configfile} is not readable."
      raise(Puppet::ParseError, msg)
    end
    config = YAML.load_file(configfile)

    # filter
    status_icon = case self.status
                        when 'changed' then ':sparkles:'
                        when 'failed' then ':no_entry:'
                        when 'unchanged' then ':white_check_mark:'
                  end

    if config[:slack_statuses].include?(self.status)
      # We don't have the socket gem available to us
      servername = Socket.gethostbyname(Socket.gethostname).first
      # construct message
      if config[:slack_puppetboard_url]
        top_message = "#{status_icon} *<#{config[:slack_puppetboard_url]}/node/#{self.host}|#{self.host}>* at #{Time.now.asctime}\nEnvironment *#{self.environment}* on *#{servername}*"
      else
        top_message = "#{status_icon} *#{self.host}* at #{Time.now.asctime}\nEnvironment *#{self.environment}* on *#{servername}*"
      end

      total_time = ''

      self.metrics.each { |metric, data|
          path = ['puppet', metric]
          data.values.each { |name, _, value|
            path << name
            debug = [path.join('.'), value].join(' ')
            Puppet.debug "Sending: '#{debug}'"
            if path.join('.') == 'puppet.time.total'
              total_time = " - " + [path.join('.'), value].join(' ') + ' seconds'
            end
            #metrics = metrics + "\n | " +  [path.join('.'), value].join(' ')
            path.pop()
          }
        }

      message = [
        {
          "type" => "section",
          "text" => {
            "type" => "mrkdwn",
            "text" => "#{top_message}"
          }
        },
        {
          "type" => "divider"
        }
      ]

      # Collect failed or changed resources
      self.resource_statuses.each do | resource, resource_data |
        if config[:slack_statuses].include?('changed')
          if resource_data.changed == true && resource_data.events.first
            message.push({"type" => "section","text" => {"type" => "mrkdwn", "text" =>"*#{resource}*\n#{resource_data.events.first.message}"}})
          end
        elsif config[:slack_statuses].include?('failed')
          if resource_data.failed == true && resource_data.events.first
            message.push({"type" => "section","text" => {"type" => "mrkdwn", "text" =>"*#{resource}*\n#{resource_data.events.first.message}"}})
          end
        end
      end

      Puppet.info "Sending status for #{self.host} to Slack."

      message = {
        :channel => config[:slack_channel],
        :blocks => message
      }

      open('/tmp/blockmessage', 'a') { |f|
        f.puts JSON.dump(message)
      }

      begin
        encoded_url = URI.encode(config[:slack_webhook])
        uri = URI.parse(encoded_url)
        req = Net::HTTP::Post.new uri.path
        req.body = JSON.dump(message)

        res = Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.ssl_version = :SSLv3
          http.request req
        end
      rescue
        Puppet.info "Failed to deliver payload to Slack endpoint"
        Puppet.info message
      end

    end
  end
end