SET soxbin="D:\Program Files (x86)\sox-14-4-2\sox.exe"

cd %~dp0
mkdir converted
FOR %%A IN (*.bin) DO (
	%soxbin% -t raw -r 48000 -b 16 -c 2 -e signed-integer -B %%A "converted/%%~nA.wav" silence 1 1 0.01%% 1 1.0 0.01%
	%soxbin% -t raw -r 48000 -b 16 -c 2 -e signed-integer -B %%A "converted/%%~nA_amp16.wav" silence 1 1 0.01%% 1 1.0 0.01% vol 16 amplitude
)
pause
