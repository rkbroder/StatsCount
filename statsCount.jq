# Use MQ Statistics Events to calculate msg/sec rates for queues.

# Define a function to truncate floating point numbers to 2 places
def roundTo2: .*100.0|round/100.0;

# Filter all events to just process those with queue stats
select(.eventData.queueStatisticsData !=null) | 
    .eventData.queueMgrName as $qMgr |
    
    # Extract time stamps and convert to epoch format in seconds
    .eventData.startDate as $startDate |
    .eventData.startTime as $startTime |
    ($startDate + " " + $startTime | strptime("%Y-%m-%d %H.%M.%S") | mktime) as $startEpoch | 
    
    .eventData.endDate as $endDate |
    .eventData.endTime as $endTime |
    ($endDate + " " + $endTime | strptime("%Y-%m-%d %H.%M.%S") | mktime) as $endEpoch |
    
    # Extract the PUT metrics and print along with the duration 
    # Duration should match (give-or-take a second or two) the 
    # qmgr's STATINT value (also given in seconds)
    #
    # Also print out the start time for a bit of sanity checking.
    # We don't show the date here; it's just nice to see a timestamp moving in a readable format).
    
    .eventData.queueStatisticsData[] |
    (.puts[0] + .puts[1] + .put1s[0] + .put1s[1]) as $putTotal | 

    # The "+0.0" converts each side into floats so we get non-integer rates.
    (($putTotal + 0.0)/ (($endEpoch - $startEpoch) + 0.0)) as $rate |
    
    {
          periodStart : $startEpoch ,
          periodEnd   : $endEpoch,
          duration : ($endEpoch - $startEpoch),
          startTime : $startTime,
          queueMgr:$qMgr, 
          queue:.queueName, 
          putNP:(.puts[0] + .put1s[0]), 
          putP: (.puts[1] + .put1s[1]),
          putTotal: $putTotal,
          rate: $rate | roundTo2
    }  

    # This final section might be optional but it further simplifies the
    # output to just the 3 elements you might need to display current state
    ##############################|  [ .periodStart, .queue, .rate ]

