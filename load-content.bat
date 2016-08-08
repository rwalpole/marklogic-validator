@echo off
if [%1]==[] goto :usage
if [%2]==[] goto :usage
if [%3]==[] goto :usage
if [%4]==[] goto :usage
if [%5]==[] goto :usage
if [%6]==[] goto :usage
set username=%1
set password=%2
set host=%3
set port=%4
set identifier=%5
set source_path=%6
set _replace_path=%source_path:\=/%
set replace_path=/%_replace_path%
set base_collection_uri=http://devexe.co.uk/collection/example
set sub_collection_uri=http://devexe.co.uk/collection/%identifier%
set data_root=http://devexe.co.uk/data/%identifier%
mlcp import -host %host% -port %port% -username %username% -password %password% -database validator-content ^
 -input_file_path %source_path% -output_uri_replace "%replace_path%,'%data_root%'" ^
 -output_collections "%base_collection_uri%,%sub_collection_uri%"
goto :eof
:usage
@echo Usage: load-content.bat ^<username^> ^<password^> ^<host^> ^<port^> ^<identifier^> ^<source path^>