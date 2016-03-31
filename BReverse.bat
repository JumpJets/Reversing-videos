@echo on
set "local=%~d0%~p0"
set /a x=1
set cnt=0
set /a rev=0
setlocal EnableDelayedExpansion
if "%1"=="" goto :ArgumentEnter
md "%~d1%~p1batch"
ffmpeg -i "%1" -an -f image2 "%~d1%~p1\batch\out_%%06d.png"
CD /D "%~d1%~p1batch"
for %%A in (*) do set /a cnt+=1
set rev=%cnt%
echo File count = %cnt%
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
cd /D "%local%"
GOTO:EOF

:ArgumentEnter
set /p FilePath=Enter path to file to proceed: 
md "%~d0%~p0batch"
ffmpeg -i "%FilePath%" -an -f image2 "%~d0%~p0\batch\out_%%06d.png"
CD /D "%~d0%~p0batch"
for %%A in (*) do set /a cnt+=1
set rev=%cnt%
echo File count = %cnt%
goto :while
GOTO:EOF