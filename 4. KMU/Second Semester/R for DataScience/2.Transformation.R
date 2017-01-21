library(tidyverse)
library(nycflights13)

# 5. Data Transformation 
# 5.1.3 dplyr basics
# 
# In this chapter you are going to learn the five key dplyr functions that allow you to solve the vast majority of your data manipulation challenges:
#   
# Pick observations by their values (filter()).
# Reorder the rows (arrange()).
# Pick variables by their names (select()).
# Create new variables with functions of existing variables (mutate()).
# Collapse many values down to a single summary (summarise()).

flights # 2013년 nyc에 이착률 비행기.

# 5.2 Filter rows with filter()

# data.table을 데이터 규모가 큰 경우 dplyr보단 더 많이 사용하지만 불편하다.

filter(flights, month==1, day==1)
flights %>% filter(month==1,day==1)

## Logical 
## | vs || (or) 
c(1,2,3) > 2 
# F, F ,T 

c(1,2,3) > 2  | c(4,5,6) <= 4  # 짝을 지어서 한다. 순서대로 1>2,4<=4 이런식으로 짝을 지어서 
c(1,2,3) > 2  || c(4,5,6) <= 4 # 맨앞에꺼 하나만 가지고 한다. 

filter(flights, month==11 | month==12)
filter(flights, month %in% c(11,12)) # 중의 연산자 : month가 11월 12월 중.


# 5.2.3 Na Missing Value
is.na(NA)
!is.na("123")

NA ^ 0 # -> 1 모든 수의 0 승은 1 
NA | TRUE
FALSE & NA

## but 
NA * 0 #NA....?

#5.2.4 Exercises
# 1. Find all flights that
## 1. Had an arrival delay of two or more hours
filter(flights, arr_delay>=120)
## 2. Flew to Houston (IAH or HOU)
filter(flights, dest %in% c('IAH','HOU'))
## 3. Were operated by United, American, or Delta
unique(flights$carrier)
filter(flights, carrier %in% c('UA','AA','DL'))
## 4. Departed in summer (July, August, and September)
filter(flights, time_hour >= '2013-07-01' & time_hour <= '2013-09-30')
filter(flights, month %in% 7:9)
filter(flights, between(month,7,9))
## 5. Arrived more than two hours late, but didn’t leave late
filter(flights, dep_delay<=0, arr_delay > 120)
## 6. Were delayed by at least an hour, but made up over 30 minutes in flight
filter(flights, dep_delay >= 60, arr_delay < dep_delay - 30)
## 7. Departed between midnight and 6am (inclusive)
filter(flights, dep_time <= 600)
# 2. Another useful dplyr filtering helper is between(). What does it do? Can you use it to simplify the code needed to answer the previous challenges?
# 3. How many flights have a missing dep_time? What other variables are missing? What might these rows represent?
filter(flights,is.na(dep_time))
# 4 Why is NA ^ 0 not missing? Why is NA | TRUE not missing? Why is FALSE & NA not missing? Can you figure out the general rule? (NA * 0 is a tricky counterexample!)

# 5.3 Arrange
arrange(flights, arr_delay)
arrange(flights, desc(arr_delay))

# 5.4 Select
select(flights, year, month,day)
select(flights, year:day)
select(flights, -(year:day))

# starts_with("abc"): matches names that begin with “abc”.
select(flights, starts_with('dep'))
# ends_with("xyz"): matches names that end with “xyz”.
select(flights, ends_with('delay'))
select(flights, ends_with('delay'),starts_with('dep'))

# contains("ijk"): matches names that contain “ijk”.
select(flights, contains('d'))
# matches("(.)\\1"): selects variables that match a regular expression. This one matches any variables that contain repeated characters. You’ll learn more about regular expressions in strings.
## Regular Expression.
select(flights, matches('d[aeiou]')) # d뒤에 aeiou가 붙는 경우 

# num_range("x", 1:3) matches x1, x2 and x3. 동일한 변수 뒤에 숫자가 붙은 경우 

## Rename
rename(flights, tail_num = tailnum)

## Everything
select(flights, time_hour, air_time, everything())


# 5.5 Add New variables with mutate()
flights_sml <- select(flights, 
                      year:day, 
                      ends_with("delay"), 
                      distance, 
                      air_time
)
mutate(flights_sml, gain=arr_delay - dep_delay, speed = distance / air_time * 60)

## pipe
arrange(filter(flights,month==1),day)
flights %>% filter(month==1) %>% arrange(day)

## Summarize 
summarise(flights, delay=mean(dep_delay,na.rm=T))

by_day <- flights %>% group_by(year,month,day) %>% summarise(delay=mean(dep_delay,na.rm=T))
by_day

flights %>% group_by(year,month,day) %>% summarise(delay=mean(dep_delay,na.rm=T), cnt=n())

# 5. 탐색적 모형 분석 
# 모형이 있는 것이 아니라, 그냥 데이터를 뒤져보는 것을 말한다.
# 환인적 탐색 분석보다 탐색적 모형분석이 오래 걸린다.
# - 그래프를 그려본다. (특징을 슥 찾아본다.)

ggplot(data=diamonds) + geom_histogram(aes(x=carat))
ggplot(data=diamonds) + geom_histogram(aes(x=carat), binwidth = 0.01)
# 특이한 패턴이 나온다. 특정한 무게에서 짤라서 쓰지 않을까?

# 기술적으로 대단한 것은 아니지만, 발상이 대단한 부분이다.
# 양봉 그래프의 경우 boxplot을 그리게 되면 중간의 데이터가 있던 없던 동일한 모양이 나오는데 
# Histogram을 세로로 세운다면 정보의 손실이 없다.
diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = n))


## Box plot에 아웃라이어
ggplot(mpg,aes(class,hwy)) + 
  geom_boxplot(outlier.alpha = 0) + 
  geom_text(aes(label=rownames(mpg)))
### 보기 힘들다 (보기 안좋다.)-> outlier.alpha = 0 추가 
### Oulier 가 아닌 경우는 보기 싫다.

### 1. 간단하게 dplyr IQR 과 median 밖은 outlier

limit <- mpg %>% group_by(class) %>% 
  summarise(first = quantile(hwy,.25),second = quantile(hwy,.5) ,third = quantile(hwy,0.75)) %>%
  mutate(IQR = third - first, upper = third + 1.5 *IQR, lower = first - 1.5 * IQR)

check_outlier <- function(cls,value){
  row = limit %>% filter(class == cls)
  return(value > row$upper[1] | value < row$lower[1])
}

ggplot(mpg,aes(class,hwy)) + 
  geom_boxplot(outlier.alpha = 0) + 
  geom_text(data = filter(mpg,check_outlier(class,hwy)), aes(label=rownames(mpg)))

## rbind => 더 빠른거 , bind_rows(),  cbind => bind_cols()

## filtering 후 차이를 알고 싶을때 
setdiff() #를 구한다.
setdiff(c(1,2,3), c(3,4,6))
# index를  생성해줘서 filter 후 차이를 알아본다.

flights <- nycflights13::flights
flights <- flights %>% mutate(name= row_number())
aa <- filter(flights, carrier == 'AA') 
july <- filter(flights, month == 7)
i = setdiff(aa$name,july$name)
## intersect() <- 교집합 확인.
flights[i,]
