#!/bin/bash

echo "prepare rs initiating"

check_mongodb_status() {
  mongo1=$(mongo --host $1 --username root --password password --authenticationDatabase admin --eval "db.stats().ok" | tail -n1 | grep -E '(^|\s)1($|\s)')
  if [[ $mongo1 == 1 ]]; then
  	echo "Port is ready, init rs"
    init_rs $1
  else
  	echo "Port is not listening, sleeping"
    sleep 3
    check_mongodb_status $1
  fi
}

init_rs() {
  ret=$(mongo --host $1 --username root --password password --authenticationDatabase admin --eval "rs.initiate()" > /dev/null 2>&1)
}

check_mysql_status() {
  echo "in mysql status"
  echo $1
  if ! nc -z "$1" "3306"; then
	echo "Port is not listening, sleeping"
    sleep 3
    check_mysql_status $1
  fi
}

echo "$1"
echo "$2"

if [[ "$1" == 'mongo' ]];
then
	echo "checking mongo" 
	check_mongodb_status $2
else 
	if [[ "$1" == 'mysql' ]];
	then
		echo "checking mysql" 
		check_mysql_status $2
	fi
fi
	
echo "rs initiating finished"
exit 0