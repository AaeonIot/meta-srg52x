echo "set ttyMU0 and ttyMU1 as RS485 full duplex / RS422 and set baud rate as 115200"
sudo uartmode -p 0 -m 2
sudo uartmode -p 1 -m 2
stty -F /dev/ttyMU0 115200 raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyMU1 115200 raw            #CONFIGURE SERIAL PORT

rm ttyDumpMU0.dat
rm ttyDumpMU1.dat

exec 3</dev/ttyMU1                        #REDIRECT SERIAL OUTPUT TO FD 3
    cat <&3 > ttyDumpMU1.dat &            #REDIRECT SERIAL OUTPUT TO FILE
    PID=$!                                #SAVE PID TO KILL CAT
        echo "send-to-MU0" > /dev/ttyMU0  #SEND COMMAND STRING TO SERIAL PORT
        sleep 0.2s                        #WAIT FOR RESPONSE
    kill $PID                             #KILL CAT PROCESS
    wait $PID 2>/dev/null                 #SUPRESS "Terminated" output
exec 3<&-                                 #FREE FD 3

exec 3</dev/ttyMU0
cat <&3 > ttyDumpMU0.dat &
    PID=$!
        echo "send-to-MU1" > /dev/ttyMU1
        sleep 0.2s
    kill $PID
    wait $PID 2>/dev/null
exec 3<&-

echo "===== DumpMU0 ====="
cat ttyDumpMU0.dat                    #DUMP CAPTURED DATA
echo "===== DumpMU1 ====="
cat ttyDumpMU1.dat
echo "==================="

if [ `cat ttyDumpMU1.dat | grep -c send-to-MU0` -ne 1 ]; then
    echo "ttyMU0 -> ttyMU1 fail"
fi

if [ `cat ttyDumpMU0.dat | grep -c send-to-MU1` -ne 1 ]; then
    echo "ttyMU1 -> ttyMU0 fail"
fi

if [ `cat ttyDumpMU1.dat | grep -c send-to-MU0` -eq 1 ]; then
    if [ `cat ttyDumpMU0.dat | grep -c send-to-MU1` -eq 1 ]; then
        echo "RS485 full duplex / RS422 test success!"
    else
        echo "RS485 full duplex / RS422 test fail!"
    fi
else
    echo "RS485 full duplex / RS422 test fail!"
fi

