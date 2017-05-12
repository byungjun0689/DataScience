---
layout: page
title: xwMOOC 기계학습
subtitle: 신용평가와 신용평점모형
output:
  html_document: 
    keep_md: yes
  pdf_document:
    latex_engine: xelatex
mainfont: NanumGothic
---
 


> ### 학습 목표 {.getready}
>
> * 신용평점모형 기반 대출 전략을 수립한다.
> * 승인율에 따른 채무 불이행 부실율을 평가한다.


### 1. 전략곡선(Strategy Curve) 사전준비

전략곡선은 대출 승인에 따른 채무불이행 부실율을 추적하는 곡선이다. 
따라서 채무불이행 위험을 따라 최적 대출승인율을 산출할 수 있다. 
이를 위해서 신용평점 모형을 의사결정나무와 로지스틱 회귀분석을 활용하여 개발한다.

개발된 신용평점모형을 기반하여 최적 대출승인 부실율을 산출하여 적용한다. 


~~~{.r}
##=====================================================================
## 01. 렌딩클럽 데이터 가져오기
##=====================================================================
# http://rstudio-pubs-static.s3.amazonaws.com/3588_81e2ebd4de1b41bc9ac2f29f5f7dab2e.html
suppressMessages(library(readr))
suppressMessages(library(dplyr))
loan.dat <- read_fwf("data/lendingclub_loan_sample.txt", fwf_widths(c(6,11,10,6,15,11,4,8,8)), skip=1)
~~~



~~~{.output}
Parsed with column specification:
cols(
  X1 = col_integer(),
  X2 = col_integer(),
  X3 = col_integer(),
  X4 = col_character(),
  X5 = col_character(),
  X6 = col_double(),
  X7 = col_integer(),
  X8 = col_character(),
  X9 = col_character()
)

~~~



~~~{.r}
names(loan.dat) <- c("seq","loan_status", "loan_amnt grade", "home_ownership", "annual_inc", "age", "emp_cat", "ir_cat")

##=====================================================================
## 02. 신용평점모형
##=====================================================================
# 훈련데이터, 테스트데이터 구분

train_index <- sample(nrow(loan.dat), 2/3*nrow(loan.dat))
train_set <- loan.dat[train_index,]
test_set <- loan.dat[-train_index,]

#---------------------------------------------------------------------
# 02-1. 의사결정나무
#---------------------------------------------------------------------
suppressMessages(library(rpart))
loan_loss_dt <- rpart(loan_status ~ ., method = "class", data =  train_set, 
                      control = rpart.control(cp = 0.001),
                      parms = list(loss = matrix(c(0, 10, 1, 0), ncol=2)))


ptree_loss <- prune(loan_loss_dt, cp = 0.0020548)

#---------------------------------------------------------------------
# 02-2. 로지스틱 회귀분석
#---------------------------------------------------------------------

logit_mod <- glm(loan_status ~ ., family = "binomial", data=train_set)
~~~

### 2. 전략곡선(Strategy Curve) 도출

신용평점모형이 도출되면 채무불이행 확률을 계산할 수 있고, 이를 기반으로 하여 
승인기준(cutoff)에 따라 대출승인을 모의시험할 수 있다. 즉, 컷오프를 0.2로 지정할 경우
채무불이행 확률과 컷오프를 0.5로 설정할 때 채무불이행 확률을 모의 시험하여 사전에 계산한다.

이런 것이 필요한 이유는 매출에 중점을 둘 경우 승인을 높이면 되는데 상대적으로 채무불이행 위험율은 높아지고,
반대로 승인을 까다롭게 하면 채무불이행 위험율은 낮아지는 반면, 매출은 상대적으로 줄어들게 된다.

따라서, 정확한 신용평점모형을 갖추게 되면, 매출과 위험율에 따른 손익을 좀더 정확하게 추정하여 사업에 반영할 수 있다.



~~~{.r}
##=====================================================================
## 03. 전략곡선 도출
##=====================================================================

#---------------------------------------------------------------------
# 03-1. 기본 개념
#---------------------------------------------------------------------

prob_default_loss <- predict(ptree_loss, newdata = test_set)[ ,2]

cutoff_loss <- quantile(prob_default_loss, 0.8)  
binary_pred_loss_80 <- ifelse(prob_default_loss > cutoff_loss, 1, 0)

accepted_status_loss_80 <- test_set$loan_status[binary_pred_loss_80 == 0]
sum(accepted_status_loss_80) / length(accepted_status_loss_80)
~~~



~~~{.output}
[1] 0.3184683

~~~

`strategy_bank` 함수를 통해 신용평점모형별 승인율과 위험율을 사전에 계산하여 대출심사 및 위험관리에 활용한다.


~~~{.r}
#---------------------------------------------------------------------
# 03-2. 모형기반 전략곡선 
#---------------------------------------------------------------------
# 
prob_default_loss_dt <- predict(ptree_loss, newdata = test_set)[,2]
prob_default_loss_glm <- predict(logit_mod, newdata = test_set)

strategy_default_loss_dt <- strategy_bank(prob_default_loss_dt)
strategy_default_loss_glm <- strategy_bank(prob_default_loss_glm)

strategy_default_loss_dt$table
~~~



~~~{.output}
      accept_rate cutoff bad_rate
 [1,]        1.00 0.5455   0.3237
 [2,]        0.95 0.4583   0.3176
 [3,]        0.90 0.4537   0.3185
 [4,]        0.85 0.4537   0.3185
 [5,]        0.80 0.4537   0.3185
 [6,]        0.75 0.4537   0.3185
 [7,]        0.70 0.4537   0.2363
 [8,]        0.65 0.4537   0.3185
 [9,]        0.60 0.4537   0.3185
[10,]        0.55 0.4537   0.3185
[11,]        0.50 0.3526   0.2347
[12,]        0.45 0.3526   0.2347
[13,]        0.40 0.3005   0.2123
[14,]        0.35 0.2777   0.2126
[15,]        0.30 0.2777   0.2126
[16,]        0.25 0.2777   0.2126
[17,]        0.20 0.2777   0.2126
[18,]        0.15 0.2381   0.1561
[19,]        0.10 0.2258   0.1573
[20,]        0.05 0.0000   0.1949
[21,]        0.00 0.0000   0.1949

~~~



~~~{.r}
strategy_default_loss_glm$table
~~~



~~~{.output}
      accept_rate  cutoff bad_rate
 [1,]        1.00  1.6090   0.3237
 [2,]        0.95  0.1294   0.3111
 [3,]        0.90  0.0061   0.3049
 [4,]        0.85 -0.0933   0.2929
 [5,]        0.80 -0.1821   0.2831
 [6,]        0.75 -0.2730   0.2747
 [7,]        0.70 -0.3765   0.2714
 [8,]        0.65 -0.4549   0.2628
 [9,]        0.60 -0.5216   0.2473
[10,]        0.55 -0.6039   0.2342
[11,]        0.50 -0.6942   0.2183
[12,]        0.45 -0.7864   0.2028
[13,]        0.40 -0.8602   0.1906
[14,]        0.35 -0.9460   0.1721
[15,]        0.30 -1.0349   0.1705
[16,]        0.25 -1.1478   0.1423
[17,]        0.20 -1.2466   0.1301
[18,]        0.15 -1.3237   0.1155
[19,]        0.10 -1.3940   0.1096
[20,]        0.05 -1.5176   0.1273
[21,]        0.00 -3.8023   1.0000

~~~



~~~{.r}
par(mfrow = c(1,2))

plot(strategy_default_loss_dt$accept_rate, strategy_default_loss_dt$bad_rate, 
     type = "l", xlab = "승인율", ylab = "부실율", 
     lwd = 2, main = "의사결정나무")

plot(strategy_default_loss_glm$accept_rate, strategy_default_loss_glm$bad_rate, 
     type = "l", xlab = "승인율", ylab = "부실율", 
     lwd = 2, main = "로지스틱 회귀")
~~~

<img src="fig/lendingclub-strategy-curve-1.png" title="plot of chunk lendingclub-strategy-curve" alt="plot of chunk lendingclub-strategy-curve" style="display: block; margin: auto;" />


### 3. 컷오프 결정

컷오프 결정, 신용카드를 발급할 것인지 말것인지 결정하는데 산업계에서 KS(Kolmogorov-Smirnov) 통계량이 많이 사용되지만, Hand가 KS를 사용하는 것은 잘못되었다는 것을 보였고, 컷오프 결정에 유일한 통계량은 **신용카드 발급이 결정된 상태에서 조건부 부실율** 이 되어야 한다는 것을 보였다. [^hand-2005]

[^hand-2005]: Hand, D. J. (2005). Good practice in retail credit score-card assessment. Journal of the Operational Research Society, 56, 1109–1117.

### 4. 신용평점에 영향을 주는 변수 식별

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

### 5. 신용평가 모형 배포 

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

