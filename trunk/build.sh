svn commit
svn2revisioninc .
lazbuild -B pfpgeditor.lpi
PVERSION=$(svnversion -n)
tar -cvzf fpg-editor_${PVERSION}_i386_lin.tgz fpg-editor lng/*
