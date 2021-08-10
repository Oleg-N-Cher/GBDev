@ECHO OFF

SET GBDev=%XDev%\GBDev
SET Include=%Include% -I%GBDev%\Lib\C -I%GBDev%\Lib\Obj -I%GBDev%\Lib
IF EXIST .debug SET Opt=--max-allocs-per-node20
IF NOT EXIST .debug SET Opt=-SO3 --opt-code-size -Cs"--max-allocs-per-node100000"

zcc +gb -compiler=sdcc -vn -create-app %Opt% %Include% %Modules% %1.c -lm -o%1.bin
IF errorlevel 1 PAUSE

IF NOT EXIST %1.gb EXIT
MOVE /Y %1.gb ..\%1.gb >NUL
DEL *.bin
START ..\%1.gb
