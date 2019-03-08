require 'pry'
require 'bundler/setup'  # for require sidekiq & puma from rails_com

require 'mina/git'
require 'mina/rails'
require 'mina/rvm'

require 'mina/whenever'
require 'mina/sidekiq'
require 'mina/puma'


if ENV['on'].nil?
  if ENV['to']
    set :branch, ENV['to']
  else
    set :branch, 'staging'
  end
  require File.expand_path('deploy/staging.rb', __dir__)
else
  require File.expand_path("deploy/#{ENV['on']}.rb", __dir__)
end

set :repository, 'git@github.com:dappore/store.git'
set :forward_agent, true

set :shared_dirs, fetch(:shared_dirs) + [
  'tmp',
  'storage',
  'node_modules',
  'public/packs'
]

set :shared_files, [
  'config/database.yml',
  'config/master.key',
  'config/apiclient_cert.p12'
]

task :local_environment do
end

task :remote_environment do
  invoke :'rvm:use', 'ruby-2.5.1@default'
end

task :setup do
  command %{ mkdir -p #{fetch :shared_path}/log }
  command %{ mkdir -p #{fetch :shared_path}/config }
  command %{ mkdir -p #{fetch :shared_path}/tmp/sockets }
  command %{ mkdir -p #{fetch :shared_path}/tmp/pids }
  command %{ mkdir -p #{fetch :shared_path}/storage }
  command %{ touch #{fetch :shared_path}/config/database.yml }
  command %{ touch #{fetch :shared_path}/config/master.key }
  command %{ touch #{fetch :shared_path}/tmp/sockets/puma.state }
  comment %{ Be sure to edit #{fetch :shared_path}/config/database.yml and master.key }
end

desc 'Deploys the current version to the server.'
task deploy: :remote_environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:assets_precompile'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'puma:restart'
      invoke :'sidekiq:restart'
      #invoke :'whenever:update'
    end
  end
end

desc 'Deploy to multiple hosts'
task :multi_deploy do
  ['staging'].each do |env|
    require File.expand_path("deploy/#{env}.rb", __dir__)
    invoke 'deploy'
  end
end
