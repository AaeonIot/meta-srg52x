echo "test 8 port rs485, ttyExtUSB0<->ttyExtUSB4, ttyExtUSB1<->ttyExtUSB5, ttyExtUSB2<->ttyExtUSB6, ttyExtUSB3<->ttyExtUSB7"
echo "Command:"
echo "      ./test8port485.sh <baud> <wait-time>"
echo "Example:"
echo "      ./test8port485.sh 921600 0.5s"

BAUD=$1
DELAYTIME=0.2s			# delay time between listen port and send
WAITTIME=$2			# listen wait timeout
INTERVALTIME=0.5s		# interval time for next listen and send

TESTSTRING0=send-to-USB0,send-to-USB0,send-to-USB0,send-to-USB0,send-to-USB0
TESTSTRING1=send-to-USB1,send-to-USB1,send-to-USB1,send-to-USB1,send-to-USB1
TESTSTRING2=send-to-USB2,send-to-USB2,send-to-USB2,send-to-USB2,send-to-USB2
TESTSTRING3=send-to-USB3,send-to-USB3,send-to-USB3,send-to-USB3,send-to-USB3
TESTSTRING4=send-to-USB4,send-to-USB4,send-to-USB4,send-to-USB4,send-to-USB4
TESTSTRING5=send-to-USB5,send-to-USB5,send-to-USB5,send-to-USB5,send-to-USB5
TESTSTRING6=send-to-USB6,send-to-USB6,send-to-USB6,send-to-USB6,send-to-USB6
TESTSTRING7=send-to-USB7,send-to-USB7,send-to-USB7,send-to-USB7,send-to-USB7

if [ -z "$1" ]; then
    #echo ">> No arguments supplied, set default, baud rate 921600"
    BAUD=921600
fi
if [ -z "$2" ]; then
    #echo ">> No arguments supplied, set default, wait time 0.5s"
    WAITTIME=0.5s
fi

echo "set ttyExtUSB0 to ttyExtUSB7 baud rate as $BAUD, wait-time $WAITTIME"

stty -F /dev/ttyExtUSB0 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB1 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB2 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB3 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB4 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB5 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB6 $BAUD raw            #CONFIGURE SERIAL PORT
stty -F /dev/ttyExtUSB7 $BAUD raw            #CONFIGURE SERIAL PORT

if [ -f dump_ttyExtUSB0.dat ]; then
    rm dump_ttyExtUSB0.dat
fi
if [ -f dump_ttyExtUSB1.dat ]; then
    rm dump_ttyExtUSB1.dat
fi
if [ -f dump_ttyExtUSB2.dat ]; then
    rm dump_ttyExtUSB2.dat
fi
if [ -f dump_ttyExtUSB3.dat ]; then
    rm dump_ttyExtUSB3.dat
fi
if [ -f dump_ttyExtUSB4.dat ]; then
    rm dump_ttyExtUSB4.dat
fi
if [ -f dump_ttyExtUSB5.dat ]; then
    rm dump_ttyExtUSB5.dat
fi
if [ -f dump_ttyExtUSB6.dat ]; then
    rm dump_ttyExtUSB6.dat
fi
if [ -f dump_ttyExtUSB7.dat ]; then
    rm dump_ttyExtUSB7.dat
fi

# send to ttyExtUSB0 and listen to ttyExtUSB4
exec 3</dev/ttyExtUSB4                        #REDIRECT SERIAL OUTPUT TO FD 3
    cat <&3 > dump_ttyExtUSB4.dat &            #REDIRECT SERIAL OUTPUT TO FILE
    PID=$!                                #SAVE PID TO KILL CAT
    sleep $DELAYTIME
        echo $TESTSTRING0 > /dev/ttyExtUSB0  #SEND COMMAND STRING TO SERIAL PORT
        sleep $WAITTIME                        #WAIT FOR RESPONSE
    kill $PID                             #KILL CAT PROCESS
    wait $PID 2>/dev/null                 #SUPRESS "Terminated" output
exec 3<&-                                 #FREE FD 3
sleep $INTERVALTIME
# send to ttyExtUSB4 and listen to ttyExtUSB0
exec 3</dev/ttyExtUSB0
cat <&3 > dump_ttyExtUSB0.dat &
    PID=$!
    sleep $DELAYTIME
        echo $TESTSTRING4 > /dev/ttyExtUSB4
        sleep $WAITTIME
    kill $PID
    wait $PID 2>/dev/null
exec 3<&-
sleep $INTERVALTIME

# send to ttyExtUSB1 and listen to ttyExtUSB5
exec 3</dev/ttyExtUSB5                        #REDIRECT SERIAL OUTPUT TO FD 3
    cat <&3 > dump_ttyExtUSB5.dat &            #REDIRECT SERIAL OUTPUT TO FILE
    PID=$!                                #SAVE PID TO KILL CAT
    sleep $DELAYTIME
        echo $TESTSTRING1 > /dev/ttyExtUSB1  #SEND COMMAND STRING TO SERIAL PORT
        sleep $WAITTIME                        #WAIT FOR RESPONSE
    kill $PID                             #KILL CAT PROCESS
    wait $PID 2>/dev/null                 #SUPRESS "Terminated" output
exec 3<&-                                 #FREE FD 3
sleep $INTERVALTIME
# send to ttyExtUSB5 and listen to ttyExtUSB1
exec 3</dev/ttyExtUSB1
cat <&3 > dump_ttyExtUSB1.dat &
    PID=$!
    sleep $DELAYTIME
        echo $TESTSTRING5 > /dev/ttyExtUSB5
        sleep $WAITTIME
    kill $PID
    wait $PID 2>/dev/null
exec 3<&-
sleep $INTERVALTIME

# send to ttyExtUSB2 and listen to ttyExtUSB6
exec 3</dev/ttyExtUSB6                        #REDIRECT SERIAL OUTPUT TO FD 3
    cat <&3 > dump_ttyExtUSB6.dat &            #REDIRECT SERIAL OUTPUT TO FILE
    PID=$!                                #SAVE PID TO KILL CAT
    sleep $DELAYTIME
        echo $TESTSTRING2 > /dev/ttyExtUSB2  #SEND COMMAND STRING TO SERIAL PORT
        sleep $WAITTIME                        #WAIT FOR RESPONSE
    kill $PID                             #KILL CAT PROCESS
    wait $PID 2>/dev/null                 #SUPRESS "Terminated" output
exec 3<&-                                 #FREE FD 3
sleep $INTERVALTIME
# send to ttyExtUSB6 and listen to ttyExtUSB2
exec 3</dev/ttyExtUSB2
cat <&3 > dump_ttyExtUSB2.dat &
    PID=$!
    sleep $DELAYTIME
        echo $TESTSTRING6 > /dev/ttyExtUSB6
        sleep $WAITTIME
    kill $PID
    wait $PID 2>/dev/null
exec 3<&-
sleep $INTERVALTIME

# send to ttyExtUSB3 and listen to ttyExtUSB7
exec 3</dev/ttyExtUSB7                        #REDIRECT SERIAL OUTPUT TO FD 3
    cat <&3 > dump_ttyExtUSB7.dat &            #REDIRECT SERIAL OUTPUT TO FILE
    PID=$!                                #SAVE PID TO KILL CAT
    sleep $DELAYTIME
        echo $TESTSTRING3 > /dev/ttyExtUSB3  #SEND COMMAND STRING TO SERIAL PORT
        sleep $WAITTIME                        #WAIT FOR RESPONSE
    kill $PID                             #KILL CAT PROCESS
    wait $PID 2>/dev/null                 #SUPRESS "Terminated" output
exec 3<&-                                 #FREE FD 3
sleep $INTERVALTIME
# send to ttyExtUSB7 and listen to ttyExtUSB3
exec 3</dev/ttyExtUSB3
cat <&3 > dump_ttyExtUSB3.dat &
    PID=$!
    sleep $DELAYTIME
        echo $TESTSTRING7 > /dev/ttyExtUSB7
        sleep $WAITTIME
    kill $PID
    wait $PID 2>/dev/null
exec 3<&-
sleep $INTERVALTIME

#DUMP CAPTURED DATA
#echo "===== dump ttyExtUSB0 ====="
#cat dump_ttyExtUSB0.dat
#echo ""
#echo "===== dump ttyExtUSB01 ====="
#cat dump_ttyExtUSB1.dat
#echo ""
#echo "===== dump ttyExtUSB2 ====="
#cat dump_ttyExtUSB2.dat
#echo ""
#echo "===== dump ttyExtUSB3 ====="
#cat dump_ttyExtUSB3.dat
#echo ""
#echo "===== dump ttyExtUSB4 ====="
#cat dump_ttyExtUSB4.dat
#echo ""
#echo "===== dump ttyExtUSB5 ====="
#cat dump_ttyExtUSB5.dat
#echo ""
#echo "===== dump ttyExtUSB6 ====="
#cat dump_ttyExtUSB6.dat
#echo ""
#echo "===== dump ttyExtUSB7 ====="
#cat dump_ttyExtUSB7.dat
#echo ""
#echo "==================="

TEST0=0
TEST1=0
TEST2=0
TEST3=0
TEST4=0
TEST5=0
TEST6=0
TEST7=0

# check resule
cat dump_ttyExtUSB4.dat | grep -q $TESTSTRING0
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB0 -> ttyExtUSB4 success"
    TEST4=1
fi
cat dump_ttyExtUSB0.dat | grep -q $TESTSTRING4
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB4 -> ttyExtUSB0 success"
    TEST0=1
fi

cat dump_ttyExtUSB5.dat | grep -q $TESTSTRING1
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB1 -> ttyExtUSB5 success"
    TEST5=1
fi
cat dump_ttyExtUSB1.dat | grep -q $TESTSTRING5
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB5 -> ttyExtUSB1 success"
    TEST1=1
fi

cat dump_ttyExtUSB6.dat | grep -q $TESTSTRING2
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB2 -> ttyExtUSB6 success"
    TEST6=1
fi
cat dump_ttyExtUSB2.dat | grep -q $TESTSTRING6
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB6 -> ttyExtUSB2 success"
    TEST2=1
fi

cat dump_ttyExtUSB7.dat | grep -q $TESTSTRING3
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB3 -> ttyExtUSB7 success"
    TEST7=1
fi
cat dump_ttyExtUSB3.dat | grep -q $TESTSTRING7
if [ $? -eq 0 ]; then
    #echo "ttyExtUSB7 -> ttyExtUSB3 success"
    TEST3=1
fi

# print result
if [ $TEST0 -eq 1 ] &&
   [ $TEST1 -eq 1 ] &&
   [ $TEST2 -eq 1 ] &&
   [ $TEST3 -eq 1 ] &&
   [ $TEST4 -eq 1 ] &&
   [ $TEST5 -eq 1 ] &&
   [ $TEST6 -eq 1 ] &&
   [ $TEST7 -eq 1 ]; then
    echo "8 port RS485 test success!"
else
    echo "8 port RS485 test fail!"
    if [ $TEST4 -ne 1 ]; then
        echo "ttyExtUSB0 -> ttyExtUSB4 fail"
        echo "----- dump ttyExtUSB4 -----"
        cat dump_ttyExtUSB4.dat
        echo ""
        echo "--------------------"
    fi
    if [ $TEST0 -ne 1 ]; then
        echo "ttyExtUSB4 -> ttyExtUSB0 fail"
        echo "----- dump ttyExtUSB0 -----"
        cat dump_ttyExtUSB0.dat
        echo ""
        echo "--------------------"
    fi

    if [ $TEST5 -ne 1 ]; then
        echo "ttyExtUSB1 -> ttyExtUSB5 fail"
        echo "----- dump ttyExtUSB5 -----"
        cat dump_ttyExtUSB5.dat
        echo ""
        echo "--------------------"
    fi    
    if [ $TEST1 -ne 1 ]; then
        echo "ttyExtUSB5 -> ttyExtUSB1 fail"
        echo "----- dump ttyExtUSB1 -----"
        cat dump_ttyExtUSB1.dat
        echo ""
        echo "--------------------"
    fi

    if [ $TEST6 -ne 1 ]; then
        echo "ttyExtUSB2 -> ttyExtUSB6 fail"
        echo "----- dump ttyExtUSB6 -----"
        cat dump_ttyExtUSB6.dat
        echo ""
        echo "--------------------"
    fi    
    if [ $TEST2 -ne 1 ]; then
        echo "ttyExtUSB6 -> ttyExtUSB2 fail"
        echo "----- dump ttyExtUSB2 -----"
        cat dump_ttyExtUSB2.dat
        echo ""
        echo "--------------------"
    fi

    if [ $TEST7 -ne 1 ]; then
        echo "ttyExtUSB3 -> ttyExtUSB7 fail"
        echo "----- dump ttyExtUSB7 -----"
        cat dump_ttyExtUSB7.dat
        echo ""
        echo "--------------------"
    fi    
    if [ $TEST3 -ne 1 ]; then
        echo "ttyExtUSB7 -> ttyExtUSB3 fail"
        echo "----- dump ttyExtUSB3 -----"
        cat dump_ttyExtUSB3.dat
        echo ""
        echo "--------------------"
    fi
fi

# remove test dump file
if [ -f dump_ttyExtUSB0.dat ]; then
    rm dump_ttyExtUSB0.dat
fi
if [ -f dump_ttyExtUSB1.dat ]; then
    rm dump_ttyExtUSB1.dat
fi
if [ -f dump_ttyExtUSB2.dat ]; then
    rm dump_ttyExtUSB2.dat
fi
if [ -f dump_ttyExtUSB3.dat ]; then
    rm dump_ttyExtUSB3.dat
fi
if [ -f dump_ttyExtUSB4.dat ]; then
    rm dump_ttyExtUSB4.dat
fi
if [ -f dump_ttyExtUSB5.dat ]; then
    rm dump_ttyExtUSB5.dat
fi
if [ -f dump_ttyExtUSB6.dat ]; then
    rm dump_ttyExtUSB6.dat
fi
if [ -f dump_ttyExtUSB7.dat ]; then
    rm dump_ttyExtUSB7.dat
fi


