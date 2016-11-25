@echo off

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"

rem InstallerWindows を opentoonz のディレクトリにクローンしておくこと
pushd ..\toonz

rmdir /S /Q build
rmdir /S /Q build_srv

rem Qt5.6.0 by default
if "%~1"=="" (
    set QT_VER=5.6
) else (
    set QT_VER=%1
)
if "%~2"=="" (
    set QT_REV=0
) else (
    set QT_REV=%2
)

if "%~3"=="32bit" (
    set IS_32BIT=TRUE
)

echo "%QT_VER%"
echo "%QT_REV%"

rem http://ftp.yz.yamagata-u.ac.jp/pub/qtproject/archive/qt/5.6/5.6.0/qt-opensource-windows-x86-msvc2015_64-5.6.0.exe
rem "C:\Qt\Qt5.6.0" にインストールしておく

mkdir build
pushd build
@echo on
cmake ../sources -G "Visual Studio 14 Win64" -DQT_PATH="C:/Qt/Qt%QT_VER%.%QT_REV%/%QT_VER%/msvc2015_64"
rem cmake --build . --config Release
@echo off
if errorlevel 1 exit /b 1

MSBuild /m OpenToonz.sln /p:Configuration=Release
if errorlevel 1 exit /b 1

popd
rem build

rem 32bit 版のビルド (t32bitsrv.exe, image.dll, tnzcore.dll 用)
rem http://ftp.yz.yamagata-u.ac.jp/pub/qtproject/archive/qt/5.6/5.6.0/qt-opensource-windows-x86-msvc2015-5.6.0.exe
rem "C:\Qt\Qt5.6.0" にインストールしておく
if DEFINED IS_32BIT (
    mkdir build_srv
    pushd build_srv
    @echo on
    cmake ../sources -G "Visual Studio 14" -DQT_PATH="C:/Qt/Qt%QT_VER%.%QT_REV%/%QT_VER%/msvc2015"
    @echo off
    if errorlevel 1 exit /b 1
    MSBuild /m OpenToonz.sln /t:t32bitsrv /p:Configuration=Release
    if errorlevel 1 exit /b 1
    popd
    rem build_srv
)
popd

rem http://www.jrsoftware.org/isdl.php から
rem innosetup-5.5.9-unicode.exe をダウンロードしてインストールしておく

rem clean
rmdir /S /Q program
rmdir /S /Q stuff
rmdir /S /Q Output

rem Program Files
mkdir program
copy /Y ..\toonz\build\Release\*.exe program
copy /Y ..\toonz\build\Release\*.dll program
copy /Y ..\thirdparty\glew\glew-1.9.0\bin\64bit\*.dll program
copy /Y ..\thirdparty\glut\3.7.6\lib\*.dll program
copy /Y "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\x64\Microsoft.VC140.CRT\*.dll" program
copy /Y "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\x64\Microsoft.VC140.OpenMP\*.dll" program
@echo on
"C:\Qt\Qt%QT_VER%.%QT_REV%\%QT_VER%\msvc2015_64\bin\windeployqt.exe" --release --dir program program\OpenToonz_1.1.exe
@echo off
if errorlevel 1 exit /b 1

rem
if DEFINED IS_32BIT (
mkdir program\srv
    copy /Y ..\toonz\build_srv\Release\*.exe program\srv
    copy /Y ..\toonz\build_srv\Release\*.dll program\srv
    copy /Y "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\x86\Microsoft.VC140.CRT\*.dll" program\srv
    @echo on
    "C:\Qt\Qt%QT_VER%.%QT_REV%\%QT_VER%\msvc2015\bin\windeployqt.exe" --release --dir program\srv program\srv\t32bitsrv.exe
    @echo off
    rem 25/11/2016 for unknown reasons, QtGui.dll is not copied to srv with windeployqt
    copy /Y "C:\Qt\Qt%QT_VER%.%QT_REV%\%QT_VER%\msvc2015\bin\Qt5Gui.dll" program\srv
    if errorlevel 1 exit /b 1
)

rem Stuff Dir
mkdir stuff
xcopy /YE ..\stuff stuff
xcopy /YE ..\toonz\build\loc stuff\config\loc
for /R %%F in (.gitkeep) do del "%%F"

python filelist.py
"C:\Program Files (x86)\Inno Setup 5\ISCC.exe" setup.iss
if errorlevel 1 exit /b 1

exit /b 0
