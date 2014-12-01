# Class: aide::params
#
# This class defines default parameters used by the main module class aide
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to aide class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class aide::params {

  ### Application related parameters

  $package = $::operatingsystem ? {
    default => 'aide',
  }

  $config_file = $::operatingsystem ? {
    default => '/etc/aide.conf',
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $data_dir = $::operatingsystem ? {
    default => '/var/lib/aide',
  }

  $log_dir = $::operatingsystem ? {
    default => '/var/log/aide',
  }

  $log_file = $::operatingsystem ? {
    default => '/var/log/aide/aide.log',
  }

  $binary_path = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => '/usr/bin/aide',
    default                   => '/usr/sbin/aide',
  }

  $db_name = $::operatingsystem ? {
    default => 'aide.db.gz',
  }

  $db_tmp_name = $::operatingsystem ? {
    default => 'aide.db.new.gz',
  }

  # General Settings
  $my_class = ''
  $dependency_class = ''
  $source = ''
  $template = ''
  $options = ''
  $version = 'present'
  $config = 'concat'
  $absent = false
  $disable = false
  $disableboot = false
  $update_db = false
  $directives = {}
  $cron = false
  $cron_hour = 7
  $cron_minute = 0

  ### General module variables that can have a site or per module default
  $debug = false
  $audit_only = false
  $noops = undef

}
