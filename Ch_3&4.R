# 3.1.1 Prerequisites

# library(nycflights13)
# library(tidyverse)
#  ── Attaching core tidyverse packages ───────────────────── tidyverse 2.0.0 ──
#  ✔ dplyr     1.1.4     ✔ readr     2.1.5
#  ✔ forcats   1.0.0     ✔ stringr   1.5.1
#  ✔ ggplot2   3.5.1     ✔ tibble    3.2.1
#  ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
#  ✔ purrr     1.0.4
#  ── Conflicts ─────────────────────────────────────── tidyverse_conflicts() ──
#  ✖ dplyr::filter() masks stats::filter()
#  ✖ dplyr::lag()    masks stats::lag()
#  ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errr


# 3.1.2 nycflights13

View(flights)

# 3.1.3 dplyr basics

flights |>
  filter(dest == "IAH") |> 
  group_by(year, month, day) |> 
  summarize(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )

# 3.2.1 filter()

flights |> 
  filter(dep_delay > 120)


#review flights
print(flights, width = Inf)
#notice no change to flights after filter
#the filtered data frame is not assigned to a new variable

# Operations 
# > (greater than)
# >= (greater than or equal to)
# < (less than)
# <= (less than or equal to)
# == (equal to)

# A shorter way to select flights that departed in January or February
flights |> 
  filter(month %in% c(1, 2))

jan1 <- flights |> 
  filter(month == 1 & day == 1)

flights |> 
  filter(month == 1 | month == 2)

flights |> 
  filter(month == 1 | 2)

# 3.2.3 arrange()

flights |> 
  arrange(year, month, day, dep_time)

flights |> 
  arrange(desc(dep_delay))

# 3.2.4 distint()

# Remove duplicate rows, if any
flights |> 
  distinct()

# Find all unique origin and destination pairs
flights |> 
  distinct(origin, dest)

# To keep other columns when filtering unique rows .keep_all = TRUE
flights |> 
  distinct(origin, dest, .keep_all = TRUE)

flights |>
  count(origin, dest, sort = TRUE)

# 3.3 Columns 
# 3.3.1 mutate()

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  )

# mutate() adds new columns to the right-hand side of data set

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1
  )

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .after = day
  )

flights |> 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )

# 3.3.2 select ()

#Select columns by name:
flights |> 
  select(year, month, day)

#Select all columns between year and day (inclusive):
flights |> 
  select(year:day)

#Select all columns except those from year to day (inclusive):
flights |> 
  select(!year:day)

#Select all columns that are characters:
flights |> 
  select(where(is.character))

#You can rename variables as you select() them by using =.
#The new name appears on the left-hand side of the =, 
#and the old variable appears on the right-hand side:
flights |> 
  select(tail_num = tailnum)

# 3.3.3 rename()

#If you want to keep all the existing variables and just want to rename a few, 
#you can use rename() instead of select():
flights |> 
  rename(tail_num = tailnum)

# 3.3.4 relocate()

#Use relocate() to move variables around.
flights |> 
  relocate(time_hour, air_time)

# to specify where to out them use .before .after
flights |> 
  relocate(year:dep_time, .after = time_hour)
flights |> 
  relocate(starts_with("arr"), .before = dep_time)

# 3.4 The Pipe

flights |> 
  filter(dest == "IAH") |> 
  mutate(speed = distance / air_time * 60) |> 
  select(year:day, dep_time, carrier, flight, speed) |> 
  arrange(desc(speed))
# verbs come at the start of each line

# without Pipe we can nest each function call:
arrange(
  select(
    mutate(
      filter(
        flights, 
        dest == "IAH"
      ),
      speed = distance / air_time * 60
    ),
    year:day, dep_time, carrier, flight, speed
  ),
  desc(speed)
)

# without Pipe we can use a bunch of intermediate objects
flights1 <- filter(flights, dest == "IAH")
flights2 <- mutate(flights1, speed = distance / air_time * 60)
flights3 <- select(flights2, year:day, dep_time, carrier, flight, speed)
arrange(flights3, desc(speed))

# 3.5 Groups
# 3.5.1 group_by()

#Use group_by() to divide your dataset into groups meaningful for your analysis:
flights |> 
  group_by(month)

# 3.5.2 summarize()
# used to calculate a single summary statistic, 
# reduces the data frame to have a single row for each group.

flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay)
  )

# use na_rm = TRUE to ignore missing values
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

# n() returns the number of rows in each group
flights |> 
  group_by(month) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    n = n()
  )

# slice_ functions 
# there are five slice functions
# df |> slice_head(n = 1) takes the first row from each group.
# df |> slice_tail(n = 1) takes the last row in each group.
# df |> slice_min(x, n = 1) takes the row with the smallest value of column x.
# df |> slice_max(x, n = 1) takes the row with the largest value of column x.
# df |> slice_sample(n = 1) takes one random row.
# n can vary to select more than one row
# EX: prop = 0.1 to select 10%

flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n = 1) |>
  relocate(dest)

# If you want exactly one row per group you can set with_ties = FALSE.

# 3.5.4 Grouping by multiple variables

daily <- flights |>  
  group_by(year, month, day)
daily

daily_flights <- daily |> 
  summarize(n = n())

daily_flights <- daily |> 
  summarize(
    n = n(), 
    .groups = "drop_last"
  )

# 3.5.5. Ungrouping 
# Use to remove grouping from a data frame without using summarize()

daily |> 
  ungroup()

daily |> 
  ungroup() |>
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE), 
    flights = n()
  )

#.5.6 .by
# Use to group within a single operation

flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = month
  )

# Group by multiple variables

flights |> 
  summarize(
    delay = mean(dep_delay, na.rm = TRUE), 
    n = n(),
    .by = c(origin, dest)
  )

# 4.1 Names

# Strive for:
short_flights <- flights |> filter(air_time < 60)

# Avoid:
SHORTFLIGHTS <- flights |> filter(air_time < 60)

# 4.2 Spaces

# Strive for
z <- (a + b)^2 / d

# Avoid
z<-( a + b ) ^ 2/d

# Strive for
mean(x, na.rm = TRUE)

# Avoid
mean (x ,na.rm=TRUE)

# Adding extra spaces is okay to make more visually apealing

flights |> 
  mutate(
    speed      = distance / air_time,
    dep_hour   = dep_time %/% 100,
    dep_minute = dep_time %%  100
  )

# 4.3 Pipes
# Pipes should always have space before it 

# Strive for 
flights |>  
  filter(!is.na(arr_delay), !is.na(tailnum)) |> 
  count(dest)

# Avoid
flights|>filter(!is.na(arr_delay), !is.na(tailnum))|>count(dest)

# 4.4 ggplot2
# treat + the same as |>

flights |> 
  group_by(month) |> 
  summarize(
    delay = mean(arr_delay, na.rm = TRUE)
  ) |> 
  ggplot(aes(x = month, y = delay)) +
  geom_point() + 
  geom_line()

# If you can not fit all of the arguments on a single line
# put each argument on its own line.

flights |> 
  group_by(dest) |> 
  summarize(
    distance = mean(distance),
    speed = mean(distance / air_time, na.rm = TRUE)
  ) |> 
  ggplot(aes(x = distance, y = speed)) +
  geom_smooth(
    method = "loess",
    span = 0.5,
    se = FALSE, 
    color = "white", 
    linewidth = 4
  ) +
  geom_point()

# 4.5 Sectioning comments

# As your scripts get longer, you can use sectioning comments to break up your file into manageable pieces

# Load data --------------------------------------

# Plot data --------------------------------------

View(flights_furthest)
flights |>
  mutate(expected_dep_delay = dep_time - sched_dep_time) |>
  select(dep_time, sched_dep_time, dep_delay, expected_dep_delay) |>
  head()
flights |> 
  group_by(carrier) |> 
  summarize(avg_arr_delay = mean(arr_delay, na.rm = TRUE), 
            avg_dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  arrange(desc(avg_arr_delay))
flights |> 
  group_by(dest) |> 
  slice_max(dep_delay, n = 1, with_ties = FALSE)
library(ggplot2)
library(dplyr)

flights |> 
  mutate(hour = sched_dep_time %/% 100) |>  # Extract scheduled departure hour
  group_by(hour) |> 
  summarize(avg_dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  ggplot(aes(x = hour, y = avg_dep_delay)) +
  geom_line(color = "blue") +
  geom_point() +
  labs(title = "Average Departure Delay by Hour",
       x = "Hour of the Day",
       y = "Average Departure Delay (minutes)") +
  theme_minimal()

flights |> 
  slice_min(dep_delay, n = -5)


















