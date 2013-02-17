#!/bin/sh
#rm *.nmap

cleanup()
# example cleanup function
{
	echo "Terminating"
	killall sh
	return $?
}
 
terminate()
# run if user hits control-c
{
  echo "\nReceived signal to terminate."
  cleanup
  exit $?
}
 
trap terminate EXIT

./spawn_dns-sd.sh Google google.com 80 &
# add more entries here

while [ true ]
do
	sleep 10 #sloppy wait code
done