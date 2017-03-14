# list up files in program and stuff

import os
import codecs

fout = codecs.open("files.iss", "w", "utf_8_sig")

for path, dirs, files in os.walk(ur'program'):
    for file in files:
        print >> fout, """Source: "%s"; DestDir: "{app}%s"; Flags: ignoreversion""" % (
            os.path.join(path, file),
            path[len("program"):])

print

for path, dirs, files in os.walk(ur'stuff'):
    for file in files:
        print >> fout, """Source: "%s"; DestDir: "{code:GetGeneralDir}%s"; Flags: uninsneveruninstall; Check: IsOverwiteStuffCheckBoxChecked""" % (
            os.path.join(path, file),
            path[len("stuff"):])
        print >> fout, """Source: "%s"; DestDir: "{code:GetGeneralDir}%s"; Flags: onlyifdoesntexist uninsneveruninstall; Check: not IsOverwiteStuffCheckBoxChecked""" % (
            os.path.join(path, file),
            path[len("stuff"):])

fout.close()
