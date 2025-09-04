#!/bin/bash
#
QM=BOBBEE2

. setmqenv -m $QM -k

# Use stdbuf to ensure output from amqsevt is unbuffered and printed as soon as available.
# The --unbuffered flag to jq does something similar
stdbuf -o0 /opt/mqm/samp/bin/amqsevt   -m $QM -q SYSTEM.ADMIN.STATISTICS.QUEUE  -w 2 -o json |\
  jq -f statsCount.jq -c --unbuffered 
