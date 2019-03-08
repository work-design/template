puts 'use production'

set :domain, '47.98.255.167'
set :port, '23215'
set :user, 'zyh'
set :deploy_to, '/home/zyh/apps/store'
set :branch, 'master'
set :rails_env, 'production'
set :keep_releases, 5
