# LSA 해석
# 절대값이 큰것을 기준으로 해석하면 된다.
# + 도 나오고 - 도 나온다. 이게 뭐냐?
# 5.PNG
# 바나나, 사과, 귤 => 과일에 관련된 차원이다. 
# 여기서 + 와 -가 뭐냐.???
# + 로 가면 갈수록 차원이 커질수록, 바나나 사과 귤 증가하게 된다. 
# 어떤 차원의 값이 0 이고 , 어떤 차원이 값이 1 이면 1인 차원의 값을 가진 문서가 바나나 사과 귤에 연관이 높다.
# 꽁치 말하다와 같은 단어는 음수에 가까울수록 많이 나타난다.
# 6.PNG
# 7.PNG
# 8.PNG
# 9.PNG
# 10. PNG
# 세로 축은 단어의 수 
# 예 ) 오징어 수가 ( 세로 ) 가로를 보면 가로 1이면 오징어 1, 가로가 2 오징어 2  => 기울기1 
# 11.PNG
# 예) 문어 
# 가로 1 세로 2, 가로 2 세로 1.5 => 기울기 -0.5
# 기울기가 크면 변화량이 크다. => 기울기는 일종의 관련성을 나타낸다고 본다. 
# 12.PNG

# LSA에서 문서의 좌표와 유사도
# 13.PNG 
# 왼쪽으로 갈수록 교통 수단, 위로 갈수록 과일이라고 치면, 왼쪽에 치우친 문서들은 교통 수단에 대한 정보가 많고 위쪽은 과일에 대한 정보가 많은 문서들.
# 문서의 유사도 -> 거리를 구한다. 
# 동일한 내용의 문서인데도 내용이 많다면 더 위쪽이나 멀리 가게 된다. 하지만 내용은 비슷하다. 즉, 벡터는 방향을 가진다 => 거리만가지고 보기엔 외곡이 있을 수 있다.
# 코사인 유사도(Cosine Similarity) 
# 절대적인 좌표를 무시하고 방향성만 보자. 중심을 기준으로 가로축 차원이 강한가 세로축 차원이 강한가.
# 왜 Cosine 유사도라고 하는가?
# 각도를 숫자로 바꾸는 방법이다.
# 14 15 16PNG 
# 각도의 크기를 1~-1  / 1에 가까울수록 굉장히 비슷, 0 다른 차원의 값, -1 같은 차원에 있지만 방향이 완전 반대다. 
# 길이는 중요치 않다. 즉, 길이를 보정해줘야된다. 표준화 해줘서 방향성만 가지고 길이를 표준화
# 17, 18PNG
# 표준화가 된다면 대략적으로 위치를 알 수 있다. 

library(tm)
library(slam)
library(lsa)
library(GPArotation)

news <- read.csv("News-article-wikipedia-DFE.csv", stringsAsFactors = F)
tdm <- TermDocumentMatrix(Corpus(VectorSource(news$newdescp)), 
                         control=list(
                           removePunctuation=T,
                           removeNumbers=T,
                           stopwords=T
                         ))

# Word Count 세기.
word.count <- as.array(rollup(tdm,2))
word.order <- order(word.count,decreasing = T)
freq.word <- word.order[1:1000]
row.names(tdm[freq.word,])

tdm.mat <- as.matrix(tdm[freq.word,]) # 자주 사용하는 단어들만 모아서 tdm(각문서에서 Term을 가지고 온다.)
tdm.mat <- lw_bintf(tdm.mat) * gw_idf(tdm.mat)
news.lsa <- lsa(tdm.mat,30) # 30차원으로 줄인다. 

# LSA결과를 Varimax로 회전

tk = Varimax(news.lsa$tk)$loadings
# 회전된 tk와 LSA를 한 term document matrix를 곱해주면 문서의 좌표를 구합니다. 
# (새로운 문서가 추가될 경우 새로운 문서의 term document matrix를 곱해주면 됩니다)
doc.space <- t(tk) %*% tdm.mat  

norm  = sqrt(colSums(doc.space ^ 2)) # 문서가 Column이다.
norm.space = sweep(doc.space, 2, norm, '/')
sum(norm.space[,1]^2) # 1이 나온다. 

cosine(norm.space[,1],norm.space[,2]) #굉장히 다른문서다. 
