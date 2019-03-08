puts 'use staging'

set :domain, '47.75.154.186'
set :port, '23215'
set :user, 'zyh'
set :deploy_to, '/home/zyh/apps/store_staging'
set :branch, 'staging'
set :rails_env, 'staging'
set :keep_releases, 1
set :sidekiq_processes, 1
