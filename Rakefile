require 'English'
require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

require 'puppet-lint/tasks/puppet-lint'
PuppetLint.configuration.fail_on_warnings
PuppetLint.configuration.send('disable_autoloader_layout')

task default: [:validate_templates, :validate_manifests, :rubocop, :spec, :lint]

desc 'Validate ERB templates.'
task :validate_templates do
  Dir['templates/**/*.erb'].each do |template|
    system "erb -P -x -T '-' #{template} | ruby -c"
  end
end

desc 'Validate Puppet manifests.'
task :validate_manifests do
  Dir['manifests/**/*.pp'].each do |manifest|
    system "puppet parser validate --noop #{manifest}"
  end
end

desc 'Style-check Ruby files with RuboCop.'
task rubocop: [:get_rubocop] do
  system 'rubocop .'
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '--format documentation --color'
end

task :get_rubocop do
  gem_install('rubocop') unless runs_ok('rubocop --version')
end

# Run a shell command and return true if it succeeds.
def runs_ok(command)
  system "#{command} > /dev/null 2>&1"
  $CHILD_STATUS.exitstatus == 0
end

# Install a Gem
def gem_install(gem)
  puts "Installing #{gem}..."
  system "sudo gem install #{gem}"
end
