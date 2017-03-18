closale <- read.csv("closale.csv")
closale2 <- closale
head(closale)

library(zoo)
library(lubridate)

as.yearmon("2007-03-01")

closale$date <- as.yearmon(closale$date)
head(closale)
plot(closale,type="l")


### lubridate 를 사용하려면 뒤에 01 를 붙여서 사용하면 된다. 
closale2$date <- paste0(closale2$date,"-01")
closale2$date <- ymd(closale2$date)
plot(closale2,type="l")

plot(closale2, type='l', lty=4, main="미국 의류 판매", xlab="연도", ylab="판매량")


# 이동 평균 
# 자기 날짜를 기준으로 앞으로 2달 뒤로 2달 총 5개를 평균. 
# 앞에 2달의 경우 앞에 달 값이 없으므로 na.pad = T를 해줘서 채워줘야된다. 
# 기간을 늘리게 된다면 더 부드럽게 된다. 

mov.avr = rollmean(closale$sales, 5, na.pad=T)

plot(closale, type='l', lty=4, main="미국 의류 판매", xlab="연도", ylab="판매량")
lines(closale$date, mov.avr, col='red', lwd=3) # x 축 : date, y 축 : mov.avr 

par(mfrow=c(1,2))
plot(closale, type='l', lty=4, main="미국 의류 판매", xlab="연도", ylab="판매량")
lines(closale$date, rollmean(closale$sales, 10, na.pad=T), col='red', lwd=3) # x 축 : date, y 축 : mov.avr 

par(mfrow=c(1,1))

# 이동 중간값
mov.med = rollmedian(closale$sales, 5, na.pad=T)

plot(closale, type='l', lty=4, main="미국 의류 판매", xlab="연도", ylab="판매량")
lines(closale$date, mov.avr, col='red', lwd=3) # x 축 : date, y 축 : mov.avr 
lines(closale$date, mov.med, col='blue', lwd=3)


# 국소 가중 회귀 locally-weighted polynomial regression
# 시계열에서 일부를 회귀, 회귀선을 이어붙여 평활 
# 일정구간에서만 회귀분석을 한다. 선들을 쭉이어서 한다.  => 가중 회귀 
# 국소 가중 회귀 => 가쪽에 있는 데이터의 경우가 Weight를 적게 주고 가운데 있는 데이터를 Weight를 많이 준다. 


loc.reg = lowess(closale$sales) # R의 기본. 

plot(closale, type='l', lty=4, main="미국 의류 판매", xlab="연도", ylab="판매량")
lines(closale$date, loc.reg$y, col='green', lwd=3) # y가 실제로 필요한 값.


# 자기 상관. ACF
# AutoCorrelation Function 

acf(closale$sales) # 12월이 Seasonality 가 있다. 
# Linear Trend가 있어서 Cor 가 약간씩 높다. 

