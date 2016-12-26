cardh <- read.csv('card_history.csv' , header = T , stringsAsFactors = F) 

par(mfrow=c(3,2)) 
plot(density(cardh$식료품) , main = "식료품")
plot(density(cardh$의복) , main = "의복")
plot(density(cardh$외식비) , main = "외식비")
plot(density(cardh$책값) , main = "책값")
plot(density(cardh$온라인소액결제) , main = "온라인소액결제")
plot(density(cardh$의료비) , main = "의료비")

cardh[abs(mean(cardh$식료품) - cardh$식료품) > sd(cardh$식료품),]
cardh[abs(mean(cardh$온라인소액결제) - cardh$온라인소액결제) > 1.5 * sd(cardh$온라인소액결제),]

card_history <- read.csv('card_history2.csv' , header = T , stringsAsFactors = F) 
head(card_history)
library(reshape2) 
card_history <- card_history[-1] 

card2 <- melt(id = 1 , card_history , na.rm = TRUE) 
card2 <- subset(card2 , value != 'N') 
colnames(card2)[2:3] <- c("WEEK" , "FOOD")
card2[card2$FOOD == 'Y',"FOOD"] <- "N"
card2[card2$FOOD == 'F',"FOOD"] <- "Y" 
head(card2) 

library(class)
card2$WEEK <- as.integer(card2$WEEK)
card2$월 <- as.integer(as.factor(card2$월)) 
knnpred <- knn(card2[1:2] , card2[1:2] , card2$FOOD , k=2 , prob = TRUE) 
table(knnpred , card2$FOOD) 

test <- data.frame(TIME=c(15,16,17) , WEEK = c(4,4,4))
knnpred <- knn(card2[1:2] , test , card2$FOOD , k=5 , prob = TRUE) 
knnpred
attributes(knnpred)$prob > 0.65

library(corrplot)
prob <- read.csv('prob3.csv' , header = T , stringsAsFactors = F)
prob <- prob[-1]
cor(prob) 
corrplot(cor(prob))

prob$total_score <- prob$만족도 + prob$우울증
plot(density(prob$total_score) , main ="TOTAL SCORE")

prob[abs(mean(prob$total_score) - prob$total_score) > sd(prob$total_score),]

m1 <- lm(만족도 ~ 우울증 , data = prob) 
rstudent(m1)

library(car) 
outlierTest(m1)
