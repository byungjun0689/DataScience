## Data Handling (for sample Data)--------------


csvList <- dir("./dataAll/")
csvList

for(i in csvList) {
  filename <- paste0("bike",substr(i,3,4), substr(i,6,7)) 
  smplDummy <- read.csv(paste0("./dataAll/",i), stringsAsFactors=FALSE)
  
  smplIndex <- sample(1:dim(smplDummy)[1] , 50000, replace=FALSE)
  smplData <- smplDummy[smplIndex,]
  assign(paste0(filename,"_smpl"), smplData)
  
  save(list=paste0(filename,"_smpl"), file=paste0("./data_smpl/",paste0(filename,"_smpl"),".RData"))
}
smpl_dir <- dir("./data_smpl")


for(i in seq_along(smpl_dir)) {
  load(paste0("./data_smpl/",smpl_dir[i]))
}


rdir <- dir("./data_smpl/")
rdir
length(rdir)


obj_vol <- NULL
for (i in seq_along(rdir)) {
  obj_vol[i] <- object.size(get(substr(rdir[i],1,13)))
}
sum(obj_vol)/1024^2


rdir[19:21] # number of columns is 9 (different from previous data)
head(get(substr(rdir[18],1,13)))
head(get(substr(rdir[21],1,13)))

for (i in 19:21) {
  dummy <- get(substr(rdir[i],1,13))
  assign(substr(rdir[i],1,13), dummy[,c(1,2,3,5,7:9)]) #exclude Start.station.number and End.station.number 
}


rdir[12:18] #arrange column order

head(get(substr(rdir[11],1,13)))
head(get(substr(rdir[18],1,13)))

for (i in 12:18) {
  dummy <- get(substr(rdir[i],1,13))
  assign(substr(rdir[i],1,13), dummy[,c(1,2,4,3,5:7)]) 
}

for (i in seq_along(rdir)) {
  print(head(get(substr(rdir[i],1,13)),1))
}

for (i in seq_along(rdir)) {
  print(dim(get(substr(rdir[i],1,13))))
}

for (i in seq_along(rdir)) {
  dummy <- get(substr(rdir[i],1,13)) 
  names(dummy) <- c("duration","start_date","end_date","start_stn","end_stn","bike_no","subs_type")
  assign(substr(rdir[i],1,13), dummy)
}

bike_smpl <- NULL
for (i in seq_along(rdir)) {
  bike_smpl <- rbind(bike_smpl, get(substr(rdir[i],1,13)))
}

dim(bike_smpl)


## Data Handling (for first 6 lines of all data)------------------

csvList <- dir("./dataAll/")
csvList


## practicing first lines of csv files

for(i in csvList) {
  filename <- paste0("bike",substr(i,3,4), substr(i,6,7)) 
  assign(filename, read.csv(paste0("./dataAll/",i), stringsAsFactors=FALSE, nrows=6))
  
  cat("\n",filename,"\n","\n")
  print(names(get(filename)))
  
  save(list=filename, file=paste0("./RData/",filename,".RData"))
}


rdir <- dir("./RData/")
rdir
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


## Doing full lines of csv files--------------------

rm(list=ls())

csvList <- dir("./dataAll/")
csvList

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
str(bike_data)

save(bike_data, file="bike_data.RData") # file save is important!!
rm(list=substr(rdir, 1, 8)) # memory management is also important!!



# Date converting ---------------------
load("bike_data.RData")
str(bike_data)
bike_data$start_date <- strptime(bike_data$start_date, format="%m/%d/%Y %H:%M")
bike_data$end_date <- strptime(bike_data$end_date, format="%m/%d/%Y %H:%M")
sum(is.na(bike_data$start_date)) #check date converting is all right!!
dummy <- is.na(bike_data$start_date)
head(bike_data[dummy,])
tail(bike_data[dummy,])

# error-data checking and handling ---------------------
load("./RData/bike14Q4.RData")
head(bike14Q4)
str(bike14Q4)


startdummy <- strptime(bike14Q4$Start.date, format="%Y-%m-%d %H:%M")

enddummy <- strptime(bike14Q4$End.date, format="%Y-%m-%d %H:%M")

bike_data[dummy,]$start_date <- startdummy
bike_data[dummy,]$end_date <- enddummy


sum(is.na(bike_data$start_date))

# weekday and month extraction--------------
bike_data$mon <- strftime(bike_data$start_date, format="%b") #월 숫자

bike_data$wday <- strftime(bike_data$start_date, format="%a") # 요일숫자

bike_data$year <- strftime(bike_data$start_date, format="%Y") #월 숫자

head(bike_data)

# dummy Number input for tapply---------------
start.time <- Sys.time()
bike_data$dummy <- 1
bike_data$duration <- as.numeric(bike_data$end_date - bike_data$start_date)

head(bike_data)
tail(bike_data)

tapply(bike_data$dummy, bike_data$subs_type, sum)
tapply(bike_data$dummy, bike_data$subs_type, sum)/sum(tapply(bike_data$dummy, bike_data$subs_type, sum))
(total.time <- Sys.time() - start.time) # roughly 4 minutes required.


# applying dplyr----------------
library(dplyr)

bike_data[,-c(2:3)] %>%
  group_by(year, wday) %>%
  summarize(N=n())

bike_data$wday <- factor(bike_data$wday, levels=c("월","화","수","목","금","토","일"), ordered=T) #월 숫자

bike_data[,-c(2:3)] %>%
  group_by(year, wday) %>%
  summarize(N=n())

wdaystat <- bike_data[,-c(2:3)] %>%
  group_by(wday) %>%
  summarize(N=n())

wdaystat
plot(wdaystat)
plot(wdaystat, type="l") #this is not working

#but this is working. because plot is generic function.
#let's trandform the dataframe into matrix

plot(as.matrix(wdaystat[,2]), type="l", xaxt="n")
axis(1, a=1:7, labels=wdaystat$wday)


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


# there are four types of member categories.
# Let's find out what are the differences between them.--------------------
library(dplyr)
start.time <- Sys.time()
bike_data[,-c(2,3)] %>%
  group_by(subs_type) %>%
  summarize(N=n(), avg_dur=mean(duration))
(total.time <- Sys.time() - start.time) # Time difference of 1.340687 secs

## according to the summarised by dplyr,
## average duration of casual is far different from other subs_type.
## We can hypothesize Member and Registered and Subscriber are all same category with different naming.

# Let's check days of week trend of each member types -----------------
start.time <- Sys.time()
bike_eda1 <- bike_data[,-c(2,3)] %>%
  group_by(subs_type, wday) %>%
  summarize(N=n(), avg_dur=mean(duration)/60)
(total.time <- Sys.time() - start.time) # Time difference of 1.340687 secs
str(bike_eda1)

# apply factor to wday for easy reading
bike_eda1$wday <- factor(bike_eda1$wday, levels=c("월","화","수","목","금","토","일"), ordered=T)
table(bike_eda1$wday)
bike_eda1
library(reshape2)
bike_eda1_N <- dcast(bike_eda1, subs_type ~ wday, value.var="N", fun.aggregate=sum )
bike_eda1_N

#plotting----------------------
# ylim means y axis minimum number and maximum number. you must input them as a vector which has two elements.
# we can handle yaxis range by this ylim keyword.
# xlim means the same and same vocabulary.

plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])), xaxt="n")
axis(1, a=1:7, labels=names(bike_eda1_N[-1]))
lines(as.numeric(bike_eda1_N[2,-1]), type="l", col="red")
lines(as.numeric(bike_eda1_N[3,-1]), type="l", col="black")
lines(as.numeric(bike_eda1_N[4,-1]), type="l", col="green")

plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])), 
     xaxt="n", yaxt="n",xlab="", ylab="Number of bike riders", main="요일별 Bike rider Trend by subs_type")
axis(1, at=1:7, labels=names(bike_eda1_N[-1]))
axis(2, at=c(0,200000,400000,600000,800000,1000000), labels=c(0,"20만","40만","60만","80만","100만"))
lines(as.numeric(bike_eda1_N[2,-1]), type="l", col="red")
lines(as.numeric(bike_eda1_N[3,-1]), type="l", col="black")
lines(as.numeric(bike_eda1_N[4,-1]), type="l", col="green")
text(7-0.5, bike_eda1_N[1,7]+ 50000, "Casual")
text(7-0.5, bike_eda1_N[2,7]+ 50000, "Member")
text(7-0.5, bike_eda1_N[3,7]+ 50000, "Registered")
text(7-0.5, bike_eda1_N[4,7]+ 50000, "Subscriber")

methods(plot) #plot is "generic function"
# [1] plot.acf*           plot.data.frame*    plot.decomposed.ts* plot.default        plot.dendrogram*   
# [6] plot.density*       plot.ecdf           plot.factor*        plot.formula*       plot.function      
# [11] plot.hclust*        plot.histogram*     plot.HoltWinters*   plot.isoreg*        plot.lm*           
# [16] plot.medpolish*     plot.mlm*           plot.ppr*           plot.prcomp*        plot.princomp*     
# [21] plot.profile.nls*   plot.raster*        plot.spec*          plot.stepfun        plot.stl*          
# [26] plot.table*         plot.ts             plot.tskernel*      plot.TukeyHSD*     
# see '?methods' for accessing help and source code

