#!/usr/bin/env bash
ssh deployer@trendom.io <<'ENDSSH'
cd trendom_backend
git stash
git pull
bundle
rake assets:precompile
bundle exec puma -e production -d -b unix:///home/deployer/trendom.sock restart
ENDSSH