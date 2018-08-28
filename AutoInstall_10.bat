@ECHO OFF
PUSHD %~DP0
title Windows 10 Automated Install
set /p DISK_NUM=输入本地硬盘的编号(通常为 0)：

CLS
echo.
title Windows 10 [1/4] 正在准备 DiskPart 命令
echo [1/4] 正在准备 DiskPart 命令
echo SELECT DISK %DISK_NUM% > DiskPart.txt
echo CLEAN >> DiskPart.txt
echo CONVERT MBR >> DiskPart.txt
echo CREATE PARTITION PRIMARY SIZE=350 >> DiskPart.txt
echo FORMAT FS=FAT32 LABEL=BOOT QUICK OVERRIDE NOERR>> DiskPart.txt
echo ACTIVE >> DiskPart.txt
echo ASSIGN LETTER=J >> DiskPart.txt
echo CREATE PARTITION PRIMARY SIZE=102800 >> DiskPart.txt
echo FORMAT FS=NTFS LABEL=Windows QUICK OVERRIDE NOERR>> DiskPart.txt
echo ASSIGN LETTER=K >> DiskPart.txt
echo CREATE PARTITION PRIMARY >> DiskPart.txt
echo FORMAT FS=NTFS QUICK OVERRIDE NOERR>> DiskPart.txt
echo ASSIGN LETTER=L >> DiskPart.txt
echo SHRINK DESIRED=8194 >> DiskPart.txt
echo CREATE PARTITION PRIMARY >> DiskPart.txt
echo FORMAT FS=NTFS LABEL=Recovery QUICK OVERRIDE NOERR>> DiskPart.txt
echo ASSIGN LETTER=M >> DiskPart.txt
echo EXIT >> DiskPart.txt
:STEP2
title Windows 10 [2/4] 正在处理 DiskPart 分区
echo [2/4] 正在处理 DiskPart 分区
DiskPart.exe /s DiskPart.txt > NUL
IF %ERRORLEVEL% EQU 0 GOTO DismDone
COLOR CF
ECHO DiskPart 出现错误
PAUSE
GOTO STEP2
:DismDone
del /f /s /q DiskPart.txt > NUL

:STEP3
title Windows 10 [3/4] 正在复制 Install.wim 文件
echo [3/4] 正在复制 Install.wim 文件
MKDIR M:\Recovery\WindowsRE > NUL
XCopy.exe Install_10.wim M:\Recovery\WindowsRE\ /Q /H /R /Y /J > NUL
RENAME M:\Recovery\WindowsRE\Install_10.wim Install.wim > NUL
XCopy.exe Unattend_10.xml X:\ /Q /H /R /Y > NUL
RENAME X:\Unattend_10.xml Unattend.xml > NUL
IF %ERRORLEVEL% EQU 0 GOTO CopyFileDone
COLOR CF
ECHO 复制文件出现错误
PAUSE
GOTO STEP3
:CopyFileDone

echo @ECHO OFF > X:\PostProc.bat
echo title Windows 10 [4/4] 正在准备 Install.wim 的安装 >> X:\PostProc.bat
echo COLOR 2F >> X:\PostProc.bat
echo CD /D X:\Windows\system32\ >> X:\PostProc.bat
echo ImageX.exe /Verify /Apply M:\Recovery\WindowsRE\Install.wim 1 K: >> X:\PostProc.bat
echo XCopy X:\Unattend.xml K:\Windows\Panther\ /Q /H /R /Y /J >> X:\PostProc.bat
echo Bcdboot.exe K:\Windows /l zh-CN /s J: /f ALL >> X:\PostProc.bat
echo DiskPart.exe /s X:\DiskPart.txt > NUL >> X:\PostProc.bat
echo DEL /F /S /Q X:\DiskPart.txt >> X:\PostProc.bat
echo IF %%ERRORLEVEL%% EQU 0 shutdown.exe /r /t 0 >> X:\PostProc.bat
echo PAUSE >> X:\PostProc.bat

echo SELECT DISK %DISK_NUM% > X:\DiskPart.txt
echo SELECT PARTITION 4 >> X:\DiskPart.txt
echo SET ID=17 OVERRIDE >> X:\DiskPart.txt
echo EXIT >> X:\DiskPart.txt

title 现在可以移除 USB Storage Device
echo 现在可以移除 USB Storage Device
POPD
Start X:\PostProc.bat
