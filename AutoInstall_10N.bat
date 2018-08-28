@ECHO OFF
PUSHD %~DP0
COLOR 0F
TITLE Windows 10 Automated Install with PC Name
SET /p DISK_NUM=输入本地硬盘的编号(通常为 0)：
SET /p PC_NAME=输入计算机名：

CLS
ECHO.
TITLE Windows 10 [1/4] 正在准备 DiskPart 命令
ECHO [1/4] 正在准备 DiskPart 命令
ECHO SELECT DISK %DISK_NUM% > DiskPart.txt
ECHO CLEAN >> DiskPart.txt
ECHO CONVERT MBR >> DiskPart.txt
IF EXIST J: (
  ECHO SELECT VOLUME J >> DiskPart.txt
  ECHO REMOVE LETTER=J >> DiskPart.txt
)
IF EXIST K: (
  ECHO SELECT VOLUME K >> DiskPart.txt
  ECHO REMOVE LETTER=K >> DiskPart.txt
)
IF EXIST L: (
  ECHO SELECT VOLUME L >> DiskPart.txt
  ECHO REMOVE LETTER=L >> DiskPart.txt
)
ECHO CREATE PARTITION PRIMARY SIZE=350 >> DiskPart.txt
ECHO FORMAT FS=FAT32 LABEL=BOOT QUICK OVERRIDE NOERR>> DiskPart.txt
ECHO ACTIVE >> DiskPart.txt
ECHO ASSIGN LETTER=J >> DiskPart.txt
ECHO CREATE PARTITION PRIMARY SIZE=102800 >> DiskPart.txt
ECHO FORMAT FS=NTFS LABEL=Windows QUICK OVERRIDE NOERR>> DiskPart.txt
ECHO ASSIGN LETTER=K >> DiskPart.txt
ECHO CREATE PARTITION PRIMARY >> DiskPart.txt
ECHO FORMAT FS=NTFS QUICK OVERRIDE NOERR>> DiskPart.txt
ECHO ASSIGN LETTER=L >> DiskPart.txt
ECHO SHRINK DESIRED=8194 >> DiskPart.txt
ECHO CREATE PARTITION PRIMARY >> DiskPart.txt
ECHO FORMAT FS=NTFS LABEL=Recovery QUICK OVERRIDE NOERR>> DiskPart.txt
ECHO ASSIGN LETTER=M >> DiskPart.txt
ECHO EXIT >> DiskPart.txt
:STEP2
TITLE Windows 10 [2/4] 正在处理 DiskPart 分区
ECHO [2/4] 正在处理 DiskPart 分区
DiskPart.exe /s DiskPart.txt > NUL
IF %ERRORLEVEL% EQU 0 GOTO DismDone
COLOR CF
ECHO DiskPart 出现错误
PAUSE
GOTO STEP2
:DismDone
DEL /f /s /q DiskPart.txt > NUL

:STEP3
TITLE Windows 10 [3/4] 正在复制 Install.wim 文件
ECHO [3/4] 正在复制 Install.wim 文件
MKDIR M:\Recovery\WindowsRE > NUL
XCopy.exe Install_10.wim M:\Recovery\WindowsRE\ /Q /H /R /Y /J > NUL
RENAME M:\Recovery\WindowsRE\Install_10.wim Install.wim > NUL
TITLE Windows 10 [3/4] 正在准备 Unattend.xml
<NUL>TEMP SET /P TMP=%PC_NAME%
>X:\Unattend.xml 2>NUL TYPE Unattend_10N1.xml TEMP Unattend_10N2.xml
DEL /F /S /Q TEMP
IF %ERRORLEVEL% EQU 0 GOTO CopyFileDone
COLOR CF
ECHO 复制文件出现错误
PAUSE
GOTO STEP3
:CopyFileDone

ECHO @ECHO OFF > X:\PostProc.bat
ECHO title Windows 10 [4/4] 正在准备 Install.wim 的安装 >> X:\PostProc.bat
ECHO COLOR 2F >> X:\PostProc.bat
ECHO CD /D X:\Windows\system32\ >> X:\PostProc.bat
ECHO ImageX.exe /Verify /Apply M:\Recovery\WindowsRE\Install.wim 1 K: >> X:\PostProc.bat
ECHO XCopy X:\Unattend.xml K:\Windows\Panther\ /Q /H /R /Y /J >> X:\PostProc.bat
ECHO Bcdboot.exe K:\Windows /l zh-CN /s J: /f ALL >> X:\PostProc.bat
ECHO DiskPart.exe /s X:\DiskPart.txt > NUL >> X:\PostProc.bat
ECHO DEL /F /S /Q X:\DiskPart.txt >> X:\PostProc.bat
IF "%DISK_NUM%" == "0" (
  ECHO IF %%ERRORLEVEL%% EQU 0 shutdown.exe /r /t 0 >> X:\PostProc.bat
)
ECHO PAUSE >> X:\PostProc.bat

ECHO SELECT DISK %DISK_NUM% > X:\DiskPart.txt
ECHO SELECT PARTITION 4 >> X:\DiskPart.txt
ECHO SET ID=17 OVERRIDE >> X:\DiskPart.txt
ECHO EXIT >> X:\DiskPart.txt

TITLE 现在可以移除 USB Storage Device
ECHO 现在可以移除 USB Storage Device
POPD
Start X:\PostProc.bat
