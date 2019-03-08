dir = File.expand_path('..', ENV['BUNDLE_GEMFILE'])

port 3000
threads 1, 1
environment 'development'
directory dir
daemonize false
#early_hints true

pidfile "#{File.expand_path('tmp/pids/puma.pid', dir)}"
state_path "#{File.expand_path('tmp/sockets/puma.state', dir)}"

on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

on_restart do
  puts "\n-----> On restart"
  puts "env: #{@options[:environment]}"
  puts "pidfile: #{@options[:pidfile]}"
  puts "binds: #{@options[:binds]}"
  puts "control_url: #{@options[:control_url]}"
end

