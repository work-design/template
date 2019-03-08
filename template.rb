require_relative 'helper'
Helper.remove_comment('Gemfile')

# gitignore
Helper.get_remote('gitignore', '.gitignore')

# postgresql
say 'Applying postgresql...'
Helper.remove_gem('sqlite3')

gem 'pg'
Helper.get_remote('config/database.yml.example')
gsub_file "config/database.yml.example", /database: myapp_development/, "database: #{app_name}_development"
gsub_file "config/database.yml.example", /database: myapp_test/, "database: #{app_name}_test"
gsub_file "config/database.yml.example", /database: myapp_production/, "database: #{app_name}_production"
get_remote('config/database.yml.example', 'config/database.yml')
gsub_file "config/database.yml", /database: myapp_development/, "database: #{app_name}_development"
gsub_file "config/database.yml", /database: myapp_test/, "database: #{app_name}_test"
gsub_file "config/database.yml", /database: myapp_production/, "database: #{app_name}_production"


# jquery, bootstrap needed
say 'Applying jquery...'
inject_into_file('app/assets/javascripts/application.js', after: "//= require rails-ujs\n") do
  "//= require jquery\n"
end

say 'Applying action cable config...'
inject_into_file 'config/environments/production.rb', after: "# Mount Action Cable outside main process or domain\n" do <<-EOF
  config.action_cable.allowed_request_origins = [ "\#{ENV['PROTOCOL']}://\#{ENV['DOMAIN']}" ]
EOF
end

# active_storage
say 'Applying active_storage...'
after_bundle do
  rake 'active_storage:install'
end

say 'Applying redis & sidekiq...'
gem 'redis-namespace'
gem 'sidekiq'
get_remote('config/initializers/sidekiq.rb')
get_remote('config/sidekiq.yml')
get_remote('config/routes.rb')

say 'Applying kaminari'
gem 'kaminari'


say 'Applying mina & its plugins...'
gem_group :development do
  gem 'mina'
end

get_remote('config/deploy.rb')
get_remote('config/puma.rb')
gsub_file 'config/puma.rb', /\/data\/www\/myapp\/shared/, "/data/www/#{app_name}/shared"
get_remote('config/deploy/production.rb')
gsub_file 'config/deploy/production.rb', /\/data\/www\/myapp/, "/data/www/#{app_name}"
get_remote('config/nginx.conf.example')
gsub_file 'config/nginx.conf.example', /myapp/, "#{app_name}"
get_remote('config/nginx.ssl.conf.example')
gsub_file 'config/nginx.ssl.conf.example', /myapp/, "#{app_name}"
get_remote('config/logrotate.conf.example')
gsub_file 'config/logrotate.conf.example', /myapp/, "#{app_name}"

get_remote('config/monit.conf.example')
gsub_file 'config/monit.conf.example', /myapp/, "#{app_name}"

get_remote('config/backup.rb.example')
gsub_file 'config/backup.rb.example', /myapp/, "#{app_name}"

say 'Applying lograge & basic application config...'
gem 'lograge'
inject_into_file 'config/application.rb', after: "class Application < Rails::Application\n" do <<-EOF
    config.generators.assets = false
    config.generators.helper = false

    config.time_zone = 'Beijing'
    config.i18n.available_locales = [:en, :'zh-CN']
    config.i18n.default_locale = :'zh-CN'

    config.lograge.enabled = true
EOF
end

say 'Applying test framework...'
gem_group :development do
  gem 'rails_apps_testing'
end
gem_group :development, :test do
  gem 'factory_bot_rails'
end
gem_group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
end
after_bundle do
  generate 'testing:configure', 'rspec --force'
end

get_remote 'README.md'

after_bundle do
  say 'Done! init `git` and `database`...'
  rake 'db:create'
  rake 'db:migrate'
  git add: '.'
  git commit: '-m "init rails"'
  say "Build successfully! `cd #{app_name}` and use `rails s` to start your rails app..."
end
