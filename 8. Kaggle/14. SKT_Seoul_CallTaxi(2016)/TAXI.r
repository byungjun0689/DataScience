
library(zoo)
library(lubridate)
library(tidyverse)

taxi <- read.csv("data/total_taxi.csv", sep = ",",header = T, encoding="utf-8")
taxi$date <- as.yearmon(taxi$기준년월일)

plot(select(taxi,date,통화건수))

mon_taxi_cnt <- taxi %>% group_by(기준년월일) %>% summarise(cnt = sum(통화건수))
str(mon_taxi_cnt)
mon_taxi_cnt$기준년월일 <- ymd(mon_taxi_cnt$기준년월일)
mon_taxi_cnt
plot(mon_taxi_cnt,type="l", main="Sum of Call Taxi from 2016-01 to 2016-12", xlab="Days", ylab="Calls")

mov.avr = rollmean(mon_taxi_cnt$cnt, 10, na.pad=T)
plot(mon_taxi_cnt,type="l", main="Sum of Call Taxi from 2016-01 to 2016-12", xlab="Days", ylab="Calls")
lines(mon_taxi_cnt$기준년월일, mov.avr, col="red",lwd=3) # 그나마 10일 평균으로 이평선을 그리니 평탄.


mov.med = rollmedian(mon_taxi_cnt$cnt, 9, na.pad=T)
plot(mon_taxi_cnt,type="l", main="Sum of Call Taxi from 2016-01 to 2016-12", xlab="Days", ylab="Calls")
lines(mon_taxi_cnt$기준년월일, mov.med, col="red",lwd=3) # 그나마 10일 평균으로 이평선을 그리니 평탄.


# 국소회귀
loc.reg = lowess(mon_taxi_cnt$cnt) # R의 기본.
plot(mon_taxi_cnt,type="l", main="Sum of Call Taxi from 2016-01 to 2016-12", xlab="Days", ylab="Calls")
lines(mon_taxi_cnt$기준년월일, loc.reg$y, col='green', lwd=3) # y가 실제로 필요한 값.


mon_taxi_cnt2 <- taxi %>% group_by(date) %>% summarise(cnt = sum(통화건수))

taxi$기준년월일 <- ymd(taxi$기준년월일)
taxi$week <- week(taxi$기준년월일) 

mon_taxi_cnt3 <-taxi %>% group_by(week) %>% summarise(cnt = sum(통화건수))
acf(mon_taxi_cnt3$cnt) # 주별로 했을때는 자기 상관이 없다.

mov.avr3 = rollmean(mon_taxi_cnt3$cnt, 5, na.pad=T)
plot(mon_taxi_cnt3,type="l", main="Sum of Call Taxi from 2016-01 to 2016-12", xlab="Days", ylab="Calls")
lines(mon_taxi_cnt3$week, mov.avr3, col="red",lwd=3) # 그나마 10일 평균으로 이평선을 그리니 평탄.

loc.reg3 = lowess(mon_taxi_cnt3$cnt) # R의 기본.
plot(mon_taxi_cnt3,type="l", main="Sum of Call Taxi from 2016-01 to 2016-12", xlab="Days", ylab="Calls")
lines(mon_taxi_cnt3$week, loc.reg$y, col='green', lwd=3) # y가 실제로 필요한 값.


plot(mon_taxi_cnt3, type='l')
lines(mon_taxi_cnt3$week, lowess(mon_taxi_cnt3$cnt)$y, col=2)

acf(mon_taxi_cnt3$cnt,17)
max(mon_taxi_cnt3$week)

d1 = diff(mon_taxi_cnt3$cnt,12)
plot(d1, type='l')
lines(lowess(d1), col=2) # 추세를 없애버렸다. 남은 건 계절성, 자기상관 등

acf(d1, 17) 
