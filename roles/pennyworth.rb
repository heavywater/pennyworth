name "pennyworth"
description "Components required for the pennyworth continuous deployment pipeline"
run_list( "recipe[reprepro]",
          "recipe[java]",
          "recipe[postfix]",
          "recipe[pennyworth::ssh_key]",
          "recipe[jenkins]",
          "recipe[pennyworth::update_version]",
          "recipe[pennyworth::dependencies]",
          "recipe[pennyworth]" )

default_attributes( "java" => { "install_flavor" => "openjdk" },
                    "jenkins" => {
                      "http_proxy" => {
                        "variant" => "apache2"
                      },
                      "server" => {
                        "plugins" => [
                                      'setenv',
                                      'git',
                                      'python',
                                      'ruby',
                                      'rake',
                                      'greenballs',
                                      'xunit',
                                      'campfire'
                                     ]
                      } },
                    "postfix" => {
                      "mail_type" => "master"
                    },
                    "pennyworth" => {
                      "package_dependencies" => [
                                                 "git",
                                                 "libtool",
                                                 "uuid-dev"
                                                ],
                      "ruby_gem_dependencies" => [
                                                  "fpm",
                                                  "bundler",
                                                  "rake",
                                                  "rdoc",
                                                  "rspec",
                                                  "cucumber"
                                                 ],
                    } )
