#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations - 329
cut -d, -f4 201402-citibike-tripdata.csv | tail -n +2  | sort | uniq

# count the number of unique bikes - 5699
cut -d, -f12 201402-citibike-tripdata.csv | tail -n +2  | sort | uniq | wc -l

# count the number of trips per day
cut -d, -f2 201402-citibike-tripdata.csv | tail -n +2 | cut -d' ' -f1 | sort | uniq -c

# find the day with the most rides - 13816 "2014-02-02

cut -d, -f2 201402-citibike-tripdata.csv | tail -n +2 | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -1

# find the day with the fewest rides -     876 "2014-02-13

cut -d, -f2 201402-citibike-tripdata.csv | tail -n +2 | cut -d' ' -f1 | sort | uniq -c | sort -n | head -1

# find the id of the bike with the most rides -  130 "20837"
cut -d, -f12 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c | sort -n | tail -1

# count the number of rides by gender and birth year
cut -d, -f15,14 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...) - 90549
cut -d, -f5 201402-citibike-tripdata.csv | grep '.*[0-9].*&.* [0-9].*' | sort

# compute the average trip duration - 874.52
cut -d, -f1 201402-citibike-tripdata.csv | tail -n +2 |  tr '"' ' ' | awk -F, '{total += $1; n++} END {print total / n}'