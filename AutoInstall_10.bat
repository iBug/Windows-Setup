@ECHO OFF
PUSHD %~DP0
title Windows 10 Automated Install
set /p DISK_NUM=���뱾��Ӳ�̵ı��(ͨ��Ϊ 0)��

CLS
echo.
title Windows 10 [1/4] ����׼�� DiskPart ����
echo [1/4] ����׼�� DiskPart ����
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
title Windows 10 [2/4] ���ڴ��� DiskPart ����
echo [2/4] ���ڴ��� DiskPart ����
DiskPart.exe /s DiskPart.txt > NUL
IF %ERRORLEVEL% EQU 0 GOTO DismDone
COLOR CF
ECHO DiskPart ���ִ���
PAUSE
GOTO STEP2
:DismDone
del /f /s /q DiskPart.txt > NUL

:STEP3
title Windows 10 [3/4] ���ڸ��� Install.wim �ļ�
echo [3/4] ���ڸ��� Install.wim �ļ�
MKDIR M:\Recovery\WindowsRE > NUL
XCopy.exe Install_10.wim M:\Recovery\WindowsRE\ /Q /H /R /Y /J > NUL
RENAME M:\Recovery\WindowsRE\Install_10.wim Install.wim > NUL
XCopy.exe Unattend_10.xml X:\ /Q /H /R /Y > NUL
RENAME X:\Unattend_10.xml Unattend.xml > NUL
IF %ERRORLEVEL% EQU 0 GOTO CopyFileDone
COLOR CF
ECHO �����ļ����ִ���
PAUSE
GOTO STEP3
:CopyFileDone

echo @ECHO OFF > X:\PostProc.bat
echo title Windows 10 [4/4] ����׼�� Install.wim �İ�װ >> X:\PostProc.bat
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

title ���ڿ����Ƴ� USB Storage Device
echo ���ڿ����Ƴ� USB Storage Device
POPD
Start X:\PostProc.bat
