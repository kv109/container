#!/usr/bin/env bash

init() {
  check_env_set AWS_ACCESS_KEY_ID $AWS_ACCESS_KEY_ID
  check_env_set AWS_REGION $AWS_REGION
  check_env_set WEB_HOST $WEB_HOST
  check_env_set POSTGRES_DB $POSTGRES_DB
  check_env_set POSTGRES_USER $POSTGRES_USER

  restore
  update_domains
  truncate_delayed_jobs
}

check_env_set()
{
  if [ -z "$2" ]; then
    echo "Env var [$1] must be set"
  fi

  echo "ENV $1 is set to [$2]"
}

restore() {
  echo "Checking if the database \"$POSTGRES_DB\" is empty..."
  DB_EXISTS=$(psql -U postgres $POSTGRES_DB -c "\d" | grep -e "No\srelations\sfound" | grep "relations" > /dev/null; echo "$?")
  if [ ${DB_EXISTS} -eq 0 ]; then
    echo "...and it is empty."
    /scripts/download_and_restore_dump.sh
  else
    echo "...it is NOT empty. Nothing will be done."
  fi
}

truncate_delayed_jobs() {
  echo "Truncating delayed_jobs table..."
  psql -U $POSTGRES_USER $POSTGRES_DB -c "truncate delayed_jobs"
  echo "...done."
}

update_domains() {
  echo "Updating domains..."
  psql -U $POSTGRES_USER $POSTGRES_DB -c "UPDATE domains SET name = REPLACE(name, 'near-me.com', '$WEB_HOST')"
  echo "...done."
}

init
