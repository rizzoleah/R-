# Chapter 24 Web Scraping
# 24.1 Introducation
# Web scraping is a very useful tool for extracting data from web pages.
# In this chapter, we’ll first discuss the ethics and legalities of scraping before we dive into the basics of HTML. You’ll then learn the basics of CSS selectors to locate specific elements on the page, and how to use rvest functions to get data from text and attributes out of HTML and into R
# We’ll then discuss some techniques to figure out what CSS selector you need for the page you’re scraping, before finishing up with a couple of case studies, and a brief discussion of dynamic websites

# 24.1.1 Prerequisites
library(tidyverse)
library(rvest)

# 24.2 Scraping ethics and legalities 
# Legalities depend a lot on where you live. However, as a general principle, if the data is public, non-personal, and factual, you’re likely to be ok
# If the data isn’t public, non-personal, or factual or you’re scraping the data specifically to make money with it, you’ll need to talk to a lawyer

# 24.2.1 Terms of service 
# Generally, to be bound to the terms of service, you must have taken some explicit action like creating an account or checking a box. This is why whether or not the data is public is important
# if you don’t need an account to access them, it is unlikely that you are bound to the terms of service

# 24.2.2 Personally identifiable information
# Even if the data is public, you should be extremely careful about scraping personally identifiable information like names, email addresses, phone numbers, dates of birth, etc
# If your work involves scraping personally identifiable information, we strongly recommend reading about the OkCupid study3 as well as similar studies with questionable research ethics involving the acquisition and release of personally identifiable information

# 24.2.3 Copyright
# Copyright law is complicated, but it’s worth taking a look at the US law which describes exactly what’s protected: “[…] original works of authorship fixed in any tangible medium of expression, […]
# This means that as long as you limit your scraping to facts, copyright protection does not apply

# 24.3 HTML basics
# To scrape webpages, you need to first understand a little bit about HTML, the language that describes web pages. HTML stands for HyperText Markup Language and looks something like this
<html>
  <head>
  <title>Page title</title>
  </head>
  <body>
  <h1 id='first'>A heading</h1>
    <p>Some text &amp; <b>some bold text.</b></p>
    <img src='myimg.png' width='100' height='100'>
</body>
      
# HTML has a hierarchical structure formed by elements which consist of a start tag (e.g., <tag>), optional attributes (id='first'), an end tag4 (like </tag>), and contents (everything in between the start and end tag)
# Web scraping is possible because most pages that contain data that you want to scrape generally have a consistent structure

# 24.3.1 Elements   
# There are over 100 HTML elements. Some of the most important are:
# Every HTML page must be in an <html> element, and it must have two children: <head>, which contains document metadata like the page title, and <body>, which contains the content you see in the browser.
# 
# Block tags like <h1> (heading 1), <section> (section), <p> (paragraph), and <ol> (ordered list) form the overall structure of the page.
#     
# Inline tags like <b> (bold), <i> (italics), and <a> (link) format text inside block tags.

# Most elements can have content in between their start and end tags. This content can either be text or more elements.
<p>
  Hi! My <b>name</b> is Hadley.
</p>


# 24.3.2 Attributes
# Tags can have named attributes which look like name1='value1' name2='value2'
# Two of the most important attributes are id and class, which are used in conjunction with CSS (Cascading Style Sheets) to control the visual appearance of the page
      
# 24.4 Extracting data
# To get started scraping, you’ll need the URL of the page you want to scrape, which you can usually copy from your web browser.
# You’ll then need to read the HTML for that page into R with read_html(). This returns an xml_document5 object which you’ll then manipulate using rvest functions
html <- read_html("http://rvest.tidyverse.org/")
html

# rvest also includes a function that lets you write HTML inline. We’ll use this a bunch in this chapter as we teach how the various rvest functions work with simple examples
html <- minimal_html("
  <p>This is a paragraph</p>
  <ul>
    <li>This is a bulleted list</li>
  </ul>
")
html

# Now that you have the HTML in R, it’s time to extract the data of interest. You’ll first learn about the CSS selectors that allow you to identify the elements of interest 
# and the rvest functions that you can use to extract data from them. Then we’ll briefly cover HTML tables, which have some special tools

# 24.4.1 Find elements
# CSS is short for cascading style sheets, and is a tool for defining the visual styling of HTML documents
# CSS selectors define patterns for locating HTML elements, and are useful for scraping because they provide a concise way of describing which elements you want to extract
# p selects all <p> elements.
# 
# .title selects all elements with class “title”.
# 
# #title selects the element with the id attribute that equals “title”. Id attributes must be unique within a document, so this will only ever select a single element.

html <- minimal_html("
  <h1>This is a heading</h1>
  <p id='first'>This is a paragraph</p>
  <p class='important'>This is an important paragraph</p>
")

# Use html_elements() to find all elements that match the selector
html |> html_elements("p")

html |> html_elements(".important")

html |> html_elements("#first")

# Another important function is html_element() which always returns the same number of outputs as inputs. If you apply it to a whole document it’ll give you the first match
html |> html_element("p")

# There’s an important difference between html_element() and html_elements() when you use a selector that doesn’t match any elements. html_elements() returns a vector of length 0, 
# where html_element() returns a missing value. This will be important shortly.
html |> html_elements("b")
html |> html_element("b")

# 24.4.2 Nesting selections 
# In most cases, you’ll use html_elements() and html_element() together, typically using html_elements() to identify elements that will become observations then using html_element() to find elements that will become variables
html <- minimal_html("
  <ul>
    <li><b>C-3PO</b> is a <i>droid</i> that weighs <span class='weight'>167 kg</span></li>
    <li><b>R4-P17</b> is a <i>droid</i></li>
    <li><b>R2-D2</b> is a <i>droid</i> that weighs <span class='weight'>96 kg</span></li>
    <li><b>Yoda</b> weighs <span class='weight'>66 kg</span></li>
  </ul>
  ")

# We can use html_elements() to make a vector where each element corresponds to a different character
characters <- html |> html_elements("li")
characters

# To extract the name of each character, we use html_element(), because when applied to the output of html_elements() it’s guaranteed to return one response per element
characters |> html_element("b")

# The distinction between html_element() and html_elements() isn’t important for name, but it is important for weight
# We want to get one weight for each character, even if there’s no weight <span>. That’s what html_element() does
characters |> html_element(".weight")

# html_elements() finds all weight <span>s that are children of characters. There’s only three of these, so we lose the connection between names and weights
characters |> html_elements(".weight")

# 24.4.3 Text and attributes 
# html_text2()6 extracts the plain text contents of an HTML element
characters |> 
  html_element("b") |> 
  html_text2()

characters |> 
  html_element(".weight") |> 
  html_text2()

# Note that any escapes will be automatically handled; you’ll only ever see HTML escapes in the source HTML, not in the data returned by rvest
# html_attr() extracts data from attributes
html <- minimal_html("
  <p><a href='https://en.wikipedia.org/wiki/Cat'>cats</a></p>
  <p><a href='https://en.wikipedia.org/wiki/Dog'>dogs</a></p>
")

html |> 
  html_elements("p") |> 
  html_element("a") |> 
  html_attr("href")

# html_attr() always returns a string, so if you’re extracting numbers or dates, you’ll need to do some post-processing

# 24.4.4 Tables
# If you’re lucky, your data will be already stored in an HTML table, and it’ll be a matter of just reading it from that table
#  it’ll have a rectangular structure of rows and columns, and you can copy and paste it into a tool like Excel

# HTML tables are built up from four main elements: <table>, <tr> (table row), <th> (table heading), and <td> (table data)
html <- minimal_html("
  <table class='mytable'>
    <tr><th>x</th>   <th>y</th></tr>
    <tr><td>1.5</td> <td>2.7</td></tr>
    <tr><td>4.9</td> <td>1.3</td></tr>
    <tr><td>7.2</td> <td>8.1</td></tr>
  </table>
  ")

# rvest provides a function that knows how to read this sort of data: html_table()
# It returns a list containing one tibble for each table found on the page. Use html_element() to identify the table you want to extract
html |> 
  html_element(".mytable") |> 
  html_table()

# Note that x and y have automatically been converted to numbers. This automatic conversion doesn’t always work, 
# so in more complex scenarios you may want to turn it off with convert = FALSE and then do your own conversion

# 24.5 Finding the right selectors
# You’ll often need to do some experimenting to find a selector that is both specific (i.e. it doesn’t select things you don’t care about) and sensitive (i.e. it does select everything you care about)
# There are two main tools that are available to help you with this process: SelectorGadget and your browser’s developer tools

# SelectorGadget is a javascript bookmarklet that automatically generates CSS selectors based on the positive and negative examples that you provide

# Every modern browser comes with some toolkit for developers, but we recommend Chrome, even if it isn’t your regular browser: its web developer tools are some of the best and they’re immediately available
# Right click on an element on the page and click Inspect. This will open an expandable view of the complete HTML page, centered on the element that you just clicked
# You can use this to explore the page and get a sense of what selectors might work. Pay particular attention to the class and id attributes, since these are often used to form the visual structure of the page, 
# and hence make for good tools to extract the data that you’re looking for

# 24.6 Putting it all together
# 24.6.1 StarWars
# rvest includes a very simple example in vignette("starwars"). This is a simple page with minimal HTML so it’s a good place to start
# You should be able to see that each movie has a shared structure that looks like this
<section>
  <h2 data-id="1">The Phantom Menace</h2>
  <p>Released: 1999-05-19</p>
  <p>Director: <span class="director">George Lucas</span></p>
  
  <div class="crawl">
  <p>...</p>
  <p>...</p>
  <p>...</p>
  </div>
  </section>
  
# Our goal is to turn this data into a 7 row data frame with variables title, year, director, and intro. We’ll start by reading the HTML and extracting all the <section> elements
  url <- "https://rvest.tidyverse.org/articles/starwars.html"
html <- read_html(url)

section <- html |> html_elements("section")
section

# This retrieves seven elements matching the seven movies found on that page, suggesting that using section as a selector is good. Extracting the individual elements is 
# straightforward since the data is always found in the text. It’s just a matter of finding the right selector
section |> html_element("h2") |> html_text2()

section |> html_element(".director") |> html_text2()

# Once we’ve done that for each component, we can wrap all the results up into a tibble
tibble(
  title = section |> 
    html_element("h2") |> 
    html_text2(),
  released = section |> 
    html_element("p") |> 
    html_text2() |> 
    str_remove("Released: ") |> 
    parse_date(),
  director = section |> 
    html_element(".director") |> 
    html_text2(),
  intro = section |> 
    html_element(".crawl") |> 
    html_text2()
)

# 24.6.2 IMBD top films
# For our next task we’ll tackle something a little trickier, extracting the top 250 movies from the internet movie database (IMDb)

# This data has a clear tabular structure so it’s worth starting with html_table()
url <- "https://web.archive.org/web/20220201012049/https://www.imdb.com/chart/top/"
html <- read_html(url)

table <- html |> 
  html_element("table") |> 
  html_table()
table

# we’ll rename the columns to be easier to work with, and remove the extraneous whitespace in rank and title. 
# We will do this with select() (instead of rename()) to do the renaming and selecting of just these two columns in one step. 
# Then we’ll remove the new lines and extra spaces, and then apply separate_wider_regex() (from Section 15.3.4) to pull out the title, year, and rank into their own variables
ratings <- table |>
  select(
    rank_title_year = `Rank & Title`,
    rating = `IMDb Rating`
  ) |> 
  mutate(
    rank_title_year = str_replace_all(rank_title_year, "\n +", " ")
  ) |> 
  separate_wider_regex(
    rank_title_year,
    patterns = c(
      rank = "\\d+", "\\. ",
      title = ".+", " +\\(",
      year = "\\d+", "\\)"
    )
  )
ratings

# Even in this case where most of the data comes from table cells, it’s still worth looking at the raw HTML. If you do so, you’ll discover that we can add a little extra data by using one of the attributes.
html |> 
  html_elements("td strong") |> 
  head() |> 
  html_attr("title")

# We can combine this with the tabular data and again apply separate_wider_regex() to extract out the bit of data we care about
ratings |>
  mutate(
    rating_n = html |> html_elements("td strong") |> html_attr("title")
  ) |> 
  separate_wider_regex(
    rating_n,
    patterns = c(
      "[0-9.]+ based on ",
      number = "[0-9,]+",
      " user ratings"
    )
  ) |> 
  mutate(
    number = parse_number(number)
  )

# 24.7 Dynamic sites
# you’ll hit a site where html_elements() and friends don’t return anything like what you see in the browser
# In many cases, that’s because you’re trying to scrape a website that dynamically generates the content of the page with javascript

# It’s still possible to scrape these types of sites, but rvest needs to use a more expensive process: fully simulating the web browser including running all javascript

