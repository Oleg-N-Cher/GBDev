@ECHO OFF

SET Pause=TRUE
SET Compiler=SDCC

SET GBDev=%XDev%\GBDev
SET Include=%Include% -I%GBDev%\Lib\C -I%GBDev%\Lib\Obj -I%GBDev%\Lib
SET CC=zcc +gb -vn -create-app

IF "%Clean%"=="" SET Clean=TRUE
IF "%Start%"=="" SET Start=TRUE
IF "%Pause%"=="" SET Pause=FALSE
IF "%Compiler%"=="SDCC" SET CC=%CC% -compiler=sdcc -Cs"--opt-code-size" -Cs"--disable-warning 59" -Cs"--disable-warning 126"

%CC% %Include% %Modules% %1.c -o%1.gb
IF errorlevel 1 PAUSE

IF "%Pause%"=="TRUE" PAUSE

IF NOT EXIST %1.gb EXIT
MOVE /Y %1.gb ..\%1.gb >NUL
DEL *.bin

IF "%Start%"=="TRUE" START ..\%1.gb
