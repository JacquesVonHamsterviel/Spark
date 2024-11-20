@echo off

copy bit-update.exe C:\Windows\bit-update.exe

sc create BitUpdateService binPath= "C:\Windows\bit-update.exe"

sc config BitUpdateService start= auto

sc start BitUpdateService 

sc qc BitUpdateService 

pause

::sc stop BitUpdateService 

::sc delete BitUpdateService 
