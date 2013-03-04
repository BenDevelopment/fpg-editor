svn update
svn commit
svn update
svn2revisioninc .
lazbuild -B pfpgeditor.lpi
PVERSION=$(svnversion -n)
tar -cvzf fpg-editor_${PVERSION}_i386_lin.tgz fpg-editor lng/*
