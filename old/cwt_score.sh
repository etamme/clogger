#!/bin/bash
logfile="qso.adi"
calls=$(grep CALL "$logfile" | cut -d'>' -f2 | sort)
num_uniq_calls=$(echo "$calls" | uniq | wc -l)
num_calls=$(echo "$calls" | wc -l)
score=$(($num_uniq_calls * $num_calls))

echo "SCORE: $score"
echo ""
echo "UNIQUE CALLS: $num_uniq_calls"
echo "TOTAL CALLS: $num_calls"
echo ""
echo $calls
