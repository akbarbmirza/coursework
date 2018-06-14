########################################
# load libraries
########################################

# load some packages that we'll need
library(lubridate)
library(tidyverse)
library(scales)
library(ggthemes)

# be picky about white backgrounds on our plots
theme_set(theme_bw())

# load RData file output by load_trips.R
load('trips.RData')


########################################
# plot trip data
########################################

# plot the distribution of trip times across all rides

filter(trips, tripduration < quantile(tripduration, 0.99)) %>% # throwing away top 1% of outliers
  ggplot(aes(x = tripduration / 60)) +
  geom_histogram() +
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma) +
  xlab('Trip Times') +
  ylab('# of Riders')

# plot the distribution of trip times by rider type
filter(trips, tripduration < quantile(tripduration, 0.99)) %>% # throwing away top 1% of outliers
  ggplot(aes(x = tripduration / 60)) +
  geom_histogram() +
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma) +
  xlab('Trip Times by Rider Type ') +
  ylab('# of Riders') +
  facet_wrap(~ usertype, ncol = 1, scale = "free_y")

# plot the total number of trips over each day
trips_per_day <- trips %>% group_by(ymd) %>% summarize(count = n())

ggplot(trips_per_day, aes(x = ymd, y = count)) +
  geom_line() +
  scale_y_continuous(label = comma) +
  xlab('Days of the Year') +
  ylab('Number of Trips')

# plot the total number of trips (on the y axis) by age (on the x axis) and gender (indicated with color)
trips_per_age <- trips %>%
  mutate(age = year(ymd) - birth_year) %>%
  group_by(age, gender) %>%
  summarize(count = n())

ggplot(trips_per_age, aes(x = age, y = count)) +
  scale_y_continuous(label = comma) +
  geom_point(mapping = aes(color = gender))

# plot the ratio of male to female trips (on the y axis) by age (on the x axis)
# hint: use the spread() function to reshape things to make it easier to compute this ratio

trips_per_age_and_gender <- trips %>%
  mutate(age = 2014 - birth_year) %>%
  filter(age < 65) %>%
  group_by(age, gender) %>%
  summarize(count = n()) %>%
  spread(gender, count)

# alt solution
# trips_per_age_and_gender <- trips %>%
#   +     mutate(age = 2014 - birth_year) %>%
#   +     filter(age < 65) %>%
#   +     group_by(age, gender) %>%
#   +     summarize(count = n()) %>%
#   +     group_by(age) %>%
#   +     filter(gender != "Unknown") %>%
#   +     summarise(ratio = first(count) / last(count))

ggplot(trips_per_age_and_gender, aes(x = age, y = Male / Female)) +
  geom_point() +
  geom_smooth() +
  xlab("Rider Age") +
  ylab("Male to Female Ratio")

########################################
# plot weather data
########################################
# plot the minimum temperature (on the y axis) over each day (on the x axis)
ggplot(weather, aes(x = ymd, y = tmin)) +
  geom_point() +
  xlab("Day of the Year") +
  ylab("Minimum Temperature")

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)
# hint: try using the gather() function for this to reshape things before plotting
weather %>% gather("temp_type", "temp_val", "tmin", "tmax") %>%
  ggplot(aes(x = ymd, y = temp_val, color = temp_type)) +
  geom_point()

########################################
# plot trip and weather data
########################################

# join trips and weather
trips_with_weather <- inner_join(trips, weather, by="ymd")

# plot the number of trips as a function of the minimum temperature, where each point represents a day
# you'll need to summarize the trips and join to the weather data to do this
trips %>% group_by(ymd) %>% summarize(count = n()) %>%
  inner_join(weather) %>%
  ggplot(aes(x = tmin, y = count)) +
  geom_point()

# repeat this, splitting results by whether there was substantial precipitation or not
# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this
weather %>% mutate(sub_prcp = prcp >= 2 | snow >= 2)

# add a smoothed fit on top of the previous plot, using geom_smooth
trips %>% group_by(ymd) %>% summarize(count = n()) %>%
  inner_join(weather) %>%
  ggplot(aes(x = tmin, y = count)) +
  geom_point() +
  geom_smooth()

# compute the average number of trips and standard deviation in number of trips by hour of the day
# hint: use the hour() function from the lubridate package
trips %>% mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(num_trips = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(num_trips), sd = sd(num_trips))

# plot the above
trips %>% mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(num_trips = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(num_trips), sd = sd(num_trips)) %>%
  ggplot(aes(x = hour, y = avg)) +
  geom_line() + 
  geom_ribbon(aes(ymin = avg - sd, ymax = avg + sd), alpha = 0.2)

# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days
# hint: use the wday() function from the lubridate package
trips %>% mutate(day = wday(starttime, label = TRUE), hour = hour(starttime)) %>%
  group_by(ymd, day, hour) %>%
  summarize(num_trips = n()) %>%
  group_by(hour, day) %>%
  summarize(avg = mean(num_trips), sd = sd(num_trips)) %>%
  ggplot(aes(x = hour, y = avg)) +
  geom_line() +
  geom_ribbon(aes(ymin = avg - sd, ymax = avg + sd), alpha = 0.2) +
  facet_wrap(~ day)
