# Chapter 16 Factors
# 16.1 Introduction
# Factors are used for categorical variables, variables that have 
# a fixed and known set of possible values.
# They are also useful when you want to display character vectors in a non-alphabetical order.
# We’ll start by motivating why factors are needed for data analysis1 
# and how you can create them with factor().
# We’ll then introduce you to the gss_cat dataset which contains a bunch of 
# categorical variables to experiment with.
# You’ll then use that dataset to practice modifying the order and values of factors, 
# before we finish up with a discussion of ordered factors.

# 16.1.1 Prerequisites
library(tidyverse)

# 16.2 Factor basics
# Imagine that you have a variable that records month:
x1 <- c("Dec", "Apr", "Jan", "Mar")

# Using a string to record this variable has two problems:
# 1. There are only twelve possible months, and there’s nothing saving you from typos:
x2 <- c("Dec", "Apr", "Jam", "Mar")

# 2. It doesn’t sort in a useful way:
sort(x1)

# Fix these issues with a factor
# To create a factor you must start by creating a list of the valid levels
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)

# Then create the factor
y1 <- factor(x1, levels = month_levels)
y1

sort(y1)

# And any values not in the level will be silently converted to NA:
y2 <- factor(x2, levels = month_levels)
y2

# This seems risky, so you might want to use forcats::fct() instead:
y2 <- fct(x2, levels = month_levels)

# If you omit the levels, they’ll be taken from the data in alphabetical order
factor(x1)

# Sorting alphabetically is slightly risky because not every computer will sort strings in the same way.
# So forcats::fct() orders by first appearance
fct(x1)

# If you ever need to access the set of valid levels directly, you can do so with levels():
levels(y2)

# You can also create a factor when reading your data with readr with col_factor():
csv <- "
month,value
Jan,12
Feb,56
Mar,12"

df <- read_csv(csv, col_types = cols(month = col_factor(month_levels)))
df$month

# 16.3 General social survey
gss_cat

# When factors are stored in a tibble, you can’t see their levels so easily.
# One way to view them is with count()
gss_cat |>
  count(race)

# When working with factors, the two most common operations are 
# changing the order of the levels, and 
# changing the values of the levels

# 16.4 Modifying factor order
# It’s often useful to change the order of the factor levels in a visualization.
relig_summary <- gss_cat |>
  group_by(relig) |>
  summarize(
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(relig_summary, aes(x = tvhours, y = relig)) +
  geom_point()

# It is hard to read this plot because there’s no overall pattern.
# We can improve it by reordering the levels of relig using fct_reorder(). fct_reorder() takes three arguments:
# .f, the factor whose levels you want to modify.
# .x, a numeric vector that you want to use to reorder the levels.
# Optionally, .fun, a function that’s used if there are multiple values of .x 
# for each value of .f. The default value is median.
ggplot(relig_summary, aes(x = tvhours, y = fct_reorder(relig, tvhours))) +
  geom_point()

# As you start making more complicated transformations,
# we recommend moving them out of aes() and into a separate mutate() step
relig_summary |>
  mutate(
    relig = fct_reorder(relig, tvhours)
  ) |>
  ggplot(aes(x = tvhours, y = relig)) +
  geom_point()

# What if we create a similar plot looking at how average age varies across reported income level?
rincome_summary <- gss_cat |>
  group_by(rincome) |>
  summarize(
    age = mean(age, na.rm = TRUE),
    n = n()
  )

ggplot(rincome_summary, aes(x = age, y = fct_reorder(rincome, age))) +
  geom_point()

# . Reserve fct_reorder() for factors whose levels are arbitrarily ordered.
# fct_relevel() takes a factor, .f, and then any number of levels that you want to move to the front of the line.
ggplot(rincome_summary, aes(x = age, y = fct_relevel(rincome, "Not applicable"))) +
  geom_point()

# fct_reorder2(.f, .x, .y) reorders the factor .f by the .y values associated with the largest .x values
by_age <- gss_cat |>
  filter(!is.na(age)) |>
  count(age, marital) |>
  group_by(age) |>
  mutate(
    prop = n / sum(n)
  )

ggplot(by_age, aes(x = age, y = prop, color = marital)) +
  geom_line(linewidth = 1) +
  scale_color_brewer(palette = "Set1")

ggplot(by_age, aes(x = age, y = prop, color = fct_reorder2(marital, age, prop))) +
  geom_line(linewidth = 1) +
  scale_color_brewer(palette = "Set1") +
  labs(color = "marital")

# you can use fct_infreq() to order levels in decreasing frequency: this is the simplest type of reordering 
# because it doesn’t need any extra variables
# Combine it with fct_rev() if you want them in increasing frequency so that in the bar 
# plot largest values are on the right, not the left
gss_cat |>
  mutate(marital = marital |> fct_infreq() |> fct_rev()) |>
  ggplot(aes(x = marital)) +
  geom_bar()

# 16.5 Modifying factor levels
# More powerful than changing the orders of the levels is changing their values.
#  fct_recode() allows you to recode, or change, the value of each level
gss_cat |> count(partyid)

# The levels are terse and inconsistent. Let’s tweak them to be longer and use a parallel construction
# the new values go on the left and the old values go on the right\
gss_cat |>
  mutate(
    partyid = fct_recode(partyid,
                         "Republican, strong"    = "Strong republican",
                         "Republican, weak"      = "Not str republican",
                         "Independent, near rep" = "Ind,near rep",
                         "Independent, near dem" = "Ind,near dem",
                         "Democrat, weak"        = "Not str democrat",
                         "Democrat, strong"      = "Strong democrat"
    )
  ) |>
  count(partyid)

# fct_recode() will leave the levels that aren’t explicitly mentioned as is,
# and will warn you if you accidentally refer to a level that doesn’t exist.
# To combine groups, you can assign multiple old levels to the same new level
gss_cat |>
  mutate(
    partyid = fct_recode(partyid,
                         "Republican, strong"    = "Strong republican",
                         "Republican, weak"      = "Not str republican",
                         "Independent, near rep" = "Ind,near rep",
                         "Independent, near dem" = "Ind,near dem",
                         "Democrat, weak"        = "Not str democrat",
                         "Democrat, strong"      = "Strong democrat",
                         "Other"                 = "No answer",
                         "Other"                 = "Don't know",
                         "Other"                 = "Other party"
    )
  )

# if you group together categories that are truly different you will end up with misleading results.
# If you want to collapse a lot of levels, fct_collapse() is a useful variant of fct_recode()
#  For each new variable, you can provide a vector of old levels:
gss_cat |>
  mutate(
    partyid = fct_collapse(partyid,
                           "other" = c("No answer", "Don't know", "Other party"),
                           "rep" = c("Strong republican", "Not str republican"),
                           "ind" = c("Ind,near rep", "Independent", "Ind,near dem"),
                           "dem" = c("Not str democrat", "Strong democrat")
    )
  ) |>
  count(partyid)

# Sometimes you just want to lump together the small groups to make a plot or table simpler. 
# fct_lump_lowfreq() is a simple starting point that progressively lumps the smallest groups
# categories into “Other”, always keeping “Other” as the smallest category.
gss_cat |>
  mutate(relig = fct_lump_lowfreq(relig)) |>
  count(relig)

# To see more details, we can use  fct_lump_n() to specify that we want exactly 10 groups
gss_cat |>
  mutate(relig = fct_lump_n(relig, n = 10)) |>
  count(relig, sort = TRUE)

# 16.6 Ordered factors
# ordered factors imply a strict ordering between levels, 
# but don’t specify anything about the magnitude of the differences between the levels. 
# You use ordered factors when you know there the levels are ranked, but there’s no precise numerical ranking
ordered(c("a", "b", "c"))

# 17 Dates and times
# 17.1 Introductions
# We’ll begin by showing you how to create date-times from various inputs,
# then once you’ve got a date-time, how you can extract components like year, month, and day.
# We’ll then dive into the tricky topic of working with time spans, which come in a variety of flavors depending on what you’re trying to do. 
# We’ll conclude with a brief discussion of the additional challenges posed by time zones.
# 17.1.1 Prerequisites
library(tidyverse)
library(nycflights13)

# 17.2 Creating date/times
# There are three types of date/time data that refer to an instant in time:
# A date. Tibbles print this as <date>.
# A time within a day. Tibbles print this as <time>.
# A date-time is a date plus a time: it uniquely identifies an instant in time 
# (typically to the nearest second). Tibbles print this as <dttm>. Base R calls these POSIXct, but that doesn’t exactly trip off the tongue.
# To get the current date or date-time you can use today() or now():
today()
now()

#the following sections describe the four ways you’re likely to create a date/time:
# While reading a file with readr.
# From a string.
# From individual date-time components.
# From an existing date/time object.

# 17.2.1 During import
# If your CSV contains an ISO8601 date or date-time, you don’t need to do anything; readr will automatically recognize it
csv <- "
  date,datetime
  2022-01-02,2022-01-02 05:12
"
read_csv(csv)

# ISO8601 is an international standard2 for writing dates where the components of a date are 
# organized from biggest to smallest separated by -
# For other date-time formats, you’ll need to use col_types plus col_date() or col_datetime() along with a date-time format.
csv <- "
  date
  01/02/15
"

read_csv(csv, col_types = cols(date = col_date("%m/%d/%y")))

read_csv(csv, col_types = cols(date = col_date("%d/%m/%y")))

read_csv(csv, col_types = cols(date = col_date("%y/%m/%d")))

# Note that no matter how you specify the date format, it’s always displayed the same way once you get it into R.
# If you are using %b or %B and working with non-English dates, you’ll also need to provide a locale()

# 17.2.2 From strings
# An alternative approach is to use lubridate’s helpers which attempt to automatically determine
# the format once you specify the order of the component. 
ymd("2017-01-31")
#> [1] "2017-01-31"
mdy("January 31st, 2017")
#> [1] "2017-01-31"
dmy("31-Jan-2017")
#> [1] "2017-01-31"

# To create a date-time, add an underscore and one or more of “h”, “m”, and “s” to the name of the parsing function
ymd_hms("2017-01-31 20:11:59")
#> [1] "2017-01-31 20:11:59 UTC"
mdy_hm("01/31/2017 08:01")
#> [1] "2017-01-31 08:01:00 UTC"

# You can also force the creation of a date-time from a date by supplying a timezone:
ymd("2017-01-31", tz = "UTC")
#> [1] "2017-01-31 UTC"

# 17.2.3 From individual components
# Instead of a single string, sometimes you’ll have the individual components of the date-time spread across multiple columns.
flights |> 
  select(year, month, day, hour, minute)

# To create a date/time from this sort of input, use make_date() for dates, or make_datetime() for date-times
flights |> 
  select(year, month, day, hour, minute) |> 
  mutate(departure = make_datetime(year, month, day, hour, minute))

make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights |> 
  filter(!is.na(dep_time), !is.na(arr_time)) |> 
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) |> 
  select(origin, dest, ends_with("delay"), ends_with("time"))

flights_dt

# With this data, we can visualize the distribution of departure times across the year
flights_dt |> 
  ggplot(aes(x = dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 seconds = 1 day

# Or within a single day
flights_dt |> 
  filter(dep_time < ymd(20130102)) |> 
  ggplot(aes(x = dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 s = 10 minutes

# 17.2.4 From other types
# You may want to switch between a date-time and a date.
# That’s the job of as_datetime() and as_date():
as_datetime(today())
#> [1] "2025-04-14 UTC"
as_date(now())
#> [1] "2025-04-14"

# Sometimes you’ll get date/times as numeric offsets from the “Unix Epoch”, 1970-01-01. 
# If the offset is in seconds, use as_datetime(); if it’s in days, use as_date().
as_datetime(60 * 60 * 10)
#> [1] "1970-01-01 10:00:00 UTC"
as_date(365 * 10 + 2)
#> [1] "1980-01-01"

# 17.3 Date-time components
# 17.3.1 Getting components
# You can pull out individual parts of the date with the accessor functions 
# year(), month(), mday() (day of the month), yday() (day of the year), wday() (day of the week), hour(), minute(), and second().
# opposites on make_datetime()
datetime <- ymd_hms("2026-07-08 12:34:56")

year(datetime)
#> [1] 2026
month(datetime)
#> [1] 7
mday(datetime)
#> [1] 8

yday(datetime)
#> [1] 189
wday(datetime)
#> [1] 4

# For month() and wday() you can set label = TRUE to return the abbreviated name of the month or day of the week.
# Set abbr = FALSE to return the full name.
month(datetime, label = TRUE)
#> [1] Jul
#> 12 Levels: Jan < Feb < Mar < Apr < May < Jun < Jul < Aug < Sep < ... < Dec
wday(datetime, label = TRUE, abbr = FALSE)
#> [1] Wednesday
#> 7 Levels: Sunday < Monday < Tuesday < Wednesday < Thursday < ... < Saturday

# We can use wday() to see that more flights depart during the week than on the weekend
flights_dt |> 
  mutate(wday = wday(dep_time, label = TRUE)) |> 
  ggplot(aes(x = wday)) +
  geom_bar()

# We can also look at the average departure delay by minute within the hour.
flights_dt |> 
  mutate(minute = minute(dep_time)) |> 
  group_by(minute) |> 
  summarize(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) |> 
  ggplot(aes(x = minute, y = avg_delay)) +
  geom_line()

# if we look at the scheduled departure time we don’t see such a strong pattern
sched_dep <- flights_dt |> 
  mutate(minute = minute(sched_dep_time)) |> 
  group_by(minute) |> 
  summarize(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()
  )

ggplot(sched_dep, aes(x = minute, y = avg_delay)) +
  geom_line()

# 17.3.2 Rounding 
# An alternative approach to plotting individual components 
# is to round the date to a nearby unit of time, with floor_date(), round_date(), and ceiling_date().
#  Each function takes a vector of dates to adjust and then the name of the unit to round down (floor), round up (ceiling), or round to
flights_dt |> 
  count(week = floor_date(dep_time, "week")) |> 
  ggplot(aes(x = week, y = n)) +
  geom_line() + 
  geom_point()

# You can use rounding to show the distribution of flights across the course of a day by computing the difference between
# dep_time and the earliest instant of that day
flights_dt |> 
  mutate(dep_hour = dep_time - floor_date(dep_time, "day")) |> 
  ggplot(aes(x = dep_hour)) +
  geom_freqpoly(binwidth = 60 * 30)

# We can convert that to an hms object to get a more useful x-axis:
flights_dt |> 
  mutate(dep_hour = hms::as_hms(dep_time - floor_date(dep_time, "day"))) |> 
  ggplot(aes(x = dep_hour)) +
  geom_freqpoly(binwidth = 60 * 30)

# 17.3.3 Modifying components
# You can also use each accessor function to modify the components of a date/time
# This doesn’t come up much in data analysis, but can be useful when cleaning data that has clearly incorrect dates
(datetime <- ymd_hms("2026-07-08 12:34:56"))
#> [1] "2026-07-08 12:34:56 UTC"

year(datetime) <- 2030
datetime
#> [1] "2030-07-08 12:34:56 UTC"
month(datetime) <- 01
datetime
#> [1] "2030-01-08 12:34:56 UTC"
hour(datetime) <- hour(datetime) + 1
datetime
#> [1] "2030-01-08 13:34:56 UTC"

# you can create a new date-time with update()
update(datetime, year = 2030, month = 2, mday = 2, hour = 2)

# If values are too big, they will roll-over
update(ymd("2023-02-01"), mday = 30)
#> [1] "2023-03-02"
update(ymd("2023-02-01"), hour = 400)
#> [1] "2023-02-17 16:00:00 UTC"

# 17.4 Time spans
# Next you’ll learn about how arithmetic with dates works, including subtraction, addition, and division
# Duration, which represent an exact number of seconds.
# Periods, which represent human units like weeks and months.
# Intervals, which represent a starting and ending point.

# 17.4.1 Duration
# In R, when you subtract two dates, you get a difftime object
h_age <- today() - ymd("1979-10-14")
h_age

# A difftime class object records a time span of seconds, minutes, hours, days, or weeks. 
as.duration(h_age)

# Duration come with a bunch of convenient constructors
dseconds(15)
#> [1] "15s"
dminutes(10)
#> [1] "600s (~10 minutes)"
dhours(c(12, 24))
#> [1] "43200s (~12 hours)" "86400s (~1 days)"
ddays(0:5)
#> [1] "0s"                "86400s (~1 days)"  "172800s (~2 days)"
#> [4] "259200s (~3 days)" "345600s (~4 days)" "432000s (~5 days)"
dweeks(3)
#> [1] "1814400s (~3 weeks)"
dyears(1)
#> [1] "31557600s (~1 years)"

# duration always record the time span in seconds
# There’s no way to convert a month to a duration, because there’s just too much variation
# You can add and multiply durations
2 * dyears(1)
#> [1] "63115200s (~2 years)"
dyears(1) + dweeks(12) + dhours(15)
#> [1] "38869200s (~1.23 years)"

# You can add and subtract durations to and from days
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)

#  because durations represent an exact number of seconds, sometimes you might get an unexpected result
one_am <- ymd_hms("2026-03-08 01:00:00", tz = "America/New_York")

one_am
#> [1] "2026-03-08 01:00:00 EST"
one_am + ddays(1)
#> [1] "2026-03-09 02:00:00 EDT"

# 17.4.2 Periods
# Periods are time spans but don’t have a fixed length in seconds, instead they work with “human” times, like days and months.
one_am
#> [1] "2026-03-08 01:00:00 EST"
one_am + days(1)
#> [1] "2026-03-09 01:00:00 EDT"

# Like durations, periods can be created with a number of friendly constructor functions.
hours(c(12, 24))
#> [1] "12H 0M 0S" "24H 0M 0S"
days(7)
#> [1] "7d 0H 0M 0S"
months(1:6)
#> [1] "1m 0d 0H 0M 0S" "2m 0d 0H 0M 0S" "3m 0d 0H 0M 0S" "4m 0d 0H 0M 0S"
#> [5] "5m 0d 0H 0M 0S" "6m 0d 0H 0M 0S"

# you can add multiple periods
10 * (months(6) + days(1))
#> [1] "60m 10d 0H 0M 0S"
days(50) + hours(25) + minutes(2)
#> [1] "50d 25H 2M 0S"

# And of course, add them to dates. Compared to durations, periods are more likely to do what you expect
# A leap year
ymd("2024-01-01") + dyears(1)
#> [1] "2024-12-31 06:00:00 UTC"
ymd("2024-01-01") + years(1)
#> [1] "2025-01-01"

# Daylight saving time
one_am + ddays(1)
#> [1] "2026-03-09 02:00:00 EDT"
one_am + days(1)
#> [1] "2026-03-09 01:00:00 EDT"

# Let’s use periods to fix an oddity related to our flight dates.
flights_dt |> 
  filter(arr_time < dep_time) 

# We used the same date information for both the departure and the arrival times, but these flights arrived on the following day
# We can fix this by adding days(1) to the arrival time of each overnight flight
flights_dt <- flights_dt |> 
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight),
    sched_arr_time = sched_arr_time + days(overnight)
  )

# now all of our flights obey the laws of physics
flights_dt |> 
  filter(arr_time < dep_time) 

# 17.4.3 Intervals
years(1) / days(1)

# for more accurate measurement use interval 
# An interval is a pair of starting and ending date times, or you can think of it as a duration with a starting point.
# You can create an interval by writing start %--% end
y2023 <- ymd("2023-01-01") %--% ymd("2024-01-01")
y2024 <- ymd("2024-01-01") %--% ymd("2025-01-01")

y2023
#> [1] 2023-01-01 UTC--2024-01-01 UTC
y2024
#> [1] 2024-01-01 UTC--2025-01-01 UTC

# You could then divide it by days() to find out how many days fit in the year
y2023 / days(1)
#> [1] 365
y2024 / days(1)
#> [1] 366

# 17.5 Time zones
# You can find out what R thinks your current time zone is with Sys.timezone()
Sys.timezone()

# And see the complete list of all time zone names with OlsonNames()
length(OlsonNames())
#> [1] 598
head(OlsonNames())

# In R, the time zone is an attribute of the date-time that only controls printing
x1 <- ymd_hms("2024-06-01 12:00:00", tz = "America/New_York")
x1
#> [1] "2024-06-01 12:00:00 EDT"

x2 <- ymd_hms("2024-06-01 18:00:00", tz = "Europe/Copenhagen")
x2
#> [1] "2024-06-01 18:00:00 CEST"

x3 <- ymd_hms("2024-06-02 04:00:00", tz = "Pacific/Auckland")
x3
#> [1] "2024-06-02 04:00:00 NZST"

# You can verify that they’re the same time using subtraction
x1 - x2
#> Time difference of 0 secs
x1 - x3
#> Time difference of 0 secs

# Operations that combine date-times, like c(), will often drop the time zone
# In that case, the date-times will display in the time zone of the first element
x4 <- c(x1, x2, x3)
x4

# You can change the time zone in two ways
# Keep the instant in time the same, and change how it’s displayed. Use this when the instant is correct, but you want a more natural display
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a
x4a - x4

# Change the underlying instant in time. Use this when you have an instant that has been labelled with the incorrect time zone, and you need to fix it
x4b <- force_tz(x4, tzone = "Australia/Lord_Howe")
x4b
x4b - x4

