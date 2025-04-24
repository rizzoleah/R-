# 20 Spreadsheets
# 20.1 Introduction
#  Now it’s time to learn how to get data out of a spreadsheet, either an Excel spreadsheet or a Google Sheet.
# we will also discuss additional considerations and complexities when working with data from spreadsheets.4

# 20.2 Excel
# Microsoft Excel is a widely used spreadsheet software program where data are organized in worksheets inside of spreadsheet files.

# 20.2.1 Prerequisites
library(readxl)
library(tidyverse)
library(writexl)

# 20.2.2 Getting started
# Most of readxl's functions allow you to load Excel spreadsheets into R
# read_xls() reads Excel files with xls format.
# read_xlsx() read Excel files with xlsx format.
# read_excel() can read files with both xls and xlsx format. It guesses the file type based on the input.

# 20.2.3 Reading Excel spreadsheets
# The first argument to read_excel() is the path to the file to read.
students <- read_excel("data/students.xlsx")

# read_excel() will read the file in as a tibble.
students

# We have six students in the data and five variables on each student. However there are a few things we might want to address in this dataset:
# You can provide column names that follow a consistent format; we recommend snake_case using the col_names argument.
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age")
)

# Unfortunately, this didn’t quite do the trick. We now have the variable names we want, but what was previously the header row now shows up as the first observation in the data.
# You can explicitly skip that row using the skip argument.
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1
)

# You can specify which character strings should be recognized as NAs with the na argument.
# By default, only "" (empty string, or, in the case of reading from a spreadsheet, an empty cell or a cell with the formula =NA()) is recognized as an NA
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A")
)

# One other remaining issue is that age is read in as a character variable, but it really should be numeric. 
# The syntax is a bit different, though. Your options are "skip", "guess", "logical", "numeric", "date", "text" or "list".
read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = c("numeric", "text", "text", "text", "numeric")
)

#  By specifying that age should be numeric, we have turned the one cell with the non-numeric entry (which had the value five) into an NA.
# In this case, we should read age in as "text" and then make the change once the data is loaded in R.
students <- read_excel(
  "data/students.xlsx",
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = c("numeric", "text", "text", "text", "text")
)

students <- students |>
  mutate(
    age = if_else(age == "five", "5", age),
    age = parse_number(age)
  )

students

#  load the data, take a peek, make adjustments to your code, load it again, and repeat until you’re happy with the result.

# 20.2.4 Reading worksheets
# An important feature that distinguishes spreadsheets from flat files is the notion of multiple sheets, called worksheets.
# You can read a single worksheet from a spreadsheet with the sheet argument in read_excel(). 
read_excel("data/penguins.xlsx", sheet = "Torgersen Island")

# Some variables that appear to contain numerical data are read in as characters due to the character string "NA" not being recognized as a true NA.
penguins_torgersen <- read_excel("data/penguins.xlsx", sheet = "Torgersen Island", na = "NA")

penguins_torgersen

# Alternatively, you can use excel_sheets() to get information on all worksheets in an Excel spreadsheet, and then read the one(s) you’re interested in
excel_sheets("data/penguins.xlsx")

# Once you know the names of the worksheets, you can read them in individually with read_excel()
penguins_biscoe <- read_excel("data/penguins.xlsx", sheet = "Biscoe Island", na = "NA")
penguins_dream  <- read_excel("data/penguins.xlsx", sheet = "Dream Island", na = "NA")

# Each worksheet has the same number of columns but different numbers of rows
dim(penguins_torgersen)
dim(penguins_biscoe)
dim(penguins_dream)

# We can put them together with bind_rows().
penguins <- bind_rows(penguins_torgersen, penguins_biscoe, penguins_dream)
penguins

# 20.2.5 Reading part of a sheet
# You can use the readxl_example() function to locate the spreadsheet on your system in the directory where the package is installed.
# This function returns the path to the spreadsheet, which you can use in read_excel() as usual.
deaths_path <- readxl_example("deaths.xlsx")
deaths <- read_excel(deaths_path)
deaths

# It’s possible to eliminate these extraneous rows using the skip and n_max arguments, but we recommend using cell ranges.
# Here the data we want to read in starts in cell A5 and ends in cell F15. In spreadsheet notation, this is A5:F15, which we supply to the range argument
read_excel(deaths_path, range = "A5:F15")

# 20.2.6 Data types
# In CSV files, all values are strings. This is not particularly true to the data, but it is simple: everything is a string
# The underlying data in Excel spreadsheets is more complex. A cell can be one of four things
# A boolean, like TRUE, FALSE, or NA.
# 
# A number, like “10” or “10.5”.
# 
# A datetime, which can also include time like “11/1/21” or “11/1/21 3:00 PM”.
# 
# A text string, like “ten”
# When working with spreadsheet data, it’s important to keep in mind that the underlying data can be very different than what you see in the cell. 

# 20.2.7 Writing to Excel
# Let’s create a small data frame that we can then write out. Note that item is a factor and quantity is an integer.
bake_sale <- tibble(
  item     = factor(c("brownie", "cupcake", "cookie")),
  quantity = c(10, 5, 8)
)

bake_sale

# You can write data back to disk as an Excel file using the write_xlsx() function from the writexl package:
write_xlsx(bake_sale, path = "data/bake-sale.xlsx")

# Just like reading from a CSV, information on data type is lost when we read the data back in.
# This makes Excel files unreliable for caching interim results as well
read_excel("data/bake-sale.xlsx")

# 20.2.8 Formatted output
# The writexl package is a light-weight solution for writing a simple Excel spreadsheet, but if you’re interested in additional features like writing to sheets within a spreadsheet and styling, you will want to use the openxlsx package.
# A good way of familiarizing yourself with the coding style used in a new package is to run the examples provided in function documentation to get a feel for the syntax and the output formats as well as reading any vignettes that might come with the package.

# 20.3 Google Sheets
# Just like with Excel, in Google Sheets data are organized in worksheets (also called sheets) inside of spreadsheet files
# 20.3.1 Prerequisites
library(googlesheets4)
library(tidyverse)

# 20.3.2 Getting started
# The main function of the googlesheets4 package is read_sheet(), which reads a Google Sheet from a URL or a file id.
# You can also create a brand new sheet with gs4_create() or write to an existing sheet with sheet_write() and friends.
# readxl and googlesheets4 packages are both designed to mimic the functionality of the readr package, which provides the read_csv() function 

# 20.3.3 Reading Google Sheets
# The first argument to read_sheet() is the URL of the file to read, and it returns a tibble:
# These URLs are not pleasant to work with, so you’ll often want to identify a sheet by its ID.
gs4_deauth()

students_sheet_id <- "1V1nPp1tzOuutXFLb3G9Eyxi3qxeEhnOXUzL5_BcCQ0w"
students <- read_sheet(students_sheet_id)
students

#Just like we did with read_excel(), we can supply column names, NA strings, and column types to read_sheet().
students <- read_sheet(
  students_sheet_id,
  col_names = c("student_id", "full_name", "favourite_food", "meal_plan", "age"),
  skip = 1,
  na = c("", "N/A"),
  col_types = "dcccc"
)

students

# Note that we defined column types a bit differently here, using short codes.
# It’s also possible to read individual sheets from Google Sheets as well. 
penguins_sheet_id <- "1aFu8lnD_g0yjF5O-K6SFgSEWiHPpgvFCF0NY9D6LXnY"
read_sheet(penguins_sheet_id, sheet = "Torgersen Island")

# You can obtain a list of all sheets within a Google Sheet with sheet_names():
sheet_names(penguins_sheet_id)

# just like with read_excel(), we can read in a portion of a Google Sheet by defining a range in read_sheet()
# Note that we’re also using the gs4_example() function below to locate an example Google Sheet that comes with the googlesheets4 package
deaths_url <- gs4_example("deaths")
deaths <- read_sheet(deaths_url, range = "A5:F15")

deaths

# 20.3.4 Writing to Google Sheets
# You can write from R to Google Sheets with write_sheet()
# The first argument is the data frame to write, and the second argument is the name (or other identifier) of the Google Sheet to write to
write_sheet(bake_sale, ss = "bake-sale")

# If you’d like to write your data to a specific (work)sheet inside a Google Sheet, you can specify that with the sheet argument as well.
write_sheet(bake_sale, ss = "bake-sale", sheet = "Sales")

# 20.3.5 Authentication
# While you can read from a public Google Sheet without authenticating with your Google account and with gs4_deauth(), reading a private sheet
# or writing to a sheet requires authentication so that googlesheets4 can view and manage your Google Sheets
# if you want to specify a specific Google account, authentication scope, etc. you can do so with gs4_auth(),
# e.g., gs4_auth(email = "mine@example.com"), which will force the use of a token associated with a specific email.

# 21 Databases
# 21.1 Introduction
# A huge amount of data lives in databases, so it’s essential that you know how to access it.
# You want to be able to reach into the database directly to get the data you need, when you need it
# In this chapter, you’ll first learn the basics of the DBI package: how to use it to connect to a database and then retrieve data with a SQL1 query
# SQL, short for structured query language, is the lingua franca of databases, and is an important language for all data scientists to learn.
# we’re not going to start with SQL, but instead we’ll teach you dbplyr, which can translate your dplyr code to the SQL

# 21.1.1 Prerequisites
library(DBI)
library(dbplyr)
library(tidyverse)

# 21.2 Database basics
# At the simplest level, you can think about a database as a collection of data frames, called tables in database terminology
#  Like a data frame, a database table is a collection of named columns, where every value in the column is the same type
# There are three high level differences between data frames and database tables
# Database tables are stored on disk and can be arbitrarily large. Data frames are stored in memory, 
# and are fundamentally limited (although that limit is still plenty large for many problems).
# 
# Database tables almost always have indexes. Much like the index of a book, 
# a database index makes it possible to quickly find rows of interest without having to look at every single row. 
# Data frames and tibbles don’t have indexes, but data.tables do, which is one of the reasons that they’re so fast.
# 
# Most classical databases are optimized for rapidly collecting data, not analyzing existing data. These databases are called row-oriented because the data is stored row-by-row, 
# rather than column-by-column like R. More recently, there’s been much development of column-oriented databases that make analyzing the existing data much faster.

# Databases are run by database management systems (DBMS’s for short), which come in three basic forms
# Client-server: DBMS’s run on a powerful central server, which you connect to from your computer (the client). 
# They are great for sharing data with multiple people in an organization. Popular client-server DBMS’s include PostgreSQL, MariaDB, SQL Server, and Oracle.

# Cloud: DBMS’s, like Snowflake, Amazon’s RedShift, and Google’s BigQuery, are similar to client server DBMS’s, but they run in the cloud.
# This means that they can easily handle extremely large datasets and can automatically provide more compute resources as needed.

# In-process: DBMS’s, like SQLite or duckdb, run entirely on your computer. They’re great for working with large datasets where you’re the primary user.

# 21.3 Connecting to a database
# To connect to the database from R, you’ll use a pair of packages
# You’ll always use DBI (database interface) because it provides a set of generic functions that connect to the database, upload data, run SQL queries, etc
# You’ll also use a package tailored for the DBMS you’re connecting to. This package translates the generic DBI commands into the specifics needed for a given DBMS.

# If you can’t find a specific package for your DBMS, you can usually use the odbc package instead
# odbc requires a little more setup because you’ll also need to install an ODBC driver and tell the odbc package where to find it.
# Concretely, you create a database connection using DBI::dbConnect()
# The first argument selects the DBMS2, then the second and subsequent arguments describe how to connect to it
con <- DBI::dbConnect(
  RMariaDB::MariaDB(), 
  username = "foo"
)
con <- DBI::dbConnect(
  RPostgres::Postgres(), 
  hostname = "databases.mycompany.com", 
  port = 1234
)

# The precise details of the connection vary a lot from DBMS to DBMS so unfortunately we can’t cover all the details here. This means you’ll need to do a little research on your own.

# 21.3.1 In this book
# Setting up a client-server or cloud DBMS would be a pain for this book, so we’ll instead use an in-process DBMS that lives entirely in an R package: duckdb
# the only difference between using duckdb and any other DBMS is how you’ll connect to the database.
# Connecting to duckdb is particularly simple because the defaults create a temporary database that is deleted when you quit R.
#  it guarantees that you’ll start from a clean slate every time you restart R
con <- DBI::dbConnect(duckdb::duckdb())

# duckdb is a high-performance database that’s designed very much for the needs of a data scientist
#  We use it here because it’s very easy to get started with, but it’s also capable of handling gigabytes of data with great speed
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "duckdb")

# 21.3.2 Load some data
# The simplest usage of dbWriteTable() needs three arguments: a database connection, the name of the table to create in the database, and a data frame of data.
dbWriteTable(con, "mpg", ggplot2::mpg)
dbWriteTable(con, "diamonds", ggplot2::diamonds)

# If you’re using duckdb in a real project, we highly recommend learning about duckdb_read_csv() and duckdb_register_arrow()

# 21.3.3 DBI basics
#You can check that the data is loaded correctly by using a couple of other DBI functions: dbListTables() lists all tables in the database3 and dbReadTable() retrieves the contents of a table.
dbListTables(con)

con |> 
  dbReadTable("diamonds") |> 
  as_tibble()

# dbReadTable() returns a data.frame so we use as_tibble() to convert it into a tibble so that it prints nicely
# If you already know SQL, you can use dbGetQuery() to get the results of running a query on the database
sql <- "
  SELECT carat, cut, clarity, color, price 
  FROM diamonds 
  WHERE price > 15000
"
as_tibble(dbGetQuery(con, sql))

# 21.4 dbplyr basics
# dbplyr is a dplyr backend, which means that you keep writing dplyr code but the backend executes it differently
# In this, dbplyr translates to SQL; other backends include dtplyr which translates to data.table, and multidplyr which executes your code on multiple cores.
# To use dbplyr, you must first use tbl() to create an object that represents a database table
diamonds_db <- tbl(con, "diamonds")
diamonds_db

# This object is lazy; when you use dplyr verbs on it, dplyr doesn’t do any work: it just records the sequence of operations that you want to perform and only performs them when needed
big_diamonds_db <- diamonds_db |> 
  filter(price > 15000) |> 
  select(carat:clarity, price)

big_diamonds_db

# You can tell this object represents a database query because it prints the DBMS name at the top, and while it tells you the number of columns, it typically doesn’t know the number of rows.
# You can see the SQL code generated by the dplyr function show_query()
big_diamonds_db |>
  show_query()

# To get all the data back into R, you call collect(). Behind the scenes, this generates the SQL, calls dbGetQuery() to get the data, then turns the result into a tibble
big_diamonds <- big_diamonds_db |> 
  collect()
big_diamonds

# Typically, you’ll use dbplyr to select the data you want from the database, performing basic filtering and aggregation using the translations described below
# Then, once you’re ready to analyse the data with functions that are unique to R, you’ll collect() the data to get an in-memory tibble, and continue your work with pure R code

# 21.5 SQL
#We’ll explore the relationship between dplyr and SQL using a couple of old friends from the nycflights13 package: flights and planes
dbplyr::copy_nycflights13(con)
flights <- tbl(con, "flights")
planes <- tbl(con, "planes")

# 21.5.1 SQL basics
# The top-level components of SQL are called statements
# Common statements include CREATE for defining new tables, INSERT for adding data, and SELECT for retrieving data

# A query is made up of clauses
# There are five important clauses: SELECT, FROM, WHERE, ORDER BY, and GROUP BY
# Every query must have the SELECT4 and FROM5 clauses and the simplest query is SELECT * FROM table, which selects all columns from the specified table
flights |> show_query()
planes |> show_query()

# WHERE and ORDER BY control which rows are included and how they are ordered
flights |> 
  filter(dest == "IAH") |> 
  arrange(dep_delay) |>
  show_query()

# GROUP BY converts the query to a summary, causing aggregation to happen
flights |> 
  group_by(dest) |> 
  summarize(dep_delay = mean(dep_delay, na.rm = TRUE)) |> 
  show_query()

#There are two important differences between dplyr verbs and SELECT clauses
# In SQL, case doesn’t matter: you can write select, SELECT, or even SeLeCt. 
# In this book we’ll stick with the common convention of writing SQL keywords in uppercase to distinguish them from table or variables names

# In SQL, order matters: you must always write the clauses in the order SELECT, FROM, WHERE, GROUP BY, ORDER BY. Confusingly, 
# this order doesn’t match how the clauses are actually evaluated which is first FROM, then WHERE, GROUP BY, SELECT, and ORDER BY

# 21.5.2 SELECT
# The SELECT clause is the workhorse of queries and performs the same job as select(), mutate(), rename(), relocate(), and, as you’ll learn in the next section, summarize()
# select(), rename(), and relocate() have very direct translations to SELECT as they just affect where a column appears (if at all) along with its name
planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  show_query()

planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  rename(year_built = year) |> 
  show_query()

planes |> 
  select(tailnum, type, manufacturer, model, year) |> 
  relocate(manufacturer, model, .before = type) |> 
  show_query()

#  In SQL terminology renaming is called aliasing and is done with AS. Note that unlike mutate(), the old name is on the left and the new name is on the right.
# The translations for mutate() are similarly straightforward: each variable becomes a new expression in SELECT
flights |> 
  mutate(
    speed = distance / (air_time / 60)
  ) |> 
  show_query()

# 21.5.3 FROM
# The FROM clause defines the data source. It’s going to be rather uninteresting for a little while, because we’re just using single tables. 
# You’ll see more complex examples once we hit the join functions

# 21.5.4 GROUP BY
#group_by() is translated to the GROUP BY6 clause and summarize() is translated to the SELECT clause
diamonds_db |> 
  group_by(cut) |> 
  summarize(
    n = n(),
    avg_price = mean(price, na.rm = TRUE)
  ) |> 
  show_query()

# 21.5.5 WHERE
# filter() is translated to the WHERE clause
flights |> 
  filter(dest == "IAH" | dest == "HOU") |> 
  show_query()

flights |> 
  filter(arr_delay > 0 & arr_delay < 20) |> 
  show_query()

# | becomes OR and & becomes AND.
# SQL uses = for comparison, not ==. SQL doesn’t have assignment, so there’s no potential for confusion there.
# SQL uses only '' for strings, not "". In SQL, "" is used to identify variables, like R’s ``

# Another useful SQL operator is IN, which is very close to R’s %in%
flights |> 
  filter(dest %in% c("IAH", "HOU")) |> 
  show_query()

# SQL uses NULL instead of NA. NULLs behave similarly to NAs
# The main difference is that while they’re “infectious” in comparisons and arithmetic, they are silently dropped when summarizing
flights |> 
  group_by(dest) |> 
  summarize(delay = mean(arr_delay))

# In general, you can work with NULLs using the functions you’d use for NAs in R
flights |> 
  filter(!is.na(dep_delay)) |> 
  show_query()

# This SQL query illustrates one of the drawbacks of dbplyr: while the SQL is correct, it isn’t as simple as you might write by hand. In this case, 
# you could drop the parentheses and use a special operator that’s easier to read
# WHERE "dep_delay" IS NOT NULL

# Note that if you filter() a variable that you created using a summarize, dbplyr will generate a HAVING clause, rather than a WHERE clause
diamonds_db |> 
  group_by(cut) |> 
  summarize(n = n()) |> 
  filter(n > 100) |> 
  show_query()

# 21.5.6 ORDER BY
# Ordering rows involves a straightforward translation from arrange() to the ORDER BY clause
flights |> 
  arrange(year, month, day, desc(dep_delay)) |> 
  show_query()

# Notice how desc() is translated to DESC: this is one of the many dplyr functions whose name was directly inspired by SQL

# 21.5.7 Subqueries
# A subquery is just a query used as a data source in the FROM clause, instead of the usual table
# the following (silly) dplyr pipeline needs to happen in two steps: the first (inner) query computes year1 and then the second (outer) query can compute year2
# flights |> 
mutate(
  year1 = year + 1,
  year2 = year1 + 1
) |> 
  show_query()

#  Remember, even though WHERE is written after SELECT, it’s evaluated before it, so we need a subquery in this (silly) example
flights |> 
  mutate(year1 = year + 1) |> 
  filter(year1 == 2014) |> 
  show_query()

# 21.5.8 Joins
# If you’re familiar with dplyr’s joins, SQL joins are very similar.
flights |> 
  left_join(planes |> rename(year_built = year), by = "tailnum") |> 
  show_query()

# The main thing to notice here is the syntax: SQL joins use sub-clauses of the FROM clause to bring in additional tables, using ON to define how the tables are related.
# dplyr’s names for these functions are so closely connected to SQL that you can easily guess the equivalent SQL for inner_join(), right_join(), and full_join()

# 21.5.9 Other verbs
# dbplyr also translates other verbs like distinct(), slice_*(), and intersect(), and a growing selection of tidyr functions like pivot_longer() and pivot_wider()
# The easiest way to see the full set of what’s currently available is to visit the dbplyr website

# 21.6 Function translations
# Now we’re going to zoom in a little and talk about the translation of the R functions that work with individual columns, e.g., what happens when you use mean(x) in a summarize()
# To help see what’s going on, we’ll use a couple of little helper functions that run a summarize() or mutate() and show the generated SQL
summarize_query <- function(df, ...) {
  df |> 
    summarize(...) |> 
    show_query()
}
mutate_query <- function(df, ...) {
  df |> 
    mutate(..., .keep = "none") |> 
    show_query()
}

# Looking at the code below you’ll notice that some summary functions, like mean(), have a relatively simple translation while others, like median(), are much more complex.
# The complexity is typically higher for operations that are common in statistics but less common in databases
flights |> 
  group_by(year, month, day) |>  
  summarize_query(
    mean = mean(arr_delay, na.rm = TRUE),
    median = median(arr_delay, na.rm = TRUE)
  )

#  In SQL, you turn an ordinary aggregation function into a window function by adding OVER after it
flights |> 
  group_by(year, month, day) |>  
  mutate_query(
    mean = mean(arr_delay, na.rm = TRUE),
  )

# In SQL, the GROUP BY clause is used exclusively for summaries so here you can see that the grouping has moved from the PARTITION BY argument to OVER
# Window functions include all functions that look forward or backwards, like lead() and lag() which look at the “previous” or “next” value respectively
flights |> 
  group_by(dest) |>  
  arrange(time_hour) |> 
  mutate_query(
    lead = lead(arr_delay),
    lag = lag(arr_delay)
  )

# Here it’s important to arrange() the data, because SQL tables have no intrinsic order
# if you don’t use arrange() you might get the rows back in a different order every time
# Another important SQL function is CASE WHEN. It’s used as the translation of if_else() and case_when(), the dplyr function that it directly inspired.
flights |> 
  mutate_query(
    description = if_else(arr_delay > 0, "delayed", "on-time")
  )

flights |> 
  mutate_query(
    description = 
      case_when(
        arr_delay < -5 ~ "early", 
        arr_delay < 5 ~ "on-time",
        arr_delay >= 5 ~ "late"
      )
  )

# CASE WHEN is also used for some other functions that don’t have a direct translation from R to SQL
flights |> 
  mutate_query(
    description =  cut(
      arr_delay, 
      breaks = c(-Inf, -5, 5, Inf), 
      labels = c("early", "on-time", "late")
    )
  )

# dbplyr also translates common string and date-time manipulation functions, which you can learn about in vignette("translation-function", package = "dbplyr")

