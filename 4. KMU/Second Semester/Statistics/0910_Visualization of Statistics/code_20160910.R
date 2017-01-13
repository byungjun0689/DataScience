library(MVA)
demo("Ch-MVA")

hist(USairpollution$SO2)
boxplot(USairpollution$SO2)

plot(popul~manu, USairpollution)

plot(USairpollution$manu, USairpollution$popul,
      xlab="Manufacturing enterprise with 20 or more workers",
     ylab="Population size",
     main="US airpollution",
     xlim=c(0,4000))
identify(USairpollution$manu, USairpollution$popul,labels= rownames(USairpollution))

library(psych)
pairs.panels(USairpollution)
corr.test(USairpollution)


USairpollution[USairpollution$manu>2500,]

outcity=match(c("Chicago","Detroit","Houston","Philadelphia"),
              rownames(USairpollution))

pairs.panels(USairpollution[-outcity,])


##bubble chart
with(USairpollution, symbols(temp, wind,circles=SO2,inches=0.5))


##Mosaic plot
UCBAdmissions[,1,]

mosaicplot(~Dept+Gender,
           data=UCBAdmissions,color=T)

mosaicplot(~Gender+Dept,
           data=UCBAdmissions,color=T)


### crime data
setwd("C:/Users/CB103/Downloads")
crime=read.csv("crime.csv")

pairs.panels(crime[,-1])

plot(crime$robbery, crime$forcible_rape)
identify(crime$robbery, crime$forcible_rape,labels=crime$state)

plot(crime$robbery, crime$population)
identify(crime$robbery, crime$population,labels=crime$state)

out=match(c("United States","Alaska","District of Columbia"),crime$state)
clr=rep(1,dim(crime)[1])
clr[out]=2
pairs(crime[,-1],col=clr,pch=clr)

crime2=crime[-out,]
pairs.panels(crime2[,-1])

symbols(crime2$murder,crime2$robbery,circles=crime2$population)
