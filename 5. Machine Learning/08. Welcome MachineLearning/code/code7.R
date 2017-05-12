kimchi <- read.csv("kimchi.csv" , header = T) 
head(kimchi)

colnames(kimchi) <- c("YYWW" , "LAST_WK" , "BIG_CNT" , "BIG_SALE" , "DEPT_CNT" , "DEPT_SALE" ,"SUPER_CNT" , "SUPER_SALE" , "CONV_CNT" , "CONV_SALE")
head(kimchi) 

sale <- kimchi$BIG_SALE
plot(sale , type = "l" , xlab = "week" , ylab = "sale price")

library(zoo)
dates <- as.Date(as.character(kimchi$LAST_WK) , format = "%Y%m%d")
BIG_sales <- kimchi$BIG_SALE
DEPT_sales <- kimchi$DEPT_SALE
SUPER_sales <- kimchi$SUPER_SALE
all_sales <- as.data.frame(cbind(BIG_sales , DEPT_sales , SUPER_sales))

yang_sales <- zoo(all_sales , dates) 
plot(yang_sales , screens = 1 , xlab = "date" , ylab = "sales amount" , col = c('red','green','blue'))
plot(yang_sales , screens = c(1,3) , xlab = "date" , ylab = "sales amount" , col = c('red','green','blue'))


#잘라주기 그리고 머징하기 
b_sales <- zoo(BIG_sales , dates)
kimchi2 <- read.csv("kimchi2.csv" , header = T) 
k_sales <- zoo(kimchi2$SALES , as.Date(as.character(kimchi2$LAST_WK) , format = "%Y%m%d")) 
merge_data <- merge(d_sales = window(b_sales , start = "2015-01-01" , end = "2015-12-31") , k_sales , all = F)
head(merge_data)

plot(merge_data)
ccf(k_sales , window(b_sales , start = "2015-01-01" , end = "2015-12-31") , main = "k_sale vs b_sale")

#차분 
plot(diff(b_sales))
plot(diff(log(b_sales)))

acf(b_sales) 
Box.test(b_sales)
Box.test(b_sales , type = "Ljung-Box")

pacf(b_sales) 

par(mfrow=c(2,2))
roll2 <- rollapply(b_sales , 2 , mean , aligh = "right")
roll4 <- rollapply(b_sales , 4 , mean , aligh = "right")
roll6 <- rollapply(b_sales , 6 , mean , aligh = "right")
roll8 <- rollapply(b_sales , 8 , mean , aligh = "right")
plot(roll2);plot(roll4);plot(roll6);plot(roll8)

par(mfrow=c(1,1))
roll11 <- rollapply(b_sales , 11 , mean , aligh = "right");plot(roll11) 

par(mfrow=c(1,2))
ma2 <- rollmean(b_sales , 2 , align = "right") ; plot(ma2) 
ma4 <- rollmean(b_sales , 4 , align = "right") ; plot(ma4) 

#추세구하고 없애기 
par(mfrow=c(1,2))
m1 <- lm(coredata(b_sales) ~ index(b_sales)) 
newts <- zoo(resid(m1) , index(b_sales)) 
plot(b_sales);plot(newts) 

#decompose
par(mfrow=c(1,2))
export <- read.table("Export_1988.txt" , header = T)
ts1 <- ts(export$Series , start = c(1988,1) , frequency = 12)
plot(ts1) 
decomp.result <- decompose(ts1);plot(decomp.result)
ts2 <- ts1 - decomp.result$seasonal
plot(ts2) 

str(decomp.result)

#예측값 및 신뢰구간
library(forecast) 
fit <- auto.arima(ts(log(BIG_sales) , frequency = 52) , seasonal = TRUE) 
plot(forecast(fit,h=20))

confint(fit) 

p <- predict(fit , n.ahead=10)

#평활 
library(KernSmooth) 
gridsize <- length(BIG_sales)
bw <- dpill(1:gridsize , BIG_sales , gridsize = gridsize) 
lp <- locpoly(x=1:gridsize , y=BIG_sales , bandwidth = bw , gridsize = gridsize) 
smooth <- lp$y 
plot(BIG_sales , type = "l") 
lines(smooth , lty=2)

tsdiag(fit) 

par(mfrow=c(1,1))
plot(fit$x , lty = 1)
lines(fitted(fit) , lty = 2 , lwd = 1 , col = "red")

accuracy(fit) 





