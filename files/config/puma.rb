dir = File.expand_path('..', ENV['BUNDLE_GEMFILE'])

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

state_path "#{File.expand_path('tmp/sockets/puma.state', dir)}"

#plugin :tmp_restart