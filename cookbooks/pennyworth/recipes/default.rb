#
# Cookbook Name:: pennyworth
# Recipe:: default
#
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2011, AJ Christensen <aj@junglist.gen.nz>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "leiningen"

template "/var/lib/jenkins/.gitconfig" do
  source "gitconfig.erb"
  variables({
              :git_config_name => node.pennyworth.git_config_name,
              :git_config_email => node.pennyworth.git_config_email })
  mode 0644
  owner node.jenkins.server.user
  group node.jenkins.server.group
end

gnupg = "/var/lib/jenkins/.gnupg"
directory gnupg do
  mode 0700
  owner node.jenkins.server.user
  group node.jenkins.server.group
end

%w[pubring.gpg secring.gpg trustdb.gpg].map do |gpg_cookbook_file|
  source = File.join("/root", ".gnupg", gpg_cookbook_file)
  target = File.join(gnupg, gpg_cookbook_file)

  execute "cp #{source} #{target}" do
    creates target
  end

  file target do
    mode 0700
    owner node.jenkins.server.user
    group node.jenkins.server.group
  end
end

file "/etc/sudoers.d/jenkins" do
  content "jenkins ALL = (ALL) NOPASSWD: /bin/chown jenkins\\:jenkins -R /var/lib/jenkins/jobs/, /usr/local/bin/rake, /usr/local/bin/bundle, /usr/local/bin/gem, /usr/bin/reprepro, /usr/bin/apt-get, /usr/local/bin/update_version.rb\n"
  mode 0440
end

file "/var/lib/jenkins/ldconfig" do
  content "#!/bin/sh\ndpkg-trigger ldconfig"
  mode 0755
end

pennyworth_jobs = data_bag node.pennyworth.data_bag
pennyworth_jobs.each do |pennyworth_job|
  job = data_bag_item node.pennyworth.data_bag, pennyworth_job
  Chef::Log.info "job: #{job.inspect}"

  # resources and providers now plz
  git_branch = job["git_branch"] || "develop"
  git_remote_name = job["git_remote_name"] || "origin"
  git_url = job["git_url"]
  git_config_name = job["git_config_name"] || "jenkins"
  git_config_email = job["git_config_email"] || "not@real.ema.il"
  bzr_source = job["bzr_source"]
  project_description = job["project_description"] || "#{pennyworth_job} #{git_branch} #{git_url}"
  days_to_keep_logs = job["days_to_keep_logs"] || 7
  mailer_recipients = job["mailer_recipients"] || node.pennyworth.mailer_recipients
  test_commands = job["test_commands"] || [ "true" ]
  build_commands = job["build_commands"] || [ "true" ]
  package_commands = job["package_commands"] || [ "true" ]
  child_projects = job["child_projects"] || []
  xunit_file = job["xunit_file"] || nil
  remote_poll = job["remote_poll"] || true
  clean = job["clean"] || true
  wipeoutworkspace = job["wipeoutworkspace"] || true
  version = job["version"] || { "major" => 0, "minor" => 0 }
  job_config = File.join(node.jenkins.server.home, "#{pennyworth_job}-config.xml")

  jenkins_job pennyworth_job do
    action :nothing
    config job_config
  end

  template job_config do
    source "#{job['project_type']}.erb"
    variables( :project_description => project_description,
               :days_to_keep_logs => days_to_keep_logs,
               :git_branch => git_branch,
               :git_url => git_url,
               :git_remote_name => git_remote_name,
               :bzr_source => bzr_source,
               :mailer_recipients => mailer_recipients,
               :test_commands => test_commands,
               :build_commands => build_commands,
               :package_commands => package_commands,
               :child_projects => child_projects,
               :xunit_file => xunit_file,
               :remote_poll => remote_poll,
               :clean => clean,
               :wipeoutworkspace => wipeoutworkspace,
               :version => version
               )
    notifies :update, resources(:jenkins_job => pennyworth_job), :immediately
    notifies :build, resources(:jenkins_job => pennyworth_job), :immediately
    owner node.jenkins.server.user
    group node.jenkins.server.group
  end
end
