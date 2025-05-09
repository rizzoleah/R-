# Chapter 29 Quarto formats

# 29.1 Introduction
# So far, you’ve seen Quarto used to produce HTML documents. This chapter gives a brief overview of some of the many other types of output you can produce with Quarto.

# There are two ways to set the output of a document
# Permanently, by modifying the YAML header:

title: "Diamond sizes"
format: html

# Transiently, by calling quarto::quarto_render() by hand:

quarto::quarto_render("diamond-sizes.qmd", output_format = "docx")

# This is useful if you want to programmatically produce multiple types of output since the output_format argument can also take a list of values.

quarto::quarto_render("diamond-sizes.qmd", output_format = c("docx", "pdf"))

# 29.2 Output options 
# Many formats share some output options (e.g., toc: true for including a table of contents)
# others have options that are format specific (e.g., code-fold: true collapses code chunks into a <details> tag for HTML output 
# so the user can display it on demand, it’s not applicable in a PDF or Word document)

# To override the default options, you need to use an expanded format field.
format:
  html:
  toc: true
toc_float: true

# You can even render to multiple outputs by supplying a list of formats:
format:
  html:
  toc: true
toc_float: true
pdf: default
docx: default

# Note the special syntax (pdf: default) if you don’t want to override any default options.
# To render to all formats specified in the YAML of a document, you can use output_format = "all".
quarto::quarto_render("diamond-sizes.qmd", output_format = "all")

# 29.3 Documents 
# The previous chapter focused on the default html output. There are several basic variations on that theme, generating different types of documents.
# pdf (makes a PDF with LaTex), docx (Microsoft Word), odt (OpenDocument Text), rtf (Rich Text Format), gfm (GitHub Flavored Markdown), ipynb (Jupyter Notebooks)

# Remember, when generating a document to share with decision-makers, you can turn off the default display of code by setting global options in the document YAML
execute:
  echo: false

# For html documents another option is to make the code chunks hidden by default, but visible with a click
format:
  html:
  code: true

# 29.4 Presentations
# Presentations work by dividing your content into slides, with a new slide beginning at each second (##) level header. Additionally, first (#) level headers 
# indicate the beginning of a new section with a section title slide that is, by default, centered in the middle.
# Quarto supports a variety of presentation formats, including:
#   
# revealjs - HTML presentation with revealjs
# 
# pptx - PowerPoint presentation
# 
# beamer - PDF presentation with LaTeX Beamer.

# 29.5 Interactivity 
# Just like any HTML document, HTML documents created with Quarto can contain interactive components as well

# 29.5.1 htmlwidgets
# HTML is an interactive format, and you can take advantage of that interactivity with htmlwidgets, R functions that produce interactive HTML visualizations.
library(leaflet)
leaflet() |>
  setView(174.764, -36.877, zoom = 16) |> 
  addTiles() |>
  addMarkers(174.764, -36.877, popup = "Maungawhau") 

# There are many packages that provide htmlwidgets, including:
# 
# dygraphs for interactive time series visualizations.
# 
# DT for interactive tables.
#
# threejs for interactive 3d plots.
# 
# DiagrammeR for diagrams (like flow charts and simple node-link diagrams)

# 29.5.2 Shiny
# shiny is a package that allows you to create interactivity using R code, not JavaScript.

# To call Shiny code from a Quarto document, add server: shiny to the YAML header
title: "Shiny Web App"
format: html
server: shiny

# Then you can use the “input” functions to add interactive components to the document
library(shiny)

textInput("name", "What is your name?")
numericInput("age", "How old are you?", NA, min = 0, max = 150)

# And you also need a code chunk with chunk option context: server which contains the code that needs to run in a Shiny server
# You can then refer to the values with input$name and input$age, and the code that uses them will be automatically re-run whenever they change
# We can’t show you a live shiny app here because shiny interactions occur on the server-side. This means that you can write interactive apps without knowing JavaScript, but you need a server to run them on

# 29.6 Websites and books
# With a bit of additional infrastructure, you can use Quarto to generate a complete website or book
# Put your .qmd files in a single directory. index.qmd will become the home page.

# Add a YAML file named _quarto.yml that provides the navigation for the site. In this file, set the project type to either book or website, e.g.
project:
  type: book

# he following _quarto.yml file creates a website from three source files: index.qmd (the home page), viridis-colors.qmd, and terrain-colors.qmd
project:
  type: website

website:
  title: "A website on color scales"
navbar:
  left:
  - href: index.qmd
text: Home
- href: viridis-colors.qmd
text: Viridis colors
- href: terrain-colors.qmd
text: Terrain colors

# The _quarto.yml file you need for a book is very similarly structured. 
# The following example shows how you can create a book with four chapters that renders to three different outputs (html, pdf, and epub)
project:
  type: book

book:
  title: "A book on color scales"
author: "Jane Coloriste"
chapters:
  - index.qmd
- intro.qmd
- viridis-colors.qmd
- terrain-colors.qmd

format:
  html:
  theme: cosmo
pdf: default
epub: default

# Based on the _quarto.yml file, RStudio will recognize the type of project you’re working on, and add a Build tab to the IDE that you can use to render and preview your websites and books

# 29.7 Other formats
#  Quarto offers even more output formats:
# 
# You can write journal articles using Quarto Journal Templates: https://quarto.org/docs/journals/templates.html.
# 
# You can output Quarto documents to Jupyter Notebooks with format: ipynb: https://quarto.org/docs/reference/formats/ipynb.html.
# 
# See https://quarto.org/docs/output-formats/all-formats.html for a list of even more formats.

