require "rubygems"
Gem.clear_paths
require "sinatra/base"
class MiniTestApp < Sinatra::Base
  configure do
    disable :logging
    set :port => 80
  end

  get "/" do
    [ 200, {}, "get / worked" ]
  end

  %w{/fitter_happier /fitter_happier/site_check /fitter_happier/site_and_database_check}.each do |path|
    get path do
      [ 200, {}, "get #{path} worked" ]
    end
  end

  run!
end
