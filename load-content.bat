@echo off
set host=localhost
set port=8000
set username=admin
set password=admin
set dpsi=0408
set source_path=C:\Users\walpolrx\Downloads\%dpsi%
set _replace_path=%source_path:\=/%
set replace_path=/%_replace_path%
set example_collection_uri=http://devexe.co.uk/collection/example
set sub_collection_uri=http://devexe.co.uk/collection/%dpsi%
set data_root=http://devexe.co.uk/data/%dpsi%
mlcp import -host %host% -port %port% -username %username% -password %password% -database example-content ^
 -input_file_path %source_path% -output_uri_replace "%replace_path%,'%data_root%'" ^
 -output_collections "%example_collection_uri%,%sub_collection_uri%"