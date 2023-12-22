D:\iverilog\bin\iverilog -pfileline=1 -o tb -s tb k052591_tb.v
if %errorlevel% NEQ 0 goto :fail
D:\iverilog\bin\vvp tb
:fail
pause