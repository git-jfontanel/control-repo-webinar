# @summary This profile installs a sample website
class profile::app::db {

  case $::kernel {
    'Linux':   { include profile::app::db::mysql::server }
    default:   {
      fail('Unsupported kernel detected')
    }
  }

}
