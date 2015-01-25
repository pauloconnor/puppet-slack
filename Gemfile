source ENV['GEM_SOURCE'] || 'https://rubygems.org'

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
end

if ENV['FACTER_GEM_VERSION'].nil?
  gem 'facter', require: false
else
  gem 'facter', ENV['FACTER_GEM_VERSION'], require: false
end

if ENV['PUPPET_GEM_VERSION'].nil?
  gem 'puppet', require: false
else
  gem 'puppet', ENV['PUPPET_GEM_VERSION'], require: false
end

# vim:ft=ruby
