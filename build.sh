svn commit
svn update
svn2revisioninc .
lazbuild -B pfpgeditor.lpi
PVERSION=$(svnversion -n)
tar -cvzf fpg-editor_r${PVERSION}_i386lin.tgz fpg-editor lng/* languages/*
