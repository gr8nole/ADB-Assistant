@ECHO off
adb kill-server
ECHO Starting, please wait a moment....
IF NOT EXIST logs mkdir logs
setlocal enabledelayedexpansion
COLOR 0E
IF (%1)==(0) goto skip
ECHO.   >> logs\ADB-Assistant.log
ECHO -%date% -- %time%- >> logs\ADB-Assistant.log 
ADB-Assistant 0 2>> logs\ADB-Assistant.log 

:skip
cd "%~dp0"
mode con:cols=89 lines=50
IF NOT EXIST install mkdir install
IF NOT EXIST push mkdir push
CLS
set app=None


:restart
cd "%~dp0"
set menunr=GARBAGE
adb kill-server
CLS
ECHO  ---------------------------------------------------------------------------------------
ECHO  G ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ G
ECHO  o                                    ADB-Assistant                                    o
ECHO    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
ECHO  N                                     by gr8nole                                      N
ECHO  o ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ o
ECHO  l                             http://gr8nole.blogspot.com                             l
ECHO  e ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ e
ECHO  s         "            >>>>>>>>>------------;;;;;;;---------->>            "          s
ECHO  ---------------------------------------------------------------------------------------
ECHO  Select an option - ensure that your device is connected to the pc         
ECHO  ---------------------------------------------------------------------------------------
ECHO.
ECHO.                             
ECHO  1    Get logcat                            
ECHO  2    Get recovery logs (while in recovery)               
ECHO  3    Get recovery logs (while booted in Android)
ECHO  4    Get last_kmsg (kernel log from previous boot)          
ECHO  5    Get dmsg (current kernel log)                       
ECHO  6    Install signed apk (Data apps only, NOT system apps)              
ECHO  7    Adb push file (recovery-mode only and only system app and framework files)
ECHO  8    Adb pull file
ECHO  9    Enter manual ADB command
ECHO  10   Show connected devices
ECHO.
ECHO  --------------                                -----------------
ECHO  Reboot options                                Recording options
ECHO  --------------                                -----------------
ECHO  r    Reboot                                   s    Screenshot from Android
ECHO  d    Reboot to Download Mode                  ss   Screenshot from recovery
ECHO  z    Reboot to Recovery                       sss  Record video of screen (4.4+)
ECHO.
ECHO  ----------------------------------
ECHO  bb   View device partition list
ECHO  55   Install Universal ADB drivers
ECHO.
ECHO  99   Donate to gr8nole
ECHO  ----------------------------------
ECHO.        
ECHO  x   Quit
ECHO  ----------
SET /P menunr=Please make your decision:

IF %menunr%==1 (goto logc)
IF %menunr%==2 (goto reclr)
IF %menunr%==3 (goto recl)
IF %menunr%==4 (goto kmsg)
IF %menunr%==5 (goto dmesg)
IF %menunr%==6 (goto ins)
IF %menunr%==7 (goto push)
IF %menunr%==8 (goto pull)
IF %menunr%==9 (goto man)
IF %menunr%==10 (goto conn)
IF %menunr%==r (goto reboot)
IF %menunr%==d (goto down)
IF %menunr%==z (goto recov)
IF %menunr%==bb (goto blocks)
IF %menunr%==55 (goto installadb)
IF %menunr%==s (goto screen)
IF %menunr%==ss (goto screenrec)
IF %menunr%==sss (goto video)
IF %menunr%==99 (goto donate)
IF %menunr%==x (goto quit)
IF %app%==None goto WHAT


:logc
ECHO.
ECHO Pulling logcat to the ADB-Assistant\logs folder
ECHO.
adb wait-for-device
adb logcat -v time -d > logs\logcat.txt
IF errorlevel 1 (
ECHO "An Error Occurred, Please Check The Log"
PAUSE
)
cd ..
goto restart

:reclr
adb shell mount /cache
adb pull /cache/recovery/ recovery_logs
adb shell umount /cache
goto restart

:recl
adb shell mkdir -p /storage/sdcard0/recovery_logs
adb shell su , cp cache/recovery/*  /storage/sdcard0/recovery_logs 
adb pull /storage/sdcard0/recovery_logs recovery_logs
adb shell rm /storage/sdcard0/recovery_logs
goto restart

:kmsg
ECHO.
ECHO Pulling last_kmsg to the ADB-Assistant\logs folder
ECHO.
adb wait-for-device
adb shell cat /proc/last_kmsg > logs\last_kmsg.txt
goto restart

:dmesg
ECHO.
ECHO Pulling dmesg to the ADB-Assistant\logs folder
ECHO.
adb wait-for-device
adb shell su -c dmesg > logs\dmesg.txt
goto restart

:ins
set app=NONE
CLS
set /A count=0
FOR %%F IN (install/*.apk) DO (
set /A count+=1
set a!count!=%%F
IF /I !count! LEQ 9 (ECHO ^- !count!  - %%F )
IF /I !count! GTR 9 (ECHO ^- !count! - %%F )
)
FOR %%F IN (install/*.jar) DO (
set /A count+=1
set a!count!=%%F
IF /I !count! LEQ 9 (ECHO ^- !count!  - %%F )
IF /I !count! GTR 9 (ECHO ^- !count! - %%F )
)
IF /I !count! LEQ 0 (ECHO There are no apps in the "install" folder.
ECHO.
pause
goto restart)
ECHO.
ECHO Choose the app to be installed?
set /P INPUT=Enter It's Number: %=%
IF /I %INPUT% GTR !count! (goto WHAT)
IF /I %INPUT% LSS 1 (goto WHAT)
set app=!a%INPUT%!
ECHO Waiting for device
adb wait-for-device
ECHO Installing Apk
adb install -r install/%app%
IF errorlevel 1 (
ECHO "An Error Occurred, Please Check The Log"
PAUSE
)
goto restart

:push
CLS
set /A count=0
FOR %%F IN (push/*.apk) DO (
set /A count+=1
set a!count!=%%F
IF /I !count! LEQ 9 (ECHO ^- !count!  - %%F )
IF /I !count! GTR 9 (ECHO ^- !count! - %%F )
)
FOR %%F IN (push/*.jar) DO (
set /A count+=1
set a!count!=%%F
IF /I !count! LEQ 9 (ECHO ^- !count!  - %%F )
IF /I !count! GTR 9 (ECHO ^- !count! - %%F )
)
IF /I !count! LEQ 0 (ECHO There are no apps in the "push" folder.
ECHO.
pause
goto restart)
ECHO.
ECHO Choose the file to be pushed?
set /P INPUT=Enter It's Number: %=%
IF /I %INPUT% GTR !count! (goto WHAT)
IF /I %INPUT% LSS 1 (goto WHAT)
set app=!a%INPUT%!
set newname=0 
goto push_dir
 
:push_dir
ECHO.
ECHO Remember you must be in recovery for this to work.
ECHO.
ECHO.
ECHO Where do you want to push the apk to? (f) framework (a) app (p) priv-app (x) exit menu
set /P fileloc=""
if %fileloc%==x (goto restart)
 
adb shell mount /system
ECHO Pushing apk
if %fileloc%==a (
adb push "push\%app%" /system/app/%app%
goto chk_err_push
)
if %fileloc%==f (
adb push "push\%app%" /system/framework/%app%
goto chk_err_push
)
if %fileloc%==p (
adb push "push\%app%" /system/priv-app/%app%
goto chk_err_push
)
ECHO "you pressed the wrong key"
goto push_dir

:chk_err_push
IF errorlevel 1 (
ECHO "An Error Occurred, Please Check The Log"
PAUSE
)
adb shell umount /system
goto restart

:pull
ECHO Where do you want to pull the apk from? 
ECHO Example of input : /system/app/launcher.apk
set /P INPUT=Type input: %=%
ECHO Pulling apk to "pulled-files"
adb pull %INPUT% "%~dp0pulled-files\%INPUT%"
IF errorlevel 1 (
ECHO "An Error Occurred, Please Check The Log"
PAUSE
goto restart
)
goto restart

:man
adb start-server
set CHOICE=none
set MANUAL=none
CLS
ECHO Type the full command you wish to execute.
ECHO.
set /P MANUAL=Enter command: %=%
ECHO.
%MANUAL%
ECHO Enter another command? y/n
set /P CHOICE= y or n: %=%
IF %CHOICE%==y (goto nextcommand)
IF %CHOICE%==n (goto restart)

:nextcommand
set MANUAL=none
ECHO Type the full command you wish to execute.
ECHO.
set /P MANUAL=Enter command: %=%
ECHO.
%MANUAL%
ECHO Enter another command? y/n
set /P CHOICE= y or n: %=%
IF %CHOICE%==y (goto nextcommand)
IF %CHOICE%==n (goto restart)

:conn
CLS
ECHO.
adb devices
ECHO.
ECHO.
pause
goto restart

:reboot
adb reboot
goto restart

:down
adb reboot download
goto restart

:recov
adb reboot recovery
goto restart

:blocks
CLS
adb shell ls -al dev/block/*/*/by-name
ECHO.
pause
goto restart

:installadb
msiexec.exe /i UniversalAdbDriverSetup.msi
goto restart

:donate
start https://gr8nole.blogspot.com
goto restart

:screen
adb start-server
CLS
ECHO Type a name for the new capture (do not use the name same as existing file).
ECHO.
set /P SCREENY=Enter screen capture name: %=%
ECHO.
ECHO Screeny will be saved to ADB-Assistant/captures/ folder as "%SCREENY%.png".
ECHO.
ECHO Press any key to begin take capture.
ECHO.
pause
adb shell screencap -p /storage/sdcard0/%SCREENY%.png
adb pull /storage/sdcard0/%SCREENY%.png captures/%SCREENY%.png
adb shell rm /storage/sdcard0/%SCREENY%.png
goto restart

:screenrec
adb start-server
CLS
ECHO Type a name for the new capture (do not use the name same as existing file).
ECHO.
set /P SCREENYREC=Enter screen capture name: %=%
ECHO.
ECHO Screeny will be saved to ADB-Assistant/captures/ folder as "%SCREENYREC%.png".
ECHO.
ECHO Press any key to begin take capture.
ECHO.
pause
adb shell mount /data 
adb push "fb2png" /data/local/
adb shell chmod 755 /data/local/fb2png
adb shell /data/local/fb2png "/data/local/%SCREENYREC%.png"
adb pull "/data/local/%SCREENYREC%.png" "captures/%SCREENYREC%.png"
adb shell rm "/data/local/%SCREENYREC%.png"
adb shell rm /data/local/fb2png
adb shell umount /data
goto restart

:video
adb start-server
CLS
ECHO Type a unique name for the new video (do not use the name same as existing file).
ECHO.
set /P VIDEO=Enter video name: %=%
ECHO.
ECHO Video will be saved to ADB-Assistant/captures/ folder as as "%VIDEO%.mp4".
ECHO.
ECHO Press any key to begin recording...Press Control C to stop recording; select N when prompted.
ECHO.
pause
adb shell screenrecord /storage/sdcard0/%VIDEO%.mp4
adb pull /storage/sdcard0/%VIDEO%.mp4 captures/%VIDEO%.mp4
adb shell rm /storage/sdcard0/%VIDEO%.mp4
goto restart

:WHAT
ECHO.
ECHO "  Hmmm...Are you a Gators fan, or maybe a Hurricane??     "
ECHO.
ECHO. ...you selected something that wasn't part of the menu.
ECHO.
PAUSE
goto restart

:quit
exit