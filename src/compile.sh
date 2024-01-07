#!/bin/bash

##############
# Compiles files in this repo's dir downloaded/ to the contents of 
# spec/ 
#
# Status: Not beta tested! Only ran by @elarson@akamai.com
#
# Repuires the following Bash utilities: 
# * mlr -- "miller"
# * jq
# * csplit
##############

# Clean up any previous run
if compgen -G "/tmp/whatsbecon.spit.out*" > /dev/null; then
  rm /tmp/whatsbecon.split.out*;
fi



##############
# Convert What's In A Beacon HTML to JSON
##############

grep 'The document was loaded hidden, so paint metrics won.t be added to the beacon' downloaded/whats-in-an-mpulse-beacon.html > /tmp/whatsbecon.grep.out;

# Expand \n, filter for Markdown table and topic names
printf "$(cat /tmp/whatsbecon.grep.out)" |\
 sed 's/^The following metrics are only available if Akamai Adaptive.*$/# AA Edge/g;' |\
 grep '^[|#]' > /tmp/whatsbecon.pipes.out 

pushd /tmp/;
csplit -f whatsbecon.split.out /tmp/whatsbecon.pipes.out '/^#/'  '{30}';
popd;

for f in /tmp/whatsbecon.split.out*; do
  TABLE=$(head -n1 ${f} | sed 's/#//g;s/ *//g');
  cat ${f} |\
    sed '
      s/,/ /g;
      s/`0x\([[:digit:]]\{3\}\)/"`000x\1"/g;
      s/ *| */|/g;
      s/|/,/g;
      s/^,//g;
      s/,$//g;
      s/`//g
    ' |\
    grep -v ':--------' |\
    grep -v '^#' \
    > ${f}.csv;
  mlr --c2j --jlistwrap cat ${f}.csv |\
    jq --arg group ${TABLE} '.[] | . + {MetricGroup:$group}' \
    > ${f}.json;
  echo "${TABLE} ${f}.json";
done;

###############
# Add Metrics 2023
###############

mlr --c2j --jlistwrap cat downloaded/metrics2023.csv | jq '.[]' > /tmp/metrics2023.json;

#############
# Concat Metrics 2023 and What's... into a single JSON lines doc 
#############

cat /tmp/whatsbecon.split.out*.json /tmp/metrics2023.json > spec/beaconspec.jsonl;

