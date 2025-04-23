# 18 Missing values
#18.1.1 Prerequisites 
library(tidyverse)

# 18.2 Explicit missing values
# 18.2.1 Last observation carried forward
# A common use for missing values is as a data entry convenience
# When data is entered by hand, missing values sometimes indicate that the value 
# in the previous row has been repeated (or carried forward)
treatment <- tribble(
  ~person,           ~treatment, ~response,
  "Derrick Whitmore", 1,         7,
  NA,                 2,         10,
  NA,                 3,         NA,
  "Katherine Burke",  1,         4
)

# You can fill in these missing values with tidyr::fill()
# It works like select(), taking a set of columns
treatment |>
  fill(everything())

# This treatment is sometimes called “last observation carried forward”, or locf for short.

# 18.2.2 Fixed values
# Some times missing values represent some fixed and known value, most commonly 0
# You can use dplyr::coalesce() to replace them
x <- c(1, 4, 5, 7, NA)
coalesce(x, 0)

# Sometimes you’ll hit the opposite problem where some concrete value actually represents a missing value
#  you can use dplyr::na_if() to handle this problem
x <- c(1, 4, 5, 7, -99)
na_if(x, -99)

# 18.2.3 NaN
# NaN or not a number is a special tyoe of missing value
x <- c(NA, NaN)
x * 10

x == 1

is.na(x)

# In the rare case you need to distinguish an NA from a NaN, you can use is.nan(x)
# You’ll generally encounter a NaN when you perform a mathematical operation that has an indeterminate result
0 / 0 

0 * Inf

Inf - Inf

sqrt(-1)

# 18.3 Implicit missing values 
# explicitly missing, i.e. you can see an NA in your data
# But missing values can also be implicitly missing,
# if an entire row of data is simply absent from the data
stocks <- tibble(
  year  = c(2020, 2020, 2020, 2020, 2021, 2021, 2021),
  qtr   = c(   1,    2,    3,    4,    2,    3,    4),
  price = c(1.88, 0.59, 0.35,   NA, 0.92, 0.17, 2.66)
)

# This dataset has two missing observations:
# The price in the fourth quarter of 2020 is explicitly missing, because its value is NA.
# The price for the first quarter of 2021 is implicitly missing, because it simply does not appear in the dataset.

# Sometimes you want to make implicit missings explicit in order to have something physical to work with
# In other cases, explicit missings are forced upon you by the structure of the data and you want to get rid of them

# 18.3.1 Pivoting
# Making data wider can make implicit missing values explicit because every combination of the rows and new columns must have some value.
stocks |>
  pivot_wider(
    names_from = qtr, 
    values_from = price
  )

# By default, making data longer preserves explicit missing values, but if they are structurally missing values that only exist 
# because the data is not tidy, you can drop them (make them implicit) by setting values_drop_na = TRUE

# 18.3.2 Complete 
# tidyr::complete() allows you to generate explicit missing values by providing a set of variables that define the combination of rows that should exist.
stocks |>
  complete(year, qtr)

# Typically, you’ll call complete() with names of existing variables, filling in the missing combinations.
# sometimes the individual variables are themselves incomplete, so you can instead provide your own data
stocks |>
  complete(year = 2019:2021, qtr)

# If the range of a variable is correct, but not all values are present, you could use full_seq(x, 1) to generate all values from min(x) to max(x) spaced out by 1

# 18.3.3 Joins
# dplyr::anti_join(x, y) is a particularly useful tool here because it selects only the rows in x that don’t have a match in y
library(nycflights13)

flights |> 
  distinct(faa = dest) |> 
  anti_join(airports)

flights |> 
  distinct(tailnum) |> 
  anti_join(planes)

# 18.4 Factors and empty groups
# A final type of missingness is the empty group, a group that doesn’t contain any observations, which can arise when working with factors
health <- tibble(
  name   = c("Ikaia", "Oletta", "Leriah", "Dashay", "Tresaun"),
  smoker = factor(c("no", "no", "no", "no", "no"), levels = c("yes", "no")),
  age    = c(34, 88, 75, 47, 56),
)

# And we want to count the number of smokers with dplyr::count()
health |> count(smoker)

# This dataset only contains non-smokers, but we know that smokers exist; the group of non-smokers is empty. 
# We can request count() to keep all the groups, even those not seen in the data by using .drop = FALSE:
health |> count(smoker, .drop = FALSE)

# The same principle applies to ggplot2’s discrete axes, which will also drop levels that don’t have any values.
# You can force them to display by supplying drop = FALSE to the appropriate discrete axis
ggplot(health, aes(x = smoker)) +
  geom_bar() +
  scale_x_discrete()

ggplot(health, aes(x = smoker)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)

# The same problem comes up more generally with dplyr::group_by().
# And again you can use .drop = FALSE to preserve all factor levels
health |> 
  group_by(smoker, .drop = FALSE) |> 
  summarize(
    n = n(),
    mean_age = mean(age),
    min_age = min(age),
    max_age = max(age),
    sd_age = sd(age)
  )

# We get some interesting results here because when summarizing an empty group, the summary functions are applied to zero-length vectors
# There’s an important distinction between empty vectors, which have length 0, and missing values, each of which has length 1
# A vector containing two missing values
x1 <- c(NA, NA)
length(x1)

# A vector containing nothing
x2 <- numeric()
length(x2)

# Sometimes a simpler approach is to perform the summary and then make the implicit missings explicit with complete()
health |> 
  group_by(smoker) |> 
  summarize(
    n = n(),
    mean_age = mean(age),
    min_age = min(age),
    max_age = max(age),
    sd_age = sd(age)
  ) |> 
  complete(smoker)

# 19 Joins
# 19.1 Introduction
# It’s rare that a data analysis involves only a single data frame. Typically you have many data frames, 
# and you must join them together to answer the questions that you’re interested in.
# Mutating joins, which add new variables to one data frame from matching observations in another.
# Filtering joins, which filter observations from one data frame based on whether or not they match an observation in another.
library(tidyverse)
library(nycflights13)

# 19.2 Keys
# 19.2.1 Primary and foreign keys
# A primary key is a variable or set of variables that uniquely identifies each observation.
# When more than one variable is needed, the key is called a compound key.
# airlines records two pieces of data about each airline: its carrier code and its full name
# You can identify an airline with its two letter carrier code, making carrier the primary key
airlines

# airports records data about each airport. You can identify each airport by its three letter airport code, making faa the primary key
airports

# planes records data about each plane. You can identify a plane by its tail number, making tailnum the primary key
planes

# weather records data about the weather at the origin airports. You can identify each observation by the combination of location and time, 
# making origin and time_hour the compound primary key.
weather

# A foreign key is a variable (or set of variables) that corresponds to a primary key in another table

# 19.2.2 Checking primary keys
# One way to verify that they do indeed uniquely identify each observation
#  is to count() the primary keys and look for entries where n is greater than one.
planes |> 
  count(tailnum) |> 
  filter(n > 1)

weather |> 
  count(time_hour, origin) |> 
  filter(n > 1)

# You should also check for missing values in your primary keys — if a value is missing then it can’t identify an observation!
planes |> 
  filter(is.na(tailnum))

weather |> 
  filter(is.na(time_hour) | is.na(origin))

# 19.2.3 Surrogate keys 
# we determined that there are three variables that together uniquely identify each flight
flights |> 
  count(time_hour, carrier, flight) |> 
  filter(n > 1)

airports |>
  count(alt, lat) |> 
  filter(n > 1)

# for flights, the combination of time_hour, carrier, and flight seems reasonable because it would be really confusing for an airline
# and its customers if there were multiple flights with the same flight number in the air at the same time
# we might be better off introducing a simple numeric surrogate key using the row number
flights2 <- flights |> 
  mutate(id = row_number(), .before = 1)
flights2

# Surrogate keys can be particularly useful when communicating to other humans: it’s much easier to tell someone to take a look at flight 2001 than to say look at UA430 which departed 9am 2013-01-03

# 19.3 Basic joins
# dplyr provides six join functions:
# left_join(), inner_join(), right_join(), full_join(), semi_join(), and anti_join()

# 19.3.1 Mutating joins
# A mutating join allows you to combine variables from two data frames: it first matches observations by their keys, then copies across variables from one data frame to the other.
# Like mutate(), the join functions add variables to the right, so if your dataset has many variables, you won’t see the new ones
flights2 <- flights |> 
  select(year, time_hour, origin, dest, tailnum, carrier)
flights2

# There are four types of mutating join, but there’s one that you’ll use almost all of the time: left_join()
# The primary use of left_join() is to add in additional metadata
flights2 |>
  left_join(airlines)

# Or we could find out the temperature and wind speed when each plane departed
flights2 |> 
  left_join(weather |> select(origin, time_hour, temp, wind_speed))

# Or what size of plane was flying
flights2 |> 
  left_join(planes |> select(tailnum, type, engines, seats))

# When left_join() fails to find a match for a row in x, it fills in the new variables with missing values
flights2 |> 
  filter(tailnum == "N3ALAA") |> 
  left_join(planes |> select(tailnum, type, engines, seats))

# 19.3.2 Specifying join keys
# By default, left_join() will use all variables that appear in both data frames as the join key, the so called natural join
# This is a useful heuristic, but it doesn’t always work
flights2 |> 
  left_join(planes)

# We only want to join on tailnum so we need to provide an explicit specification with join_by()
flights2 |> 
  left_join(planes, join_by(tailnum))

# Note that the year variables are disambiguated in the output with a suffix (year.x and year.y), which tells you whether the variable came from the x or y argument
# You can override the default suffixes with the suffix argument.
# join_by(tailnum) is short for join_by(tailnum == tailnum).
# It’s important to know about this fuller form for two reasons
# Firstly, it describes the relationship between the two tables: the keys must be equal
# that’s why this type of join is often called an equi join
# Secondly, it’s how you specify different join keys in each table. For example, there are two ways to join the flight2 and airports table: either by dest or origin
flights2 |> 
  left_join(airports, join_by(dest == faa))

flights2 |> 
  left_join(airports, join_by(origin == faa))

# In older code you might see a different way of specifying the join keys, using a character vector
# by = "x" corresponds to join_by(x).
# by = c("a" = "x") corresponds to join_by(a == x).
# Now that it exists, we prefer join_by() since it provides a clearer and more flexible specification

# left join keeps all the rows in x
#  the right join keeps all rows in y
# the full join keeps all rows in either x or y
# the inner join only keeps rows that occur in both x and y

# 19.3.3 Filtering joins
# There are two types: semi-joins and anti-joins
# Semi-joins keep all rows in x that have a match in y
airports |> 
  semi_join(flights2, join_by(faa == origin))

# Or just the destinations
airports |> 
  semi_join(flights2, join_by(faa == dest))

# Anti-joins are the opposite: they return all rows in x that don’t have a match in y
# useful for finding missing values that are implicit in the data
flights2 |> 
  anti_join(airports, join_by(dest == faa)) |> 
  distinct(dest)

# Or we can find which tailnums are missing from planes
flights2 |>
  anti_join(planes, join_by(tailnum)) |> 
  distinct(tailnum)

# 19.4 How do joins work
# We’ll begin by introducing a visual representation of joins, using the simple tibbles defined below
x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)
y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

# It shows all potential matches between x and y as the intersection between lines drawn from each row of x and each row of y
# To describe a specific type of join, we indicate matches with dots. The matches determine the rows in the output, a new data frame that contains the key, the x values, and the y values
# We can apply the same principles to explain the outer joins, which keep observations that appear in at least one of the data frames

# A left join keeps all observations in x
# Every row of x is preserved in the output because it can fall back to matching a row of NAs in y.

# A right join keeps all observations in y
# Every row of y is preserved in the output because it can fall back to matching a row of NAs in x. The output still matches x as much as possible; any extra rows from y are added to the end.

# A full join keeps all observations that appear in x or y
# Every row of x and y is included in the output because both x and y have a fall back row of NAs. Again, the output starts with all rows from x, followed by the remaining unmatched y rows.

# 19.4.1 Row matching 
# What happens if it matches more than one row? 
# To understand what’s going on let’s first narrow our focus to the inner_join() and then draw a picture,

# There are three possible outcomes for a row in x:
#   If it doesn’t match anything, it’s dropped.
# If it matches 1 row in y, it’s preserved.
# If it matches more than 1 row in y, it’s duplicated once for each match.

# In principle, this means that there’s no guaranteed correspondence between the rows in the output and the rows in x, but in practice, this rarely causes problems.
df1 <- tibble(key = c(1, 2, 2), val_x = c("x1", "x2", "x3"))
df2 <- tibble(key = c(1, 2, 2), val_y = c("y1", "y2", "y3"))

# While the first row in df1 only matches one row in df2, the second and third rows both match two rows.
# This is sometimes called a many-to-many join, and will cause dplyr to emit a warning:
df1 |> 
  inner_join(df2, join_by(key))

# If you are doing this deliberately, you can set relationship = "many-to-many", as the warning suggests.

# 19.4.2 Filtering joins
#  The semi-join keeps rows in x that have one or more matches in y
#  The anti-join keeps rows in x that match zero rows in y
# In both cases, only the existence of a match is important; it doesn’t matter how many times it matches. This means that filtering joins never duplicate rows like mutating joins do.

# 19.5 Non-equi joins
#  In equi joins the x keys and y are always equal, so we only need to show one in the output
# we can request that dplyr keep both keys with keep = TRUE, leading to the code below and the re-drawn inner_join() 
x |> inner_join(y, join_by(key == key), keep = TRUE)

# When we move away from equi joins we’ll always show the keys, because the key values will often be different.
#  instead of matching only when the x$key and y$key are equal, we could match whenever the x$key is greater than or equal to the y$key

# dplyr helps by identifying four particularly useful types of non-equi join
# Cross joins match every pair of rows.
# Inequality joins use <, <=, >, and >= instead of ==.
# Rolling joins are similar to inequality joins but only find the closest match.
# Overlap joins are a special type of inequality join designed to work with ranges

# 19.5.1 Cross joins
# Cross joins are useful when generating permutations
# Since we’re joining df to itself, this is sometimes called a self-join.
# Cross joins use a different join function because there’s no distinction between inner/left/right/full when you’re matching every row
df <- tibble(name = c("John", "Simon", "Tracy", "Max"))
df |> cross_join(df)

# 19.5.2 Inequality joins
# Inequality joins use <, <=, >=, or > to restrict the set of possible matches
# Inequality joins are extremely general, so general that it’s hard to come up with meaningful specific use cases
# One small useful technique is to use them to restrict the cross join so that instead of generating all permutations, we generate all combinations
df <- tibble(id = 1:4, name = c("John", "Simon", "Tracy", "Max"))

df |> inner_join(df, join_by(id < id))

# 19.5.3 Rolling joins
# Rolling joins are a special type of inequality join where instead of getting every row that satisfies the inequality, you get just the closest row
#  imagine that you’re in charge of the party planning commission for your office
parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03"))
)

# Now imagine that you have a table of employee birthdays
set.seed(123)
employees <- tibble(
  name = sample(babynames::babynames$name, 100),
  birthday = ymd("2022-01-01") + (sample(365, 100, replace = TRUE) - 1)
)
employees

# And for each employee we want to find the first party date that comes after (or on) their birthday. We can express that with a rolling join
employees |> 
  left_join(parties, join_by(closest(birthday >= party)))

# There is, however, one problem with this approach: the folks with birthdays before January 10 don’t get a party
employees |> 
  anti_join(parties, join_by(closest(birthday >= party)))

# To resolve that issue we’ll need to tackle the problem a different way, with overlap joins.

# 19.5.4 Overlap joins
# Overlap joins provide three helpers that use inequality joins to make it easier to work with intervals
# between(x, y_lower, y_upper) is short for x >= y_lower, x <= y_upper.
# within(x_lower, x_upper, y_lower, y_upper) is short for x_lower >= y_lower, x_upper <= y_upper.
# overlaps(x_lower, x_upper, y_lower, y_upper) is short for x_lower <= y_upper, x_upper >= y_lower
#  it might be better to be explicit about the date ranges that each party spans, and make a special case for those early birthdays
parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03")),
  start = ymd(c("2022-01-01", "2022-04-04", "2022-07-11", "2022-10-03")),
  end = ymd(c("2022-04-03", "2022-07-11", "2022-10-02", "2022-12-31"))
)
parties

# Hadley is hopelessly bad at data entry so he also wanted to check that the party periods don’t overlap
# One way to do this is by using a self-join to check if any start-end interval overlap with another
parties |> 
  inner_join(parties, join_by(overlaps(start, end, start, end), q < q)) |> 
  select(start.x, end.x, start.y, end.y)

# Ooops, there is an overlap, so let’s fix that problem and continue
parties <- tibble(
  q = 1:4,
  party = ymd(c("2022-01-10", "2022-04-04", "2022-07-11", "2022-10-03")),
  start = ymd(c("2022-01-01", "2022-04-04", "2022-07-11", "2022-10-03")),
  end = ymd(c("2022-04-03", "2022-07-10", "2022-10-02", "2022-12-31"))
)

# This is a good place to use unmatched = "error" because we want to quickly find out if any employees didn’t get assigned a party.
employees |> 
  inner_join(parties, join_by(between(birthday, start, end)), unmatched = "error")


