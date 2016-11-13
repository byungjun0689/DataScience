# par(mfrow=c(1,1))
# hc1 <- hclust(dist(Cereal_s),method="single")
# plot(hc1)
# hc2 <- hclust(dist(Cereal_s),method="complete")
# plot(hc2)
# hc3 <- hclust(dist(Cereal_s),method="average")
# plot(hc3)
# hc4 <- hclust(dist(Cereal_s),method="ward.D")
# plot(hc4)
# hc4_result <- cutree(hc4,k=6)
# plot(Murder ~ Assault, data=Cereal_s, col=hc4_result,pch=hc4_result)

# 다변량통계분석
# 2016년 2학기
# -	각 문항에 답을 하기 위해 사용된 그래프, 표, 통계량 등을 반드시 모두 제시하시오. 
# -	각 문제에 대한 답안 파일과 문제를 해결하기 위해 사용한 R 스크립트 파일을 함께 제출하시오. 

# 'data.frame':	43 obs. of  10 variables:
# $ Brand         : chr  "ACCheerios" "Cheerios" "CocoaPuffs" "CountChocula" ...
# $ Manufacturer  : chr  "G" "G" "G" "G" ...
# $ Calories      : int  110 110 110 110 110 110 110 110 100 130 ...
# $ Protein       : int  2 6 1 1 1 3 2 2 2 3 ...
# $ Fat           : int  2 2 1 1 1 1 1 1 1 2 ...
# $ Sodium        : int  180 290 180 180 280 250 260 180 220 170 ...
# $ Fiber         : num  1.5 2 0 0 0 1.5 0 0 2 1.5 ...
# $ Carbonhydrates: num  10.5 17 12 12 15 11.5 21 12 15 13.5 ...
# $ Sugar         : int  10 1 13 13 9 10 3 12 6 10 ...
# $ Potassium     : int  70 105 55 65 45 90 40 55 90 120 ...


# 1.	Cereal.csv는 3개의 미국 시리얼 제조사(General Mills: G, Kellogg: K, Quaker: Q)에 의해 생산되는 
# 아침식사용 시리얼 각 브랜드의 영양성분 자료이다. 
# A.	영양성분 상 특성을 시리얼 별로 한눈에 비교하기 위한 그래프를 그린 후 비슷한 영양성분을 가지는 
# 시리얼들을 탐색적으로 구분하여 서술하시오.

library(psych)

Cereal <- read.csv("cereal.csv", stringsAsFactors = F)
Cereal_s <- Cereal[,-c(1,2)]
Cereal_s <- as.data.frame(Cereal_s)
rownames(Cereal_s) <- Cereal[,1]
pairs.panels(Cereal_s)

pca = prcomp(Cereal_s,scale=T)  # 상관계수로 주성분 분석을 한다. scale된 변수로 (평균0 표편1)
summary(pca)
pca
biplot(pca, cex=0.7)

# B.	8개의 영양성분 상의 특성을 보다 적은 차원에서 설명하기 위해 주성분분석을 활용하여 분석을 진행하시오. 
# 적절한 그래프와 결과물을 사용하여 아래의 문항에 답변하시오.
# i.	적절한 주성분의 개수는 무엇인가? 
# ii.	각 주성분은 어떤 의미를 가지는가?
# iii.	이상치가 있는가? 있다면 어떤 성질을 가지는가?
# iv.	주성분 분석의 결과를 활용하여 볼 때 각 제조사가 생산하는 시리얼 별로 영양성분 상의 특성이 다른가?
# 2.	Psych package 안에 포함되어 있는 Thurstone.33 데이터셋은 4175명의 학생의 인지능력 테스트로부터 계산된 상관계수 행렬이다. 
# A.	이 데이터를 사용하여 요인분석을 진행하여 9개의 테스트 결과에 영향을 주는 잠재요인을 파악하시오. (적절한 요인 개수와 요인회전 고려) 
# B.	잠재요인에 의해 가장 설명이 잘되는 원변수와 가장 설명이 안되는 원변수를 찾으시오. 
# C.	각 잠재요인이 데이터의 변동을 설명해 주는 비율을 계산하시오.
