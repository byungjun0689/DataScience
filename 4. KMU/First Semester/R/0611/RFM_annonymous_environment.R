library(dplyr)
library(reshape2)

### data loading -----
cust <- read.csv("customerDb.csv", stringsAsFactors=F)
basket <- read.csv("basketData.csv", stringsAsFactors=F)


## RFM Analysis---------------
head(basket)
head(cust)

basket$date <- as.Date(as.character(basket$date), format="%Y%m%d")
basket$date_num <- as.numeric(basket$date)
date_dum <- as.Date(basket$date_num, origin="1970-01-01")
head(date_dum)


library(dplyr)

## double group_by for frequency counting.
userF <- basket %>%
  group_by(custId, date) %>%
  summarize(N=n()) %>%
  group_by(custId) %>%
  summarize(freq=n())
userF


userRFM <- basket %>%
  group_by(custId) %>%
  summarize(minRecency=min(date),
            recency=max(date),
            monetary=sum(amount),
            period=as.numeric(max(date)-min(date)))


head(userRFM)

userRFM <- left_join(userRFM, userF)

head(userRFM);tail(userRFM)


## how to define quantile of basket data-------

plot(table(userRFM$recency), main="Guests Recency")

plot(table(userRFM$freq), main="Guests Frequency")

hist(userRFM$monetary, breaks=100, main="Guests Monetary")


## How to use quantile function---------

(recentDate <- quantile(as.numeric(userRFM$recency), c(0.2,0.4,0.6,0.8))) # be careful about as.numeric
as.Date(recentDate, origin="1970-01-01")

quantile(userRFM$freq, c(0.2,0.4,0.6,0.8))

quantile(userRFM$monetary, c(0.2,0.4,0.6,0.8))


# RFM Weight Rating (upper 20% share of sales)----------------

sumM <- sum(userRFM$monetary[userRFM$monetary > quantile(userRFM$monetary, 0.8)])
sumM/sum(userRFM$monetary) # 65%

sumF <- sum(userRFM$monetary[userRFM$freq > quantile(userRFM$freq, 0.8)])
sumF/sum(userRFM$monetary) # 58%

sumR <- sum(userRFM$monetary[as.numeric(userRFM$recency) > quantile(as.numeric(userRFM$recency), 0.8)])
sumR/sum(userRFM$monetary) # 42%

(weightR <- sumR/(sumR + sumF + sumM))
(weightF <- sumF/(sumR + sumF + sumM))
(weightM <- sumM/(sumR + sumF + sumM))

# RFM???? = weightR * Recency rating + weightF * Frequency rating + weightM * Monetary rating

quantM <- quantile(userRFM$monetary,c(0,0.2,0.4,0.6,0.8,1))
quantM
quantR <- as.Date(quantile(as.numeric(userRFM$recency),c(0,0.2,0.4,0.6,0.8,1)),origin="1970-01-01")
quantR
quantF <- quantile(userRFM$freq,c(0,0.2,0.4,0.6,0.8,1))
quantF



# How to use eval and parse function-------------------
columnName <- paste0("userRFM","$","freq")
eval(parse(text=columnName))[2] 
eval(parse(columnName))[2] # beware the difference with a line above.


## interval Grade user defined function-----------------
intervalGrade <- function(mainData, fileName, rfmName, quantileData) {
  forLength <- dim(mainData)[1]
  results <- rep(0, forLength)
  for (i in 1:forLength) {
    data <- eval(parse(text=paste0(fileName,"$",rfmName)))[i]
    if (data >= quantileData[1] && data < quantileData[2] ) {
      results[i] <- 1
    } else if (data >= quantileData[2] && data < quantileData[3]) {
      results[i] <- 2
    } else if (data >= quantileData[3] && data < quantileData[4]) {
      results[i] <- 3
    } else if (data >= quantileData[4] && data < quantileData[5]) {
      results[i] <- 4
    } else { results[i] <- 5 }
  }
  return(results)
}


userRFM$R <- intervalGrade(userRFM, "userRFM", "recency", quantR )
userRFM$F <- intervalGrade(userRFM, "userRFM", "freq", quantF )
userRFM$M <- intervalGrade(userRFM, "userRFM", "monetary", quantM )

head(userRFM)

userRFM$score <- (weightR * userRFM$R + weightF * userRFM$F + weightM * userRFM$M)*100/5

hist(userRFM$score)


dim(userRFM)

(quantS <- quantile(userRFM$score,c(0,0.2,0.4,0.6,0.8,1)))


# final grade function : algorithm is same as interval grade.
finalGrade <- function(mainData, fileName, rfmName, quantileData) {
  
  forLength <- dim(mainData)[1]
  
  results <- rep(0, forLength)

  for (i in 1:forLength) {
    
    data <- eval(parse(text=paste0(fileName,"$",rfmName)))[i]
    
    if (data >= quantileData[1] && data < quantileData[2] ) {
      results[i] <- "E"
    } else if (data >= quantileData[2] && data < quantileData[3]) {
      results[i] <- "D"
    } else if (data >= quantileData[3] && data < quantileData[4]) {
      results[i] <- "C"
    } else if (data >= quantileData[4] && data < quantileData[5]) {
      results[i] <- "B"
    } else { results[i] <- "A" }
  }
  
  return(results)
}

userRFM$grade <- finalGrade(userRFM, "userRFM", "score", quantS )
head(userRFM)
str(userRFM)

## Annonymous function--------------
datamat <- matrix(sample(1:10, 100, replace=T), nrow=5)
datamat
count5 <- function(x) {
  count = 0
  for (i in 1:length(x) ) {
    if(x[i] == 5) count=count+1
  }
  return(count)
}
apply(datamat, 1, count5)
apply(datamat, 1, 
      function(x) if (count5(x) >= 3) {
        "quite many" 
      } else {
        "not quite" 
      })

## Environment and scoping--------------

# 3 conponets of functions
formals(count5)
formals(intervalGrade)

body(count5)
body(intervalGrade)

environment(count5)
environment(intervalGrade)

# compare global environment and local environment
count5_envir <- function(x) {
  count = 0
  local_envir = environment()
  print(local_envir)
  for (i in 1:length(x) ) {
    if(x[i] == 5) count=count+1
  }
  return(count)
}

apply(datamat, 1, count5_envir)

#lexical scoping

a <- 1
b <- 2

f <- function(x) {
  a*x + b
}

g <- function(x) {
  a <- 2
  b <- 1
  f(x)
}

g(2)  # answer is?


a <- 1
b <- 2

f <- function(a, b) {
  return( function (x) {
    a*x + b
  })
}

g <- f(2, 1)

g(2) # answer is?

