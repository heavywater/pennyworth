begin
  Gem.clear_paths
  gem "minitest", "2.3.1"
  require "minitest/unit"
rescue LoadError => e
  Chef::Log.info "minitest 2.3.1 required #{e}"
end

action :test do
  class ChefMiniTestInlineRunner < MiniTest::Unit
    def before_suites
      Chef::Log.info "chef minitest inline runner starting"
    end

    def after_suites
      Chef::Log.info "chef minitest inline runner completed"
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

  resource = new_resource
  MiniTest::Unit.runner = ChefMiniTestInlineRunner.new
  testcase = Class.new(MiniTest::Unit::TestCase)
  testcase.class_eval do
    define_method resource.name, &resource.block
    define_method :node do
      resource.node
    end
  end
  new_resource.updated_by_last_action(!!MiniTest::Unit.new.run(["-v"]))
end

action :create do
  new_resource.name("test_#{new_resource.name.to_s.gsub("-","_")}".to_sym) unless new_resource.name.to_s =~ /^test_/
  Chef::Log.debug "minitest_unit_testcase[#{new_resource.name}] fired action :create"
  new_resource.updated_by_last_action(true)
end


