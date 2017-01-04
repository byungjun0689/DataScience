#앙상블 테스트
ret_err <- function(n,err) {

  sum <- 0 
  for(i in floor(n/2):n) { 
    sum <- sum + choose(n,i) * err^i * (1-err)^(n-i)
  }
  sum
}

for(j in 1:60) {
  
  err <- ret_err(j , 0.4)
  cat(j,'--->',1-err,'\n') 
  if(1-err >= 0.9) break
}


library(rpart)
head(kyphosis)
# grow tree 
fit <- rpart(Kyphosis ~ Age + Number + Start,method="class", data=kyphosis)

#plot tree 
plot(fit, uniform=TRUE, main="Classification Tree for Kyphosis")
text(fit, use.n=TRUE, all=TRUE, cex=.8)

#result 
res <- predict(fit , newdata = kyphosis)
sum(kyphosis$Kyphosis == ifelse(res[,1]>0.5 , "absent" , "present"))/NROW(kyphosis) #0.8395062

# Random Forest prediction of Kyphosis data
library(randomForest)
fit <- randomForest(Kyphosis ~ Age + Number + Start,   data=kyphosis)
print(fit) # view results 
res2 <- predict(fit , newdata = kyphosis)
sum(res2 == kyphosis$Kyphosis)/NROW(kyphosis)

importance(fit) # importance of each predictor 
varImpPlot(fit) 

grid <- expand.grid(ntree = c(10,20,30) , mtry = c(2,3)) 
result <- foreach(g=1:nrow(grid) , .combine = rbind) %do% {
  m <- randomForest(Kyphosis ~ Age + Number + Start,   data=kyphosis , ntree=grid[g,"ntree"] , mtry=grid[g,"mtry"])
  pred <- predict(m , newdata = kyphosis) #예측 
  accur <- sum(kyphosis$Kyphosis == pred) / nrow(kyphosis)
  return(data.frame(g=g , accuracy=accur))
}
result 
grid 

#Bagging TEST
data(pima, package="faraway")
pima$test <- factor(pima$test)

preds <- c() 
for(i in 1:100) {
  tidx <- sample(1:nrow(pima) , nrow(pima) , replace = TRUE)
  m <- glm(test ~ pregnant + glucose + bmi , family=binomial, data=pima[tidx,])
  pred <- as.integer(predict(m , newdata = pima , type = "response") > 0.5)
  preds <- rbind(preds , pred) 
}

new_pred <- as.integer(apply(preds , 2 , mean) > 0.5)
sum(pred != pima$test)
sum(new_pred != pima$test)

#Ada Boosting TEST
library(ada)
data(pima, package="faraway")
pima$test <- factor(pima$test)
m <- ada(test ~ pregnant + glucose + bmi , data=pima , iter = 100 , nu = 1 , type = "discret")
pred <- predict(m , newdata = pima)
sum(pima$test != pred)


