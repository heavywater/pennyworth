gem_package "sinatra" do
  action :nothing
end.run_action(:install)

cookbook_file("/tmp/sinatra.rb") do
  action :nothing
end.run_action(:create)

ruby_block "launch sinatra" do
  block do
    pid = fork { exec "ruby /tmp/sinatra.rb" }
    Process.detach pid
    at_exit do
      if Process.kill(0, pid)
        Chef::Log.debug "killing backgrounded sinatra process at #{pid}"
        Process.kill "TERM", pid
      end
    end
  end
  action :nothing
end.run_action(:create)

minitest_unit_testcase :test_inline_truth do
  block do
    refute_equal true, false, "true is not false"
  end
  action :test
end

minitest_unit_testcase :test_truth do
  block do
    refute_equal true, false, "true is not false"
  end
end

minitest_unit_testcase "test_sleep" do
  block do
    assert(sleep 10)
  end
  action :test
end

http_port = 80
dns_search_path = "junglist.gen.nz"
dns_ndots = 1
Gem.clear_paths
require 'socket'
require 'uri'
require 'chef/config'
require 'chef/rest'
require 'timeout'
require 'resolv'
require 'tempfile'
require 'net/tftp'
require 'timeout'

minitest_unit_testcase :test_http_port do
  block do
    assert_instance_of TCPSocket, TCPSocket.new(node.ipaddress, http_port), "http_port: socket could not be established to port #{node.ipaddress}:#{http_port}"
  end
end

minitest_unit_testcase :test_http_fitter_happier do
  block do
    %w{/fitter_happier /fitter_happier/site_check /fitter_happier/site_and_database_check}.each do |path|
      uri = URI::HTTP.build :host => node.ipaddress, :port => http_port, :path => path
      request = Chef::REST::RESTRequest.new(:GET, uri, nil)
      Timeout::timeout(5) do
        assert_instance_of Net::HTTPOK, request.call, "http_fitter_happier: GET to #{uri.inspect} did not return HTTPOK"
      end
    end
  end
end

minitest_unit_testcase :test_dns_resolution do
  block do
    resolver = Resolv::DNS.new(:nameserver => node.ipaddress, :search => dns_search_path, :ndots => dns_ndots)
    refute_instance_of Resolv::IPv4, resolver.getaddress("www.google.com"), "dns_resolution: could not resolve www.google.com"
  end
  action :nothing
end
