#!/bin/bash
echo "prepare e2e rs initiating"
check_db_status() {
  mongo1=$(mongo --host mongo-service --username root --password password --authenticationDatabase admin --eval "db.stats().ok" | tail -n1 | grep -E '(^|\s)1($|\s)')
  if [[ $mongo1 == 1 ]]; then
    init_rs
  else
    sleep 3
    check_db_status
  fi
}
init_rs() {
  ret=$(mongo --host mongo-service --username root --password password --authenticationDatabase admin --eval "rs.initiate()" > /dev/null 2>&1)
}
check_db_status > /dev/null 2>&1
echo "rs initiating finished"
exit 0