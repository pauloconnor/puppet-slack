source ENV['GEM_SOURCE'] || "https://rubygems.org"

gem 'i18n', '0.6.11', :platform => [:ruby_18]
gem 'activesupport', '3.1.0', :platform => [:ruby_18]
gem 'nokogiri', '1.5.10', :platform => [:ruby_18]
gem 'retriable', '1.4.1', :platform => [:ruby_18]
gem 'highline', '1.6.21', :platform => [:ruby_18]

group :development, :test do
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'serverspec',              :require => false
  gem 'puppet-lint',             :require => false
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
  gem 'pry',                     :require => false
  gem 'simplecov',               :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
