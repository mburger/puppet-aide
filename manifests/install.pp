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
}
