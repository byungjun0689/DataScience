# 1203. Multivariable Regression ####
# Innovation in insurance industry

library(ggplot2)

insuracne <- read.csv("insurance.csv")
ggplot(insuracne,aes(x=size,y=time,color=type)) + geom_point(size=3)

cor(insuracne$time,insuracne$size)
# 음의 상관관계가 나온다. 그림또한 비슷하다.

formula <- as.formula("time~size+type")

model1 <- lm(time~size+type,insuracne)
summary(model1)

# Machine learning 에서 배운 Matirx의 합으로 수식을 최소화하는 방법과 같다. 
model.matrix(time~size+type,insuracne)

model1$fitted.values


# Graph

insuracne$fit = model1$fitted.values
gg <- ggplot(insuracne,aes(y=fit,x=size,group=type,color=type)) + geom_line() 
gg + geom_point(aes(y=time,x=size,shape=type))



# Reference Level 조정. 
# type(0 if stock, 1 if mutual)

insuracne$type = relevel(insuracne$type,ref="Stock")
model2 = lm(time ~ ., insuracne)
summary(model2)

model.matrix(time~size+type,insuracne)

insuracne$fit = model2$fitted.values
gg <- ggplot(insuracne,aes(y=fit,x=size,group=type,color=type)) + geom_line() 
gg + geom_point(aes(y=time,x=size,shape=type))

insuracne <- insuracne[,-c(4)] # if there is fit_value, delete fit_value

# Making dummy variable ( Effect coding )
model3 = lm(time~.,insuracne,contrasts = list(type=contr.sum))
model.matrix(time~.,insuracne,contrasts = list(type=contr.sum))
contr.sum(insuracne$type)

insuracne$fit = model3$fitted.values
gg <- ggplot(insuracne,aes(y=fit,x=size,group=type,color=type)) + geom_line() 
gg + geom_point(aes(y=time,x=size,shape=type))

df <- data.frame(m3 = model3$fitted.values, m2 = model2$fitted.values)



# over two level ####
# Country demographic information 
# 미국의 가장 인구가 많은 440개 county 의 자료

cdi <- read.csv("CDI.csv")
# y = crime
# x1 = pop
# region 지역 : (1=NE,2=NC,3=S,4=W)

cdi$region <- as.factor(cdi$region)
model_cdi <- lm(crime ~ pop + region, data=cdi)
summary(model_cdi)

model.matrix(crime ~ pop + region, data=cdi)

# anova 
anova(model_cdi)
# df = 3 -> b1,b2,b3이 동시에 0인지 확인하기 위한 Degree of freedom
# 기각이다. 같지 않다.

plot(model_cdi)
# 6번 Outlier 
cdi[6,]

cdi2 <- cdi[-6,]
model_cdi2 <- lm(crime ~ pop + region, data=cdi2)
summary(model_cdi2)
anova(model_cdi2)


model_cdi3 <- lm(crime ~ pop + region, data=cdi2, contrasts = list(region=contr.sum))
summary(model_cdi3)

# 평균 .
#(Intercept) -6.300e+03  6.983e+02  -9.022  < 2e-16 ***
#  pop          8.008e-02  9.561e-04  83.754  < 2e-16 ***
# region 1일때가 평균보다 -7.267e+03 

cdi2$fit = model_cdi2$fitted.values
gg <- ggplot(cdi2,aes(x=pop,y=fit,color=region)) + geom_line()
gg + geom_point(aes(x=pop,y=crime,shape=region))


model_cdi4 <- lm(crime ~ pop+region+pop*region,data=cdi2)
anova(model_cdi4)
# p-value < 0.05 차이가 잇다. 즉, 넣는것이 좋다.


# 교호작용 insurance data ####

model4 <- lm(time ~ size+type + size*type,insuracne)
anova(model4) 
# pvalue > 0.05 즉, 같다고 보면된다.


# 연속형변수
model_cdi5 <- lm(crime~pop+unemployment+pop*unemployment,cdi2)


# 교호작용을 적용할때 
# Centering 을 해주고 교호작용을 넣는 것이 좋다. 
# 선형관계가 강해질 수 있기 때문에 평균이 0이되도록 
# x1 - x-bar
# x2 - x-bar 해서 사용.
