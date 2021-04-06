
APORT=$1
BPORT=$2
BAUD=$3
DELAYTIME=0.2s			# delay time between listen port and send
WAITTIME=$4			# listen wait timeout
INTERVALTIME=0.5s		# interval time for next listen and send

TESTSTRINGA=send-to-$APORT,send-to-$APORT,send-to-$APORT,send-to-$APORT,send-to-$APORT
TESTSTRINGB=send-to-$BPORT,send-to-$BPORT,send-to-$BPORT,send-to-$BPORT,send-to-$BPORT

if [ -z "$1" ]; then 
    echo "./test8port485.sh <A-port> <B-port> <baud> <wait-time>"
    echo "Example:"
    echo "      test 1: ttyExtUSB0 -> ttyExtUSB1, 921600, 0.5s"
    echo "      test 2: ttyExtUSB1 -> ttyExtUSB0, 921600, 0.5s"
    echo "      ./test8port485.sh ttyExtUSB0 ttyExtUSB1 921600 0.5s"
    echo ""
    echo ">> No A port (output first)"
    exit 0
fi
if [ -z "$2" ]; then 
    echo "./test8port485.sh <A-port> <B-port> <baud> <wait-time>"
    echo "Example:"
    echo "      test 1: ttyExtUSB0 -> ttyExtUSB1, 921600, 0.5s"
    echo "      test 2: ttyExtUSB1 -> ttyExtUSB0, 921600, 0.5s"
    echo "      ./test8port485.sh ttyExtUSB0 ttyExtUSB1 921600 0.5s"
    echo ""
    echo ">> No B port (input first)"
    exit 0
fi
if [ -z "$3" ]; then
    #echo ">> No arguments supplied, set default, baud rate 921600"
    BAUD=921600
fi
if [ -z "$4" ]; then
    #echo ">> No arguments supplied, set default, wait time 0.5s"
    WAITTIME=0.5s
fi

echo "test 2 port rs485, $APORT <-> $BPORT, baud rate $BAUD, wait-time $WAITTIME"

stty -F /dev/$APORT $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/$BPORT $BAUD raw            #CONFIGURE SERIAL PORT

if [ -f dump_tty$APORT.dat ]; then
    rm dump_tty$APORT.dat
fi
if [ -f dump_tty$BPORT.dat ]; then
    rm dump_tty$BPORT.dat
fi

# send to $APORT and listen to $BPORT
exec 3</dev/$BPORT                        #REDIRECT SERIAL OUTPUT TO FD 3
    cat <&3 > dump_tty$BPORT.dat &            #REDIRECT SERIAL OUTPUT TO FILE
    PID=$!                                #SAVE PID TO KILL CAT
    sleep $DELAYTIME
        echo $TESTSTRINGA > /dev/$APORT  #SEND COMMAND STRING TO SERIAL PORT
        sleep $WAITTIME                        #WAIT FOR RESPONSE
    kill $PID                             #KILL CAT PROCESS
    wait $PID 2>/dev/null                 #SUPRESS "Terminated" output
exec 3<&-                                 #FREE FD 3
sleep $INTERVALTIME
# send to $BPORT and listen to $APORT
exec 3</dev/$APORT
cat <&3 > dump_tty$APORT.dat &
    PID=$!
    sleep $DELAYTIME
        echo $TESTSTRINGB > /dev/$BPORT
        sleep $WAITTIME
    kill $PID
    wait $PID 2>/dev/null
exec 3<&-
sleep $INTERVALTIME

TESTA=0
TESTB=0

# check resule
cat dump_tty$BPORT.dat | grep -q $TESTSTRINGA
if [ $? -eq 0 ]; then
    #echo "$APORT -> $BPORT success"
    TESTA=1
fi
cat dump_tty$APORT.dat | grep -q $TESTSTRINGB
if [ $? -eq 0 ]; then
    #echo "$BPORT -> $APORT success"
    TESTB=1
fi

# print result
if [ $TESTA -eq 1 ] &&
   [ $TESTB -eq 1 ]; then
    echo "2 port RS485 test success!"
else
    echo "2 port RS485 test fail!"
    if [ $TESTB -ne 1 ]; then
        echo "$APORT -> $BPORT fail"
        echo "----- dump tty$BPORT -----"
        cat dump_tty$BPORT.dat
        echo ""
        echo "--------------------"
    fi
    if [ $TESTA -ne 1 ]; then
        echo "$BPORT -> $APORT fail"
        echo "----- dump tty$APORT -----"
        cat dump_tty$APORT.dat
        echo ""
        echo "--------------------"
    fi
fi

# remove test dump file
if [ -f dump_tty$APORT.dat ]; then
    rm dump_tty$APORT.dat
fi
if [ -f dump_tty$BPORT.dat ]; then
    rm dump_tty$BPORT.dat
fi

