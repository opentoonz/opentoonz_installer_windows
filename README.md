# OpenToonz Windows用インストーラー

[Inno Setup](http://www.jrsoftware.org/isinfo.php)用のスクリプトです。

## 必要なファイル

実行可能ファイルなどは含めていないので、ビルドしたOpenToonz本体などから集める必要があります。

### InstallerWindows/program

この中身がProgram Filesにインストールされます。64ビット版をビルドした.exeや.dllをコピーします。Qt関係のDLLはビルドしたOpenToonz.exeをwindeployqtに渡すと集めてくれます。

glew32.dllとglut64.dllは、それぞれOpenToonzリポジトリのthirdparty/glew/glew-1.9.0/bin/64bit/と/thirdparty/glut/3.7.6/lib/にあります。

msvcp140.dllとmsvcr140.dllはC:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\x64\Microsoft.VC140.CRTにあります。

### InstallerWindows/program/srv

**x86用にビルドした**t32bitsrv.exe, image.dll, tnzcore.dllをコピーします。Qt5Core.dll, Qt5Network.dllはQtの32版からコピー。

msvcp140.dllとmsvcr140.dllはC:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\redist\x86\Microsoft.VC140.CRTにあります。

### InstallerWindows/stuff

Stuffフォルダとしてインストールされます。OpenToonzリポジトリのstuffからコピー。

## インストーラー作成方法

1. このリポジトリをcloneする
2. 必要なファイルを集める
3. Inno Setupをインストールする
4. Inno Setupでビルドすると、Outputフォルダ内にインストーラーができる

## filelist.pyについて

setup.iss中のprogramとstuffのファイルの一覧を出力するスクリプトです。Python 2.7で動作します。Inno Setupにはフォルダを全て指定する記法もありますが、ファイルの不足や余計なファイルの混入を避けるため、ファイルの一覧を記載するようにしています。

現在は空ディレクトリに対応していないので、`.gitignore`が含まれている行を手で削除し、`[Dirs]`に追加する必要があります。
