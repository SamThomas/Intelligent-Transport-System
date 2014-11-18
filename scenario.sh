#/bin/bash
  
# Creating the FIFO -----------------------------------------------------------#
echo "+  Deleting previous FIFO if they still exist"
\rm -f /tmp/in? /tmp/out? > /dev/null
 
echo "+  Creating one input FIFO per vehicle"
mkfifo /tmp/in1 /tmp/in2 /tmp/in3
echo "+  Creating one output FIFO per vehicle"
mkfifo /tmp/out1 /tmp/out2 /tmp/out3 
 
# Launching the applications --------------------------------------------------#
echo "+  Launching one CAR application per vehicle"
 
./app.tk --ident=one   --auto < /tmp/in1 > /tmp/out1 & pid_app1=$!
echo "id app1 : $pid_app1"

./app.tk --ident=two   --auto < /tmp/in2 > /tmp/out2 & pid_app2=$!
echo "id app2 : $pid_app2"

./app.tk --ident=three --auto < /tmp/in3 > /tmp/out3 & pid_app3=$!
echo "id app3 : $pid_app3"

# Creating the network topology -----------------------------------------------#
#  Connecting the vehicles in convoy:
#  one <--> two <--> three 
 
#   one --> two
cat /tmp/out1 > /tmp/in2 & pid_com1=$!
echo "id com1 : $pid_com1"
 
#   one <-- two --> three
cat /tmp/out2 | tee /tmp/in1 > /tmp/in3 & pid_com2=$!
echo "id com2 : $pid_com2"
 
#   Two <-- three
cat /tmp/out3 > /tmp/in2 & pid_com3=$!
echo "id com3 : $pid_com3"
 
# Waiting for the end of the scenario -----------------------------------------#
echo "+ Waiting for the end of the scenario: type \"end\" for quitting. ";
 
#  Reading stdin until "end" is typed
read -a foo
while ! [ "$foo" = "end" ]; do 
		echo "* reading $foo, not end. To terminate, type \"end\". ";
		read -a foo
done
 
echo "+  Killing the applications"
kill -9 $pid_app1 $pid_app2 $pid_app3 
echo "kill app : $pid_app1 $pid_app2 $pid_app3"

echo "+  Killing the communications"
kill -9 $pid_com1 $pid_com2 $pid_com3 
echo "kill com : $pid_com1 $pid_com2 $pid_com3"

echo "+  Deleting the FIFO"
\rm -f /tmp/in? /tmp/out? > /dev/null
 
echo "+ End of the scenario"