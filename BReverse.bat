@echo on
chcp 65001
set "local=%~dp0"
set /a x=1
set cnt=0
set /a rev=0
set noa=0
setlocal EnableDelayedExpansion

if %1=="" goto :ArgumentEnter
md "%~dp1batch"
ffmpeg -i %1 -an -f image2 "%~dp1batch\out_%%06d.png"
CD /D "%~dp1batch"
for %%A in (*) do set /a cnt+=1
set rev=%cnt%
echo File count = %cnt%
REM explorer /n, "%~d1%~p1batch"
:while
if %x% leq %cnt% (
set "formattedValueX=000000%x%"
set "formattedValueR=000000%rev%"
echo %x% %rev% !formattedValueX:~-6! !formattedValueR:~-6!
ren "out_!formattedValueX:~-6!.png" "out2_!formattedValueR:~-6!.png"
set /a x+=1
set /a rev-=1
goto :while
)
cd ..

set /p "continue=Compile all image sequences again in reverse file? (yes - leave blank): "
if "%continue%" NEQ "" GOTO:EOF
if %1=="" GOTO ArgumentEnter2
ffprobe -loglevel 16 -print_format ini -select_streams a -show_streams "%~1" > "%~n1.a.ini"
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i codec_name= %~n1.a.ini') DO set CODECNAMEA=%%~j
IF "%CODECNAMEA%" == "" (
echo "Video doesn't content audio stream(-s)"
set noa=1
goto noaudio
)
ffmpeg -i %1 -vn -ac 2 "%~n1.wav"
sox -V "%~dpn1.wav" "%~dpn1.rev.wav" reverse

:noaudio
ffprobe -loglevel 16 -print_format ini -select_streams v -show_streams "%~1" > "%~n1.v.ini"
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i codec_name= %~n1.v.ini') DO set CODECNAMEV=%%~j

cd batch
IF "%noa%" == "0" ffmpeg -i out2_%%06d.png -vcodec %CODECNAMEV% -i "%~dpn1.rev.wav" -strict -2 -acodec %CODECNAMEA% "..\%~n1.rev%~x1"
IF "%noa%" == "1" ffmpeg -i out2_%%06d.png -vcodec %CODECNAMEV% "..\%~n1.rev%~x1"
if %ERRORLEVEL% == 0 goto noerr
:repeat
set /p "manualcodeca=If problem with audio codec, type another (or leave blank for write without audio or same): "
set /p "manualcodecv=If in log problem with video codec, type another here (or leave blank for use: %CODECNAMEV%): "
IF "%manualcodecv%" == "" set "manualcodecv=%CODECNAMEV%"
IF "%manualcodeca%" NEQ "" ffmpeg -i out2_%%06d.png -vcodec %manualcodecv% -i "%~dpn1.rev.wav" -strict -2 -acodec %manualcodeca% "..\%~n1.rev%~x1"
IF "%manualcodeca%" == "" ffmpeg -i out2_%%06d.png -vcodec %manualcodecv% "..\%~n1.rev%~x1"
if %ERRORLEVEL% NEQ 0 (
set /p "continue=Try different codec? (leave blank to repeat): " 
if "%continue%" NEQ "" goto repeat
)

:noerr
cd /D "%local%"
set /p "continue=Delete all temporary files? (no - leave blank) "
if "%continue%" NEQ "" goto clearing
GOTO:EOF

:ArgumentEnter
set /p FilePath=Enter path to file to proceed: 
md "%~dp0batch"
ffmpeg -i "%FilePath%" -an -f image2 "%~dp0\batch\out_%%06d.png"
CD /D "%~dp0batch"
for %%A in (*) do set /a cnt+=1
set rev=%cnt%
echo File count = %cnt%
explorer /n, "%~dp0batch"
goto :while

:ArgumentEnter2
ffprobe -loglevel 16 -print_format ini -select_streams a -show_streams "%FilePath%" > "temp.a.ini"
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i codec_name= temp.a.ini') DO set CODECNAMEA=%%~j
IF "%CODECNAMEA%" == "" (
echo "Video doesn't content audio streams"
set noa=1
goto noaudio2
)
ffmpeg -i "%FilePath%" -vn -ac 2 "%local%temp.wav"
sox -V "%local%temp.wav" "%local%temp.rev.wav" reverse

:noaudio2
ffprobe -loglevel 16 -print_format ini -select_streams v -show_streams "%FilePath%" > "temp.v.ini"
FOR /F "eol=; eol=[ tokens=1,2* delims==" %%i in ('findstr /b /l /i codec_name= temp.v.ini') DO set CODECNAMEV=%%~j

cd batch
IF "%noa%" == "0" ffmpeg -i out2_%%06d.png -vcodec %CODECNAMEV% -i "..\temp.rev.wav" -strict -2 -acodec %CODECNAMEA% "%FilePath:~0,-4%.rev%FilePath:~-4%"
IF "%noa%" == "1" ffmpeg -i out2_%%06d.png -vcodec %CODECNAMEV% "%FilePath:~0,-4%.rev%FilePath:~-4%"
if %ERRORLEVEL% == 0 goto noerr2
:repeat2
set /p "manualcodeca=If problem with audio codec, type another (or leave blank for write without audio or same): "
set /p "manualcodecv=If in log problem with video codec, type another here (or leave blank for use: %CODECNAMEV%): "
IF "%manualcodecv%" == "" set "manualcodecv=%CODECNAMEV%"
IF "%manualcodeca%" NEQ "" ffmpeg -i out2_%%06d.png -vcodec %manualcodecv% -i "..\temp.rev.wav" -strict -2 -acodec %manualcodeca% "%FilePath:~0,-4%.rev%FilePath:~-4%"
IF "%manualcodeca%" == "" ffmpeg -i out2_%%06d.png -vcodec %manualcodecv% "%FilePath:~0,-4%.rev!FilePath:~-4%"
if %ERRORLEVEL% NEQ 0 (
set /p "continue=Try different codec? (leave blank to repeat): " 
if "%continue%" NEQ "" goto repeat2
)

:noerr2
cd /D "%local%"
set /p "continue=Delete all temporary files? (no - leave blank) "
if "%continue%" NEQ "" goto clearing2
GOTO:EOF

:clearing
rd /Q /S "%~dp1batch"
del "%~dpn1.a.ini" "%~dpn1.v.ini" "%~dpn1.wav" "%~dpn1.rev.wav" /Q
GOTO:EOF

:clearing2
rd /Q /S "%~dp0batch"
del "temp.a.ini" "temp.v.ini" "temp.wav" "temp.rev.wav" /Q
