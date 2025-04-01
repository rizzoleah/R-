# Chapter 7 Data Import 
# 7.1.1 Prerequisites
library(tidyverse)

# 7.2 Reading data from a file
# use read_cvs()

students <- read_csv("data/students.csv")

# can read directly from URL 
students <- read_csv("https://pos.it/r4ds-students-csv")

# 7.2.1 Practical advise 
students

students <- read_csv("data/students.csv", na = c("N/A", ""))

students |> 
  rename(
    student_id = `Student ID`,
    full_name = `Full Name`
  )

students |> janitor::clean_names()

students |>
  janitor::clean_names() |>
  mutate(meal_plan = factor(meal_plan))

students <- students |>
  janitor::clean_names() |>
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  )

# 7.2.2 Other aruguments

read_csv(
  "a,b,c
  1,2,3
  4,5,6"
)

read_csv(
  "The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3",
  skip = 2
)

read_csv(
  "1,2,3
  4,5,6",
  col_names = FALSE
)

read_csv(
  "1,2,3
  4,5,6",
  col_names = c("x", "y", "z")
)

# 7.2.3 Other file types

# read_csv2() reads semicolon-separated files. These use ; instead of , to separate fields and are common in countries that use , as the decimal marker.
# 
# read_tsv() reads tab-delimited files.
# 
# read_delim() reads in files with any delimiter, attempting to automatically guess the delimiter if you don’t specify it.
# 
# read_fwf() reads fixed-width files. You can specify fields by their widths with fwf_widths() or by their positions with fwf_positions().
# 
# read_table() reads a common variation of fixed-width files where columns are separated by white space.
# 
# read_log() reads Apache-style log files.

# 7.2.4 Exercises 

# 5
read_csv("a,b\n1,2,3\n4,5,6")
read_csv("a,b,c\n1,2\n1,2,3,4")
read_csv("a,b\n\"1")
read_csv("a,b\n1,2\na,b")
read_csv("a;b\n1;3")

# 6 
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)

# 7.3 Controlling column types
# 7.3.1 Guessing types

read_csv("
  logical,numeric,date,string
  TRUE,1,2021-01-15,abc
  false,4.5,2021-02-15,def
  T,Inf,2021-02-16,ghi
")

# 7.3.2 Missing values, column types, and problems

simple_csv <- "
  x
  10
  .
  20
  30"

read_csv(simple_csv)

df <- read_csv(
  simple_csv, 
  col_types = list(x = col_double())
)

read_csv(simple_csv, na = ".")

# 7.3.3 Column types

another_csv <- "
x,y,z
1,2,3"

read_csv(
  another_csv, 
  col_types = cols(.default = col_character())
)

read_csv(
  another_csv,
  col_types = cols_only(x = col_character())
)

# 7.4 Reading data from multiple files

sales_files <- c("data/01-sales.csv", "data/02-sales.csv", "data/03-sales.csv")
read_csv(sales_files, id = "file")

sales_files <- c(
  "https://pos.it/r4ds-01-sales",
  "https://pos.it/r4ds-02-sales",
  "https://pos.it/r4ds-03-sales"
)
read_csv(sales_files, id = "file")

sales_files <- list.files("data", pattern = "sales\\.csv$", full.names = TRUE)
sales_files
#> [1] "data/01-sales.csv" "data/02-sales.csv" "data/03-sales.csv"


# 7.5 Writing to a file 

write_csv(students, "students.csv")

write_rds(students, "students.rds")
read_rds("students.rds")

# 7.6 Data entry 

tibble(
  x = c(1, 2, 5), 
  y = c("h", "m", "g"),
  z = c(0.08, 0.83, 0.60)
)

tribble(
  ~x, ~y, ~z,
  1, "h", 0.08,
  2, "m", 0.83,
  5, "g", 0.60
)

# Chapter 8 Workflow: getting help

# Google is your friend 
# It is important to prepare a reprex
# Reprex: Reproducible Example

y <- 1:4
mean(y)

reprex::reprex()

# 8.3 Investing in yourself 
# you should prepare yourself to solve problems before they occur








