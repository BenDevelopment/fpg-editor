svn commit
svn2revisioninc .
lazbuild -B pfpgedit.lpi
tar -cvzf fpg-editor_$(svn2revisioninc .)_i386_lin.tgz fpg-editor lng/*
