fa2=factanal(app,4,rotation="none")
print(fa2,digits=2,sort=T)

library(psych)
library(GPArotation)
fa3=fa(app[,-1],3,rotate="oblimin")
print(fa3,digits=2,sort=T)


###
stock=read.csv("stock_price.csv")
fa1=fa(stock[,-1],2,rotate="oblimin")
fa1=fa(stock[,-1],2,rotate="varimax")
fa1=fa(stock[,-1],2,rotate="quartimax")

print(fa1,sort=T)

bank=apply(stock[,2:4],1,mean)
oil=apply(stock[,5:6],1,mean)

windows()
plot(bank,oil)

plot(bank,type="l",ylim=c(-0.1,0.1),ylab="Stock Rate")
lines(oil,col=2)
legend("topright",c("bank","oil"),lty=1,col=1:2)
