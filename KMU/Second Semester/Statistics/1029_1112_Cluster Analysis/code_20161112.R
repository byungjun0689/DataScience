install.packages("mclust")
library(mclust)
mc=Mclust(USArrests,4)
mc$classification
plot(mc)

par(mfrow=c(2,2))
for (i in 1:4){
  boxplot(USArrests[,i]~mc$classification,main=names(USArrests)[i])
}

par(mfrow=c(3,1))
for (i in 1:3){
  USArrests_s=as.data.frame(scale(USArrests))
  boxplot(USArrests_s[mc$classification==i,])
}


library(psych)
result=describeBy(USArrests[,1],group=mc$classification,mat=T)

library(ggplot2)
ggplot(result,aes(x=group1,y=mean,fill=group1))+
  geom_bar(position=position_dodge() ,stat="identity")+
  geom_errorbar(aes(ymin=mean-2*se, ymax=mean+2*se),width=0.1)


model=aov(USArrests$Murder~factor(mc$classification))
summary(model)
TukeyHSD(model)


####
setwd("C:/Users/CB103/Downloads")
jet=read.csv("jet.csv")


mc2=Mclust(jet[,2:5],2)
summary(mc2)

mc3=Mclust(jet[,2:5],3)
summary(mc3)
