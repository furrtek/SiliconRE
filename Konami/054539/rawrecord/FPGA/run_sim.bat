D:\iverilog\bin\iverilog -o tb -s tb tb.v
if %errorlevel% NEQ 0 goto :fail
D:\iverilog\bin\vvp tb
:fail
pause