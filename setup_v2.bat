@echo off

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\vcvarsall.bat"

rem InstallerWindows を opentoonz のディレクトリにクローンしておくこと
pushd ..\toonz

rem rmdir /S /Q build
rem rmdir /S /Q build_srv

rem Qt5.15.2 by default
if "%~1"=="" (
    set QT_VER=5.15
) else (
    set QT_VER=%1
)
if "%~2"=="" (
    set QT_REV=2
) else (
    set QT_REV=%2
)

if "%~3"=="32bit" (
    set IS_32BIT=TRUE
)

echo "%QT_VER%"
echo "%QT_REV%"

rem "C:\Qt\5.15.2" にインストールしておく

mkdir -p build
pushd build
@echo on
cmake ../sources -G "Visual Studio 16 2019" -Ax64 -DQT_PATH="C:/Qt/%QT_VER%.%QT_REV%/msvc2019_64" -DOpenCV_DIR="C:/opencv/build" -DBOOST_ROOT="C:/boost/boost_1_75_0" -DWITH_CANON=ON
rem cmake --build . --config Release
@echo off
if errorlevel 1 exit /b 1

MSBuild /m OpenToonz.sln /p:Configuration=Release
if errorlevel 1 exit /b 1

popd
rem build

rem 32bit 版のビルド (t32bitsrv.exe, image.dll, tnzcore.dll 用)
if DEFINED IS_32BIT (
    mkdir -p build_srv
    pushd build_srv
    @echo on
    cmake ../sources -G "Visual Studio 16 2019" -AWin32 -DQT_PATH="C:/Qt/%QT_VER%.%QT_REV%/msvc2019" -DBOOST_ROOT="C:/boost/boost_1_75_0
    @echo off
    if errorlevel 1 exit /b 1
    MSBuild /m OpenToonz.sln /t:t32bitsrv /p:Configuration=Release
    if errorlevel 1 exit /b 1
    popd
    rem build_srv
)
popd

rem innosetup6 をダウンロードしてインストールしておく

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
copy /Y ..\thirdparty\libmypaint\dist\64\*.dll program
copy /Y "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC140.CRT\*.dll" program
copy /Y "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x64\Microsoft.VC140.OpenMP\*.dll" program
copy /Y "C:\EDSDK\Windows\EDSDK_64\Dll\EDSDK.dll" program
copy /Y "C:\libjpeg-turbo64\bin\turbojpeg.dll" program
copy /Y "C:\opencv\build\x64\vc15\bin\opencv_world451.dll" program
@echo on
"C:/Qt/%QT_VER%.%QT_REV%/msvc2019_64\bin\windeployqt.exe" --release --dir program program\OpenToonz.exe
@echo off
if errorlevel 1 exit /b 1

rem
if DEFINED IS_32BIT (
mkdir program\srv
    copy /Y ..\toonz\build_srv\Release\*.exe program\srv
    copy /Y ..\toonz\build_srv\Release\*.dll program\srv
    copy /Y "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.28.29325\x86\Microsoft.VC140.CRT\*.dll" program\srv
    @echo on
    "C:/Qt/%QT_VER%.%QT_REV%/msvc2019\bin\windeployqt.exe" --release --dir program\srv program\srv\t32bitsrv.exe
    @echo off
    rem 25/11/2016 for unknown reasons, QtGui.dll is not copied to srv with windeployqt
    rem copy /Y "C:\Qt\Qt%QT_VER%.%QT_REV%\%QT_VER%\msvc2015\bin\Qt5Gui.dll" program\srv\Qt5Gui.dll
    if errorlevel 1 exit /b 1
)

rem Stuff Dir
mkdir stuff
xcopy /YE ..\stuff stuff
xcopy /YE ..\toonz\build\loc stuff\config\loc
for /R %%F in (.gitkeep) do del "%%F"

python filelist.py
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" setup.iss
if errorlevel 1 exit /b 1

exit /b 0
