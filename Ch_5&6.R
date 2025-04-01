# 5 Data Tidying

library(tidyverse)

# 5.2 Tidy Data

# Three general rules to make a dataset tidy
# Each variable is a column; each column is a variable.
# Each observation is a row; each row is an observation.
# Each value is a cell; each cell is a single value.

# 5.3 Lengthening Data 
#tidyr provides two functions for pivoting data: pivot_longer() and pivot_wider()

# 5.3.1 Data in Column Names
billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank"
  )

billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  )
# Rows with 'NA' were dropped

billboard_longer <- billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  ) |> 
  mutate(
    week = parse_number(week)
  )
# Making visualizations
billboard_longer |> 
  ggplot(aes(x = week, y = rank, group = track)) + 
  geom_line(alpha = 0.25) + 
  scale_y_reverse()

# 5.3.2 How Does Pivoting Work

df <- tribble(
  ~id,  ~bp1, ~bp2,
  "A",  100,  120,
  "B",  140,  115,
  "C",  120,  125
)

df |> 
  pivot_longer(
    cols = bp1:bp2,
    names_to = "measurement",
    values_to = "value"
  )

# The column names become values in a new variable, whose name is defined by names_to
# They need to be repeated once for each row in the original dataset.

# # 5.3.3 Many Variables in Column names
# To organize these six pieces of information in six separate columns, we use pivot_longer() with a vector of column names 
# for names_to and instructors for splitting the original variable names into pieces for names_sep as well as a column name for values_to

who2 |> 
  pivot_longer(
    cols = !(country:year),
    names_to = c("diagnosis", "gender", "age"), 
    names_sep = "_",
    values_to = "count"
  )

# 5.3.4 data and variable names in the comlumn headers
household |> 
  pivot_longer(
    cols = !family, 
    names_to = c(".value", "child"), 
    names_sep = "_", 
    values_drop_na = TRUE
  )

#We again use values_drop_na = TRUE, 
# since the shape of the input forces the creation of explicit missing variables 

# 5.4 Widening Data
cms_patient_experience

# We can see the complete set of values for measure_cd and measure_title by using distinct():
cms_patient_experience |> 
  distinct(measure_cd, measure_title)

cms_patient_experience |> 
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  )

# We also need to tell pivot_wider() which column or columns have values that uniquely identify each row; 
# In this case those are the variables starting with "org"

cms_patient_experience |> 
  pivot_wider(
    id_cols = starts_with("org"),
    names_from = measure_cd,
    values_from = prf_rate
  )

# 5.4.1 How does piviot_wider() work

df <- tribble(
  ~id, ~measurement, ~value,
  "A",        "bp1",    100,
  "B",        "bp1",    140,
  "B",        "bp2",    115, 
  "A",        "bp2",    120,
  "A",        "bp3",    105
)

# taking values from values 
# names from measurement
df |> 
  pivot_wider(
    names_from = measurement,
    values_from = value
  )
# pivot_wider() needs to first figure out what will go in the rows and columns. 
# The new column names will be the unique values of measurement.

df |> 
  distinct(measurement) |> 
  pull()

df |> 
  select(-measurement, -value) |> 
  distinct()

# pivot_wider() then combines these results to generate an empty data frame
df |> 
  select(-measurement, -value) |> 
  distinct() |> 
  mutate(x = NA, y = NA, z = NA)

# 6 Workflow: scripts and projects
# 6.1 scripts
# # Enter script editor by clicking the File menu, selecting New File, then R script, 
# or using the keyboard shortcut Cmd/Ctrl + Shift + N.

# 6.1.1 Running code

library(dplyr)
library(nycflights13)

not_cancelled <- flights |> 
 filter(!is.na(dep_delay)█, !is.na(arr_delay))

not_cancelled |> 
  group_by(year, month, day) |> 
  summarize(mean = mean(dep_delay))

#Execute the complete script in one step with Cmd/Ctrl + Shift + S.

# 6.1.2 RStudio diagnostics
# RStudio will highlight syntax errors with a red squiggly line and a cross in the sidebar
# Hover over to see the problem

# 6.1.3 Saving and naming
# # Numbering the key scripts makes it obvious in which order to run them and a consistent naming scheme makes it easier to see what varies.
#  EX:
#     01-load-data.R
#     02-exploratory-analysis.R
#     03-model-approach-1.R
#     04-model-approach-2.R
#     fig-01.png
#     fig-02.png
#     report-2022-03-20.qmd
#     report-2022-04-02.qmd
#     report-draft-notes.txt

# 6.2 Projects
# 6.2.1 What is the source of truth

# #Press Cmd/Ctrl + Shift + 0/F10 to restart R.
# Press Cmd/Ctrl + Shift + S to re-run the current script.

# 6.2.2 Where does your analysis live?

getwd()
#> [1] "/Users/hadley/Documents/r4ds"
# The working directory is considered 'Home'

# 6.2.3 RStudio projects

library(tidyverse)

ggplot(diamonds, aes(x = carat, y = price)) + 
  geom_hex()
ggsave("diamonds.png")

write_csv(diamonds, "data/diamonds.csv")

# 6.2.4 Relative and absolute paths

# Absolute paths point to the same place regardless of your working directory.
# You should never use absolute paths in your scripts, because they hinder sharing: 
# no one else will have exactly the same directory configuration as you.









