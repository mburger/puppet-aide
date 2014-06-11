# Class: aide::config
#
# This class manages aide configuration
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
class aide::config {

  case $aide::config {
    'file': {
      file { 'aide.conf':
        ensure  => $aide::manage_file,
        path    => $aide::config_file,
        mode    => $aide::config_file_mode,
        owner   => $aide::config_file_owner,
        group   => $aide::config_file_group,
        source  => $aide::manage_file_source,
        content => $aide::manage_file_content,
        replace => $aide::manage_file_replace,
        audit   => $aide::manage_audit,
        noop    => $aide::noops,
      }
    }
    'concat': {
      concat { $aide::config_file:
        ensure  => $aide::manage_file,
        mode    => $aide::config_file_mode,
        owner   => $aide::config_file_owner,
        group   => $aide::config_file_group,
        replace => $aide::manage_file_replace,
        audit   => $aide::manage_audit,
        noop    => $aide::noops,
      }

      concat::fragment { 'aide_header':
        ensure  => $aide::manage_file,
        order   => '01',
        target  => $aide::config_file,
        source  => $aide::manage_file_source,
        content => $aide::manage_file_content,
      }
    }
    'default': {
      fail("specify either 'file' or 'concat' for $aide::config")
    }
  }

}
