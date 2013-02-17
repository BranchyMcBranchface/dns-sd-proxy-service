#!/bin/sh

NAME=$1
HOST=$2
PORT=$3
SERVERUP=0
PID=0

cleanup()
# example cleanup function
{
	rm $$.nmap
	if [ $PID -ne 0 ]; then
		echo "Terminating" $PID
		kill $PID && echo "Done"
		PID=0
	fi
	return $?
}
 
terminate()
# run if user hits control-c
{
  echo "\n"$$ "received signal to terminate."
  cleanup
  exit $?
}
 
trap terminate SIGHUP SIGINT SIGTERM

while [ true ]
do
	nmap -oG $$.nmap -Pn -n -p T:$PORT $HOST &> /dev/null
	grep Ports $$.nmap | grep open &> /dev/null

	if [ $? -eq 0 ]; then
		if [ $SERVERUP -ne 1 ]; then
		    echo "Host" $HOST "is up on" $PORT;
			dns-sd -P $NAME _http._tcp local $PORT $NAME.local $HOST &
			PID=$!
			if [ $? -eq 0 ]; then
				echo "dns-sd started ["$PID"]"
			else
				echo "Could not register service"
			fi
			SERVERUP=1
		fi
	else 
		if [ $PID -ne 0 ]; then
		    echo "Host" $HOST "is down on" $PORT;
			kill $PID &> /dev/null
			if [ $? -eq 0 ]; then
				echo "Quit:" $PID
			else
				echo "Problem terminating dns-sd process on dropped connection"
			fi
			PID=0
			SERVERUP=0
		fi
	fi

	sleep 5 # too fast will cause excessive CPU usage by nmap
done
