#!/bin/sh

usage ()
{
  echo 'Usage : load-content.sh <username> <password> <host> <port> <identifier> <source path>'
  exit
}

if [ "$#" -ne 6 ]; then
    usage
fi

username=$1
password=$2
host=$3
port=$4
identifier=$5
source_path=$6
replace_path=/$source_path
base_collection_uri=http://devexe.co.uk/collection/example
sub_collection_uri=http://devexe.co.uk/collection/$identifier
data_root=http://devexe.co.uk/data/$identifier
mlcp.sh import -host $host -port $port -username $username -password $password -database validator-content \
 -input_file_path $source_path -output_uri_replace "$source_path,'$data_root'" \
 -output_collections "$base_collection_uri,$sub_collection_uri"