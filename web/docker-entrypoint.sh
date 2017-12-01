#!/usr/bin/env bash

init() {
    check_env_set RAILS_ENV $RAILS_ENV

    wait_for postgres 5432
    wait_for redis 6379
    wait_for es 9200
    migrate
    # TODO update_domains if not already updated

    if [ "$ROLE" == "delayed_job" ]; then
      start_delayed_job
    else
      build_assets
      start_web_server
    fi
}


build_assets() {
  if [ ! -d "/usr/app/public/assets" ]; then
    echo "Building assets..."
    npm install && npm run gulp build:$RAILS_ENV
    echo "Building assets... done!"
  else
    echo "Assets already built, nothing will be done."
  fi
}


check_env_set()
{
  if [ -z "$2" ]; then
    echo "Env var [$1] must be set"
  fi

  echo "ENV $1 is set to [$2]"
}

migrate() {
    bundle exec rake db:migrate
}

start_delayed_job() {
  echo "Starting delayed job..."
  # rake jobs:work consumes much more resources for some reason
  script/delayed_job run
}

start_web_server() {
    echo "Starting rails app..."
    # kill app server if already running
    [ -f /usr/app/tmp/pids/server.pid ] && (kill -INT $(cat /usr/app/tmp/pids/server.pid); ([ -f /usr/app/tmp/pids/server.pid ] && rm /usr/app/tmp/pids/server.pid))

    service nginx start
    bundle exec unicorn -c config/unicorn_$RAILS_ENV.rb
}

wait_for() {
    if [ -z "$1" ]; then
      echo "ERROR hostname is not set aborting"
    fi
    if [ -z "$2" ]; then
      echo "ERROR port is not set aborting (hostname if set was [$1])"
    fi

    echo "Waiting for $1:$2 to become available"
    start_ts=$(date +%s)
    while :
    do
        (echo > /dev/tcp/$1/$2) >/dev/null 2>&1
        result=$?
        if [[ $result -eq 0 ]]; then
            end_ts=$(date +%s)
            echo "$1:$2 is available after $((end_ts - start_ts)) seconds"
            break
        fi
        sleep 1
    done
    return $result
}

init
