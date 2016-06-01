#!/usr/bin/env bash

#sudo ln -sf /etc/nginx/sites-available/trendom.conf /etc/nginx/sites-enabled/trendom.conf
# http://ruby-journal.com/how-to-setup-rails-app-with-puma-and-nginx/
git stash
git pull
bundle
rake assets:precompile
bundle exec puma -e production -d -b unix:///home/deployer/trendom.sock restart
chmod +x restart.sh
