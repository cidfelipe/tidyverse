# 1 tidyverse essentials:

rm(list = ls())
graphics.off()

#install the packages
install.packages("tidyverse")
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("ggplot2")


#load the package
library(dplyr)
library(tidyr)
library(ggplot2)
library(tidyverse)

#inspect the data
help("mpg")

df <- mpg
View(mpg)
print(df)

str(df)
nrow(df); ncol(df)

#manipulando variaveis (colunas)
#select() - selecao de colunas
##extract: manufacturer, model, year

select(df, manufacturer, model, year)
df.car.info <- select(df, manufacturer, model, year)

## columns that begin with letter: "m"

select(df, starts_with(match = "m"))

## columns that contain with letter: "r"

select(df, contains(match = "r"))

## columns that end with letter: "y"

select(df, ends_with(match = "y"))

## select columns by column index (positions)

select(df, 1:3)
select(df, c(2, 5, 7))

#select(df, 9:11) mesmo comando da linha abaixo
select(df, (ncol(df)-2):ncol(df))


#rename() - rename columns
#rename "manufacturer" and "model"

df1 <- rename(df,
              mnfc = manufacturer,
              mod = model)

#select columns and rename columns in one call

df1 <- select(df, mnfc = manufacturer,
       mod = model,
       everything())


################################################################################
################################################################################
#AULA 2

#mutate() - create a new variable
#create variable: average between highway and city miles per gallon

df <- mutate(df, 'avgmilespergalon' = (cty + hwy) / 2)


df <- mutate(df, car = paste(manufacturer, model, sep = " "),
             'cyl / trans' = paste(cyl, " cylinders", " / ", trans, "transmission", sep = ""))


#transmute() - create a new variable and drop other variables

df2 <- transmute(df, 
          'avgmilespergalon' = (cty + hwy) / 2)

df2 <- transmute(df, car = paste(manufacturer, model, sep = " "),
             'cyl / trans' = paste(cyl, " cylinders", " / ", trans, "transmission", sep = ""))


#resetando os dados
rm(df, df2)

df <- mpg

#manipulate cases (rows)

##filter() -  filter rows by condition

#filter where manufacturer = "audi"
filter(df, manufacturer == "audi")

#filter where manufacturer = "audi" and year = 1999
#filter(df, manufacturer == "audi", year == 1999) mesmo comando da linha abaixo
#operador and (&)
filter(df, manufacturer == "audi" & year == 1999)

##where a manufacturer is either "audi"or "dodge"
#operador or (|)

df1 <- filter(df, manufacturer == "audi" | manufacturer == "dodge")

#hwy is greater or equal than 30
filter(df, hwy >= 30)

#where year is not equal 1999
filter(df, year != 1999)


#slice() - extract rows by position

## extract firs 5 rows
slice(df, 1:5)

## extract rows from 20th row up to 30 row
slice(df, 20:30)

#extract last 10 rowns
slice(df, (nrow(df)-9):nrow(df))


################################################################################
################################################################################
#aula 3


#arrange() - sort rowns

## sort rows by year (ascending order)
arrange(df, year)


## sort rows by year (descending order)
arrange(df, desc(year))

##sort rowns by year (asc. order), cyl and displ

df.sort <- arrange(df, year, cyl, displ)


# distinct() - unique rows

## our small example

df.example <- data.frame(id = 1:3,
                         name = c("John", "Max", "Julia"))

df.example <- bind_rows(df.example, slice(df.example, 2)) #duplicando a segunda linha

df.example <- arrange(df.example, id)
df.example

#remove duplicate row
distinct(df.example)

#criando tabela com valores duplicardos a partir do df dos carros
df.dupl <- select(df, manufacturer, model)

df.nodupl <- distinct(df.dupl)




#sample rowns

## sample() - randomly select n different rows
set.seed(567)

## 10 ramdonly selected rows without replacement
sample_n(df, size = 10, replace = F)

## 10 ramdonly selected rows with replacement
sample_n(df, size = 10, replace = T)

# sample_frac() - randomly select a fraction of rows

## 10% of table rows rand. selected
sample_frac(df, size = 0.1, replace = F)


# summarize() - apply summary functions on our table and create sumaries

## calculate average hwy
summarise(df, 'mean hwy' = mean(hwy))


## count table rowns, count distinc car models
summarise(df, 
          rows = n(),
          'nr models' = n_distinct(model))


## calculate min / max value hwy and cty
summarise(df, 
          'min hwy' = min(hwy),
          'min cty' = min(cty),
          'max hwy' = max(hwy),
          'max cty' = max(cty))


################################################################################
################################################################################

#group_by and count()

#group_by() - gruoup cases using one or more grouping variables

##group by manufacturer

df
group_by(df, manufacturer)

# combine summarise & group_by() - summary statistics for groupe data

##count nr of cars per each manufacturer

summarise(group_by(df, manufacturer),
          cars = n())

#calculate min / max for hwy and cty group by model

df.group_model <- group_by(df, model)


summarise(df.group_model, 
          'min hwy' = min(hwy),
          'min cty' = min(cty),
          'max hwy' = max(hwy),
          'max cty' = max(cty))


#count() - count rows for group variables

##count number of table rows

count(df)

#count number of rows /cars per model

count(df, model)


################################################################################
## OPERADOR PIPE %>%
################################################################################

# pipe operator %>%
# chain dplyr functions using pipe operator
# every step is executed in a single pipeline

## count number of cars where manufacturer is "audi"

df %>% 
  filter(manufacturer == "audi") %>% 
  count()


## filter rows for manufacturer "dodge" or "chevrolet" and 
## select only columns manufacturer, model, year and class

df1 <- df %>% 
  filter(manufacturer == "dodge" | manufacturer == "chevrolet") %>% 
  select(manufacturer, model, year, class)

## calculate avg., hwy and count number of cars for each
## manufacturer, model, class, transmission type
## filter results where average hwy is greater then 30
## show results in descending order bases on average hwy


df2 <- df %>% 
  group_by(manufacturer, model, class, trans) %>% 
  summarise(`meanhwy`= mean(hwy), 
            cars = n()) %>% 
  ungroup() %>%
  filter(`meanhwy` > 30) %>% 
  arrange(desc(`meanhwy`))
  

  
################################################################################
## PIVOT TABLE
################################################################################


# pivoting - convert table from long to wide format (and vice versa)
## let's create a simple table in long format 


table.long <- data.frame(id = 1:6,
                         type = c("a", "b", "a", "c", "c", "a"),
                         count = c(20, 50, 45, 15, 12, 5))

table.long


# pivot_wider() - converts long data to wide data

## convert to wide format - each "type" is written in its own column

table.wide <-  pivot_wider(table.long,
                           names_from = type,
                           values_from = count)


table.wide


#pivot_longer() - converts wide data to long data

## convert table back to long format

table.long1 <- pivot_longer(table.wide,
                            cols = c("a", "b", "c"),
                            names_to = "type",
                            values_to = "count", 
                            values_drop_na = T)



table.long1


# now let's pivot our car dataset

# filter rows where manufacturer is "jeep" / "land rover" / "hyundai"
# select model, trans., hwy
# calculate avg. hwy for each model and trans.
# this will be long table format

df.long <- df %>% 
  filter(manufacturer %in% c("jeep", "land rover", "hyundai")) %>% 
  select(model, trans, hwy) %>% 
  group_by(model, trans) %>% 
  summarise('mean hwy' = mean(hwy)) %>% 
  ungroup()


df.long

#Now convert long to wide format -  where trans. in transformed into columns

df.wide <- df.long %>% 
  pivot_wider(names_from = trans,
              values_from = 'mean hwy')

# convert back to long format

df.long1 <- df.wide %>% 
  pivot_longer(-model,#exclude column model and use all remaining columns for pivoting
               names_to = "trans",
               values_to = 'mean why',
               values_drop_na = T
               ) %>% 
  filter(!is.na('mean why'))


df.long1
  

################################################################################
## SEPARATE AND UNITE COLUMNS
################################################################################
  
# separating & uniting columns

## lets' create a table with date column (generate date for 1 years)

dates <- seq.Date(from = as.Date("2021-01-01"), to = as.Date("2021-12-31"), by = "day")
table <- data.frame(date = dates)  
table %>% head()
table %>% tail()

# separate() split one column into multiple columns

## split date into year, month and day of month
## remove leading zeros where is necessary
## sort columns

table.sep <- table %>%
  separate(data = .,
           col = date,
           into = c("year", "month", "dayofmonth"),
           sep = "-") %>% 
#  mutate(month = as.numeric(month),
#         dayofmonth = as.numeric(dayofmonth)) %>% 
  mutate_at(.tbl = .,
            .vars = c("year", "month", "dayofmonth"),
            .funs = as.numeric) %>% 
  arrange(year, month, dayofmonth)
  
  
  
  
  
  
  
  
  
  
  

















