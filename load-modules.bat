@echo off
set host=localhost
set port=8000
set username=admin
set password=admin
set source_path=C:\Users\walpolrx\github\marklogic-validator\src
set _replace_path=%source_path:\=/%
set replace_path=/%_replace_path%
mlcp import -host %host% -port %port% -username %username% -password %password% -database example-modules ^
-input_file_path %source_path% -output_uri_replace "%replace_path%,'http://devexe.co.uk/apps/validator'" ^
-input_file_type documents -document_type mixed
