## Data Sampling


dummy <- dir()
dumwhich <- which(substr(dummy, nchar(dummy)-2, nchar(dummy)) == "csv")
csvList <- dummy[dumwhich]
csvList

for(i in csvList) {
  filename <- paste0("bike",substr(i,3,4), substr(i,6,7)) 
  smplDummy <- read.csv(i, stringsAsFactors=FALSE)
  

  smplIndex <- sample(1:dim(smplDummy)[1] , 50000, replace=FALSE)
  smplData <- smplDummy[smplIndex,]
  assign(paste0(filename,"_smpl"), smplData)
  
  save(list=paste0(filename,"_smpl"), file=paste0("./data_smpl/",paste0(filename,"_smpl"),".RData"))
  rm(list=paste0(filename,"_smpl"))
}

install.packages("dplyr")

## Data Handling

csvList <- dir()
csvList


## practicing first lines of csv files
# i <- csvList[1]
for(i in csvList) {
  filename <- paste0("bike",substr(i,3,4), substr(i,6,7)) 
  assign(filename, read.csv(paste0("./dataAll/",i), stringsAsFactors=FALSE, nrows=6))
  
  cat("\n",filename,"\n","\n")
  print(names(get(filename)))
  
  save(list=filename, file=paste0("./RData/",filename,".RData"))
  
}

head(bike12Q2)
head(bike14Q4)
head(bike15Q1)
head(bike15Q3)
head(bike16Q1)


# rm(smplDummy)
rdir <- dir("./RData/")
length(rdir)
obj_vol <- NULL
for (i in seq_along(rdir)) {
  obj_vol[i] <- object.size(get(substr(rdir[i],1,8)))
}
sum(obj_vol)/1024^2

rdir[19:21]
for (i in 19:21) {
  dummy <- get(substr(rdir[i],1,8))
  assign(substr(rdir[i],1,8), dummy[,c(1,2,3,5,7:9)]) 
}

rdir[12:18]
for (i in 12:18) {
  dummy <- get(substr(rdir[i],1,8))
  assign(substr(rdir[i],1,8), dummy[,c(1,2,4,3,5:7)]) 
}

for (i in seq_along(rdir)) {
  print(head(get(substr(rdir[i],1,8)),1))
}

for (i in seq_along(rdir)) {
  dummy <- get(substr(rdir[i],1,8)) 
  names(dummy) <- c("duration","start_date","end_date","start_stn","end_stn","bike_no","subs_type")
  assign(substr(rdir[i],1,8), dummy)
}

bike_data <- NULL
for (i in seq_along(rdir)) {
  bike_data <- rbind(bike_data, get(substr(rdir[i],1,8)))
}

dim(bike_data)



## Dlong full lines of csv files
# i <- csvList[1]
for(i in csvList) {
  filename <- paste0("bike",substr(i,3,4), substr(i,6,7)) 
  assign(filename, read.csv(paste0("./dataAll/",i), stringsAsFactors=FALSE))
  
  cat("\n",filename,"\n","\n")
  print(names(get(filename)))
  
  save(list=filename, file=paste0("./RData/",filename,".RData"))
  
}

head(bike12Q2)
head(bike14Q4)
head(bike15Q1)
head(bike15Q3)
head(bike16Q1)


# rm(smplDummy)
rdir <- dir("./RData/")
length(rdir)
obj_vol <- NULL
for (i in seq_along(rdir)) {
  obj_vol[i] <- object.size(get(substr(rdir[i],1,8)))
}
sum(obj_vol)/1024^2

rdir[19:21]
for (i in 19:21) {
  dummy <- get(substr(rdir[i],1,8))
  assign(substr(rdir[i],1,8), dummy[,c(1,2,3,5,7:9)]) 
}

rdir[12:18]
for (i in 12:18) {
  dummy <- get(substr(rdir[i],1,8))
  assign(substr(rdir[i],1,8), dummy[,c(1,2,4,3,5:7)]) 
}

for (i in seq_along(rdir)) {
  print(head(get(substr(rdir[i],1,8)),1))
}

for (i in seq_along(rdir)) {
  dummy <- get(substr(rdir[i],1,8)) 
  names(dummy) <- c("duration","start_date","end_date","start_stn","end_stn","bike_no","subs_type")
  assign(substr(rdir[i],1,8), dummy)
}

bike_data <- NULL
for (i in seq_along(rdir)) {
  bike_data <- rbind(bike_data, get(substr(rdir[i],1,8)))
}

dim(bike_data)


bike_data$start_date <- strptime(bike_data$start_date, format="%m/%d/%Y %H:%M")
sum(is.na(bike_data$start_date))
dummy <- is.na(bike_data$start_date)
tail(bike_data[dummy,])

head(bike14Q4)
startdummy <- strptime(bike14Q4$start_date, format="%Y-%m-%d %H:%M")
enddummy <- strptime(bike14Q4$end_date, format="%Y-%m-%d %H:%M")
startformat <- strftime(startdummy, format="%m/%d/%Y %H:%M")
head(startformat)
endformat <- strftime(enddummy, format="%m/%d/%Y %H:%M")
head(endformat)
bike14Q4$start_date <- startformat
bike14Q4$end_date <- endformat

bike_data <- NULL
for (i in seq_along(rdir)) {
  bike_data <- rbind(bike_data, get(substr(rdir[i],1,8)))
}

dim(bike_data)

bike_data$start_date <- strptime(bike_data$start_date, format="%m/%d/%Y %H:%M")
sum(is.na(bike_data$start_date))
bike_data$end_date <- strptime(bike_data$end_date, format="%m/%d/%Y %H:%M")

bike_data$mon <- strftime(bike_data$start_date, format="%b") #?? ????

bike_data$wday <- strftime(bike_data$start_date, format="%a") #?? ????


bike_data$year <- strftime(bike_data$start_date, format="%Y") #?? ????

head(bike_data)
bike_data$dummy <- 1
bike_data$duration <- as.numeric(bike_data$end_date - bike_data$start_date)

head(bike_data)
tail(bike_data)

tapply(bike_data$dummy, bike_data$subs_type, sum)
tapply(bike_data$dummy, bike_data$subs_type, sum)/sum(tapply(bike_data$dummy, bike_data$subs_type, sum))


###############
# dplyr
###############


library(dplyr)

bike_data[,-c(2:3)] %>%
group_by(year, wday) %>%
summarize(N=n())

bike_data$wday <- factor(bike_data$wday, levels=c("??","화","??","??","??","??","??"), ordered=T) #?? ????

bike_data[,-c(2:3)] %>%
group_by(year, wday) %>%
summarize(N=n())

wdaystat <- bike_data[,-c(2:3)] %>%
group_by(wday) %>%
summarize(N=n())

plot(wdaystat)

plot(bike_data[,-c(2:3)] %>%
filter(year == 2011) %>%
group_by(wday) %>%
summarize(N=n())
)

plot(bike_data[,-c(2:3)] %>%
filter(year %in% 2011:2015) %>%
group_by(year) %>%
summarize(N=n())
)


###############
# join
###############
example(merge)
example(match)

match(c(255,11,22),c(255,11,33))  #return index which비슷한 기능.
match(c(255,11,22),c(11,33, 255))

?match

match(1:10, 7:20) #[1] 0 0 0 0 0 0 1 2 3 4      # 앞에 데이터 값이 뒤의 데이터 값과 동일 한것을 찾고 뒤에 해당된 INDEX를 출력.
match(10:1, 7:20) #[1]  4  3  2  1 NA NA NA NA NA NA
match(1:10, 7:20, nomatch=0)
max(match(1:10, 7:20, nomatch=0))
intersect <- function(x, y) y[match(x, y, nomatch = 0)]
intersect(1:10, 7:20)

intersect_nomatch_1 <- function(x, y) y[match(x, y, nomatch = 1)]
intersect_nomatch_1(1:10, 7:20)

intersect_nomatch_NA <- function(x, y) y[match(x, y, nomatch = NA)]
intersect_nomatch_NA(1:10, 7:20)

intersect_nomatch_ln <- function(x, y) y[match(x, y, nomatch = length(y))]
intersect_nomatch_ln(1:10, 7:20)

intersect_nomatch_asterisk <- function(x, y) y[match(x, y, nomatch = "*")]
intersect_nomatch_asterisk(1:10, 7:20)

df1 = data.frame(CustomerId = c(1:6), Product = c(rep("Toaster", 3), rep("Radio", 3)))
df2 = data.frame(CustomerId = c(2, 4, 6), State = c(rep("Alabama", 2), rep("Ohio", 1)))

df1
df2

# default merge is inner join
merge(x = df1, y = df2)
merge(x = df2, y = df1)

# Outer join (== full outer join) : 
merge(x = df1, y = df2, by = "CustomerId", all = TRUE)
merge(x = df2, y = df1, by = "CustomerId", all = TRUE)

# Left outer: 
merge(x = df1, y = df2, by = "CustomerId", all.x = TRUE)
merge(x = df2, y = df1, by = "CustomerId", all.x = TRUE)

# Right outer: 
merge(x = df1, y = df2, by = "CustomerId", all.y = TRUE)
merge(x = df2, y = df1, by = "CustomerId", all.y = TRUE)

# Cross join: 
merge(x = df1, y = df2, by = NULL)
merge(x = df2, y = df1, by = NULL)

# install.packages("plyr")
library(plyr)
?join


# by 함수를 통해 key지정 가능
# join(A,B, by = 키명, type="타입")
# default plyr::join is left outer join
join(df1, df2)
join(df2, df1)

# inner join
join(df1, df2, type="inner")
join(df2, df1, type="inner")

# right outer join
join(df1, df2, type="right")
join(df2, df1, type="right")

# full outer join
join(df1, df2, type="full")
join(df2, df1, type="full")
