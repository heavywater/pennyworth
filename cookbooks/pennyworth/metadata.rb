maintainer       "AJ Christensen"
maintainer_email "aj@junglist.gen.nz"
license          "Apache 2.0"
description      "Configures the pennyworth continuous deployment pipeline system"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.0"

depends "java"
depends "jenkins"
depends "postfix"
depends "build-essential"
depends "reprepro"
depends "leiningen"
