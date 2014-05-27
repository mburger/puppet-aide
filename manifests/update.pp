# Class: aide::update
#
# This class manages aide database updates
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
class aide::update {

  if $aide::manage_db_update {
    exec { 'aide.db.init':
      command     => "${aide::binary_path} --init --config ${aide::config_file}",
      user        => $aide::config_file_owner,
      refreshonly => true,
    }

    exec { 'aide.db.install':
      command     => "/bin/cp -f ${aide::data_dir}/${aide::db_tmp_name} ${aide::data_dir}/${aide::db_name}",
      user        => $aide::config_file_owner,
      refreshonly => true,
      subscribe   => Exec['aide.db.init']
    }
  }
}
