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
