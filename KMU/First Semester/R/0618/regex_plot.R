## regular expression---------------
load("myDirData.RData")
myDirData

# write.csv(myDirData, file="myDirData_UTF_8.csv", fileEncoding="UTF-8", row.names=F)

#' 
#' 
#' Á¤±Ô Ç¥Çö½Ä (°£·«ÇÑ ¼Ò°³¿ë ½Ç½À)
#' 
#' 
#' 

head(myDirData)
str(myDirData)
myDirData

# ¸ÞÅ¸¹®ÀÚ : ^ (¹®ÀåÀÇ Ã¹±ÛÀÚ¸¦ ÀÇ¹ÌÇÔ)
grepIndex <- grep("^jan", x = myDirData)
myDirData[grepIndex]
length(myDirData[grepIndex])

# ¸ÞÅ¸¹®ÀÚ : $ (¹®ÀåÀÇ ¸¶Áö¸·À» ÀÇ¹ÌÇÔ)
grepIndex <- grep("pdf$", x = myDirData)
myDirData[grepIndex]
length(myDirData[grepIndex])


# ¸ÞÅ¸¹®ÀÚ : ? (¼±Çà¹®ÀÚ ÆÐÅÏÀÌ 0°³ È¤Àº 1°³ ³ªÅ¸³³´Ï´Ù)
grepIndex <- grep("_?.png$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

grepIndex <- grep("nd?.png$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

# ¸ÞÅ¸¹®ÀÚ : + (¼±Çà¹®ÀÚ ÆÐÅÏÀÌ 1°³ÀÌ»ó ³ªÅ¸³³´Ï´Ù)
grepIndex <- grep("^jun[0-9a-zA-Z_]+.png$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

# ¸ÞÅ¸¹®ÀÚ : + (¼±Çà¹®ÀÚ ÆÐÅÏÀÌ 1°³ÀÌ»ó ³ªÅ¸³³´Ï´Ù)
grepIndex <- grep("[°¡-ÆR]+\\.RData$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

# ¸ÞÅ¸¹®ÀÚ + ¿Í * ÀÇ Â÷ÀÌ¸¦ ´À²¸º¸¼¼¿ä. 
grepIndex <- grep("[°¡-ÆR]*\\.RData$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

#'
#'
#' stringr ÆÐÅ°Áö¸¦ È°¿ë Á¤±Ô Ç¥Çö½Ä È°¿ë
#' stringr ÆÐÅ°Áö´Â data º¤ÅÍ¸¦ Á¦ 1¾Æ±Ô¸ÕÆ®·Î ÁöÁ¤ÇÏ°í,
#' Á¤±Ô Ç¥Çö½Ä ÆÐÅÏÀ» ³ªÁß¿¡ ÁöÁ¤ÇÑ´Ù.
#' str_match() ÇÔ¼ö´Â ÆÐÅÏ¿¡ ¸Â´Â ¹®ÀÚ¿­À» Ã£¾Æ¼­ °ýÈ£·Î °¨½Ñ ºÎºÐÀ» ÃßÃâÇØÁØ´Ù.
#' 
#' 


library(stringr)
rmatch <- str_match(myDirData, "([°¡-ÆR]+)")
rmatch2 <- str_match(myDirData, "([°¡-ÆR]+)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]

rmatch <- str_match(myDirData, "(\\.[0-9a-zA-z]?)")
rmatch
rmatch2 <- str_match(myDirData, "(\\.[0-9a-zA-z]?)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]

rmatch <- str_match(myDirData, "(\\.[0-9a-zA-z]+)")
rmatch
rmatch2 <- str_match(myDirData, "(\\.[0-9a-zA-z]]+)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]


rmatch <- str_match(myDirData, "(\\.[csv]+)")
rmatch
rmatch <- str_match(myDirData, "(\\.csv)")
rmatch
rmatch2 <- str_match(myDirData, "(\\.csv)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]

rmatch2 <- str_match(myDirData, "(\\.csv$)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]


## plot---------------

##Ploting-------------

load("anscombe.RData")
(anscombe)
apply(anscombe, 2, mean)
apply(anscombe, 2, var)

plot(anscombe$Ax, anscombe$Ay, pch=19)
plot(anscombe$Bx, anscombe$By, pch=19)
plot(anscombe$Cx, anscombe$Cy, pch=19)
plot(anscombe$Dx, anscombe$Dy, pch=19)


par(mfrow=c(2,2))
plot(anscombe$Ax, anscombe$Ay)
A <- coef(lm(anscombe$Ay~anscombe$Ax))
abline(a=A[1], b=A[2], col="red")

plot(anscombe$Bx, anscombe$By)
B <- coef(lm(anscombe$By~anscombe$Bx))
abline(a=B[1], b=B[2], col="red")

plot(anscombe$Cx, anscombe$Cy)
C <- coef(lm(anscombe$Cy~anscombe$Cx))
abline(a=C[1], b=C[2], col="red")

plot(anscombe$Dx, anscombe$Dy)
D <- coef(lm(anscombe$Dy~anscombe$Dx))
abline(a=D[1], b=D[2], col="red")
par(mfrow=c(1,1))


help(par)


# bike_EDA

load("bike_eda1_N.RData")
head(bike_eda1_N)

plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])), xaxt="n")
axis(1, a=1:7, labels=names(bike_eda1_N[-1]))
lines(as.numeric(bike_eda1_N[2,-1]), type="l", col="red")
lines(as.numeric(bike_eda1_N[3,-1]), type="l", col="black")
lines(as.numeric(bike_eda1_N[4,-1]), type="l", col="green")

plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])), 
     xaxt="n", yaxt="n",xlab="", ylab="Number of bike riders", main="¿äÀÏº° Bike rider Trend by subs_type")
axis(1, at=1:7, labels=names(bike_eda1_N[-1]))
axis(2, at=c(0,200000,400000,600000,800000,1000000), labels=c(0,"20¸¸","40¸¸","60¸¸","80¸¸","100¸¸"))
lines(as.numeric(bike_eda1_N[2,-1]), type="l", col="red")
lines(as.numeric(bike_eda1_N[3,-1]), type="l", col="black")
lines(as.numeric(bike_eda1_N[4,-1]), type="l", col="green")
text(7-0.5, bike_eda1_N[1,7]+ 50000, "Casual")
text(7-0.5, bike_eda1_N[2,7]+ 50000, "Member")
text(7-0.5, bike_eda1_N[3,7]+ 50000, "Registered")
text(7-0.5, bike_eda1_N[4,7]+ 50000, "Subscriber")

methods(plot) #plot is "generic function"
# [1] plot.acf*           plot.data.frame*    plot.decomposed.ts* plot.default        plot.dendrogram*   
# [6] plot.density*       plot.ecdf           plot.factor*        plot.formula*       plot.function      
# [11] plot.hclust*        plot.histogram*     plot.HoltWinters*   plot.isoreg*        plot.lm*           
# [16] plot.medpolish*     plot.mlm*           plot.ppr*           plot.prcomp*        plot.princomp*     
# [21] plot.profile.nls*   plot.raster*        plot.spec*          plot.stepfun        plot.stl*          
# [26] plot.table*         plot.ts             plot.tskernel*      plot.TukeyHSD*     
# see '?methods' for accessing help and source code
