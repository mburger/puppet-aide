# Class: aide::install
#
# This class installs aide
#
# == Variables
#
# Refer to aide class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It's automatically included by aide
#
class aide::install {
  ### Managed resources
  package { $aide::package:
    ensure  => $aide::manage_package,
    noop    => $aide::noops,
  }

  if $aide::bool_cron {
    cron { 'aide':
      ensure  => $aide::manage_file,
      command => "nice -19 ${aide::binary_path} --update ; /bin/mv -f ${aide::data_dir}/${aide::db_tmp_name} ${aide::data_dir}/${aide::db_name}",
      user    => $aide::config_file_owner,
      hour    => $aide::cron_hour,
      minute  => $aide::cron_minute,
    }
  }
}
