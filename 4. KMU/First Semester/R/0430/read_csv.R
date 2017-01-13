rm(list=ls())  #메모리 내의 변수 값 초기화 

dummy <- read.csv("2016-Q1-Trips-History-Data.csv",
                  stringsAsFactor=F, nrows=1000)
dim(dummy)
str(dummy)
head(dummy)
View(dummy)
Q1_16 <- read.csv("2016-Q1-Trips-History-Data.csv", stringsAsFactor=F)
summary(Q1_16)   #length = 55만건...

Q1_16 <- read.csv("2016-Q1-Trips-History-Data.csv", stringsAsFactor=T)
object.size(Q1_16)/1024^2
?aggregate

head(Q1_16);tail(Q1_16)
head(Q1_16[,1:5]);tail(Q1_16[,1:5])

Q1_16[which.max(Q1_16[,1]),]
str(Q1_16)
which.max(Q1_16[,1])
Q1_16[which.max(Q1_16[,1]),]

head(Q1_16[,8])

Q1_16$dummy <- 1

a <- c(1,2,3,4)
length(a)
length(which(Q1_16$Bike.number=="W21934"))
?tapply
bikecount <- tapply(Q1_16$dummy, Q1_16$Bike.number, sum)
bikecount["W21934"]

hist(bikecount)

biketime <- tapply(Q1_16[,1]/1000/60,Q1_16$Bike.number, mean)
head(biketime)

length(biketime)

sapply(iris[,-5],mean)  # 열을 기준으로 값더하기 vector 출력
lapply(iris[,-5],mean)  # 열 기준으로 ㅋㅋ list출력

head(Q1_16)
membershipbiketime <- tapply(Q1_16[,1]/1000/60,Q1_16$Member.Type, mean)
head(membershipbiketime)

save(membershipbiketime, file="membershipbiketime.RData")
save(Q1_16,file="Q1_16_2016_washington_bike.RData")
rm(Q1_16)
load("Q1_16_2016_washington_bike.RData")

a <- Q1_16[Q1_16$Member.Type=="Registered",]
write.csv(a,file="member_registered",row.names = F)

str(aggregate(Q1_16$Duration..ms. ~ Q1_16$Member.Type, FUN = mean))

Q1_16$rideTime = Q1_16[,1]/1000/60

sort(Q1_16$rideTime)
sort(Q1_16$rideTime, decreasing = T)

order(Q1_16$rideTime)
order(Q1_16$rideTime, decreasing = T)

age <- c(25, 60, 45, 19, 48, 27)
sort(age)
sort(age, decreasing = T)
rank(age)  # rank: 가장 낮은게 1  
order(age)  # 가장 작은 거부터 index를 보여준다.
age[order(age)]

order(age, decreasing = T)
?order
as.numeric(Q1_16$dateEnd[1])

epochkor <- as.POSIXct(as.numeric(Q1_16$dateEnd[1]), origin="1970-01-01", tz="Asia/Seoul")
epochkor
as.numeric(epochkor)
epochusa <- as.POSIXlt(as.numeric(epochkor), origin="1970-01-01", tz="America/Dawson")
epochusa

pdate <- strftime(epochkor, format="%d")
str(pdate)
pyear <- strftime(epochkor, format="%Y")
pmonth <- strftime(epochkor, format="%m")
pweek <- strftime(epochkor, format="%W")




Q1_16$dateStart <- strptime(Q1_16$Start.date,format="%m/%d/%Y %H:%M")
Q1_16$dateEnd <- strptime(Q1_16$End.date,format="%m/%d/%Y %H:%M")
Q1_16$rideTime <- (as.numeric(Q1_16$dateEnd) - as.numeric(Q1_16$dateStart))
head(Q1_16)

hist(Q1_16$rideTime)
hist(Q1_16$rideTime, breaks = 200)
fivenum(Q1_16$rideTime)

tapply(Q1_16$rideTime, Q1_16$Member.Type, sum)
names(Q1_16)
bikeAvgTime <- tapply(Q1_16$rideTime, Q1_16$Bike.number, mean)

hist(bikeAvgTime)
hist(bikeAvgTime, breaks=200)
