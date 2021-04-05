@echo off
setlocal EnableDelayedExpansion
PUSHD %~DP0 & cd /d "%~dp0"
%1 %2
mshta vbscript:createobject("shell.application").shellexecute("%~s0","goto :runas","","runas",1)(window.close)&goto :eof

:runas
mode con: cols=30 lines=5
title network status monitor
::设置检测IP
set "ip_addr=192.168.1.1"
::设置网卡名
set "network_adapter=Ethernet0"
::设置失败次数后重启，【0】不重启
set /a max_times=5
::设置检测时间间隔，单位秒
set /a interval_time=60

:start
cls
set /a times=0
echo ==Do not close me==
choice /t 600 /d y /n >nul

:error
ping %ip_addr% -w 200 -n 2 >nul
if %ERRORLEVEL%==0 goto start
::echo restart network .......
::echo  
netsh interface set interface %network_adapter% disabled
choice /t 2 /d y /n >nul
netsh interface set interface %network_adapter% enabled
choice /t %interval_time% /d y /n >nul
set /a times=%times%+1
if %times% geq %max_times% goto reboot
goto error

:reboot
if %max_times%==0 goto start
shutdown /r /f 
goto start