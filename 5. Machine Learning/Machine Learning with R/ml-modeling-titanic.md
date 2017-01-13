---
layout: page
title: xwMOOC 기계학습
subtitle: 전통방식 모형개발 - 타이타닉 생존 데이터
output:
  html_document: 
    keep_md: yes
  pdf_document:
    latex_engine: xelatex
mainfont: NanumGothic
---


 
> ## 학습목표 {.objectives}
>
> * 전통방식 모형개발 방식을 타이타닉 생존데이터에 적용한다.
> * CMM 3수준에 해당되는 모형개발 방식으로 간주할 수도 있다.

## 1. 타이타닉 생존 데이터 [^r-bloggers-logistic]

[^r-bloggers-logistic]: [R-bloggers, How to perform a Logistic Regression in R](http://www.r-bloggers.com/how-to-perform-a-logistic-regression-in-r/)

타이타닉 생존데이터는 영화로도 만들어지고, 여러가지 에피소드가 많이 들어있는 소재로 데이터 과학과 통계학적인 측면에서 바라보면 범주형 데이터로 생존여부가 종속변수로 녹아져 있어, 예측모형으로 적합시키기도 적절한 데이터이기도 하다.

<iframe width="560" height="315" src="https://www.youtube.com/embed/9xoqXVjBEF8" frameborder="0" allowfullscreen></iframe>


### 1.1. 타이타닉 생존 데이터 가져오기 [^r-blogger-titanic]

[^r-blogger-titanic]: [How to perform a Logistic Regression in R](http://www.r-bloggers.com/how-to-perform-a-logistic-regression-in-r/)

[캐글 타이타닉 데이터](https://www.kaggle.com/c/titanic/data)를 다운로드 받아 로컬컴퓨터에서 불러읽어오거나,
GitHub 사이트에서 캐글 타이타닉 데이터를 올려놓은 것을 바로 불러온다.
캐글 타이나틱 생존 데이터는 `train.csv`와 `test.csv`로 나눠져 있는데 일단 모두 합쳐 하나의 데이터셋으로 만들고 난후에 동일하게 전처리 작업을 하고 전통적 방식으로 예측하는 방법을 전개한다.

|  변수명        |          변수명 설명            |
|--------------|------------------------------|
|  **survival**    |    Survival (0 = No; 1 = Yes)|
|  pclass      |    Passenger Class  (1 = 1st; 2 = 2nd; 3 = 3rd)|
|  name        |    Name|
|  sex         |    Sex|
|  age         |    Age|
|  sibsp       |    Number of Siblings/Spouses Aboard|
|  parch       |    Number of Parents/Children Aboard|
|  ticket      |    Ticket Number|
|  fare        |    Passenger Fare|
|  cabin       |    Cabin|
|  embarked    |    Port of Embarkation (C = Cherbourg; Q = Queenstown; S = Southampton)|

`survival` 이 종속변수이며, 나머지를 예측변수로 사용해서 생존을 예측하는 모형을 개발한다.


~~~{.r}
##========================================================
## 01. 데이터 준비
##========================================================
# Titanic: Machine Learning from Disaster, https://www.kaggle.com/c/titanic/data

suppressMessages(library(readr))
suppressMessages(library(dplyr))
titanic.train.df <- read_csv("https://raw.githubusercontent.com/agconti/kaggle-titanic/master/data/train.csv")
titanic.test.df <- read_csv("https://raw.githubusercontent.com/agconti/kaggle-titanic/master/data/test.csv")
titanic <- bind_rows(titanic.train.df, titanic.test.df)
~~~


## 1.2. 데이터 정제 

타이타닉 생존데이터를 불러온 다음 현황을 파악하고, 결측값에 대한 대응방안을 마련한다.
예를 들어, 결측값이 너무 많은 경우 변수(`Cabin`) 자체를 제거한다.
`Name`, `Ticket`처럼 관측점마다 유일한 변수는 정보로서 의미가 없기 때문에 이것도 제거한다.
`Age` 변수는 평균을 매워넣는 것으로 하고, 상대적으로 적은 결측값이 있는 관측점은 
`Embarked`, `Fare`, `Survived`는 관측점을 제거하는 방식으로 정제 작업을 수행한다.

특히, `Amelia` 팩키지의 `missmap` 함수를 사용해서 결측값 진행 작업을 바로 시각적으로 확인한다.


~~~{.r}
##========================================================
## 02. 데이터 정제
##========================================================
# 2.1. 현황 파악
summary(titanic)
~~~



~~~{.output}
  PassengerId      Survived          Pclass          Name          
 Min.   :   1   Min.   :0.0000   Min.   :1.000   Length:1309       
 1st Qu.: 328   1st Qu.:0.0000   1st Qu.:2.000   Class :character  
 Median : 655   Median :0.0000   Median :3.000   Mode  :character  
 Mean   : 655   Mean   :0.3838   Mean   :2.295                     
 3rd Qu.: 982   3rd Qu.:1.0000   3rd Qu.:3.000                     
 Max.   :1309   Max.   :1.0000   Max.   :3.000                     
                NA's   :418                                        
     Sex                 Age            SibSp            Parch      
 Length:1309        Min.   : 0.17   Min.   :0.0000   Min.   :0.000  
 Class :character   1st Qu.:21.00   1st Qu.:0.0000   1st Qu.:0.000  
 Mode  :character   Median :28.00   Median :0.0000   Median :0.000  
                    Mean   :29.88   Mean   :0.4989   Mean   :0.385  
                    3rd Qu.:39.00   3rd Qu.:1.0000   3rd Qu.:0.000  
                    Max.   :80.00   Max.   :8.0000   Max.   :9.000  
                    NA's   :263                                     
    Ticket               Fare            Cabin          
 Length:1309        Min.   :  0.000   Length:1309       
 Class :character   1st Qu.:  7.896   Class :character  
 Mode  :character   Median : 14.454   Mode  :character  
                    Mean   : 33.295                     
                    3rd Qu.: 31.275                     
                    Max.   :512.329                     
                    NA's   :1                           
   Embarked        
 Length:1309       
 Class :character  
 Mode  :character  
                   
                   
                   
                   

~~~



~~~{.r}
sapply(titanic, function(x) sum(is.na(x)))
~~~



~~~{.output}
PassengerId    Survived      Pclass        Name         Sex         Age 
          0         418           0           0           0         263 
      SibSp       Parch      Ticket        Fare       Cabin    Embarked 
          0           0           0           1        1014           2 

~~~



~~~{.r}
sapply(titanic, function(x) length(unique(x)))
~~~



~~~{.output}
PassengerId    Survived      Pclass        Name         Sex         Age 
       1309           3           3        1307           2          99 
      SibSp       Parch      Ticket        Fare       Cabin    Embarked 
          7           8         929         282         187           4 

~~~



~~~{.r}
suppressMessages(library(Amelia))
missmap(titanic, main = "결측값과 관측값")
~~~

<img src="fig/titanic-clean-1.png" title="plot of chunk titanic-clean" alt="plot of chunk titanic-clean" style="display: block; margin: auto;" />

~~~{.r}
# 2.2. 결측값에 대한 응징
# 분석에 사용될 변수만 선정

titanic <- titanic %>% 
  select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked) %>%  # 결측값이 많은 Cabin과 이름, Ticket은 제거
  mutate(Age = ifelse(is.na(Age), mean(Age, na.rm=TRUE), Age)) %>%  # 나이를 평균값으로 치환
  filter(!is.na(Embarked)) %>%  # 결측값 2개 행 제거
  filter(!is.na(Fare)) %>%   # 결측값 1개 행 제거
  filter(!is.na(Survived))   # 결측값 418개 행 제거

missmap(titanic, main = "결측값과 관측값")
~~~

<img src="fig/titanic-clean-2.png" title="plot of chunk titanic-clean" alt="plot of chunk titanic-clean" style="display: block; margin: auto;" />

## 1.3. 예측모형 적용

`caret` 팩키지 `createDataPartition` 함수를 사용해서 7:3으로 훈련데이터와 검증데이터로 구분한다.

`glm` 함수에 `family=binomial(link='logit')` 인자를 넣어 이항회귀모형을 적합시킨다.
특히, 전체 변수를 모두 넣어 `Survived ~.` 생존을 예측하는 모형을 구축한다.

변수를 선정하는 방법은 여러가지가 있으나, 먼저 `anova`함수를 사용해서 포화모델에서 
유의적인 변수와 그렇지 않는 변수를 구별한다. 비유의적인 변수를 제거하고 `logit.reduced.m` 축소된 
이항회귀모형을 개발한다. 

이항회귀식에는 $R^2$ 결정계수가 큰 의미가 없다고 주장하는 경우도 있으나, `pscl` 팩키지의 기능을 사용하여 계산해본다.

`ROCR` 팩키지를 사용해서 포화모형과 축소모형간에 차이가 있는지 ROC 면적과 더불어 ROC 곡선을 도식화하여 비교한다.

두 모형간에 성능의 차이는 없어 보이며, 4개 모형이 사용된 축약된 모형이 포화모형과 거의 비슷한 성능을 내고 있다.


~~~{.r}
##========================================================
## 03. 모형 적합
##========================================================
## 
suppressMessages(library(caret))

#---------------------------------------------------------
# 3.1. 훈련데이터와 검증데이터 분리

train.id <- createDataPartition(titanic$Survived, p = 0.7)[[1]] 
titanic.train.df <- titanic[ train.id,] 
titanic.test.df <- titanic[-train.id,]

#---------------------------------------------------------
# 3.1. 선형회귀 적합

logit.full.m <- glm(Survived ~.,family=binomial(link='logit'), data=titanic.train.df)
summary(logit.full.m)
~~~



~~~{.output}

Call:
glm(formula = Survived ~ ., family = binomial(link = "logit"), 
    data = titanic.train.df)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-2.7882  -0.5605  -0.3859   0.6278   2.4974  

Coefficients:
              Estimate Std. Error z value Pr(>|z|)    
(Intercept)  5.9124097  0.6813718   8.677  < 2e-16 ***
Pclass      -1.3132473  0.1731615  -7.584 3.35e-14 ***
Sexmale     -2.7380153  0.2429523 -11.270  < 2e-16 ***
Age         -0.0464928  0.0095414  -4.873 1.10e-06 ***
SibSp       -0.3346004  0.1342922  -2.492   0.0127 *  
Parch       -0.0915437  0.1484707  -0.617   0.5375    
Fare         0.0009746  0.0025971   0.375   0.7075    
EmbarkedQ    0.2813593  0.4585272   0.614   0.5395    
EmbarkedS   -0.2699759  0.2883458  -0.936   0.3491    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 838.41  on 622  degrees of freedom
Residual deviance: 540.73  on 614  degrees of freedom
AIC: 558.73

Number of Fisher Scoring iterations: 5

~~~



~~~{.r}
#---------------------------------------------------------
# 3.2. 변수선택
anova(logit.full.m, test="Chisq")
~~~



~~~{.output}
Analysis of Deviance Table

Model: binomial, link: logit

Response: Survived

Terms added sequentially (first to last)

         Df Deviance Resid. Df Resid. Dev  Pr(>Chi)    
NULL                       622     838.41              
Pclass    1   81.897       621     756.51 < 2.2e-16 ***
Sex       1  181.439       620     575.07 < 2.2e-16 ***
Age       1   20.196       619     554.88 6.992e-06 ***
SibSp     1   10.583       618     544.30  0.001142 ** 
Parch     1    0.550       617     543.75  0.458227    
Fare      1    0.456       616     543.29  0.499589    
Embarked  2    2.562       614     540.73  0.277792    
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

~~~



~~~{.r}
#---------------------------------------------------------
# 3.3. 최적모형

logit.reduced.m <- glm(Survived  ~ Pclass+Sex+Age+SibSp, family=binomial(link='logit'), data=titanic.train.df)
summary(logit.reduced.m)
~~~



~~~{.output}

Call:
glm(formula = Survived ~ Pclass + Sex + Age + SibSp, family = binomial(link = "logit"), 
    data = titanic.train.df)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-2.8295  -0.5752  -0.3860   0.6094   2.4585  

Coefficients:
             Estimate Std. Error z value Pr(>|z|)    
(Intercept)  5.771741   0.595671   9.689  < 2e-16 ***
Pclass      -1.321349   0.148115  -8.921  < 2e-16 ***
Sexmale     -2.762281   0.236329 -11.688  < 2e-16 ***
Age         -0.045853   0.009418  -4.869 1.12e-06 ***
SibSp       -0.373944   0.127109  -2.942  0.00326 ** 
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 838.41  on 622  degrees of freedom
Residual deviance: 544.30  on 618  degrees of freedom
AIC: 554.3

Number of Fisher Scoring iterations: 5

~~~



~~~{.r}
#---------------------------------------------------------
# 3.3. R^2 결정계수

suppressMessages(library(pscl))
pR2(logit.full.m)
~~~



~~~{.output}
         llh      llhNull           G2     McFadden         r2ML 
-270.3643861 -419.2050418  297.6813114    0.3550545    0.3798656 
        r2CU 
   0.5135687 

~~~



~~~{.r}
pR2(logit.reduced.m)
~~~



~~~{.output}
         llh      llhNull           G2     McFadden         r2ML 
-272.1482830 -419.2050418  294.1135175    0.3507991    0.3763041 
        r2CU 
   0.5087535 

~~~



~~~{.r}
#---------------------------------------------------------
# 3.4. 모형 평가

suppressMessages(library(ROCR))
# 전체 모형
logit.full.pred <- predict(logit.full.m, newdata=titanic.test.df, type="response")
logit.full.pr <- prediction(logit.full.pred, titanic.test.df$Survived)
logit.full.prf <- performance(logit.full.pr, measure = "tpr", x.measure = "fpr")
plot(logit.full.prf)
~~~

<img src="fig/titanic-model-1.png" title="plot of chunk titanic-model" alt="plot of chunk titanic-model" style="display: block; margin: auto;" />

~~~{.r}
# ROC 면적
logit.full.auc <- performance(logit.full.pr, measure = "auc")
logit.full.auc <- logit.full.auc@y.values[[1]]
logit.full.auc
~~~



~~~{.output}
[1] 0.8259341

~~~



~~~{.r}
# 축소 모형
logit.reduced.pred <- predict(logit.reduced.m, newdata=titanic.test.df, type="response")
logit.reduced.pr <- prediction(logit.reduced.pred, titanic.test.df$Survived)
logit.reduced.prf <- performance(logit.reduced.pr, measure = "tpr", x.measure = "fpr")
plot(logit.reduced.prf)
~~~

<img src="fig/titanic-model-2.png" title="plot of chunk titanic-model" alt="plot of chunk titanic-model" style="display: block; margin: auto;" />

~~~{.r}
# ROC 면적
logit.reduced.auc <- performance(logit.reduced.pr, measure = "auc")
logit.reduced.auc <- logit.reduced.auc@y.values[[1]]
logit.reduced.auc
~~~



~~~{.output}
[1] 0.8274411

~~~



~~~{.r}
#---------------------------------------------------------
# 3.5. ROC 면적비교

plot(logit.full.prf)
plot(logit.reduced.prf, add=TRUE, col="red")
~~~

<img src="fig/titanic-model-3.png" title="plot of chunk titanic-model" alt="plot of chunk titanic-model" style="display: block; margin: auto;" />

~~~{.r}
logit.full.auc
~~~



~~~{.output}
[1] 0.8259341

~~~



~~~{.r}
logit.reduced.auc
~~~



~~~{.output}
[1] 0.8274411

~~~

## 1.4. 자동 모형 선정 방법

만약 $p$개 변수가 있다면 $2^p$ 만큼 가능한 모형이 존재한다. 모형을 모두 적합시켜 $2^p$ 모형중에서 성능 등 기준조건을 만족하는 최적의 모형을 선정한다. 경우의 수가 너무 많고, 성능이 비슷한 모형을 반복적으로 개발할 우려도 있고 해서, 기준조건(Criterion-based) 방법으로 통해 변수를 추출해 나간다. 즉, 가장 성능이 좋은 변수부터 선택해 나가면서 복잡성과 성능을 최적화한다. 가장 일반적으로 많이 사용되는 방식이 $AIC(Akaike Information Criterion)$, $BIC(Bayes Information Criterion)$을 들 수 있다.

$$AIC = -2 ln(L) + 2k $$
$$BIC = -2 ln(L) + k ln(n) $$

$L$은 모형에 대한 우도함수 최대값이고, $k$는 모형에 사용된 추정모수갯수, $n$은 관측점 갯수가 된다.


~~~{.r}
##========================================================
## 04. 변수선택 모형 선정
##========================================================
## 

logit.null.m <- glm(Survived ~1, family=binomial(link='logit'), data=titanic.train.df)
logit.full.m <- glm(Survived ~., family=binomial(link='logit'), data=titanic.train.df)

logit.bic.m <- step(logit.null.m, scope=formula(logit.full.m), direction="both", criterion="BIC", k=log(nrow(titanic.train.df)))
~~~



~~~{.output}
Start:  AIC=844.84
Survived ~ 1

           Df Deviance    AIC
+ Sex       1   651.61 664.48
+ Pclass    1   756.51 769.38
+ Fare      1   792.64 805.51
+ Embarked  2   822.86 842.16
<none>          838.41 844.84
+ Age       1   833.74 846.61
+ Parch     1   834.03 846.90
+ SibSp     1   837.61 850.48

Step:  AIC=664.48
Survived ~ Sex

           Df Deviance    AIC
+ Pclass    1   575.07 594.38
+ Fare      1   629.44 648.75
+ SibSp     1   643.52 662.82
<none>          651.61 664.48
+ Embarked  2   640.21 665.95
+ Parch     1   649.67 668.97
+ Age       1   650.72 670.03
- Sex       1   838.41 844.84

Step:  AIC=594.38
Survived ~ Sex + Pclass

           Df Deviance    AIC
+ Age       1   554.88 580.62
<none>          575.07 594.38
+ SibSp     1   570.25 595.99
+ Parch     1   573.70 599.44
+ Fare      1   575.05 600.79
+ Embarked  2   570.94 603.11
- Pclass    1   651.61 664.48
- Sex       1   756.51 769.38

Step:  AIC=580.62
Survived ~ Sex + Pclass + Age

           Df Deviance    AIC
+ SibSp     1   544.30 576.47
<none>          554.88 580.62
+ Parch     1   551.55 583.72
+ Fare      1   554.84 587.01
+ Embarked  2   550.36 588.97
- Age       1   575.07 594.38
- Pclass    1   650.72 670.03
- Sex       1   723.68 742.98

Step:  AIC=576.47
Survived ~ Sex + Pclass + Age + SibSp

           Df Deviance    AIC
<none>          544.30 576.47
- SibSp     1   554.88 580.62
+ Parch     1   543.75 582.35
+ Fare      1   544.05 582.66
+ Embarked  2   541.18 586.22
- Age       1   570.25 595.99
- Pclass    1   640.86 666.60
- Sex       1   720.76 746.50

~~~



~~~{.r}
logit.aic.m <- step(logit.null.m, scope=formula(logit.full.m), direction="both", criterion="AIC", k=2)
~~~



~~~{.output}
Start:  AIC=840.41
Survived ~ 1

           Df Deviance    AIC
+ Sex       1   651.61 655.61
+ Pclass    1   756.51 760.51
+ Fare      1   792.64 796.64
+ Embarked  2   822.86 828.86
+ Age       1   833.74 837.74
+ Parch     1   834.03 838.03
<none>          838.41 840.41
+ SibSp     1   837.61 841.61

Step:  AIC=655.61
Survived ~ Sex

           Df Deviance    AIC
+ Pclass    1   575.07 581.07
+ Fare      1   629.44 635.44
+ Embarked  2   640.21 648.21
+ SibSp     1   643.52 649.52
<none>          651.61 655.61
+ Parch     1   649.67 655.67
+ Age       1   650.72 656.72
- Sex       1   838.41 840.41

Step:  AIC=581.07
Survived ~ Sex + Pclass

           Df Deviance    AIC
+ Age       1   554.88 562.88
+ SibSp     1   570.25 578.25
+ Embarked  2   570.94 580.94
<none>          575.07 581.07
+ Parch     1   573.70 581.70
+ Fare      1   575.05 583.05
- Pclass    1   651.61 655.61
- Sex       1   756.51 760.51

Step:  AIC=562.88
Survived ~ Sex + Pclass + Age

           Df Deviance    AIC
+ SibSp     1   544.30 554.30
+ Parch     1   551.55 561.55
+ Embarked  2   550.36 562.36
<none>          554.88 562.88
+ Fare      1   554.84 564.84
- Age       1   575.07 581.07
- Pclass    1   650.72 656.72
- Sex       1   723.68 729.68

Step:  AIC=554.3
Survived ~ Sex + Pclass + Age + SibSp

           Df Deviance    AIC
<none>          544.30 554.30
+ Embarked  2   541.18 555.18
+ Parch     1   543.75 555.75
+ Fare      1   544.05 556.05
- SibSp     1   554.88 562.88
- Age       1   570.25 578.25
- Pclass    1   640.86 648.86
- Sex       1   720.76 728.76

~~~



~~~{.r}
logit.bic.m
~~~



~~~{.output}

Call:  glm(formula = Survived ~ Sex + Pclass + Age + SibSp, family = binomial(link = "logit"), 
    data = titanic.train.df)

Coefficients:
(Intercept)      Sexmale       Pclass          Age        SibSp  
    5.77174     -2.76228     -1.32135     -0.04585     -0.37394  

Degrees of Freedom: 622 Total (i.e. Null);  618 Residual
Null Deviance:	    838.4 
Residual Deviance: 544.3 	AIC: 554.3

~~~



~~~{.r}
logit.aic.m
~~~



~~~{.output}

Call:  glm(formula = Survived ~ Sex + Pclass + Age + SibSp, family = binomial(link = "logit"), 
    data = titanic.train.df)

Coefficients:
(Intercept)      Sexmale       Pclass          Age        SibSp  
    5.77174     -2.76228     -1.32135     -0.04585     -0.37394  

Degrees of Freedom: 622 Total (i.e. Null);  618 Residual
Null Deviance:	    838.4 
Residual Deviance: 544.3 	AIC: 554.3

~~~
