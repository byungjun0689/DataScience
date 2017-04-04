# LDA 
# Latent Dirichelt Allocation 
# 잠재 디리클레 할당 
# 19.PNG (어렵게)
# 20.PNG (쉽게) 문서 드럼통 안에 빨, 초, 파 공이 들어있다 (공 -> 토픽, 하나의 문서안에 어려 토픽), 글마다 비율이 다르다.
# 21.PNG 텍스트 -> 토픽 -> 단어를 뽑는 구조. 이런 구조를 통해 글을 썼다고 분석하는 것이 LDA
# LSA : 해석하기가 어렵다. 
# LDA 장점 : 이론적으로는 어렵지만, 개념은 훨씬 간단하다. 하나의 글에 어떠한 토픽이 몇퍼센트, 어떠한 토픽이 몇퍼센터 그 토픽안에 단어가 몇퍼센트 등 수치가 나온다. 
# LDA 단점 : 수학적으로 굉장히 복잡하다. LSA는 대부분 답이 나온다. 하지만 LDA는 추정하는 과정이 답이 나온다는 보장이 없다. 
# LSA는 적은 데이터도 잘돌아간다. LDA 데이터가 많이 필요하다. 
# LDA 장점 : 확장이 용이하다. 시간을 추가 한다던지 등의 확장이 가능. 

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

# LDA패키지에서 사용할 수 있는 모양으로 변형
# DocumentTermMatrix로 변환

dtm <- as.DocumentTermMatrix(tdm[freq.word,])

# topicmodels 패키지에 있는 dtm2ldaformat 함수를 이용해 dtm을 lda에서 쓰는 형식으로 바꾼다
install.packages("topicmodels")
library(topicmodels)
ldaform <- dtm2ldaformat(dtm, omit_empty = T)
ldaform

install.packages("lda")
library(lda)

result.lda <- lda.collapsed.gibbs.sampler(documents = ldaform$documents,
                                         K = 30, # topic의 갯수. 감으로 해보는 경우 결과가 맘에 안들면 늘리거나 줄이면 된다.
                                         vocab = ldaform$vocab, # 어떤 단어들이 있는가?
                                         num.iterations = 5000, # LDA가 한번에 답이 나오는 과정이 아니다. 계산을 하면할 수록 좋아진다. 몇번이나 반복할까?
                                         burnin = 1000, # 계산을 반복해서 하면 좋아진다고 했는데, 앞부분의 계산은 부정확 할 수 있다.(높다) 앞에 1000개는 버리고 뒤에 4000개만 쓰겠다.
                                         alpha = 0.01, # 30개의 토픽이 얼마나 골고루 들어갈지 0보다 큰값이 항상. 1을 하게 된다면 uniform하다 모든 경우수가 동일하다. 1000을하게되면 모든 문서에 토픽이 동일하게 들어간다. 
                                         # 0.00001 이면 1개의 문서에 30개 중 하나만 들어가고 나머지는 안들어간다. 
                                         eta = 0.01) # 한 토픽내에서 단어가 얼마나 골고르 섞여있느냐? 한 토픽에서 단어가 골고루 나오는건 말이 안된다. 


# 결과 해석
attributes(result.lda) # "topics"           "topic_sums"       "document_sums" 요정도가 쓸만 할 것이다.

# topics 각 단어들이 어떤 토픽에서 나왔는지 표 형태로 보여준다
dim(result.lda$topics) #토픽이 30개, 1000열 ( 단어를 1000개 썻으므로 )
View(result.lda$topics) #표로보면 불편하다.
top.topic.words(result.lda$topics) # 토픽 별로 상위 20개 단어를 표 형태로 보여준다
View(top.topic.words(result.lda$topics))


# 모든 불만 이슈에 자주 나오는 불만을 우선 처리 해야 된다. 
# 토픽 별로 총 단어 수를 보여준다
result.lda$topic_sums # -> 이걸 보고 위에 top topic에 관련된 내용을 보면될듯하다.

# 문서 별로 각 토픽에 해당하는 단어 수를 표 형태로 보여준다. 
result.lda$document_sums

dim(result.lda$document_sums) # 2999개 문서의 중에 30개의 토픽에 관련된 것.
result.lda$document_sums[,1] # 첫 번째문서가 각 토픽에 있는 단어가 몇개가 들어갔는지 
# 6,7번째 토픽에 관련된 단어가 28개 6개 나왔다.
View(top.topic.words(result.lda$topics))
news$newdescp[1]



