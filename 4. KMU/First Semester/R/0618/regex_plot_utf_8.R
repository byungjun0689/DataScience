## regular expression---------------
load("myDirData.RData")
myDirData

# write.csv(myDirData, file="myDirData_UTF_8.csv", fileEncoding="UTF-8", row.names=F)

#' 
#' 
#' 정규 표현식 (간략한 소개용 실습)
#' 
#' 
#' 

head(myDirData)
str(myDirData)
myDirData

# 메타문자 : ^ (문장의 첫글자를 의미함)
grepIndex <- grep("^jan", x = myDirData)
myDirData[grepIndex]
length(myDirData[grepIndex])

# 메타문자 : $ (문장의 마지막을 의미함)
grepIndex <- grep("pdf$", x = myDirData)
myDirData[grepIndex]
length(myDirData[grepIndex])


# 메타문자 : ? (선행문자 패턴이 0개 혹은 1개 나타납니다)
grepIndex <- grep("_?.png$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

grepIndex <- grep("nd?.png$", x = myDirData)  #nd 패턴이 0번혹은 1번 나온다. 
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

# 메타문자 : + (선행문자 패턴이 1개이상 나타납니다)  [0-9a-zA-Z_] 중의 글자가 1개 이상 반복. 
# 즉 Jun으로 시작하고 [0-9a-zA-Z_] 가 반복하는 png앞에 .(한글자이상이 있다.)
grepIndex <- grep("^jun[0-9a-zA-Z_]+.png$", x = myDirData)
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

# 메타문자 : + (선행문자 패턴이 1개이상 나타납니다)
# 한글이 있고 .Rdata로 끝나는 문자열을 찾는다.
grepIndex <- grep("[가-힣]+\\.RData$", x = myDirData)  
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

# 메타문자 + 와 * 의 차이를 느껴보세요. 
grepIndex <- grep("[가-힣]*\\.RData$", x = myDirData)  # 0개 이상 반복이니깐 전부 다 나온다. 한글이 없어도 나옴. 
grepIndex
myDirData[grepIndex]
length(myDirData[grepIndex])

#'
#'
#' stringr 패키지를 활용 정규 표현식 활용
#' stringr 패키지는 data 벡터를 제 1아규먼트로 지정하고,
#' 정규 표현식 패턴을 나중에 지정한다.
#' str_match() 함수는 패턴에 맞는 문자열을 찾아서 괄호로 감싼 부분을 추출해준다.
#' 
#' 


library(stringr)
rmatch <- str_match(myDirData, "([가-힣]+)")
rmatch2 <- str_match(myDirData, "([가-힣]+)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]


# 한글자만 빼낸다.
rmatch <- str_match(myDirData, "(\\.[0-9a-zA-z]?)")
rmatch
rmatch2 <- str_match(myDirData, "(\\.[0-9a-zA-z]?)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]

# 1개이상 반복.
rmatch <- str_match(myDirData, "(\\.[0-9a-zA-z]+)")
rmatch
rmatch2 <- str_match(myDirData, "(\\.[0-9a-zA-z]]+)")[,2]
rlocate <- which(!is.na(rmatch2))
rmatch[rlocate]


rmatch <- str_match(myDirData, "(\\.[csv]+)")   # 앞의 패턴 c, s,v cs, csv, sv 등등 다 나옴.
rmatch
length(rmatch[!is.na(rmatch)])
rmatch[!is.na(rmatch)]

rmatch <- str_match(myDirData, "(\\.csv)")   #csv 만 나온다.
rmatch
length(rmatch[!is.na(rmatch)])
rmatch[!is.na(rmatch)]  

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

#plot < generic function -> 각각의 데이터의 형태에 따라 모양을 다르게 표현해준다.
methods(plot)
plot(anscombe$Ax, anscombe$Ay, pch=15)  # pch = 값을 표현하는 모양? 
plot(anscombe$Bx, anscombe$By, pch=19)
plot(anscombe$Cx, anscombe$Cy, pch=19)
plot(anscombe$Dx, anscombe$Dy, pch=19 )

# plot 의 속성 
# main =  ?  : 그래프의 이름
# xlab : x 축 이름
# ylab : y 축 이름
# axis 1 : x축
# axis 2 : y축 
# xaxt, yaxt : x,y 축 설명.


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


# ylim : y축 지정 c(0.max) 0부터 max값까지.   xaxt ="n" x축에 아무것도 적지마라.
plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])), xaxt="n")
plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])))
axis(1, a=1:7, labels=names(bike_eda1_N[-1]))
lines(as.numeric(bike_eda1_N[2,-1]), type="l", col="red")
lines(as.numeric(bike_eda1_N[3,-1]), type="l", col="black")
lines(as.numeric(bike_eda1_N[4,-1]), type="l", col="green")

plot(as.numeric(bike_eda1_N[1,-1]), type="l", col="blue", ylim=c(0, max(bike_eda1_N[,-1])), 
     xaxt="n", yaxt="n",xlab="", ylab="Number of bike riders", main="요일별 Bike rider Trend by subs_type")
axis(1, at=1:7, labels=names(bike_eda1_N[-1]))
axis(2, at=c(0,200000,400000,600000,800000,1000000), labels=c(0,"20만","40만","60만","80만","100만"))
lines(as.numeric(bike_eda1_N[2,-1]), type="l", col="red")
lines(as.numeric(bike_eda1_N[3,-1]), type="l", col="black")
lines(as.numeric(bike_eda1_N[4,-1]), type="l", col="green")

# 7- 0.5 는 index로 어디에 붙일지 보는것. 7이 일. 그래서 0.5만큼 빼서 
# y는 첫번째 그림 위에 밑에 붙여라 ( 50000만큼 ) 이것을 4번 반복. 
text(7-0.5, bike_eda1_N[1,7]+ 50000, "Casual")   
text(7-0.5, bike_eda1_N[2,7]+ 50000, "Member")
text(7-0.5, bike_eda1_N[3,7]+ 50000, "Registered")
text(7-0.5, bike_eda1_N[4,7]+ 50000, "Subscriber")
?text
methods(plot) #plot is "generic function"
# [1] plot.acf*           plot.data.frame*    plot.decomposed.ts* plot.default        plot.dendrogram*   
# [6] plot.density*       plot.ecdf           plot.factor*        plot.formula*       plot.function      
# [11] plot.hclust*        plot.histogram*     plot.HoltWinters*   plot.isoreg*        plot.lm*           
# [16] plot.medpolish*     plot.mlm*           plot.ppr*           plot.prcomp*        plot.princomp*     
# [21] plot.profile.nls*   plot.raster*        plot.spec*          plot.stepfun        plot.stl*          
# [26] plot.table*         plot.ts             plot.tskernel*      plot.TukeyHSD*     
# see '?methods' for accessing help and source code
