####################################################
###############모비율에 대한 검정###################
####################################################

prop.test(67, 120, p=0.5)
prop.test(c(60,120), c(150,250), alternative="less")

###독립성 검정
matrix(c(33,28,5,67,122,45),3,2)
chisq.test(matrix(c(33,28,5,67,122,45),3,2))
#P-value가 낮다. 귀무가설을 기각한다.
#서로 독립이 아니다. 상관이 있다. 

nyr <- read.csv("NYreform.csv")
head(nyr)
str(nyr)

par(las=1)
par(mfcol=c(1,2))
tabl <- xtabs(~Pay.Cut+Party, nyr)
chisq.test(tabl)
mosaicplot(tabl)
mosaicplot(t(tabl))

tabl2 <- xtabs(~Lobbyists+Party, nyr)
chisq.test(tabl2)
mosaicplot(tabl2)
mosaicplot(t(tabl2))

tabl3 <- xtabs(~Term.Limits+Party, nyr)
chisq.test(tabl3)
mosaicplot(tabl3)
mosaicplot(t(tabl3))

prop.test(c(17,32), c(36,45), alternative="less")
prop.test(21, 36, p=0.5)   #p의 디폴트 값은 0.5 

