# 1. Scatter Plots

library(ggplot2)

x <- ggplot(iris, aes(Sepal.Length, Sepal.Width))
x + geom_point()
x + geom_point(aes(color=Species))
x + geom_point(aes(color=Species, size = Petal.Width))

# Exercises #1
# [문제] y = x/(x+1)를아래와같이Scatter Plot으로도식하시오. 
# 단, x는1에서50까지의정수임

x <- 1:50
y <- sapply(x,function(x) x/(x+1))
df <- data.frame(x=x,y=y)
df

ex1 <- ggplot(df,aes(x=x,y=y))
ex1 + geom_point()


# Exercises #2

# Histogram

x <- ggplot(iris, aes(Sepal.Length))
x + geom_histogram(binwidth = 0.1)
x + geom_histogram(binwidth = 0.1, aes(fill=Species))
x + geom_histogram(fill='red',alpha=0.3)

# Line Charts
head(economics)
# date   pce    pop psavert uempmed unemploy
# 1 1967-07-01 507.4 198712    12.5     4.5     2944
# 2 1967-08-01 510.5 198911    12.5     4.7     2945
# 3 1967-09-01 516.3 199113    11.7     4.6     2958
# 4 1967-10-01 512.9 199311    12.5     4.9     3143
# 5 1967-11-01 518.1 199498    12.5     4.7     3066
# 6 1967-12-01 525.8 199657    12.1     4.8     3018
x <- ggplot(economics)
x + geom_line(aes(x=date, y=unemploy))
x + geom_line(aes(x=date, y=unemploy), colour="blue", size=2)
x + geom_line(aes(x=date, y=unemploy), linetype=2) +
  geom_line(aes(x=date, y=pce), colour="#CC79A7")


# Inheritances
head(Orange)
# Tree  age circumference
# 1    1  118            30
# 2    1  484            58
# 3    1  664            87
# 4    1 1004           115
# 5    1 1231           120
# 6    1 1372           142
x <-ggplot(Orange, aes(age, circumference))
x + geom_line(aes(colour=Tree))
x + geom_line(aes(colour=Tree)) + geom_point()
ggplot(Orange, aes(age, circumference, colour=Tree)) +
  geom_line() + geom_point()

# Exercises #4
d <-data.frame(x=1:50, y=sapply(1:50, function(x) 1/sum(1:x)))
d
gg <- ggplot(d, aes(x=x,y=y))
gg + geom_line(color = 'red', size=2)

#Bar Charts
head(mtcars)
# mpg cyl disp  hp drat    wt  qsec vs am gear carb
# Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
# Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
# Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
# Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
# Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
# Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
x <-ggplot(mtcars, aes(factor(cyl)))
x + geom_bar(aes(fill=factor(cyl)), width=.5)
x + geom_bar(aes(fill=factor(gear)), width=.5)
x + geom_bar(aes(fill=factor(gear)), width=.5) + coord_flip()


x <- ggplot(mtcars,aes(factor(cyl),mpg))
x + geom_bar(aes(fill=factor(cyl)), width =.5, stat="identity")


# Position Adjustments
x <- ggplot(diamonds,aes(x=price))
x + geom_bar(aes(fill=cut),binwidth = 3000)
x + geom_bar(aes(fill=cut),binwidth = 3000, position = "dodge")
x + geom_bar(aes(fill=cut),binwidth = 3000, position = "fill")


# Circle Charts
x <- ggplot(mtcars,aes(x=factor(1),fill=factor(cyl)))
x + geom_bar(width = 1) + coord_polar(theta="y")


# Box Plots
x <- ggplot(mtcars,aes(factor(cyl),mpg))
x + geom_boxplot()
x + geom_boxplot() + geom_jitter()
x + geom_boxplot(aes(fill=factor(cyl)), outlier.colour = "green", outlier.size = 4)

# Facets
x <- ggplot(diamonds, aes(x=price))
x + geom_bar(binwidth = 3000) + facet_wrap(~ cut)
x + geom_bar(binwidth = 3000) + facet_grid(.~cut)
x + geom_bar(binwidth = 1000) + facet_grid(color ~ cut)


#Density

x <- ggplot(iris,aes(Petal.Length))
x + geom_density()
x + geom_density(aes(color=Species))
