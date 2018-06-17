################################################################################
# Chapter 9 Exercises
################################################################################

# p.151
################################################################################
# Exercise 2 
# Compute the rate for table2, and table4a + table4b. You will need to perform four operations:
#   
# 1. Extract the number of TB cases per country per year.
# 2. Extract the matching population per country per year.
# 3. Divide cases by population, and multiply by 10000.
# 4. Store back in the appropriate place.
# 5. Which representation is easiest to work with? Which is hardest? Why?

# table2
t2_tidy <- table2 %>% spread(type, count) %>%
  mutate(rate = cases / population)

# table4
t4_cases <- table4a %>% gather(year, cases, 2:3)
t4_population <- table4b %>% gather(year, population, 2:3)
t4_tidy <- t4_cases %>% inner_join(t4_population) %>%
  mutate(rate = cases / population)

# p.154
################################################################################

# Exercise 1
# Why are gather() and spread() not perfectly symmetrical?
# Carefully consider the following example:
#   
#   stocks <- tibble(
#     year   = c(2015, 2015, 2016, 2016),
#     half  = c(   1,    2,     1,    2),
#     return = c(1.88, 0.59, 0.92, 0.17)
#   )
#   stocks %>% 
#   spread(year, return) %>% 
#   gather("year", "return", `2015`:`2016`)
#   (Hint: look at the variable types and think about column names.)
# 
# Both spread() and gather() have a convert argument. What does it do?

# Exercise 3