
### multivariate normal

install.packages("rgl")
library(mvtnorm)
library(rgl)

x2=x1=seq(-4,4,0.1)
x1=matrix(x1,length(x1),length(x1))
x2=matrix(x2,length(x2),length(x2),byrow=T)

# independent normal
f=dmvnorm(cbind(as.vector(x1),as.vector(x2)))
f=matrix(f,dim(x1)[1],dim(x1)[1])
persp3d(x1,x2,f,col="lightblue",xlab="x1",ylab="x2")

X=rmvnorm(500,c(0,0),matrix(c(1,0,0,1),2,2))
plot(X[,1],X[,2],xlim=c(-4,4),ylim=c(-4,4),xlab="x1",ylab="x2")


# correlated normal
f=dmvnorm(cbind(as.vector(x1),as.vector(x2)),c(0,0),matrix(c(1,0.5,0.5,1),2,2))
f=matrix(f,dim(x1)[1],dim(x1)[1])
persp3d(x1,x2,f,col="lightblue",xlab="x1",ylab="x2")

X=rmvnorm(500,c(0,0),matrix(c(1,0.5,0.5,1),2,2))
plot(X[,1],X[,2],xlim=c(-4,4),ylim=c(-4,4),xlab="x1",ylab="x2")


### qq plot
x=seq(-4,4,0.01)

q=seq(0.1,0.9,0.1)
plot(x,dnorm(x),type='l',lwd=1.5,ylab="f(x)",xaxt="n")
for (i in 1:length(q)){
  lines(c(1,1)*qnorm(q[i]),c(-0.1,dnorm(qnorm(q[i]))))
}

axis(1,at=qnorm(q),labels=parse(text=paste("q[",q,"]",sep="")),cex.axis=0.8)
