drink <- read.csv("drink.csv" , header = T)
drink

str(drink)
attach(drink) 
library(class) 
m <- glm(지각여부 ~ 나이 + 결혼여부 + 자녀여부 + 체력 + 주량 + 직급 + 성별 , family = binomial(link = logit) , data = drink) 
m

predict(m , drink , type = "response") 

predict(m , drink , type = "response") >= 0.5
drink$지각여부
table(drink$지각여부 , predict(m , drink , type = "response") > 0.5)
summary(m) 

#발렌타인 선물 
ball <- read.csv("ball.csv" , header = T) 
ball
str(ball) 

library(nnet) 
m2 <- multinom(선물 ~ . , data = ball) 
m2

cbind(fitted(m2) , levels(ball$선물)[ball$선물])

predicted <- levels(ball$선물)[apply(fitted(m2) , 1 , which.max)]
predicted
sum(predicted != ball$선물)

xtabs(~ predicted + ball$선물)
