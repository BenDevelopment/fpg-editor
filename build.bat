svn commit
svn update
c:\lazarus\tools\svn2revisioninc.exe .
c:\lazarus\lazbuild.exe pfpgeditor.lpi
"c:\Program Files\7-Zip\7z.exe" a -t7z -mx9 fpg-editor.7z fpg-editor.exe lng\*.* zlib\*.*
