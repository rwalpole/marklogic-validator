#!/bin/sh
#!/bin/sh

usage ()
{
  echo 'Usage : load-modules.sh <username> <password> <host> <port> <source path>'
  exit
}

if [ "$#" -ne 5 ]; then
    usage
fi

username=$1
password=$2
host=$3
port=$4
source_path=$5
mlcp.sh import -host $host -port $port -username $username -password $password -database validator-modules \
-input_file_path $source_path -output_uri_replace "$source_path,'http://devexe.co.uk/apps/validator'" \
-input_file_type documents -document_type mixed