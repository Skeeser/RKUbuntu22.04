for /L %%i in (1,1,255) do (ping -n 1 -w 60 192.168.137.%%i | find "»Ø¸´" >>pingall.txt)

ping 123.45.67.89 -n 1 -w 10000 > null

exit