library(tidyverse)
library(lubridate)

########################################
# READ AND TRANSFORM THE DATA
########################################

# read one month of data
trips <- read_csv('201402-citibike-tripdata.csv')

# replace spaces in column names with underscores
names(trips) <- gsub(' ', '_', names(trips))

# convert dates strings to dates
# trips <- mutate(trips, starttime = mdy_hms(starttime), stoptime = mdy_hms(stoptime))

# recode gender as a factor 0->"Unknown", 1->"Male", 2->"Female"
trips <- mutate(trips, gender = factor(gender, levels=c(0,1,2), labels = c("Unknown","Male","Female")))


########################################
# YOUR SOLUTIONS BELOW
########################################

# count the number of trips (= rows in the data frame)
nrow(trips) # 224736

# find the earliest and latest birth years (see help for max and min to deal with NAs)
min(as.numeric(trips$birth_year),
    na.rm = TRUE) # 1899

max(as.numeric(trips$birth_year),
    na.rm = TRUE) # 1997

# use filter and grepl to find all trips that either start or end on broadway
filter(trips, grepl('Broadway', start_station_name,ignore.case = TRUE) | grepl('Broadway', end_station_name,ignore.case = TRUE))

# do the same, but find all trips that both start and end on broadway
filter(trips, grepl('Broadway', start_station_name,ignore.case = TRUE) & grepl('Broadway', end_station_name,ignore.case = TRUE))

# find all unique station names
unique(c(trips$start_station_name, trips$end_station_name))

# count the number of trips by gender
# first create "grouped data frame" by gender
trips_by_gender <- group_by(trips, gender)
summarize(trips_by_gender, count = n())

# compute the average trip time by gender
summarize(trips_by_gender,
          average_trip_time = mean(tripduration))
# comment on whether there's a (statistically) significant difference


# find the 10 most frequent station-to-station trips
trips_by_station_to_station <- group_by(trips, start_station_name, end_station_name)

summarize(trips_by_station_to_station, count = n()) %>%
  arrange(desc(count)) %>%
  head(10)


# find the top 3 end stations for trips starting from each start station
select((trips_by_station_to_station), start_station_name, end_station_name) %>%
  summarize(count = n()) %>% filter(rank(desc(count)) < 4) %>%
  arrange(start_station_name, desc(count))

# find the top 3 most common station-to-station trips by gender
group_by(trips, start_station_name, end_station_name, gender) %>%
  summarize(count = n()) %>%
  group_by(gender) %>%
  filter(rank(desc(count)) < 4) %>%
  arrange(gender, desc(count))

# find the day with the most trips
# tip: first add a column for year/month/day without time of day (use as.Date or floor_date from the lubridate package)
trips_with_ymd <- mutate(trips, ymd = as.Date(starttime))
summarize(group_by(trips_with_ymd, ymd), count = n()) %>%
  arrange(desc(count)) %>%
  head(1) # 2014-02-02 13816


# compute the average number of trips taken during each of the 24 hours of the day across the entire month
trips %>%
  mutate(ymd = as.Date(starttime), hour_of_day = hour(starttime)) %>%
  group_by(ymd, hour_of_day) %>%
  summarize(count = n()) %>%
  group_by(hour_of_day) %>%
  summarize(average_trips_per_hour = mean(count))

# what time(s) of day tend to be peak hour(s)?
trips %>%
  mutate(ymd = as.Date(starttime), hour_of_day = hour(starttime)) %>%
  group_by(ymd, hour_of_day) %>%
  summarize(count = n()) %>%
  group_by(hour_of_day) %>%
  summarize(average_trips_per_hour = mean(count)) %>%
  arrange(desc(average_trips_per_hour)) %>% head # from 2 - 6 PM, and 8 AM