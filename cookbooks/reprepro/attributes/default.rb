default.reprepro.fqdn fqdn
default.reprepro.repo_dir = "/srv/apt"
default.reprepro.incoming = "/srv/apt_incoming"
default.reprepro.description = "APT repository at #{fqdn}"
default.reprepro.codenames = %w[lucid maverick natty]
default.reprepro.pgp.email = "apt@#{domain}"
default.reprepro.pgp.fingerprint = ""
default.reprepro.pgp.public = ""
default.reprepro.pgp.private = ""
default.reprepro.pulls.name = "natty"
default.reprepro.pulls.from = "natty"
default.reprepro.pulls.component = "main universe multiverse"
default.reprepro.architectures = %w[amd64]
