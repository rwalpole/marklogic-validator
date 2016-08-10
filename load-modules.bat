@echo off
if [%1]==[] goto :usage
if [%2]==[] goto :usage
if [%3]==[] goto :usage
if [%4]==[] goto :usage
if [%5]==[] goto :usage
set username=%1
set password=%2
set host=%3
set port=%4
set source_path=%5
set _replace_path=%source_path:\=/%
set replace_path=/%_replace_path%
mlcp import -host %host% -port %port% -username %username% -password %password% -database validator-modules ^
-input_file_path %source_path% -output_uri_replace "%replace_path%,'http://devexe.co.uk/apps/validator'" ^
-input_file_type documents -document_type mixed
goto :eof
:usage
@echo Usage: load-content.bat ^<username^> ^<password^> ^<host^> ^<port^> ^<source path^>
