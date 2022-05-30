# assignment - dplyr & tidyr

rm(list = ls())
graphics.off()

library(dplyr)
library(tidyr)
library(ggplot2)
library(hflights)

# data

df <- hflights

# Exercise 1
# table dimensions 

df %>% nrow(); df %>% ncol()

df %>% 
  select(Origin, Dest) %>%
  distinct() %>% 
  pivot_longer(cols = everything(), names_to = "orig/dest",
               values_to = "airport") %>%
  distinct(airport) %>% 
  arrange(airport)
  