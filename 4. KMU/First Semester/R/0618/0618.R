TMP <- read.csv("trainData_CDR.csv",stringsAsFactors = F)
TMP$Date <- paste(TMP$dateChar,TMP$timeChar,sep = " ")
TMP$Date2 <- strptime(TMP$Date,format = "%Y/%m%d %H%M-%S")
TMP <- TMP[c(1,4,5,7)]
names(TMP)[4] <- "Date"

head(TMP)
library("dplyr")
Q1 <- TMP[c(1:3)] %>% 
  group_by(touristID,nation) %>%
  summarize(N=n()) 

Q1 <- Q1[order(Q1$N,decreasing = T),]

Q2 <- TMP

Q2$wday <- TMP$Date$wday
Q2$wday <- factor(Q2$wday,levels=c(1:6,0),labels=c("Mon","Tue","Wed","Thu","Fri","Sat","Sun"), ordered = T)
Q2$wday
days <- Q2$wday
table(days)


Q3 <- Q2

Q3$rTime <- Q3$Date$hour
Q3$rTime <- factor(Q3$rTime, levels = c(0:23), ordered = T)
table(Q3$rTime)

Q4 <- TMP[c(1:3)]
head(Q4)

Q4Result <- Q4 %>%
              group_by(city,nation) %>%
              summarize(N=n())

Q4Result <- Q4Result[order(Q4Result$N,decreasing = T),]
head(Q4Result)
totalSum <- sum(Q4Result$N)
Q4Result$Per <- round((Q4Result$N / totalSum) * 100,2)




