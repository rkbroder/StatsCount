This will format the SYSTEM.ADMIN.STATIS.QUEUE event messages into singline JSON where you can push it to a file.

You should set up a trigget to kick this off every time a message lands on the SYSTEM Event queue
I installed this into /home/mqm/scripts/StatsCount. Then updated the sh to 'x'. table.sh is not used.
./statsCount.sh >> statsCount.txt

This requires JS which needs to be installed.

Google 'installing jq on rhel'

My command was:

sudo dnf install -y jq
jq --version
