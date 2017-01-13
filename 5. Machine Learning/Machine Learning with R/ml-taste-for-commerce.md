---
layout: page
title: xwMOOC 기계학습
subtitle: 기계학습 (고객용) 맛보기
output:
  html_document: 
    keep_md: yes
  pdf_document:
    latex_engine: xelatex
mainfont: NanumGothic
---
 


> ### 신용카드 기계학습 목표 {.getready}
>
> 은행입장에서 **수익을 극대화** 하고, **신용위험을 최소화** 한다.

### 1. 신용평가 모형 [^ml-credit-scoring-sharma]

[^ml-credit-scoring-sharma]: [Guide to Credit Scoring in R](https://cran.r-project.org/doc/contrib/Sharma-CreditScoring.pdf)

대한민국에서 이영애 누님께서 IMF를 극복하고 2000년대 초반에 신용카드로 행복한 삶을 사는 모습을 러닝머신을 타면서 보여주면서 신용카드의 전성기가 도래했지만, 소수의 사람을 빼고 신용카드가 결국 미래 소비를 현재로 앞당겨서 돈을 쓰는 것에 불과하다는 것은 그로부터 몇년 뒤에 명확해졌고, 이를 신용대란이라고 불렀다. 이후 기업금융과 마찬가지로 소매금융도 위험관리가 중요해졌으며, 소매금융에 있어 위험관리 기법으로 신용평점에 따라 엄격하게 관리하는 것이 필요해졌고, 이에 신용평가모형(Credit Scoring Model)과 더불어 이를 자동화한 금융시스템이 각광을 받기 시작했다. 

파이썬은 과학컴퓨팅에 많은 경험과 라이브러리가 구축되어 있는 반면, R은 상대적으로 통계학기반이라 통계학이 많이 사용되는 금융위험관리 분야에 구축된 블로그, 논문, 기고문, 라이브러리가 많다. 현실과 밀접한 신용할당문제를 기계학습에서 대규모 적용할 경우 풀어가는 방식을 R로 살펴보고, 추후 파이썬으로 확장을 고려해 본다. [^credit-scoring-101] [^credit-scoring-woe] [^credit-scoring-binning]

[^credit-scoring-101]: [Credit Scoring in R 101](http://www.r-bloggers.com/credit-scoring-in-r-101/)
[^credit-scoring-woe]: [R Credit Scoring – WoE & Information Value in woe Package](http://www.r-bloggers.com/r-credit-scoring-woe-information-value-in-woe-package/)
[^credit-scoring-binning]: [R Package 'smbinning': Optimal Binning for Scoring Modeling](http://www.r-bloggers.com/r-package-smbinning-optimal-binning-for-scoring-modeling/)

#### 1.1. 신용평가 모형 전처리

범주형 데이터를 요인변수로 처리해야 하거나, 숫자형 `as.numeric` 혹은 `as.double`로 처리한다. 특히, 연속형 변수를 범주형으로 처리하면 성능향상이 된다는 연구결과도 있다.


~~~{.r}
# 변수 --> 요인(factor)
data$property <-as.factor(data$ property)
# 변수 --> 숫자
data$age <-as.numeric(data$age)
# 변수 --> 숫자(double)
data$amount<-as.double(data$amount)

# 연속형 변수 --> 범주형 (구간 쪼갬)
data$amount<-as.factor(ifelse(data$amount<=2500,'0-
2500',ifelse(data$amount<=5000,'2600-5000','5000+')))
~~~

#### 1.2. 컷오프 결정

컷오프 결정, 신용카드를 발급할 것인지 말것인지 결정하는데 산업계에서 KS(Kolmogorov-Smirnov) 통계량이 많이 사용되지만, Hand가 KS를 사용하는 것은 잘못되었다는 것을 보였고, 컷오프 결정에 유일한 통계량은 **신용카드 발급이 결정된 상태에서 조건부 부실율** 이 되어야 한다는 것을 보였다. [^hand-2005]

[^hand-2005]: Hand, D. J. (2005). Good practice in retail credit score-card assessment. Journal of the Operational Research Society, 56, 1109–1117.

#### 1.3 신용평점에 영향을 주는 변수 식별

신용카드 발급이 되지 않는 경우 어떤 사유로 카드발급이 되지 않았는지 이유를 제시하여야 한다.



~~~{.r}
## 신용점수함수에 가장 영향을 주는 변수 3개 추출
g <- predict(m, type='terms', test)

ftopk<- function(x,top=3){
  res <- names(x)[order(x, decreasing = TRUE)][1:top]
  paste(res, collapse=";", sep="")
}
# 상위 변수 3개를 추출
topk <- apply(g, 1, ftopk, top=3)
# 테스트 테스트 데이터에 사유가 되는 변수를 부착
test <- cbind(test, topk)
~~~

### 2. 비용함수(행렬)/수익함수(행렬)

저신용자에게 신용카드를 발급할 경우는 그 반대의 경우에 비해 5배 비용이 많이 소요된다. 이를 비용함수 혹은 비용행렬이라고 부른다.
아래 **비용함수(Cost Function)** 를 마케팅 캠페인등에 사용하면 **수익함수(Profit Function)** 라고 부르기도 한다. 1종, 2종 오류를 범할 경우 수익/비용에서 차이가 나기 때문이다. 

| | 1 | 2 |
|----|-----|-----|
| 1  |  0  |  1  |
| 2  |  5  |  0  |

기계학습을 활용한 은행이나 카드사는 수익성을 전제로하여 기계학습 알고리듬을 도입한다. 예를 들어, 
향후 5년간 신용카드발급에서 이자수익이 40% 예상되고, 신용불량으로 인해 대손이 발생된다면 다음과 같이 수익행렬을 작성할 수 있다.

|                 | 정상(예측) | 신용불량(예측) |
|-----------------|:---------:|:---------:|
| 정상(실제)         |   0.4     |     0     |
| 신용불량(실제)      |    -1     |     0     |

#### 2.1. 독일신용 데이터를 통한 사례분석 [^profit-analysis-sas]

독일신용 데이터에는 1,000명의 고객이 있다. 700명이 정상이고, 300명이 신용불량자로 등록되어 있다. 이럴 경우 신용불량으로 인한 대손이 발생하지 않을 경우 35% 수익이 예상되고, 신용불량으로 확정될 경우 100% 손실이 불가피하다. 신용불량이 전혀 없다고 가정하고 대출을 진행할 경우 모의시험을 수행하면 다음과 같다.

|                 | 정상(예측) | 신용불량(예측) |
|-----------------|:---------:|:---------:|
| 정상(실제)         |   0.35     |     0     |
| 신용불량(실제)      |    -1     |     0     |

1,000명에게 모두 1원씩 한단위 제공한다면, $\frac{700 \times 0.35 - 300 \times 1}{1000} = \frac{-55}{1000} = -0.055$ 만큼 손실이 불가피하다.

좀더 현실적으로 고객당 천만원을 신용카드를 통해 대출을 준다면, $-0.055 \times 10,000,000 * 1000 = -5.5$ 억원 손실이 난다.


#### 2.2. 신용평가 알고리듬을 구축한 경우


|                 | 정상(예측) | 신용불량(예측) |
|-----------------|:---------:|:---------:|
| 정상(실제)         |   608    |    46     |
| 신용불량(실제)      |    192    |   154    |


신용평가 알고리듬을 개발하여 다음과 같이 구축했다고 가정하면, 다음과 같은 결과가 예상된다.
신용불량이라고 예측한 경우 신용카드발급을 통한 대출을 주지 않아 정상적인 고객이 신용카드를 활용하지 못해 손실(+35% 이자수익)이 발생하고, 정상이라고 예측했지만, 신용카드를 발급해서 생기는 손실(-100%)도 있다. 하지만, 정상이라고 예측해서 정상으로 사용되는 경우 생기는 수익이 608명으로부터 나오고, 신용불량으로 예측해서 실제 신용불량을 맞춤으로써 생기는 이익도 함께 존재한다.

이를 정리하여 합치게 되면 다음과 같은 수익이 예상된다.

$$ 608 \times 10,000,000 \times 0.35 - 192 \times 10,000 = 2.08억$$

신용평가 모형을 갖는 것과 갖지않는 전체적인 효과는 $2.08억 - (-5.5억) = 7.58억$ 으로 추산할 수 있다.

[^profit-analysis-sas]: [Profit Analysis of the German Credit Data Using SAS® Enterprise MinerTM 5.3](http://www.sas.com/technologies/analytics/datamining/miner/trial/german-credit-data.pdf)



~~~{.r}
##================================================================
## 04. 비용함수/행렬
##================================================================
matrix_dimensions <- list(c("good", "bad"), c("good", "bad"))
names(matrix_dimensions) <- c("acutual", "predicted")

error_cost <- matrix(c(0.35, -1, 0, 0), nrow = 2,
                     dimnames = matrix_dimensions)
#       predicted
#acutual  good bad
#   good  0.35   0
#   bad  -1.00   0

##================================================================
## 05. 모형 개발
##================================================================
library(c50)
c50.cost.m <- C5.0(train[,-1], train$Creditability, costs = error_cost)

##================================================================
## 05. 모형 성능평가
##================================================================
credit_cost_pred <- predict(c50.cost.m, test)
CrossTable(test$Creditability, credit_cost_pred,
             prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
             dnn = c('actual default', 'predicted default'))
~~~

### 3. 신용평가 모형 배포 

최적의 성능을 자랑하는 기계학습 신용평가 알고리듬 구축이 완료되었으면, 다음 단계로 실운영 시스템(production)으로 이관하는 것이다. 통상 규칙엔진(Rule Engine)을 사용하거나, SQL 문장으로 작성하여 실운영 시스템에 내장되어 활용된다. [^convert-tree-to-rules]
학습된 나무모형을 SQL 혹은 규칙엔진으로 전환하면 다음과 같은 결과를 실운영 시스템에서 사용하게 된다.

~~~ {.output}
Rule number: 16 [yval=bad cover=220 N=121 Y=99 (37%) prob=0.04]
     checking< 2.5
     afford< 54
     history< 3.5
     coapp< 2.5

Rule number: 34 [yval=bad cover=7 N=3 Y=4 (1%) prob=0.06]
     checking< 2.5
     afford< 54
     history< 3.5
     coapp>=2.5
     age< 27
~~~


[^convert-tree-to-rules]: [DATA MINING Desktop Survival Guide by Graham Williams, Convert Tree to Rules](http://www.togaware.com/datamining/survivor/Convert_Tree.html)



~~~{.r}
list.rules.rpart(rpart.fit)

list.rules.rpart <- function(model)
{
  if (!inherits(model, "rpart")) stop("Not a legitimate rpart tree")
  #
  # Get some information.
  #
  frm     <- model$frame
  names   <- row.names(frm)
  ylevels <- attr(model, "ylevels")
  ds.size <- model$frame[1,]$n
  #
  # Print each leaf node as a rule.
  #
  for (i in 1:nrow(frm))
  {
    if (frm[i,1] == "<leaf>")
    {
      # The following [,5] is hardwired - needs work!
      cat("\n")
      cat(sprintf(" Rule number: %s ", names[i]))
      cat(sprintf("[yval=%s cover=%d (%.0f%%) prob=%0.2f]\n",
                  ylevels[frm[i,]$yval], frm[i,]$n,
                  round(100*frm[i,]$n/ds.size), frm[i,]$yval2[,5]))
      pth <- path.rpart(model, nodes=as.numeric(names[i]), print.it=FALSE)
      cat(sprintf("   %s\n", unlist(pth)[-1]), sep="")
    }
  }
}
~~~
