# 14 Stings
library(tidyverse)
library(babynames)

# 14.2 Creating a string
string1 <- "This is a string"
string2 <- 'If I want to include a "quote" inside a string, I use single quotes'

#14.2.1 Escapes 
double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"
backslash <- "\\"

#To see the raw contents of the string, use str_view()
x <- c(single_quote, double_quote, backslash)
x

str_view(x)

# 14.2.2 Raw strings
tricky <- "double_quote <- \"\\\"\" # or '\"'
single_quote <- '\\'' # or \"'\""
str_view(tricky)

# Do not fall into 'leaning toothpick syndrome
# use a raw string instead
tricky <- r"(double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'")"
str_view(tricky)

# 14.2.3 Other special characters
x <- c("one\ntwo", "one\ttwo", "\u00b5", "\U0001f604")
x

str_view(x)

# 14.3 Creating many strings from data
# 14.3.1 str_c()
#str_c() takes any number of vectors as arguments and returns a character vector
str_c("x", "y")
#> [1] "xy"
str_c("x", "y", "z")
#> [1] "xyz"
str_c("Hello ", c("John", "Susan"))
#> [1] "Hello John"  "Hello Susan"

df <- tibble(name = c("Flora", "David", "Terra", NA))
df |> mutate(greeting = str_c("Hi ", name, "!"))

#If you want missing values to display in another way, use coalesce() to replace them
df |> 
  mutate(
    greeting1 = str_c("Hi ", coalesce(name, "you"), "!"),
    greeting2 = coalesce(str_c("Hi ", name, "!"), "Hi!")
  )

# 14.3.2 str_glue()
#anything inside {} will be evaluated like it’s outside of the quotes
df |> mutate(greeting = str_glue("Hi {name}!"))

#instead of prefixing with special character like \, you double up the special characters:
df |> mutate(greeting = str_glue("{{Hi {name}!}}"))

# 14.3.3 str_flatten()
# takes a character vector and combines each element of the vector into a single string
str_flatten(c("x", "y", "z"))
#> [1] "xyz"
str_flatten(c("x", "y", "z"), ", ")
#> [1] "x, y, z"
str_flatten(c("x", "y", "z"), ", ", last = ", and ")
#> [1] "x, y, and z"

# works well with summarize()
df <- tribble(
  ~ name, ~ fruit,
  "Carmen", "banana",
  "Carmen", "apple",
  "Marvin", "nectarine",
  "Terence", "cantaloupe",
  "Terence", "papaya",
  "Terence", "mandarin"
)
df |>
  group_by(name) |> 
  summarize(fruits = str_flatten(fruit, ", "))

# 14.4 Extracting data from strings

# df |> separate_longer_delim(col, delim)
# df |> separate_longer_position(col, width)
# df |> separate_wider_delim(col, delim, names)
# df |> separate_wider_position(col, widths)

# 14.4.1 Seperating into rows
df1 <- tibble(x = c("a,b,c", "d,e", "f"))
df1 |> 
  separate_longer_delim(x, delim = ",")

df2 <- tibble(x = c("1211", "131", "21"))
df2 |> 
  separate_longer_position(x, width = 1)

# 14.4.2 Seperating into columns 
#To use separate_wider_delim(), we supply the delimiter and the names in two arguments:
df3 <- tibble(x = c("a10.1.2022", "b10.2.2011", "e15.1.2015"))
df3 |> 
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", "edition", "year")
  )

df3 |> 
  separate_wider_delim(
    x,
    delim = ".",
    names = c("code", NA, "year")
  )

# seperate_wider_position() 
#You can omit values from the output by not naming them
df4 <- tibble(x = c("202215TX", "202122LA", "202325CA")) 
df4 |> 
  separate_wider_position(
    x,
    widths = c(year = 4, age = 2, state = 2)
  )

# 14.4.3 Diagnosing widening problems
df <- tibble(x = c("1-1-1", "1-1-2", "1-3", "1-3-2", "1"))

df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z")
  )

# debugging the problem
debug <- df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_few = "debug"
  )

# x_ok lets you quickly find the inputs that failed
debug |> filter(!x_ok)

#too_few = "align_start" and too_few = "align_end"
# allow you to control where the NAs should go
df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_few = "align_start"
  )

df <- tibble(x = c("1-1-1", "1-1-2", "1-3-5-6", "1-3-2", "1-3-5-7-9"))

df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z")
  )

debug <- df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "debug"
  )

#you can either silently “drop” any additional pieces or “merge” them all into the final column
df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "drop"
  )

df |> 
  separate_wider_delim(
    x,
    delim = "-",
    names = c("x", "y", "z"),
    too_many = "merge"
  )

# 14.5 Letters
# 14.5.1 Length
# str_length() tells you the number of letters in the string
str_length(c("a", "R for data science", NA))

babynames |>
  count(length = str_length(name), wt = n)

babynames |> 
  filter(str_length(name) == 15) |> 
  count(name, wt = n, sort = TRUE)

# 14.5.2 Subsetting
# You can extract parts of a string using str_sub(string, start, end)
x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)
str_sub(x, -3, -1)
str_sub("a", 1, 5)

# We could use str_sub() with mutate() to find the first and last letter of each name
babynames |> 
  mutate(
    first = str_sub(name, 1, 1),
    last = str_sub(name, -1, -1)
  )

# 14.6 Non-english text
# 14.6.1 Encoding
# we can get at the underlying representation of a string using charToRaw()
charToRaw("Hadley")

# here are two inline CSVs with unusual encodings
x1 <- "text\nEl Ni\xf1o was particularly bad this year"
read_csv(x1)$text

x2 <- "text\n\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"
read_csv(x2)$text

# To read these correctly, you specify the encoding via the locale argument
read_csv(x1, locale = locale(encoding = "Latin1"))$text

read_csv(x2, locale = locale(encoding = "Shift-JIS"))$text

# 14.6.2 Letter variations
u <- c("\u00fc", "u\u0308")
str_view(u)

str_length(u)

str_sub(u, 1, 1)

# note that a comparison of these strings with == interprets these strings as different, 
# while the handy str_equal() function in stringr recognizes that both have the same appearance
u[[1]] == u[[2]]


str_equal(u[[1]], u[[2]])

# 14.6.3 Locale-dependent functions
# The rules for changing cases differ among languages
# your code might work differently if you share it with someone who lives in a different country. To avoid this problem, 
# stringr defaults to English rules by using the “en” locale and requires you to specify the locale argument to override it
str_to_upper(c("i", "ı"))
str_to_upper(c("i", "ı"), locale = "tr")

# 15 Regular expressions
library(tidyverse)
library(babynames)

# 15.2 Pattern basics
# str_view() will show only the elements of the string vector that match
str_view(fruit, "berry")

# Letters and numbers match exactly and are called literal characters
# punctuation characters, like ., +, *, [, ], and ?, have special meanings2 and are called metacharacters
str_view(c("a", "ab", "ae", "bd", "ea", "eab"), "a.")

str_view(fruit, "a...e")

# ? makes a pattern optional (i.e. it matches 0 or 1 times)
# + lets a pattern repeat (i.e. it matches at least once)
# * lets a pattern be optional or repeat (i.e. it matches any number of times, including 0).

# ab? matches an "a", optionally followed by a "b".
str_view(c("a", "ab", "abb"), "ab?")

# ab+ matches an "a", followed by at least one "b".
str_view(c("a", "ab", "abb"), "ab+")

# ab* matches an "a", followed by any number of "b"s.
str_view(c("a", "ab", "abb"), "ab*")

str_view(words, "[aeiou]x[aeiou]")
str_view(words, "[^aeiou]y[^aeiou]")

# Character classes are defined by []
str_view(words, "[aeiou]x[aeiou]")


str_view(words, "[^aeiou]y[^aeiou]")

# use alternation, |, to pick between one or more alternative patterns
str_view(fruit, "apple|melon|nut")

str_view(fruit, "aa|ee|ii|oo|uu")

# 15.3 Key functions
# 15.3.1 Detect matches
#str_detect() returns a logical vector that is TRUE if the pattern matches an element of the character vector and FALSE otherwise
str_detect(c("a", "b", "c"), "[aeiou]")

# str_detect() pairs well with filter()
babynames |> 
  filter(str_detect(name, "x")) |> 
  count(name, wt = n, sort = TRUE)

# sum(str_detect(x, pattern)) tells you the number of observations that match 
# mean(str_detect(x, pattern)) tells you the proportion that match
babynames |> 
  group_by(year) |> 
  summarize(prop_x = mean(str_detect(name, "x"))) |> 
  ggplot(aes(x = year, y = prop_x)) + 
  geom_line()

# 15.3.2 Count matches
# str_count(): rather than a true or false, it tells you how many matches there are in each string
x <- c("apple", "banana", "pear")
str_count(x, "p")

str_count("abababa", "aba")

str_view("abababa", "aba")

babynames |> 
  count(name) |> 
  mutate(
    vowels = str_count(name, "[aeiou]"),
    consonants = str_count(name, "[^aeiou]")
  )

babynames |> 
  count(name) |> 
  mutate(
    name = str_to_lower(name),
    vowels = str_count(name, "[aeiou]"),
    consonants = str_count(name, "[^aeiou]")
  )

# 15.3.3 Replace values
# str_replace() replaces the first match
# str_replace_all() replaces all matches
x <- c("apple", "pear", "banana")
str_replace_all(x, "[aeiou]", "-")

x <- c("apple", "pear", "banana")
str_remove_all(x, "[aeiou]")

# 15.3.4 Extract variables
df <- tribble(
  ~str,
  "<Sheryl>-F_34",
  "<Kisha>-F_45", 
  "<Brandon>-N_33",
  "<Sharon>-F_38", 
  "<Penny>-F_58",
  "<Justin>-M_41", 
  "<Patricia>-F_84", 
)

#To extract this data using separate_wider_regex() 
# we just need to construct a sequence of regular expressions that match each piece
df |> 
  separate_wider_regex(
    str,
    patterns = c(
      "<", 
      name = "[A-Za-z]+", 
      ">-", 
      gender = ".",
      "_",
      age = "[0-9]+"
    )
  )

# 15.4 Pattern details 
# 15.4.1 Escaping
# To create the regular expression \., we need to use \\.
dot <- "\\."

# But the expression itself only contains one \
str_view(dot)

# And this tells R to look for an explicit .
str_view(c("abc", "a.c", "bef"), "a\\.c")

x <- "a\\b"
str_view(x)

str_view(x, "\\\\")

str_view(x, r"{\\}")

# If you’re trying to match a literal ., $, |, *, +, ?, {, }, (, ), 
# there’s an alternative to using a backslash escape: 
# you can use a character class: [.], [$], [|], … all match the literal values.
str_view(c("abc", "a.c", "a*c", "a c"), "a[.]c")

str_view(c("abc", "a.c", "a*c", "a c"), ".[*]c")

# 15.4.2 Anchors
# f you want to match at the start or end 
# you need to anchor the regular expression using ^ to match the start or $ to match the end
str_view(fruit, "^a")


str_view(fruit, "a$")

# To force a regular expression to match only the full string, anchor it with both ^ and $'
str_view(fruit, "apple")

str_view(fruit, "^apple$")

# You can also match the boundary between words (i.e. the start or end of a word) with \b.
x <- c("summary(x)", "summarize(df)", "rowsum(x)", "sum(x)")
str_view(x, "sum")

str_view(x, "\\bsum\\b")

# anchors will produce a zero-width match
str_view("abc", c("$", "^", "\\b"))

str_replace_all("abc", c("$", "^", "\\b"), "--")

# 15.4.3 Character classes
# A character class, or character set, allows you to match any character in a set.
# - defines a range, e.g., [a-z] matches any lower case letter and [0-9] matches any number.
# \ escapes special characters, so [\^\-\]] matches ^, -, or ].

x <- "abcd ABCD 12345 -!@#%."
str_view(x, "[abc]+")

str_view(x, "[a-z]+")

str_view(x, "[^a-z0-9]+")

# You need an escape to match characters that are otherwise
# special inside of []
str_view("a-b-c", "[a-c]")

str_view("a-b-c", "[a\\-c]")

#Some character classes are used so commonly that they get their own shortcut.
# \d matches any digit;
# \D matches anything that isn’t a digit.
# 
# \s matches any whitespace (e.g., space, tab, newline);
# \S matches anything that isn’t whitespace.
# 
# \w matches any “word” character, i.e. letters and numbers;
# \W matches any “non-word” character.

x <- "abcd ABCD 12345 -!@#%."
str_view(x, "\\d+")

str_view(x, "\\D+")

str_view(x, "\\s+")

str_view(x, "\\S+")

str_view(x, "\\w+")

str_view(x, "\\W+")

# 15.4.4 Quantifiers
# Quantifiers control how many times a pattern matches
# {n} matches exactly n times.
# {n,} matches at least n times.
# {n,m} matches between n and m times.

# 15.4.5 Operator precedence and parentheses
# Think of PEMDAS or BEDMAS rules
#  quantifiers have high precedence and alternation has low precedence 
# which means that ab+ is equivalent to a(b+), and ^a|b$ is equivalent to (^a)|(b$)

# 15.4.6 Grouping and capturing 
# parentheses create capturing groups that allow you to use sub-components of the match
str_view(fruit, "(..)\\1")

str_view(words, "^(..).*\\1$")

sentences |> 
  str_replace("(\\w+) (\\w+) (\\w+)", "\\1 \\3 \\2") |> 
  str_view()

# If you want to extract the matches for each group you can use str_match()
sentences |> 
  str_match("the (\\w+) (\\w+)") |> 
  head()

sentences |> 
  str_match("the (\\w+) (\\w+)") |> 
  as_tibble(.name_repair = "minimal") |> 
  set_names("match", "word1", "word2")

# You can create a non-capturing group with (?:)
x <- c("a gray cat", "a grey dog")
str_match(x, "gr(e|a)y")

str_match(x, "gr(?:e|a)y")

# 15.5 Pattern control
# 15.5.1 Regex flags
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")

str_view(bananas, regex("banana", ignore_case = TRUE))

# If you’re doing a lot of work with multiline strings (i.e. strings that contain \n), dotalland multiline may also be useful
# dotall = TRUE lets . match everything, including \n:
x <- "Line 1\nLine 2\nLine 3"
str_view(x, ".Line")
str_view(x, regex(".Line", dotall = TRUE))

# multiline = TRUE makes ^ and $ match the start and end of each line rather than the start and end of the complete string:
x <- "Line 1\nLine 2\nLine 3"
str_view(x, "^Line")

str_view(x, regex("^Line", multiline = TRUE))

phone <- regex(
  r"(
    \(?     # optional opening parens
    (\d{3}) # area code
    [)\-]?  # optional closing parens or dash
    \ ?     # optional space
    (\d{3}) # another three numbers
    [\ -]?  # optional space or dash
    (\d{4}) # four more numbers
  )", 
  comments = TRUE
)

str_extract(c("514-791-8141", "(123) 456 7890", "123456"), phone)

# 15.5.2 Fixed Matches 
# You can opt-out of the regular expression rules by using fixed()
str_view(c("", "a", "."), fixed("."))

# fixed() also gives you the ability to ignore case
str_view("x X", "X")

str_view("x X", fixed("X", ignore_case = TRUE))

# If you’re working with non-English text, you will probably want coll() instead of fixed()
str_view("i İ ı I", fixed("İ", ignore_case = TRUE))

str_view("i İ ı I", coll("İ", ignore_case = TRUE, locale = "tr"))

# 15.6 Practice 
# 15.6.1 Check your work
str_view(sentences, "^The")

# We need to make sure that the “e” is the last letter in the word, which we can do by adding a word boundary:
str_view(sentences, "^The\\b")

str_view(sentences, "^She|He|It|They\\b")

str_view(sentences, "^(She|He|It|They)\\b")

pos <- c("He is a boy", "She had a good time")
neg <- c("Shells come from the sea", "Hadley said 'It's a great day'")

pattern <- "^(She|He|It|They)\\b"
str_detect(pos, pattern)

str_detect(neg, pattern)

# 15.6.2 Boolean operations 
# finding words that only contain consonants
# create a character class that contains all letters
# except for the vowel
str_view(words, "^[^aeiou]+$")

#Instead of looking for words that contain only consonants, we could look for words that don’t contain any vowels:
str_view(words[!str_detect(words, "[aeiou]")])

# looking for all words that contain an "a" followed by a "b" or
# a "b" followed by an "a"
str_view(words, "a.*b|b.*a")

# combining the results of two calls to str_detect()
words[str_detect(words, "a") & str_detect(words, "b")]

# to see a word that contains all vowels
# we would need to generate 5! (120) different patterns
words[str_detect(words, "a.*e.*i.*o.*u")]

words[str_detect(words, "u.*o.*i.*e.*a")]

# its easier to combine five calls to str_detect()
words[
  str_detect(words, "a") &
    str_detect(words, "e") &
    str_detect(words, "i") &
    str_detect(words, "o") &
    str_detect(words, "u")
]

# 15.6.3 Creating a pattern with code
# to find all sentences that mention color
str_view(sentences, "\\b(red|green|blue)\\b")

#as the number of colors grows, it would quickly get tedious to construct this pattern by hand
# we can store the colors in a vector by
# creating the pattern from the vector using str_c() and str_flatten()
rgb <- c("red", "green", "blue")
str_c("\\b(", str_flatten(rgb, "|"), ")\\b")

str_view(colors())

# eliminate numbered variants
cols <- colors()
cols <- cols[!str_detect(cols, "\\d")]
str_view(cols)

# we can turn this into one giant pattern
pattern <- str_c("\\b(", str_flatten(cols, "|"), ")\\b")
str_view(sentences, pattern)

# 15.7 Regular expressions in other places
# 15.7.2 Base R
# apropos(pattern) searches all objects available from the global environment that match the given pattern
apropos("replace")

# list.files(path, pattern) lists all files in path that match a regular expression pattern.
head(list.files(pattern = "\\.Rmd$"))






                           
                           
                           
