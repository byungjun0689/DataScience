library(tree)

real.estate <- read.table("cadata.dat", header=TRUE)
tree.model <- tree(log(MedianHouseValue) ~ Longitude + Latitude, data=real.estate)
plot(tree.model)
text(tree.model, cex=.75)
head(real.estate) 

price.deciles <- quantile(real.estate$MedianHouseValue, 0:10/10)
cut.prices    <- cut(real.estate$MedianHouseValue, price.deciles, include.lowest=TRUE)
plot(real.estate$Longitude, real.estate$Latitude, col=grey(10:2/11)[cut.prices], pch=20, xlab="Longitude",ylab="Latitude")
partition.tree(tree.model, ordvars=c("Longitude","Latitude"), add=TRUE)

summary(tree.model)

tree.model3 <- tree(log(MedianHouseValue) ~ Longitude + Latitude, data=real.estate , mindev=0.001)
plot(tree.model3)
text(tree.model3, cex=.75)

price.deciles2 <- quantile(real.estate$MedianHouseValue, 0:10/10)
cut.prices2    <- cut(real.estate$MedianHouseValue, price.deciles, include.lowest=TRUE)
plot(real.estate$Longitude, real.estate$Latitude, col=grey(10:2/11)[cut.prices], pch=20, xlab="Longitude",ylab="Latitude")
partition.tree(tree.model3, ordvars=c("Longitude","Latitude"), add=TRUE)

#tree model (piecewise linear regression) ##########################################
N <- 40 # number of sampled points
K <- 5  # number of knots

f <- function(x) {
  2 * sin(6 * x)
}

set.seed(1)
x <- seq(-1, 1, len = N)
y <- f(x) + rnorm(length(x))
x
y

plot(x, y)

piece.formula <- function(var.name, knots) {
  formula.sign <- rep(" - ", length(knots))
  formula.sign[knots < 0] <- " + "
  paste(var.name, "+",
        paste("I(pmax(", var.name, formula.sign, abs(knots), ", 0))",
              collapse = " + ", sep=""))
}

knots <- seq(min(x), max(x), len = K + 2)[-c(1, K + 2)]
model <- lm(formula(paste("y ~", piece.formula("x", knots))))
summary(model) 

par(mar = c(4, 4, 1, 1))
plot(x, y)
lines(x, f(x))
new.x <- seq(min(x), max(x) ,len = 10000)
points(new.x, predict(model, newdata = data.frame(x = new.x)),col = "red", pch = ".")
points(knots, predict(model, newdata = data.frame(x = knots)),col = "blue", pch = 18 , cex = 5)


######################################
library(segmented) 

set.seed(1234)
z <- runif(100)
y <- rpois(100,exp(2 + 1.8*pmax(z - .6,0)))
#points.segmented 15
o <- glm(y ~ z , family=poisson)
o.seg <- segmented(o , seg.Z = ~z , psi=list(z=.5))

par(mfrow=c(2,1))
plot(o.seg , conf.level=0.95, shade=TRUE)
plot(z , y)
## add the fitted lines using different colors and styles..
plot(o.seg , add=TRUE , link=FALSE , lwd=2 , col=2:3 , lty=c(1,2))
lines(o.seg , col=3 , pch=19 , bottom=FALSE , lwd=2)

######################################