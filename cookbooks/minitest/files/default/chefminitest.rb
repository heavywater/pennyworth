require "chef/handler"
Gem.clear_paths
gem "minitest", "2.3.1"
require "minitest/unit"

class ChefMiniTestRunner < MiniTest::Unit
  def before_suites
    Chef::Log.info "chef minitest report handler runner starting"
  end

  def after_suites
    Chef::Log.info "chef minitest report handler runner completed"
  end

  def _run_suites(suites, type)
    begin
      before_suites
      super(suites, type)
    ensure
      after_suites
    end
  end

  def _run_suite(suite, type)
    begin
      suite.before_suite if suite.respond_to?(:before_suite)
      super(suite, type)
    ensure
      suite.after_suite if suite.respond_to?(:after_suite)
    end
  end
end

module ChefMiniTest
  class Handler < ::Chef::Handler
    def report
      if run_status.updated_resources.map do |resource|
          next unless resource.resource_name == :minitest_unit_testcase and resource.respond_to? :block and !resource.block.nil? and resource.action == :create
          Chef::Log.debug "#{resource} detected, creating anonymous test class: #{resource.inspect}"
          testcase = Class.new(MiniTest::Unit::TestCase)
          testcase.class_eval do
            define_method resource.name, &resource.block
            define_method :node do
              resource.node
            end
          end
        end.any?
        MiniTest::Unit.runner = ChefMiniTestRunner.new
        MiniTest::Unit.new.run(["-v"])
      else
        Chef::Log.info "chef minitest report handler: no tests found"
      end
    end
  end
end
