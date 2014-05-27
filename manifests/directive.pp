# = Define: aide::directive
#
# == Parameters
#
# [*content*]
#   Sets the value of content parameter for the aide fragment.
#   Can be set as an array (joined with newlines)
#
# [*source*]
#   Sets the value of source parameter for the aide fragment
#
# [*template*]
#   Sets the value of content parameter for the aide fragment
#   Note: This option is alternative to the source one
#
# [*ensure*]
#   Define if the fragment should be present (default) or 'absent'
#
# [*order*]
#   Sets the order of the fragment inside /etc/aideers or /etc/aideers.d
#   Default 20
#
define aide::directive (
  $ensure  = present,
  $content = '',
  $source  = '',
  $order   = '02'
) {

  include aide

  $manage_source = $source ? {
    ''        => undef,
    default   => $source,
  }

  $manage_content = $content ? {
    ''        => $manage_source ? {
      default   => undef,
      undef     => $name,
    },
    default   => $content,
  }

  case $aide::config {
    'concat': {
      concat::fragment { "aide_fragment_${name}":
        ensure  => $ensure,
        order   => $order,
        target  => $aide::config_file,
        source  => $manage_source,
        content => $manage_content,
        require => Package[$aide::package],
      }
    }
    'default': {
      fail("aide::directive works only when $aide::config is set to 'concat'")
    }
  }
}
