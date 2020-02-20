# rubocop:disable Style/HashSyntax
source ENV['GEM_SOURCE'] || 'https://rubygems.org'

gem 'i18n', '0.6.11', :platform => [:ruby_18]
gem 'activesupport', '3.1.0', :platform => [:ruby_18]
gem 'nokogiri', '1.5.10', :platform => [:ruby_18]
gem 'retriable', '1.4.1', :platform => [:ruby_18]
gem 'highline', '1.6.21', :platform => [:ruby_18]

group :development, :test do
  gem 'rake',                   :require => false
  gem 'rspec-puppet',           :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'serverspec',             :require => false
  gem 'puppet-lint',            :require => false
  gem 'beaker',                 :require => false
  gem 'beaker-rspec',           :require => false
  gem 'pry',                    :require => false
  gem 'simplecov',              :require => false
  gem 'rubocop',                :require => false
end

if ENV['FACTER_GEM_VERSION'].nil?
  gem 'facter', :require => false
else
  gem 'facter', ENV['FACTER_GEM_VERSION'], :require => false
end

if ENV['PUPPET_GEM_VERSION'].nil?
  gem 'puppet', :require => false
else
  gem 'puppet', ENV['PUPPET_GEM_VERSION'], :require => false
end

# rubocop:enable Style/HashSyntax
