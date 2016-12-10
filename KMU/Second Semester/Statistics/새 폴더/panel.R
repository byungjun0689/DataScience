install.packages("mice")
library(mice)
library(ggplot2)
head(potthoffroy)

data = reshape(potthoffroy,idvar="id", varying = list(3:6), v.name="dist", direction = "long")
data$sex.m = 1
data$sex.m[data$sex=="F"] <- 0
head(data)

ggplot(data,aes(y=dist,x=time,group=id,colour=sex)) + geom_line(aes(linetype=sex),stat="identity") + geom_point()

library(plyr)
data2 <- ddply(data,~sex+time,summarize,mean=mean(dist))

ggplot(data2,aes(y=mean,x=time,colour=sex)) + geom_line(aes(linetype=sex), stat="identity") + geom_point()


# anova test ####
model1 <- lm(dist~sex,data)
anova(model1) # p-value < 0.05   즉, H0 기각. 같지 않다. sex별 dist값의 평균은 같지 않다.


# repeated measure anova ####
library(nlme)

# generalize list square 
model3 <- gls(dist~sex,data,correlation = corAR1(form=~1|id))
anova(model3)
summary(model4)


model4 <- gls(dist~sex,data,correlation = corCompSymm(form=~1|id))
anova(model4)
summary(model4)


# 선형혼합모형 ####

model4 = lm(dist~sex+time+sex:time,data)
summary(model4)

install.packages("lme4")
install.packages("lmerTest")
library(lme4)
library(lmerTest)
model5 <- lmer(dist~sex+time+sex:time+(1|id),data)
summary(model5)

model6 <- lmer(dist~sex+time+sex:time+(1|id),data)
summary(model6)


# random intercept and slope model ####
model7 <- lmer(dist~sex+time+sex:time+(1+time|id),data)
summary(model7)

# Random effects:
#   Groups   Name        Variance Std.Dev. Corr 
#    id     (Intercept) 3.4818   1.8660        
#    time                 0.1301   0.3607   -0.28   > intercept 랑 time의  Cor 이다. 절편이 작을 수록 기울기가 커진다. 
#    Residual             1.7162   1.3100        
#    Number of obs: 108, groups:  id, 27



# timber slippage ####
library("MVA")
install.packages("RLRsim")
library(RLRsim)
demo("Ch-LME")
head(timber)
data(timber)
