default.pennyworth.package_dependencies = [ "libxml2-dev",
                                    "libxslt1-dev",
                                    "erlang" ]
default.pennyworth.ruby_gem_package_dependencies = []
default.pennyworth.filesystem_scm_basedir = "/usr/src"
default.pennyworth.mailer_recipients = "ci@jenkins-ci.org"
default.pennyworth.git_config_name = "Jenkins"
default.pennyworth.git_config_email = "jenkins@jenkins-ci.org"

default.pennyworth.ephemeral_device = "/dev/xvdb1"
default.pennyworth.ephemeral_mount_point = "/var/lib/jenkins"
default.pennyworth.ephemeral_volume_group = "ephemeral"
default.pennyworth.ephemeral_logical_volume = "storage"
default.pennyworth.lv_path = File.join("/dev", "mapper", "#{pennyworth.ephemeral_volume_group}-#{pennyworth.ephemeral_logical_volume}")
default.pennyworth.data_bag = "pennyworth"
