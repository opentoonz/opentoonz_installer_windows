# list up files in program and stuff
# for python version 3.x (converted with 2to3.py from filelist.py)

import os
import codecs

fout = codecs.open("files.iss", "w", "utf_8_sig")

for path, dirs, files in os.walk(r'program'):
    for file in files:
        print("""Source: "%s"; DestDir: "{app}%s"; Flags: ignoreversion""" % (
            os.path.join(path, file),
            path[len("program"):]), file=fout)

print()

for path, dirs, files in os.walk(r'stuff'):
    for file in files:
        print("""Source: "%s"; DestDir: "{code:GetGeneralDir}%s"; Flags: uninsneveruninstall; Check: IsOverwiteStuffCheckBoxChecked""" % (
            os.path.join(path, file),
            path[len("stuff"):]), file=fout)
        print("""Source: "%s"; DestDir: "{code:GetGeneralDir}%s"; Flags: onlyifdoesntexist uninsneveruninstall; Check: not IsOverwiteStuffCheckBoxChecked""" % (
            os.path.join(path, file),
            path[len("stuff"):]), file=fout)

fout.close()
