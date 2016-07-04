require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, 'trendom.io'
set :deploy_to, '/home/deploy/trendom.io'
set :repository, 'git://github.com/k2m30/trendom_backend'
set :branch, 'master'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/database.yml', 'config/secrets.yml', 'log']

# Optional settings:
  set :user, 'deploy'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'."]

  queue! %[ln -s /var/log/nginx/error.log "#{deploy_to}/#{shared_path}/log/nginx_error.log"]
  queue! %[ln -s /var/log/nginx/access.log "#{deploy_to}/#{shared_path}/log/nginx_access.log"]

  if repository
    repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
    repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'

    queue %[
      if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
        ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
      fi
    ]
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'
    queue! "rm /etc/nginx/sites-enabled/trendom.conf"
    queue! "ln -s #{deploy_to}/#{current_path}/config/nginx/trendom.conf /etc/nginx/sites-enabled/trendom.conf"

    to :launch do
      invoke :restart
      invoke :restart_nginx
    end
  end
end

task :cold_start => :environment do
  queue! "cd #{deploy_to}/#{current_path}"
  queue! "PIDFILE=#{deploy_to}/#{shared_path}/resque.pid COUNT=5 RAILS_ENV=production BACKGROUND=yes QUEUE=* rake environment resque:work"
  invoke :restart_nginx
  invoke :start
end

task :start => :environment do
  queue! "cd #{deploy_to}/#{current_path}"
  queue! 'puma -C config/puma/production.rb'
end

task :restart => :environment do
  queue! 'pumactl -P puma.pid restart'
end

task :stop => :environment do
  queue! 'pumactl -P puma.pid stop'
end

task :restart_all => :environment do
  invoke :restart_nginx
  invoke :restart
end

task :restart_nginx => :environment do
  queue! 'sudo service nginx restart'
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers