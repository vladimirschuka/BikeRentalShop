#!/bin/bash

parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("")}
         printf("%s%s%s=\"%s\"\n","'$prefix'",vn, $2, $3);
      }
   }'
}


CONFIG_FILE="dbconfig/config.yml"
DUMP_FILE="dump/dump.sql"

eval $(parse_yaml $CONFIG_FILE)

set PGPASSWORD = $dbconfigurationpassword



export PGPASSWORD=$dbconfigurationpassword;

echo 'connecting to : '$dbconfigurationhost

if psql -Upostgres -lqt|cut -d \| -f 1| grep -qw $dbconfigurationdatabase; then
 	echo 'DB '$dbconfigurationdatabase' already exist.'
	read -p "Use this DB.Are you sure? (Y/N)" -n 1 -r
	echo -e 
	if [[  $REPLY =~ ^[Nn]$ ]]
	then
	    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 #|| return 1 # handle exits from shell or function but don't exit interactive shell
	fi
else
	echo 'Creating DB '$dbconfigurationdatabase
	psql -U$dbconfigurationusername -h$dbconfigurationhost -c 'CREATE DATABASE '$dbconfigurationdatabase' ;'
	if [ $? -eq 0 ]; then
	    echo 'Database '$dbconfigurationdatabase' was created'
	else
	    echo 'line 42. Something wron with DB'
	fi
fi 	

echo -e "Add database model"
echo $DUMP_FILE

psql -U$dbconfigurationusername -h$dbconfigurationhost -d$dbconfigurationdatabase -f$DUMP_FILE >& /dev/null 

if [ $? -eq 0 ]; then
    echo 'DB scheme was created'
else
    echo 'Please check dump file: '$DUMP_FILE
fi

read -p "Add sample data? (Y/N)" -n 1 -r
echo -e 
if [[  $REPLY =~ ^[Yy]$ ]]
then
	ruby -r "./db_sample_data.rb" -e "SampleData.addData"
fi



echo "For start applicatio ruby run_me.rb"






