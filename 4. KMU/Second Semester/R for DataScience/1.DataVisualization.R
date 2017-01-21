##### R for DataScience ####
##### http://r4ds.had.co.nz/index.html

library(gridExtra)

install.packages("tidyverse")
library(tidyverse)
#tibble : dataframe과 다른 포맷 하지만 사용법은 비슷하다.

install.packages(c("nycflights13", "gapminder", "Lahman"))
library(nycflights13)
library(gapminder)
library(Lahman)

# 기존 제공하는 함수가 덮어졌을 경우 Class로 접근
median = function(x){x[0]}
median(c(1,2,3))

stats::median(c(1,2,3))

# library를 사용하지 않더라도 사용이가능한데. 
# library를 사용하지 않더라도 :: 를 사용해서 함수를 사용하는 것이 코드를 다른사라밍 보기에 
# 정리하거나 보기 좋다. 

# 3. Data Visualization ####
# 3.2.1 mpg dataframe ####
mpg ## tibble format, 출력할 시 화면크기에 맞게 출력이된다.(짤라준다.), 데이터 type 보여준다.

# 3.2.2 Creating a ggplot ####
ggplot(data=mpg) + 
  geom_point(mapping = aes(x = displ, y =hwy)) 
##displ 엔진 사이즈, hwy 연비, 효율

ggplot(data=mpg) + 
  geom_point(mapping = aes(x = displ, y =hwy), color='pink')  
## color가 aes밖에 있는 이유는 data에 mapping되는 것이 아니라 임의의 색이므로

#ggplot 에는 공통적인 요소만 적용. 

# 3.2.4 Exercise ####
## 1. Run ggplot(data = mpg) what do you see? Nothing
## 2. How many rows are in mtcars? How many columns? dim(mtcars)
## 3. What does the drv variable describe? Read the help for ?mpg to find out. do it ?mpg
## 4. Make a scatterplot of hwy vs cyl.
ggplot(data=mpg) + geom_point(aes(x=hwy,y=cyl)) # 명목형이라 Scatter가 의미가 없는듯.
# 5. What happens if you make a scatterplot of class vs drv. Why is the plot not useful?
ggplot(data=mpg) + geom_point(aes(x=class,y=drv)) # 둘다 명목이라 의미가 없는 듯.

## 연속변수, 이산변수(범주형변수), 명목변수 ####
## 숫자        1,2,3 /              남,여
## Scatter plot은 변화가 있는 모습을 확인하려고 사용하는데, 범주나 명목은 변화가 없다 => 즉, 쓸모가 없다.

# 3.3 Aesthetic Mappings #### 
ggplot(data=mpg) + 
  geom_point(mapping = aes(x = displ, y =hwy, color=class)) 
## color를 aes안에 넣게 되면 data에 mapping 

ggplot(data=mpg) + 
  geom_point(mapping = aes(x = displ, y =hwy, color=drv)) # 색


ggplot(data=mpg) + 
  geom_point(mapping = aes(x = displ, y =hwy, shape=class)) # 모양

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy),alpha = .2,size=3) # 투명도(20%) -> 5개가 겹쳐야 100%가 된다.
## 범주형 또는 이산형일 경우 점들이 겹친다. 이럴때 alpha를 이용하면 유용하다. 

## 또 다른 겹칠때 사용하는 그래프 
ggplot(data = mpg) + 
  geom_jitter(mapping = aes(x = displ, y = hwy),alpha = .2,size=3)

# 3.3.1  Exercise

## 1. What’s gone wrong with this code? Why are the points not blue?
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"))
## Answer
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), shape=21, 
             color = "white", 
             fill='black', size=5,
             stroke=5) # stroke 테두리 굵기 인ㄷ

ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), shape=21, 
             color = "white", 
             fill='black', size=5)

era <- function(year){
  if(year < 2001){
    return('pre')
  }else if(year < 2004){
    return('mid')
  }else{
    return('post')
  }
}
era(2001)
purrr::map_chr(mpg$year,era) # 어떤 데이터의 모든 원소에 함수를 적용. 문자 Vector로 변환하여 출력.
purrr::map(mpg$year,era) # List로 나온다.
# list와 verctor의 차이, 각각의 자료형이 다르다.(list) 

ggplot(data=mpg) + 
  geom_point(aes(displ,hwy,color=purrr::map_chr(year,era)))

map_dbl(c(1,2,3), function(x){x+1})
cut(mpg$year,c(1998,2001,2004,2009))

ggplot(data=mpg) + 
  geom_point(aes(displ,hwy,color=cut(year,c(1998,2001,2004,2009))))


# 2. Which variables in mpg are categorical? Which variables are continuous? (Hint: type ?mpg to read the documentation for the dataset). 
# How can you see this information when you run mpg?
str(mpg) 
class(mpg$displ)
summary(mpg)
# 
# 3. Map a continuous variable to color, size, and shape. How do these aesthetics behave differently for categorical vs. continuous variables?
# 
# 4. What happens if you map the same variable to multiple aesthetics?
# 
# 5. What does the stroke aesthetic do? What shapes does it work with? (Hint: use ?geom_point)
# 
# 6. What happens if you map an aesthetic to something other than a variable name, like aes(colour = displ < 5)?

# Tips ####
# Chapter 28. Theme 를 이용해서 그래프에 제목과 같은 할수있는 것을 알려준다.

# 3.5 Facets 
## Using Categorical variables to split plot into facets
## grid : 격자 
## wrap : 그림이 길어지면 자동으로 다음줄로 넘기는 형식(하나씩 그려주다가)

ggplot(data=mpg) + 
  geom_point(aes(x=displ, y=hwy)) + facet_wrap(~class,nrow=2) # Class별로 따로그려라  
## 최대 row = 2 
ggplot(data=mpg) + 
  geom_point(aes(x=displ, y=hwy)) + facet_wrap(~class,ncol=2) # Class별로 따로그려라 
## 최대 Col = 2

ggplot(data=mpg) +
  geom_point(aes(x=displ, y=hwy)) + facet_grid(~class) # 격자처럼 쪼개서 그린다. 가로를 쪼갠다

ggplot(data=mpg) +
  geom_point(aes(x=displ, y=hwy)) + facet_grid(class~.) # 격자처럼 쪼개서 그린다. 세로를 쪼갠다.

ggplot(data=mpg) +
  geom_point(aes(x=displ, y=hwy)) + facet_grid(class~drv) # 세로로는 Class, 가로로는 drv로 쪼갠다.

## 하나로 그리게 되면 한눈에 알아보기 좋다.
ggplot(data=mpg) +
  geom_point(aes(x=displ, y=hwy, color = class))
## 하지만 색이 많다면은 알아보기 힘들다.

## class를 가로로 짜르게 되면 아래와 같이 보기 쉬워진다.
ggplot(data=mpg) +
  geom_point(aes(x=displ, y=hwy, color = class)) + facet_grid(~class)

# 3.5.1 Exercises
# 
## 1. What happens if you facet on a continuous variable?
# 
## 2. What do the empty cells in plot with facet_grid(drv ~ cyl) mean? How do they relate to this plot?
ggplot(data = mpg) +
  geom_point(mapping = aes(x = drv, y = cyl))

# 3. What plots does the following code make? What does . do?
# 문법적으로 없어도 되는 자리에 빈공간을 체운다.
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
# 4. Take the first faceted plot in this section:
#   
  ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)
# 5. What are the advantages to using faceting instead of the colour aesthetic? What are the disadvantages? How might the balance change if you had a larger dataset?
# 
# 6. Read ?facet_wrap. What does nrow do? What does ncol do? What other options control the layout of the individual panels? Why doesn’t facet_grid() have nrow and ncol variables?
# 
# 7. When using facet_grid() you should usually put the variable with more unique levels in the columns. Why?
  
# 3.6 Geometric objects
## Geom_smoothed : 이평선이랑 비슷한 개념으로 생각하면 된다.
## 부분 데이터들의 회기선을 이어서 붙이는 것을 로이스 라고 한다. 끝부분에서도 패턴을 찾아낸다. 
## geom_smooth()` using method = 'loess'
  
ggplot(data=mpg) +
  geom_smooth(aes(displ,hwy)) +
  geom_point(aes(displ,hwy,color=class))
  
ggplot(data=mpg) +
  geom_smooth(aes(displ,hwy),method = 'lm',se=F) #전체 데이터의 회귀선, se(standard error)=F를 하게 되면 신뢰구간 =  F, 

ggplot(data=mpg, aes(displ,hwy)) + geom_smooth() + geom_point(aes(color=class))
## 공통요소들이 들어가면 된다.

## smooth 는 선인데 어떻게 다르게 할까
ggplot(data=mpg, aes(displ,hwy,color=drv)) + geom_smooth(se=F,aes(size=2)) + geom_point()

ggplot(data=mpg, aes(displ,hwy)) + 
  geom_smooth(aes(.=drv)) + # . 대신에 group=drv
  geom_point() #선만 따로 그린다. 

ggplot(data=mpg, aes(displ,hwy)) + 
  geom_smooth(aes(linetype=drv,color=drv)) + 
  geom_point()


## dplyr filter
ggplot(data=mpg, aes(displ,hwy)) + 
  geom_point(aes(color=class)) +
  geom_smooth(data=filter(mpg,class=='subcompact'), se=F)




## 1
gg <- ggplot(data=mpg, aes(displ,hwy))

gg + geom_point(size=2) + geom_smooth(se=F)
gg + geom_point(size=2) + geom_smooth(aes(group=drv), se=F)
gg + geom_point(aes(color=drv)) + geom_smooth(aes(color=drv),se=F)
gg + geom_point(aes(color=drv)) + geom_smooth(se=F)
gg + geom_point(aes(color=drv)) + geom_smooth(aes(linetype=drv),se=F)
gg +
  geom_point(aes(fill=drv),color="white",shape=21, size=5,
             stroke=3) 

# 3.7 Statistical Transformations 
diamonds # tibble

ggplot(diamonds) + geom_bar(aes(x=cut,fill=cut))

## dataframe vs tibble
## DataFrame to tibble = as_data_frame()
a <- data.frame(x=c(1,4,7), y=c(2,3,4)) #  열방식으로 들어간다.
tibble(x=c(1,2,3), y=c(2,3,4)) # 열형태로도 되고 행 형태로도 된다.
tribble(
  ~x, ~y,
  1,5,
  2,3,
  4,7
  )

as_data_frame(a)

demo <- tribble(
  ~a,      ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40
)

ggplot(data = demo) +
  geom_bar(mapping = aes(x = a, y = b), stat = "identity")


ggplot(data = diamonds) + 
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))


# 3.3.8 Position

ggplot(data=diamonds) + geom_bar(aes(cut,fill=color), position='dodge')
ggplot(data=diamonds) + geom_bar(aes(cut,fill=color), position='fill') # 100%로 꽉채운 후 비율을 나타낸다.

# 3.3.9 Coordinate systems

gg1 <- ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot()
gg2 <- ggplot(data = mpg, mapping = aes(x = class, y = hwy)) + 
  geom_boxplot() +
  coord_flip()

grid.arrange(gg1,gg2,ncol=2)

## coord_polar()
bar <- ggplot(data = diamonds) + 
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE,
    width = 1
  ) + 
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

gg1 <- bar + coord_flip()
gg2 <- bar + coord_polar()

grid.arrange(gg1,gg2,ncol=2)


