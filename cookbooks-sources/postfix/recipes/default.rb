package "postfix" do
  version "2.8.2-1ubuntu2.1"
  action :upgrade
end

service "postfix" do
  action [:enable, :start]
end

template "/etc/postfix/main.cf" do
  source    "main.cf.erb"
  owner     "root"
  group     "root"
  mode      "0644"
  variables( :sendgrid_password => node[:postfix][:sendgrid_password] )
  notifies  :restart, "service[postfix]"
end
