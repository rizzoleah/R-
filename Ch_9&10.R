# Chapter 9 Layers

# Prerequisites 
library(tidyverse)

# Chapter 9.1 Aesthetic Mappings

mpg 

# Left
ggplot(mpg, aes(x = displ, y = hwy, color = class)) +
  geom_point()

# Right
ggplot(mpg, aes(x = displ, y = hwy, shape = class)) +
  geom_point()

# check the warning of missing discrete values 
# and missing values outside the scale range

# mapping class, size, or alpha aesthetics

# Left
ggplot(mpg, aes(x = displ, y = hwy, size = class)) +
  geom_point()

# Right
ggplot(mpg, aes(x = displ, y = hwy, alpha = class)) +
  geom_point()

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(color = "blue")

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(color = "blue", size =4, shape=8)

# there are built-in shapes that are identified by numbers
# https://ggplot2.tidyverse.org/articles/ggplot2-specs.html

# 9.2.1 Exercises

# 2 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy, color = "blue"))
# default color applied because "blue" is not a variable in this case

ggplot(mpg,aes(x = displ, y = hwy))+
    goem_point(color="blue")
# color is applied to the geom_point directly

# 9.3 Geometric 

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point()

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_smooth()
#> `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

# Left
ggplot(mpg, aes(x = displ, y = hwy, shape = drv)) + 
  geom_smooth()

# Right
ggplot(mpg, aes(x = displ, y = hwy, linetype = drv)) + 
  geom_smooth()

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) + 
  geom_point() +
  geom_smooth(aes(linetype = drv))

# Left
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth()

# Middle
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(group = drv))

# Right
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(color = drv), show.legend = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(aes(color = class)) + 
  geom_smooth()

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  geom_point(
    data = mpg |> filter(class == "2seater"), 
    color = "red"
  ) +
  geom_point(
    data = mpg |> filter(class == "2seater"), 
    shape = "circle open", size = 3, color = "red"
  )

# Left
ggplot(mpg, aes(x = hwy)) +
  geom_histogram(binwidth = 2)

# Middle
ggplot(mpg, aes(x = hwy)) +
  geom_density()

# Right
ggplot(mpg, aes(x = hwy)) +
  geom_boxplot()

library(ggridges)

ggplot(mpg, aes(x = hwy, y = drv, fill = drv, color = drv)) +
  geom_density_ridges(alpha = 0.5, show.legend = FALSE)
#> Picking joint bandwidth of 1.28

# 9.3.1 Exercises 

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(color = drv), show.legend = FALSE)

# 9.4 Facets

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  facet_wrap(~cyl)
# splits a plot into subplots that each display one subset

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  facet_grid(drv ~ cyl)
# combination of two variables

ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  facet_grid(drv ~ cyl, scales = "free")

# 9.4.1 Exercises

# 2 
ggplot(mpg) + 
  geom_point(aes(x = drv, y = cyl))

# 3 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# 4 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) + 
  facet_wrap(~ cyl, nrow = 2)

# 6
ggplot(mpg, aes(x = displ)) + 
  geom_histogram() + 
  facet_grid(drv ~ .)

ggplot(mpg, aes(x = displ)) + 
  geom_histogram() +
  facet_grid(. ~ drv)

# 7 
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

# 9.5 Statistical transformation

ggplot(diamonds, aes(x = cut)) + 
  geom_bar()

# overriding the default stat 
diamonds |>
  count(cut) |>
  ggplot(aes(x = cut, y = n)) +
  geom_bar(stat = "identity")

# overriding default mapping
ggplot(diamonds, aes(x = cut, y = after_stat(prop), group = 1)) + 
  geom_bar()

# drawing attention to the statistical transformation in the code
ggplot(diamonds) + 
  stat_summary(
    aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )

# 9.5.1 Exercises

# 5
ggplot(diamonds, aes(x = cut, y = after_stat(prop))) + 
  geom_bar()
ggplot(diamonds, aes(x = cut, fill = color, y = after_stat(prop))) + 
  geom_bar()

# 9.6 Position adjustments

# Left
ggplot(mpg, aes(x = drv, color = drv)) + 
  geom_bar()

# Right
ggplot(mpg, aes(x = drv, fill = drv)) + 
  geom_bar()

# mapping the fill aesthetic to another variable
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar()

# Left
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(alpha = 1/5, position = "identity")

# Right
ggplot(mpg, aes(x = drv, color = class)) + 
  geom_bar(fill = NA, position = "identity")

# Left
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "fill")

# Right
ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "dodge")

# setting position adjustment 
ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point(position = "jitter")

# 9.6.1 Exercises
# 1 
ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point

# 2 
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(position = "identity")

# 9.7 Coordinate systems 

nz <- map_data("nz")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

# coord_polar() uses polar coordinates
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = clarity, fill = clarity), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1)

bar + coord_flip()
bar + coord_polar()

# 9.7.1 Exercises

# 3 
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()

# 9.8 The layers grammar of graphics 

ggplot(data = <DATA>) + 
  <GEOM_FUNCTION>(
    mapping = aes(<MAPPINGS>),
    stat = <STAT>, 
    position = <POSITION>
  ) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION>
  
# Chapter 10 Exploratory data analysis
# 10.2 Questions 
# What type of variation occurs within my variables?
# What type of covariation occurs between my variables?

# 10.3 Variation

ggplot(diamonds, aes(x = carat)) +
geom_histogram(binwidth = 0.5)

# 10.3.1 Typical values

smaller <- diamonds |> 
  filter(carat < 3)

ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

# 10.3.2 Unusual values

ggplot(diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.5)

# make it easy to see unusual values
ggplot(diamonds, aes(x = y)) + 
  geom_histogram(binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

unusual <- diamonds |> 
  filter(y < 3 | y > 20) |> 
  select(price, x, y, z) |>
  arrange(y)
unusual

# 10.4 Unusual values 

# drop the entire row with strange values
diamonds2 <- diamonds |> 
  filter(between(y, 3, 20))

# we recommend replaceing unusual values with missing values
diamonds2 <- diamonds |> 
  mutate(y = if_else(y < 3 | y > 20, NA, y))

ggplot(diamonds2, aes(x = x, y = y)) + 
  geom_point()

# suppress warning
ggplot(diamonds2, aes(x = x, y = y)) + 
  geom_point(na.rm = TRUE)

# to compare the scheduled departure times for cancelled and non-cancelled times
nycflights13::flights |> 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) |> 
  ggplot(aes(x = sched_dep_time)) + 
  geom_freqpoly(aes(color = cancelled), binwidth = 1/4)

# 10.5 Covariation
# 10.5.1 A categorical and a numerical variable
ggplot(diamonds, aes(x = price)) + 
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)





  



















