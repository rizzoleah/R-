library(tidyverse)
library(ggplot2)

# Load the dataset
df <- read.csv("Visualization_Project_Video_data.csv")

# Convert trending_date to Date format
df <- df |> mutate(trending_date = as.Date(trending_date, format="%Y-%m-%d"))

# a) Count of videos by trending date
count_by_date <- df |> 
  group_by(trending_date) |> 
  summarise(count = n())

ggplot(count_by_date, aes(x = trending_date, y = count)) +
  geom_bar(stat = "identity") + 
  labs(title = "Count of Videos by Trending Date", x = "Trending Date", y = "Count")

# b) Channel with highest number of videos trending each date
top_channel <- df |> 
  count(channel_title, sort = TRUE) |> 
  slice(1) |> 
  pull(channel_title)

trending_top_channel <- df |> 
  filter(channel_title == top_channel) |> 
  group_by(trending_date) |> 
  summarise(count = n())

ggplot(trending_top_channel, aes(x = trending_date, y = count)) +
  geom_col() +
  labs(title = paste("Trending Videos for", top_channel), x = "Trending Date", y = "Count")

# c) Rank Channel_titles by Likes to Views ratio
channel_rank <- df |> 
  group_by(channel_title) |> 
  summarise(like_view_ratio = sum(likes, na.rm=TRUE) / sum(views, na.rm=TRUE)) |> 
  arrange(desc(like_view_ratio))


# d) Rank Titles by Likes / (Likes + Dislikes)
title_rank <- df |> 
  mutate(like_dislike_ratio = likes / (likes + dislikes)) |> 
  select(title, like_dislike_ratio) |> 
  arrange(desc(like_dislike_ratio))


# e) Videos per channel with ratings disabled
ratings_disabled_count <- df |> 
  filter(ratings_disabled == TRUE) |> 
  count(channel_title, sort = TRUE)

ggplot(ratings_disabled_count, aes(x = fct_reorder(channel_title, n), y = n)) +
  geom_col() +
  coord_flip() +
  labs(title = "Videos with Ratings Disabled per Channel", x = "Channel", y = "Count")

# f) Difference in likes when comments are disabled
df |> 
  group_by(comments_disabled) |> 
  summarise(avg_likes = mean(likes, na.rm=TRUE)) |> 
  ggplot(aes(x = as.factor(comments_disabled), y = avg_likes, fill = as.factor(comments_disabled))) +
  geom_col() +
  labs(title = "Average Likes for Videos with and without Comments Disabled", x = "Comments Disabled", y = "Average Likes")

# g) Difference in total likes for videos with "funny" tag
df <- df |> mutate(has_funny_tag = str_detect(str_to_lower(tags), "funny"))

funny_likes <- df |> 
  group_by(has_funny_tag) |> 
  summarise(total_likes = sum(likes, na.rm=TRUE))

ggplot(funny_likes, aes(x = as.factor(has_funny_tag), y = total_likes, fill = as.factor(has_funny_tag))) +
  geom_col() +
  labs(title = "Total Likes for Videos With and Without 'Funny' Tag", x = "Contains 'Funny' Tag", y = "Total Likes")

# h) Rank Channels by various ratios
channel_ratios <- df |> 
  group_by(channel_title) |> 
  summarise(like_view = sum(likes, na.rm=TRUE) / sum(views, na.rm=TRUE),
            dislike_view = sum(dislikes, na.rm=TRUE) / sum(views, na.rm=TRUE),
            net_like_view = sum(likes - dislikes, na.rm=TRUE) / sum(views, na.rm=TRUE)) |> 
  arrange(desc(like_view))


