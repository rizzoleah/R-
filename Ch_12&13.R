# 12 Logical vectors 
library(tidyverse)
library(nycflights13)

x <- c(1, 2, 3, 5, 7, 11, 13)
x * 2
#> [1]  2  4  6 10 14 22 26

df <- tibble(x)
df |> 
  mutate(y = x * 2)
#> # A tibble: 7 × 2
#>       x     y
#>   <dbl> <dbl>
#> 1     1     2
#> 2     2     4
#> 3     3     6
#> 4     5    10
#> 5     7    14
#> 6    11    22
#> # ℹ 1 more row

#12.2 Comprarisons

#A very common way to create a logical vector is via a numeric comparison 
# with <, <=, >, >=, !=, and ==

flights |> 
  filter(dep_time > 600 & dep_time < 2000 & abs(arr_delay) < 20)
#> # A tibble: 172,286 × 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      601            600         1      844            850
#> 2  2013     1     1      602            610        -8      812            820
#> 3  2013     1     1      602            605        -3      821            805
#> 4  2013     1     1      606            610        -4      858            910
#> 5  2013     1     1      606            610        -4      837            845
#> 6  2013     1     1      607            607         0      858            915
#> # ℹ 172,280 more rows
#> # ℹ 11 more variables: arr_delay <dbl>, carrier <chr>, flight <int>, …

# It’s useful to know that this is a shortcut and you can explicitly create 
# the underlying logical variables with mutate()
flights |> 
  mutate(
    daytime = dep_time > 600 & dep_time < 2000,
    approx_ontime = abs(arr_delay) < 20,
    .keep = "used"
  )
#> # A tibble: 336,776 × 4
#>   dep_time arr_delay daytime approx_ontime
#>      <int>     <dbl> <lgl>   <lgl>        
#> 1      517        11 FALSE   TRUE         
#> 2      533        20 FALSE   FALSE        
#> 3      542        33 FALSE   FALSE        
#> 4      544       -18 FALSE   TRUE         
#> 5      554       -25 FALSE   FALSE        
#> 6      554        12 FALSE   TRUE         
#> # ℹ 336,770 more rows

flights |> 
  mutate(
    daytime = dep_time > 600 & dep_time < 2000,
    approx_ontime = abs(arr_delay) < 20,
  ) |> 
  filter(daytime & approx_ontime)

# 12.2.1 Floating point comparison
#Beware of using == with numbers
x <- c(1 / 49 * 49, sqrt(2) ^ 2)
x
#> [1] 1 2

#But if you test them for equality, you get FALSE
x == c(1, 2)
#> [1] FALSE FALSE

#We can see the exact values by calling print() with the digits1 argument
print(x, digits = 16)
#> [1] 0.9999999999999999 2.0000000000000004

#One option is to use dplyr::near() which ignores small differences
near(x, c(1, 2))

# 12.2.2 Missing values 
# We don't know how old Mary is
age_mary <- NA

# We don't know how old John is
age_john <- NA

# Are Mary and John the same age?
age_mary == age_john
#> [1] NA
# We don't know!

Instead we’ll need a new tool: is.na()

# 12.2.3 is.na()
#is.na(x) works with any type of vector and returns TRUE for 
#missing values and FALSE for everything else

is.na(c(TRUE, NA, FALSE))
#> [1] FALSE  TRUE FALSE
is.na(c(1, NA, 3))
#> [1] FALSE  TRUE FALSE
is.na(c("a", NA, "b"))
#> [1] FALSE  TRUE FALSE

flights |> 
  filter(is.na(dep_time))

# arrange() usually puts all the missing values at the end 
#but you can override this default by first sorting by is.na()

flights |> 
  filter(month == 1, day == 1) |> 
  arrange(dep_time)

flights |> 
  filter(month == 1, day == 1) |> 
  arrange(desc(is.na(dep_time)), dep_time)

# 12.3 Boolean algebra
#Once you have multiple logical vectors, 
#you can combine them together using Boolean algebra
# & is "and"
# | is "or" 
# ! is "not"
# xor() is exclusive or^2
# Examples:
# df |> filter(!is.na(x)) finds all rows where x is not missing
# df |> filter(x < -10 | x > 0) finds all rows where x is smaller than -10 or bigger than 0

# 12.3.1 Missing values
# df <- tibble(x = c(TRUE, FALSE, NA))

df |> 
  mutate(
    and = x & NA,
    or = x | NA
  )

# 12.3.2 Order of operations
flights |> 
  filter(month == 11 | month == 12)

flights |> 
  mutate(
    nov = month == 11,
    final = nov | 12,
    .keep = "used"
  )

# 12.3.3 %in%
#An easy way to avoid the problem of getting 
# your ==s and |s in the right order is to use %in%

1:12 %in% c(1, 5, 11)
#>  [1]  TRUE FALSE FALSE FALSE  TRUE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE
letters[1:10] %in% c("a", "e", "i", "o", "u")
#>  [1]  TRUE FALSE FALSE FALSE  TRUE FALSE FALSE FALSE  TRUE FALSE

flights |> 
  filter(month %in% c(11, 12))

#Note that %in% obeys different rules for NA to ==, as NA %in% NA is TRUE
c(1, 2, NA) == NA
#> [1] NA NA NA
c(1, 2, NA) %in% NA
#> [1] FALSE FALSE  TRUE

flights |> 
  filter(dep_time %in% c(NA, 0800))

# 12.4 Summaries
#There are two main logical summaries: any() and all()

flights |> 
  group_by(year, month, day) |> 
  summarize(
    all_delayed = all(dep_delay <= 60, na.rm = TRUE),
    any_long_delay = any(arr_delay >= 300, na.rm = TRUE),
    .groups = "drop"
  )

# 12.4.2 Numeric summaries of logical vectors
flights |> 
  group_by(year, month, day) |> 
  summarize(
    proportion_delayed = mean(dep_delay <= 60, na.rm = TRUE),
    count_long_delay = sum(arr_delay >= 300, na.rm = TRUE),
    .groups = "drop"
  )

# 12.4.3 Logical subsetting 
# you can use a logical vector to filter a single variable to a subset of interest

flights |> 
  filter(arr_delay > 0) |> 
  group_by(year, month, day) |> 
  summarize(
    behind = mean(arr_delay),
    n = n(),
    .groups = "drop"
  )

flights |> 
  group_by(year, month, day) |> 
  summarize(
    behind = mean(arr_delay[arr_delay > 0], na.rm = TRUE),
    ahead = mean(arr_delay[arr_delay < 0], na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# 12.5 Conditional tranformations
# 12.5.1 if_else()
#If you want to use one value when a condition is TRUE and another value when it’s FALSE,
# you can use dplyr::if_else()

x <- c(-3:3, NA)
if_else(x > 0, "+ve", "-ve")
#> [1] "-ve" "-ve" "-ve" "-ve" "+ve" "+ve" "+ve" NA

if_else(x > 0, "+ve", "-ve", "???")
#> [1] "-ve" "-ve" "-ve" "-ve" "+ve" "+ve" "+ve" "???"

if_else(x < 0, -x, x)
#> [1]  3  2  1  0  1  2  3 NA
x1 <- c(NA, 1, 2, NA)
y1 <- c(3, NA, 4, 6)
if_else(is.na(x1), y1, x1)
#> [1] 3 1 2 6

if_else(x == 0, "0", if_else(x < 0, "-ve", "+ve"), "???")
#> [1] "-ve" "-ve" "-ve" "0"   "+ve" "+ve" "+ve" "???"

# 12.5.2 case_when()
#dplyr’s case_when() is inspired by SQL’s CASE statement and provides a flexible way of performing different computations for different conditions.

x <- c(-3:3, NA)
case_when(
  x == 0   ~ "0",
  x < 0    ~ "-ve", 
  x > 0    ~ "+ve",
  is.na(x) ~ "???"
)

case_when(
  x < 0 ~ "-ve",
  x > 0 ~ "+ve"
)

#Use .default if you want to create a “default”/catch all value:
case_when(
  x < 0 ~ "-ve",
  x > 0 ~ "+ve",
  .default = "???"
)

#if multiple conditions match, only the first will be used:
case_when(
  x > 0 ~ "+ve",
  x > 2 ~ "big"
)

flights |> 
  mutate(
    status = case_when(
      is.na(arr_delay)      ~ "cancelled",
      arr_delay < -30       ~ "very early",
      arr_delay < -15       ~ "early",
      abs(arr_delay) <= 15  ~ "on time",
      arr_delay < 60        ~ "late",
      arr_delay < Inf       ~ "very late",
    ),
    .keep = "used"
  )

# 12.5.3 Copatible types
# Note that both if_else() and case_when() require compatible types in the output. 
# If they’re not compatible, you’ll see errors like this

if_else(TRUE, "a", 1)
#> Error in `if_else()`:
#> ! Can't combine `true` <character> and `false` <double>.

case_when(
  x < -1 ~ TRUE,  
  x > 0  ~ now()
)
#> Error in `case_when()`:
#> ! Can't combine `..1 (right)` <logical> and `..2 (right)` <datetime<local>>.

# 13 Numbers
library(tidyverse)
library(nycflights13)

# 13.2 Making numbers 
#Use parse_double() when you have numbers that have been written as strings

x <- c("1.2", "5.6", "1e3")
parse_double(x)

#Use parse_number() when the string contains non-numeric text that you want to ignore. 

x <- c("$1,234", "USD 3,513", "59%")
parse_number(x)

# 13. Counts
flights |> count(dest)

#If you want to see the most common values, add sort = TRUE
flights |> count(dest, sort = TRUE)

#if you want to see all the values, you can use |> View() or |> print(n = Inf)

#You can perform the same computation “by hand” with group_by(), summarize() and n()
flights |> 
  group_by(dest) |> 
  summarize(
    n = n(),
    delay = mean(arr_delay, na.rm = TRUE)
  )

#n_distinct(x) counts the number of distinct (unique) values of one or more variables.
flights |> 
  group_by(dest) |> 
  summarize(carriers = n_distinct(carrier)) |> 
  arrange(desc(carriers))

flights |> 
  group_by(tailnum) |> 
  summarize(miles = sum(distance))

flights |> count(tailnum, wt = distance)

#You can count missing values by combining sum() and is.na()
flights |> 
  group_by(dest) |> 
  summarize(n_cancelled = sum(is.na(dep_time))) 

# 13.4 Numeric transformations
# 13.4.1 Arithmetic and recycling rules
x <- c(1, 2, 10, 20)
x / 5
#> [1] 0.2 0.4 2.0 4.0
# is shorthand for
x / c(5, 5, 5, 5)
#> [1] 0.2 0.4 2.0 4.0

#13.4.2 Minimum and maximum
# pmin() when given two or more variables will return the smallest value in each row
# pmax() When given two or more variables will return the largest value in each row
df <- tribble(
  ~x, ~y,
  1,  3,
  5,  2,
  7, NA,
)

df |> 
  mutate(
    min = pmin(x, y, na.rm = TRUE),
    max = pmax(x, y, na.rm = TRUE)
  )

# these are different to the summary functions min() and max() which take multiple observations and return a single value
df |> 
  mutate(
    min = min(x, y, na.rm = TRUE),
    max = max(x, y, na.rm = TRUE)
  )

# 13.4.3 Modular arithmetic
# %/% does integer division and %% computes the remainder
1:10 %/% 3
1:10 %% 3

flights |> 
  mutate(
    hour = sched_dep_time %/% 100,
    minute = sched_dep_time %% 100,
    .keep = "used"
  )

flights |> 
  group_by(hour = sched_dep_time %/% 100) |> 
  summarize(prop_cancelled = mean(is.na(dep_time)), n = n()) |> 
  filter(hour > 1) |> 
  ggplot(aes(x = hour, y = prop_cancelled)) +
  geom_line(color = "grey50") + 
  geom_point(aes(size = n))

# 13.4.4 Logarithms
#you have a choice of three logarithms: log() (the natural log, base e), log2() (base 2), and log10() (base 10). 
# We recommend using log2() or log10()

# 13.4.5 Rounding 
# round(x) to round a number to the nearest integer
round(123.456)

round(123.456, 2)  # two digits
#> [1] 123.46
round(123.456, 1)  # one digit
#> [1] 123.5
round(123.456, -1) # round to nearest ten
#> [1] 120
round(123.456, -2) # round to nearest hundred
#> [1] 100

#round() is paired with floor() which always rounds down and ceiling() which always rounds up
x <- 123.456

floor(x)
ceiling(x)

# 13.4.6 Cutting numbers into ranges
x <- c(1, 2, 5, 10, 15, 20)
cut(x, breaks = c(0, 5, 10, 15, 20))

cut(x, breaks = c(0, 5, 10, 100))

cut(x, 
    breaks = c(0, 5, 10, 15, 20), 
    labels = c("sm", "md", "lg", "xl")
)

y <- c(NA, -10, 5, 10, 30)
cut(y, breaks = c(0, 5, 10, 15, 20))

# 13.4.7 Cumulative and rolling aggregates
#  cumsum(), cumprod(), cummin(), cummax() for running, or cumulative, sums, products, mins and maxes
x <- 1:10
cumsum(x)

# 13.5 General transformations
# 13.5.1 Ranks
# dplyr::min_rank() uses the typical method for dealing with ties, e.g., 1st, 2nd, 2nd, 4th.
x <- c(1, 2, 2, 3, 4, NA)
min_rank(x)

min_rank(desc(x))

df <- tibble(x = x)
df |> 
  mutate(
    row_number = row_number(x),
    dense_rank = dense_rank(x),
    percent_rank = percent_rank(x),
    cume_dist = cume_dist(x)
  )

#row_number() can also be used without any arguments when inside a dplyr verb. 
# In this case, it’ll give the number of the “current” row.
df <- tibble(id = 1:10)

df |> 
  mutate(
    row0 = row_number() - 1,
    three_groups = row0 %% 3,
    three_in_each_group = row0 %/% 3
  )

# 13.5.2 Offsets
# dplyr::lead() and dplyr::lag() allow you to refer to the values just before or just after the “current” value.
x <- c(2, 5, 11, 11, 19, 35)
lag(x)

lead(x)

# x - lag(x) gives you the difference between the current and previous value.
# x == lag(x) tells you when the current value changes.

# 13.5.3 Consecutive identifiers
events <- tibble(
  time = c(0, 1, 2, 3, 5, 10, 12, 15, 17, 19, 20, 27, 28, 30)
)

events <- events |> 
  mutate(
    diff = time - lag(time, default = first(time)),
    has_gap = diff >= 5
  )

events |> mutate(
  group = cumsum(has_gap)
)

df <- tibble(
  x = c("a", "a", "a", "b", "c", "c", "d", "e", "a", "a", "b", "b"),
  y = c(1, 2, 3, 2, 4, 1, 3, 9, 4, 8, 10, 199)
)

df |> 
  group_by(id = consecutive_id(x)) |> 
  slice_head(n = 1)

# 13.6 Numeric summaries
flights |>
  group_by(year, month, day) |>
  summarize(
    mean = mean(dep_delay, na.rm = TRUE),
    median = median(dep_delay, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) |> 
  ggplot(aes(x = mean, y = median)) + 
  geom_abline(slope = 1, intercept = 0, color = "white", linewidth = 2) +
  geom_point()

# 13.6.2 Minimum, maximum, and quantiles
flights |>
  group_by(year, month, day) |>
  summarize(
    max = max(dep_delay, na.rm = TRUE),
    q95 = quantile(dep_delay, 0.95, na.rm = TRUE),
    .groups = "drop"
  )

# 13.6.3 
flights |> 
  group_by(origin, dest) |> 
  summarize(
    distance_iqr = IQR(distance), 
    n = n(),
    .groups = "drop"
  ) |> 
  filter(distance_iqr > 0)

# 13.6.4 Distributions
# check that distributions for subgroups resemble the whole
flights |>
  filter(dep_delay < 120) |> 
  ggplot(aes(x = dep_delay, group = interaction(day, month))) + 
  geom_freqpoly(binwidth = 5, alpha = 1/5)

# 13.6.5 Positions
flights |> 
  group_by(year, month, day) |> 
  summarize(
    first_dep = first(dep_time, na_rm = TRUE), 
    fifth_dep = nth(dep_time, 5, na_rm = TRUE),
    last_dep = last(dep_time, na_rm = TRUE)
  )

flights |> 
  group_by(year, month, day) |> 
  mutate(r = min_rank(sched_dep_time)) |> 
  filter(r %in% c(1, max(r)))

# 13.6.6 With mustate()
# x / sum(x) calculates the proportion of a total.
# (x - mean(x)) / sd(x) computes a Z-score (standardized to mean 0 and sd 1)
# (x - min(x)) / (max(x) - min(x)) standardizes to range [0, 1].
# x / first(x) computes an index based on the first observation.


