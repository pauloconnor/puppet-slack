# Report processor integration with Slack.com
class slack (
  $slack_webhook        = undef,
  $slack_channel        = '#puppet',
  $slack_puppet_reports = undef,
  $slack_puppet_dir     = '/etc/puppet',
  $slack_statuses       = ['changed', 'failed', 'unchanged'],
  $ca_server            = undef,
) {

  anchor {'slack::begin':}

  file { "${slack_puppet_dir}/slack.yaml":
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template('slack/slack.yaml.erb'),
  }

  if $slack_puppet_reports {
    ini_setting { 'slack_puppet_reports':
      ensure  => present,
      path    => "${slack_puppet_dir}/puppet.conf",
      section => 'master',
      setting => 'reports',
      value   => $slack_puppet_reports,
      require => File["${slack_puppet_dir}/slack.yaml"],
      before  => Anchor['slack::end'],
    }
  }

  # There's a bug in Puppet 5 that requires this
  file { '/opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/reports/slack.rb':
    ensure => 'link',
    target => '/opt/puppetlabs/puppet/cache/lib/puppet/reports/slack.rb',
  }

  anchor{'slack::end':
    require => File["${slack_puppet_dir}/slack.yaml"],
  }
}
