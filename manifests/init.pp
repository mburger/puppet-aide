# = Class: aide
#
# This is the main aide class
#
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*my_class*]
#   Name of a custom class to autoload to manage module's customizations
#   If defined, aide class will automatically "include $my_class"
#   Can be defined also by the (top scope) variable $aide_myclass
#
# [*dependency_class*]
#   Name of the class that provides third modules dependencies.
#
# [*source*]
#   Sets the content of source parameter for main configuration file
#   If defined, aide main config file will have the param: source => $source
#   Can be defined also by the (top scope) variable $aide_source
#
# [*template*]
#   Sets the path to the template to use as content for main configuration file
#   If defined, aide main config file has: content => content("$template")
#   Note source and template parameters are mutually exclusive: don't use both
#   Can be defined also by the (top scope) variable $aide_template
#
# [*options*]
#   An hash of custom options to be used in templates for arbitrary settings.
#   Can be defined also by the (top scope) variable $aide_options
#
# [*version*]
#   The package version, used in the ensure parameter of package type.
#   Default: present. Can be 'latest' or a specific version number.
#   Note that if the argument absent (see below) is set to true, the
#   package is removed, whatever the value of version parameter.
#
# [*absent*]
#   Set to 'true' to remove package(s) installed by module
#   Can be defined also by the (top scope) variable $aide_absent
#
# [*disable*]
#   Set to 'true' to disable service(s) managed by module
#   Can be defined also by the (top scope) variable $aide_disable
#
# [*debug*]
#   Set to 'true' to enable modules debugging
#   Can be defined also by the (top scope) variables $aide_debug and $debug
#
# [*audit_only*]
#   Set to 'true' if you don't intend to override existing configuration files
#   and want to audit the difference between existing files and the ones
#   managed by Puppet.
#   Can be defined also by the (top scope) variables $aide_audit_only
#   and $audit_only
#
# [*noops*]
#   Set noop metaparameter to true for all the resources managed by the module.
#   Basically you can run a dryrun for this specific module if you set
#   this to true. Default: undef
#
# Default class params - As defined in aide::params.
# Note that these variables are mostly defined and used in the module itself,
# overriding the default values might not affected all the involved components.
# Set and override them only if you know what you're doing.
# Note also that you can't override/set them via top scope variables.
#
# [*package*]
#   The name of aide package
#
# [*config_file*]
#   Main configuration file path
#
# [*config_file_mode*]
#   Main configuration file path mode
#
# [*config_file_owner*]
#   Main configuration file path owner
#
# [*config_file_group*]
#   Main configuration file path group
#
# [*pid_file*]
#   Path of pid file. Used by monitor
#
# [*log_dir*]
#   Base logs directory. Used by puppi
#
# [*log_file*]
#   Log file(s). Used by puppi
#
# See README for usage patterns.
#
class aide (
  $my_class            = params_lookup( 'my_class' ),
  $dependency_class    = params_lookup( 'dependency_class' ),
  $source              = params_lookup( 'source' ),
  $template            = params_lookup( 'template' ),
  $options             = params_lookup( 'options' ),
  $version             = params_lookup( 'version' ),
  $absent              = params_lookup( 'absent' ),
  $disable             = params_lookup( 'disable' ),
  $debug               = params_lookup( 'debug' , 'global' ),
  $audit_only          = params_lookup( 'audit_only' , 'global' ),
  $noops               = params_lookup( 'noops' ),
  $package             = params_lookup( 'package' ),
  $config              = params_lookup( 'config' ),
  $config_file         = params_lookup( 'config_file' ),
  $config_file_mode    = params_lookup( 'config_file_mode' ),
  $config_file_owner   = params_lookup( 'config_file_owner' ),
  $config_file_group   = params_lookup( 'config_file_group' ),
  $data_dir            = params_lookup( 'data_dir' ),
  $log_dir             = params_lookup( 'log_dir' ),
  $log_file            = params_lookup( 'log_file' ),
  $update_db           = params_lookup( 'update_db' ),
  $binary_path         = params_lookup( 'binary_path' ),
  $db_name             = params_lookup( 'db_name' ),
  $db_tmp_name         = params_lookup( 'db_tmp_name' ),
  $directives          = params_lookup( 'directives' ),
  $cron                = params_lookup( 'cron' ),
  $cron_hour           = params_lookup( 'cron_hour'),
  $cron_minute         = params_lookup( 'cron_minute' )
  ) inherits aide::params {

  $bool_absent=any2bool($absent)
  $bool_disable=any2bool($disable)
  $bool_debug=any2bool($debug)
  $bool_audit_only=any2bool($audit_only)
  $bool_cron=any2bool($cron)

  ### Definition of some variables used in the module
  $manage_package = $aide::bool_absent ? {
    true  => 'absent',
    false => $aide::version,
  }

  $manage_file = $aide::bool_absent ? {
    true    => 'absent',
    default => 'present',
  }

  $manage_audit = $aide::bool_audit_only ? {
    true  => 'all',
    false => undef,
  }

  $manage_db_update = $aide::bool_absent ? {
    true  => false,
    false => $aide::bool_disable ? {
      true  => false,
      false => $aide::update_db ? {
        true  => $aide::update_db,
        false => false
      }
    }
  }

  $manage_file_replace = $aide::bool_audit_only ? {
    true  => false,
    false => true,
  }

  $manage_file_source = $aide::source ? {
    ''        => undef,
    default   => $aide::source,
  }

  $manage_file_content = $aide::template ? {
    ''        => undef,
    default   => template($aide::template),
  }

  ### Include custom class if $my_class is set
  if $aide::my_class {
    include $aide::my_class
  }

  ### Include dependencies provided by other Example42 modules
  if $dependency_class {
    require $aide::dependency_class
  }

  ### Create directives for integration with Hiera
  if $directives != {} {
    validate_hash($directives)
    create_resources(aide::directive, $directives)
  }

  class { 'aide::install': } ->
  class { 'aide::config': } ~>
  class { 'aide::update': } ->
  Class['aide']


  ### Debugging, if enabled ( debug => true )
  if $aide::bool_debug == true {
    file { 'debug_aide':
      ensure  => $aide::manage_file,
      path    => "${settings::vardir}/debug-aide",
      mode    => '0640',
      owner   => 'root',
      group   => 'root',
      content => inline_template('<%= scope.to_hash.reject { |k,v| k.to_s =~ /(uptime.*|path|timestamp|free|.*password.*|.*psk.*|.*key)/ }.to_yaml %>'),
      noop    => $aide::noops,
    }
  }

}
