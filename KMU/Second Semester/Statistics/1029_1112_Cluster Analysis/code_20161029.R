dist(USArrests,method="manhattan")
mahalanobis(USArrests,colMeans(USArrests), cov(USArrests))


x=data.frame(c(1,3,6,12,20))
rownames(x)=c("a","b","c","d","e")
dist(x)
hc1=hclust(dist(USArrests),method="single")
plot(hc1)

hc2=hclust(dist(USArrests),method="complete")
windows()
plot(hc2)

hc3=hclust(dist(USArrests),method="average")
windows()
plot(hc3)

hc4=hclust(dist(USArrests),method="ward.D")
windows()
plot(hc4)

USArrests_s=scale(USArrests)
hc3=hclust(dist(USArrests_s),method="average")
plot(hc3)
hc3_result=cutree(hc3,k=5)

plot(Murder~Rape,data=USArrests,type="n")
text(USArrests$Rape,USArrests$Murder,
     rownames(USArrests),col=hc3_result,cex=0.8)

par(mfcol=c(2,2))
for (i in 1:4){
boxplot(USArrests[,i]~hc3_result,main=names(USArrests)[i])
}

library(psych)
describeBy(USArrests,group=hc3_result)

data.frame()
