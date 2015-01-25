require 'spec_helper.rb'
Puppet.settings[:confdir] = 'spec/fixtures'
require_relative '../lib/puppet/reports/slack.rb'

describe SlackReporter do
  sr = SlackReporter.new

  describe '.build_json_request' do
    request = JSON.parse(sr.build_json_request('Message!'))

    it 'sets the text' do
      expect(request['text']).to eq('Message!')
    end

    it 'sets the channel' do
      expect(request['channel']).to eq('#puppet_channel')
    end

    it 'sets the username' do
      expect(request['username']).to eq('puppet_user')
    end

    it 'sets the icon url' do
      expect(request['icon_url']).to eq('http://server/puppet.jpg')
    end
  end
end
