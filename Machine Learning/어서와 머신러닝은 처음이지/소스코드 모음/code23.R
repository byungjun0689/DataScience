#피겨스케이팅 문제
n <- 1000 #실험횟수 
m <- numeric(1000) 

for(j in 1:n) { 
  run <- runif(100) 
  success <- as.numeric(run < 0.6) #성공하면 1, 실패하면 0
  
  for(i in 1:(100-2)) {
    
    #3번 연속으로 성공하면 멈춘다.
    if((success[i] * success[i+1] * success[i+2]) == 1) break
  }
  
  m[j] <- i + 2
}

mean(m) 
m 

#평균 자녀수문제 
n <- 1000
for(i in 1:n) { 
  for(j in 1:4) {
    run <- runif(1) 
    if(run > 0.5) break
  }
  m[i] = j 
  
}

m 
mean(m) 

buffon_needle <- function(n , L , D) {
  #n은 시행횟수 , L은 바늘의 길이 , D는 평행선의 간격 
  l <- L/2
  d <- D/2 
  k <- 0 
  
  for(i in 1:n) {
    if(runif(1)*d < l*sin(runif(1) * pi)) k <- k + 1
  }
  p <- k/n 
  hpi <- 2 * l / (p*d) 
  return(hpi) 
}

buffon_needle(100 , 18 , 24) 
buffon_needle(1000 , 18 , 24) 
buffon_needle(10000 , 18 , 24) 
buffon_needle(100000 , 18 , 24) 

#주가 시뮬레이션 
#load quantmod
library(quantmod)
getSymbols("AAPL")
price_AAPL <- AAPL[,6]
plot(price_AAPL, main = "The price of AAPL")
nrow(price_AAPL) 

returns_AAPL <- diff(log(price_AAPL))
plot(returns_AAPL, main = "AAPL returns")
hist(returns_AAPL, breaks = 100, col="blue")

head(returns_AAPL)
acf(returns_AAPL[-1], main = "Autocorrelation of returns")

mt  <- mean(returns_AAPL[-1])
sdt <- sd(returns_AAPL[-1])
mt;sdt

N     <- 1000
mu    <- 0.0009165089
sigma <- 0.02118514
p  <- c(100, rep(NA, N-1))

for(i in 2:N)
  p[i] <- p[i-1] * exp(rnorm(1, mu, sigma))

plot(p, type = "l", col = "blue", main = "Simulated Stock Price")

require(MASS)
require(quantmod)

getSymbols(c("AAPL", "GOOG", "CVX"))

par(mfrow = c(2,2))
plot(AAPL[,6], main = "AAPL")
plot(GOOG[,6], main = "GOOG")
plot(CVX[,6], main = "CVX")

#주가와 수익률 
pM <- cbind(AAPL[,6], GOOG[,6], CVX[,6])
rM <- apply(pM,2,function(x) diff(log(x)))

pairs(coredata(rM))
covR <- cov(rM)
covR
meanV <- apply(rM, 2, mean)
rV    <- mvrnorm(n = nrow(rM), mu = meanV, Sigma = covR)
meanV

p0 <- apply(pM,2,mean)
sPL <- list()
for(i in 1:ncol(rM)){
  sPL[[i]] <- round(p0[i]*exp(cumsum(rV[,i])),2)
}

#plot simulated prices
par(mfrow = c(2,2)) 
plot(sPL[[1]],main="AAPLsim",type="l")
plot(sPL[[2]], main = "GOOG sim",type = "l") 
plot(sPL[[3]], main = "CVX sim", type = "l")
p0 

#SNA simulation
library(igraph) 
n <- 100
N <- n*(n*1) 
mu <- 5 
social <- random.graph.game(n+1 , p=mu/n , directed=T) 
dist.D <- path.length.hist(social) 
round(dist.D$res/N*100,2) 
round(dist.D$unconnected/N*100,2) 
plot(social , edge.arrow.mode = "-") 

