
dummy <- dir()
dumwhich <- which(substr(dummy, nchar(dummy)-2, nchar(dummy)) == "csv")
loadlist <- dummy[dumwhich]
loadlist

FileCnt <- length(loadlist)

for (i in seq_along(loadlist)) {
  assign(paste0("bikedata_",i), read.csv(loadlist[i], stringsAsFactors = F))
  
}


## 13 ~ 19 번 파일의 2,3 번째 컬럼 위치 변경 필요 ( Enddate, Start.station)

bikedata_13 <- bikedata_13[c(1,2,4,3,5,6,7)]
bikedata_14 <- bikedata_14[c(1,2,4,3,5,6,7)]
bikedata_15 <- bikedata_15[c(1,2,4,3,5,6,7)]
bikedata_16 <- bikedata_16[c(1,2,4,3,5,6,7)]
bikedata_17 <- bikedata_17[c(1,2,4,3,5,6,7)]
bikedata_18 <- bikedata_18[c(1,2,4,3,5,6,7)]
bikedata_19 <- bikedata_19[c(1,2,4,3,5,6,7)]


## 20 ~ 22 파일은 중간 station.number를 맨뒤로 바꿔야 한다.
bikedata_20 <-  bikedata_20[c(1,2,3,5,7,8,9)]   # 4번 startstation  6번 endstation
bikedata_21 <-  bikedata_21[c(1,2,3,5,7,8,9)]
bikedata_22 <-  bikedata_22[c(1,2,3,5,7,8,9)]    # stationNumber삭

StandardColname <- colnames(bikedata_1)

## 6~22 파일 컬럼명 변경.
colnames(bikedata_6) <-  StandardColname
colnames(bikedata_7) <-  StandardColname
colnames(bikedata_8) <-  StandardColname
colnames(bikedata_9) <-  StandardColname
colnames(bikedata_10) <-  StandardColname
colnames(bikedata_11) <-  StandardColname
colnames(bikedata_12) <-  StandardColname
colnames(bikedata_13) <-  StandardColname
colnames(bikedata_14) <-  StandardColname
colnames(bikedata_15) <-  StandardColname
colnames(bikedata_16) <-  StandardColname
colnames(bikedata_17) <-  StandardColname
colnames(bikedata_18) <-  StandardColname
colnames(bikedata_19) <-  StandardColname
colnames(bikedata_20) <-  StandardColname
colnames(bikedata_21) <-  StandardColname
colnames(bikedata_22) <-  StandardColname


## 1~5 station 내부 station number 보유 ( 나머지 데이터에서 구할 수 가 없다. ) 삭제

withoutString <- function(x){
  tmp <- unlist(strsplit(x, split= " \\("))
  return(tmp[1])
  #x$Start.station <- tmp[1]
}

bikedata_1$Start.station <- sapply(bikedata_1$Start.station,withoutString)
bikedata_1$End.station <- sapply(bikedata_1$End.station,withoutString)
bikedata_2$Start.station <- sapply(bikedata_2$Start.station,withoutString)
bikedata_2$End.station <- sapply(bikedata_2$End.station,withoutString)
bikedata_3$Start.station <- sapply(bikedata_3$Start.station,withoutString)
bikedata_3$End.station <- sapply(bikedata_3$End.station,withoutString)
bikedata_4$Start.station <- sapply(bikedata_4$Start.station,withoutString)
bikedata_4$End.station <- sapply(bikedata_4$End.station,withoutString)
bikedata_5$Start.station <- sapply(bikedata_5$Start.station,withoutString)
bikedata_5$End.station <- sapply(bikedata_5$End.station,withoutString)

##Date Type 변경. 17번 파일을 제외하고 전체 데이트 형태 동일.

dateConversion <- function(x){
  x$Start.date <- strptime(x$Start.date, format="%m/%d/%Y %H:%M")
  x$End.date <- strptime(x$End.date, format="%m/%d/%Y %H:%M")
  x$Duration <- as.numeric(x$End.date - x$Start.date, unit="mins")
  return(x)
}

bikedata_1 <- dateConversion(bikedata_1)
bikedata_2 <- dateConversion(bikedata_2)
bikedata_3 <- dateConversion(bikedata_3)
bikedata_4 <- dateConversion(bikedata_4)
bikedata_5 <- dateConversion(bikedata_5)
bikedata_6 <- dateConversion(bikedata_6)
bikedata_7 <- dateConversion(bikedata_7)
bikedata_8 <- dateConversion(bikedata_8)
bikedata_9 <- dateConversion(bikedata_9)
bikedata_10 <- dateConversion(bikedata_10)
bikedata_11 <- dateConversion(bikedata_11)
bikedata_12 <- dateConversion(bikedata_12)
bikedata_13 <- dateConversion(bikedata_13)
bikedata_14 <- dateConversion(bikedata_14)
bikedata_15 <- dateConversion(bikedata_15)
bikedata_16 <- dateConversion(bikedata_16)
bikedata_18 <- dateConversion(bikedata_18)
bikedata_19 <- dateConversion(bikedata_19)
bikedata_20 <- dateConversion(bikedata_20)
bikedata_21 <- dateConversion(bikedata_21)
bikedata_22 <- dateConversion(bikedata_22)

bikedata_17$Start.date <- strptime(bikedata_17$Start.date, format="%Y-%m-%d %H:%M")
bikedata_17$End.date <- strptime(bikedata_17$End.date, format="%Y-%m-%d %H:%M")
bikedata_17$Duration <- as.numeric(bikedata_17$End.date - bikedata_17$Start.date,unit="mins")

# 해당 년도 분기 입력.

makeYear <- function(x){
  year <- (x$Start.date$year + 1900)
  return(year)
}

makeQuarter <- function(x){
  quarter <- NULL
  mon <- (x$Start.date$mon + 1)
  if(mon <= 3){
    quarter <- "Q1"
  }else if(mon >= 4 && mon <= 6){
    quarter <- "Q2"
  }else if(mon >= 7 && mon <= 9){
    quarter <- "Q3"
  }else{
    quarter <- "Q4"
  }
  return(quarter)
}

bikedata_1$year <- makeYear(bikedata_1)
bikedata_1$quarter <- makeQuarter(bikedata_1)
bikedata_2$year <- makeYear(bikedata_2)
bikedata_2$quarter <- makeQuarter(bikedata_2)
bikedata_3$year <- makeYear(bikedata_3)
bikedata_3$quarter <- makeQuarter(bikedata_3)
bikedata_4$year <- makeYear(bikedata_4)
bikedata_4$quarter <- makeQuarter(bikedata_4)
bikedata_5$year <- makeYear(bikedata_5)
bikedata_5$quarter <- makeQuarter(bikedata_5)
bikedata_6$year <- makeYear(bikedata_6)
bikedata_6$quarter <- makeQuarter(bikedata_6)
bikedata_7$year <- makeYear(bikedata_7)
bikedata_7$quarter <- makeQuarter(bikedata_7)
bikedata_8$year <- makeYear(bikedata_8)
bikedata_8$quarter <- makeQuarter(bikedata_8)
bikedata_9$year <- makeYear(bikedata_9)
bikedata_9$quarter <- makeQuarter(bikedata_9)
bikedata_10$year <- makeYear(bikedata_10)
bikedata_10$quarter <- makeQuarter(bikedata_10)
bikedata_11$year <- makeYear(bikedata_11)
bikedata_11$quarter <- makeQuarter(bikedata_11)
bikedata_12$year <- makeYear(bikedata_12)
bikedata_12$quarter <- makeQuarter(bikedata_12)
bikedata_13$year <- makeYear(bikedata_13)
bikedata_13$quarter <- makeQuarter(bikedata_13)
bikedata_14$year <- makeYear(bikedata_14)
bikedata_14$quarter <- makeQuarter(bikedata_14)
bikedata_15$year <- makeYear(bikedata_15)
bikedata_15$quarter <- makeQuarter(bikedata_15)
bikedata_16$year <- makeYear(bikedata_16)
bikedata_16$quarter <- makeQuarter(bikedata_16)
bikedata_17$year <- makeYear(bikedata_17)
bikedata_17$quarter <- makeQuarter(bikedata_17)
bikedata_18$year <- makeYear(bikedata_18)
bikedata_18$quarter <- makeQuarter(bikedata_18)
bikedata_19$year <- makeYear(bikedata_19)
bikedata_19$quarter <- makeQuarter(bikedata_19)
bikedata_20$year <- makeYear(bikedata_20)
bikedata_20$quarter <- makeQuarter(bikedata_20)
bikedata_21$year <- makeYear(bikedata_21)
bikedata_21$quarter <- makeQuarter(bikedata_21)
bikedata_22$year <- makeYear(bikedata_22)
bikedata_22$quarter <- makeQuarter(bikedata_22)

totalBike <- rbind(bikedata_1,bikedata_2,bikedata_3,bikedata_4,bikedata_5,bikedata_6,bikedata_7,bikedata_8,bikedata_9,bikedata_10,bikedata_11
                   ,bikedata_12,bikedata_13,bikedata_14,bikedata_15,bikedata_16,bikedata_17,bikedata_18,bikedata_19,bikedata_20,bikedata_21
                   ,bikedata_22)

tail(totalBike)

write.csv(totalBike,"TotalBikeOrigin.csv")

totalBike$dummy <- 1
totalBike$wday <- totalBike$Start.date$wday
head(totalBike$wday)
totalBike$wday <- factor(totalBike$wday,levels=c(1:6,0),labels=c("Mon","Tue","Wed","Thu","Fri","Sat","Sun"), ordered = T)
tail(totalBike$wday)
wdayCount <- totalBike$wday
plot(wdayCount)
day <- aggregate(dummy ~ wday,data = totalBike, sum)
head(day)
plot(day)

totalBike <- read.csv("TotalBikeOrigin.csv" , stringsAsFactors = F)  # 순서를 없애는 것이 있을듯.
totalBike$Start.date <- strptime(totalBike$Start.date,format = "%Y-%m-%d %H:%M:%S")
totalBike$End.date <- strptime(totalBike$End.date,format = "%Y-%m-%d %H:%M:%S")

  # 각 연도별, 각 분기별 상승 추위 
YearQuarter <- aggregate(dummy ~ year + quarter,data = totalBike, sum)
YearQuarter


Year1Q <- YearQuarter[YearQuarter$quarter=="Q1",]
plot(y = Year1Q$dummy, x=Year1Q$year)
Year2Q <- YearQuarter[YearQuarter$quarter=="Q2",]
plot(y = Year2Q$dummy, x=Year2Q$year)
Year3Q <- YearQuarter[YearQuarter$quarter=="Q3",]
plot(y = Year3Q$dummy, x=Year3Q$year)
Year4Q <- YearQuarter[YearQuarter$quarter=="Q4",]
plot(y = Year4Q$dummy, x=Year4Q$year)

# 분기별로 나눈 데이터 에서 멤버쉽 종류별 추위분석
unique(totalBike$Member.Type)

totalBike$rtime <- totalBike$Start.date$hour
totalBike$rtime <- factor(totalBike$rtime, levels = c(0:23), ordered = T)
hour <- totalBike$rtime
plot(hour)

unique(totalBike$Member.Type)

TBRegistered <- totalBike[totalBike$Member.Type == "Registered",]
TBReHour <- tapply(TBRegistered$dummy, TBRegistered$rtime, sum)
plot(TBReHour)
TBCasual <- totalBike[totalBike$Member.Type == "Casual",]
TBCaHour <- tapply(TBCasual$dummy, TBCasual$rtime, sum)
plot(TBCaHour)
TBSub <- totalBike[totalBike$Member.Type == "Subscriber",]
TBSubHour <- tapply(TBSub$dummy, TBSub$rtime, sum)
plot(TBSubHour)
TBMember <- totalBike[totalBike$Member.Type == "Member",]
TBMemberHour <- tapply(TBMember$dummy, TBMember$rtime, sum)
plot(TBMemberHour)

#위 결과로 보아  Casual을 제외한 모든 타입은 Registered와 동일함.

totalBike[which(totalBike$Member.Type == "Subscriber"),"Member.Type"] = "Registered"
totalBike[which(totalBike$Member.Type == "Member"),"Member.Type"] = "Registered"

TBRegistered2 <- totalBike[totalBike$Member.Type == "Registered",]
TBReHour2 <- tapply(TBRegistered$dummy, TBRegistered$rtime, sum)
plot(TBReHour2)

#memberType 별 연도 추위 
# Type별로 구분 후 위 작업을 그대로 진행.
# TBRegistered2, TBCasual

YearQuarterRegi <- aggregate(dummy ~ year + quarter,data = TBRegistered2, sum)
summary(YearQuarterRegi)
YearQuarterRegi
tmp <- YearQuarterRegi[YearQuarterRegi$quarter=="Q4",]
plot(y = YearQuarterRegi$dummy, x=YearQuarterRegi$year)
barplot(tmp$dummy, names.arg = tmp$year)

YearQuarterCasual <- aggregate(dummy ~ year + quarter,data = TBCasual, sum)
plot(y = YearQuarterCasual$dummy, x=YearQuarterCasual$year)
?hist
Year1Q <- YearQuarter[YearQuarter$quarter=="Q1",]
plot(y = Year1Q$dummy, x=Year1Q$year)
Year2Q <- YearQuarter[YearQuarter$quarter=="Q2",]
plot(y = Year2Q$dummy, x=Year2Q$year)
Year3Q <- YearQuarter[YearQuarter$quarter=="Q3",]
plot(y = Year3Q$dummy, x=Year3Q$year)
Year4Q <- YearQuarter[YearQuarter$quarter=="Q4",]
plot(y = Year4Q$dummy, x=Year4Q$year)
barplot(Year4Q$dummy, names.arg = Year4Q$year)
Year4Q

# Type 별 평균 얼마나 타는지. 
TypeMean <- aggregate(Duration ~ Member.Type, data = totalBike, mean)

TypeLocation <- aggregate(dummy ~ Member.Type + Start.station, data = totalBike, sum)

head(TypeLocation)

order(TypeLocation$dummy)
TypeLocationRe <- TypeLocation[TypeLocation$Member.Type=="Registered",]
TypeLocationCa <- TypeLocation[TypeLocation$Member.Type=="Casual",]
  
stationTMP2 <- aggregate(dummy ~ Start.station, data = totalBike, sum)
barplot(stationTMP2$dummy, names.arg = stationTMP2$Start.station)

stattion <- aggregate( dummy ~ Start.station + End.station ,data=totalBike, sum)

MeanStation <- aggregate( Duration ~ Start.station , data = totalBike, mean)
barplot(MeanStation$Duration, names.arg = MeanStation$Start.station)
MeanStation <- MeanStation[order(MeanStation$Duration, decreasing = T),] 
head(MeanStation)

SumStartStation <- aggregate( dummy ~ Start.station, data = totalBike, sum)
SumStartStation <- SumStartStation[order(SumStartStation$dummy, decreasing = T),] 
head(SumStartStation)

SumEndStation <- aggregate( dummy ~ End.station, data = totalBike, sum)
SumEndStation <- SumEndStation[order(SumEndStation$dummy, decreasing = T),] 
head(SumEndStation)

BikeNumber <- aggregate( Duration ~ Bike., data = totalBike, sum)
BikeNumber <- BikeNumber[order(BikeNumber$Duration, decreasing = T),] 
barplot(BikeNumber$Duration, names.arg = BikeNumber$Bike.)

EachStationBike <- aggregate( dummy ~ Bike. + Start.station, data =totalBike ,sum )
head(EachStationBike,10)
EachStationBike2 <- EachStationBike[order(EachStationBike$dummy, decreasing = T),] 
head(EachStationBike2,100)

EachQBike <- aggregate( dummy ~ quarter + Bike. ,data = totalBike, sum)
head(EachQBike,100)
