# @summary This role installs an apache webserver and sample content on port 80.
class role::db {
  include ::profile::platform::baseline
  include ::profile::app::db
}
