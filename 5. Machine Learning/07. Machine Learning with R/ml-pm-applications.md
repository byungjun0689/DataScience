---
layout: page
title: xwMOOC 기계학습
subtitle: 예측모형 활용분야
---

> ## 학습목표 {.objectives}
>
> * 예측모형 활용분야에 대해 살펴본다.
> * 예측모형과 적용분야에 대한 관계를 추론한다.
> * 거시에서 미시로, 미시에서 거시로 들어가는 고객분석에 대해 이해한다.

## 1. 예측모형과 고객 

고객에 대한 정의는 게임산업에서는 게임사용자가 될 수 있고, 교육분야에서는 학생이 될 수 있고, 자동차회사에서는 자동차 구매자가 될 수 있고, 병원에서는 환자가 될 수 있다. 고객이 누구든지 관계없이 고객을 취득(Acquistion)하고 개발(Development)하고, 유지(Retention)하는 것이 우리가 살고 있는 지금 세상에서는 일상적으로 일어나고 있고, 열심히 경주하는 일이라고도 볼 수 있다.

<img src="fig/ml-macro2micro.png" alt="거시에서 미시로 바라보는 고객" width="77%">

거시에서 미시로 들어가는 모형에 대해 살펴보자. 모집단에 대한 이해를 하고, 연관성을 파악하고자 할 경우 RFM 분석모형이 제시되고 있다. 고객집단과 세분화결과 생긴 군집에 대한 인과추론 작업도 만약 대조군/실험군을 통한 제어를 했다면 가능하다. 모집단에서 개인으로 넘어가서 심하게는 각 개인별 연관성에 초점을 맞추거나 맞춤형 실험처리하는 경우 다양한 모형과 통계적 이론을 접목하여 이해한다.

## 2. 거시에서 미시로 들어가는 고객분석 [^pm-lift] [^pm-uplift]

[^pm-lift]: [Uplift modelling](https://en.wikipedia.org/wiki/Uplift_modelling)

### 2.1. RFM 요약 

RFM(Recency, Frequency, Monetary)은 고객의 가치(매출???)를 다음 세가지 측도로 평가하고, 이 모형을 바탕으로 연관성과 더불어 필요하면 가설을 도출할 수도 있다.

* **R** ecency- 거래 최근성: 고객이 얼마나 최근에 구입했는가?
* **F** requency- 거래빈도: 고객이 얼마나 빈번하게 우리 상품을 구입했나?
* **M** onetary- 거래규모: 고객이 구입했던 총 금액은 어느 정도인가? 

$$\begin{align*} V_{고객가치} &= f(거래 최근성, 거래빈도, 거래규모)\\
&= \beta_0 + \beta_1 \times 거래 최근성 + \beta_2 \times 거래빈도
+ \beta_3 \times 거래규모 + \epsilon \end{align*}$$

### 2.2. 반응/성향 모형

[^pm-uplift]: [Uplift Modeling Workshop](http://www.slideshare.net/odsc/victor-lomachinelearningpresentation)

예측모형은 다양한 분야에 활용되었는데 고객관계관리(CRM, Customer Relationship Management)에서 **고객유치(acqusition)**, **교차판매(cross-sell)나 상향판매(upsell)**, **고객유지율(retention)** 향상을 통해 나타난다. 일반적 캠페인의 예를 들면, 

신규고객을 유치(미성년자 &rarr; 성년)하거나, 남의 집 고객을 다시 되찾아 오거나(KT &rarr; SKT), 문제 혹은 고비용 고객을 안내하여 타사 고객으로 바꾸는 등 다양한 사례가 존재한다.

고객이 유치되면 고객에 대해 더 고급진 제품과 서비스를 통해 매출을 신장(upsell)하거나 다른 제품을 소개하거나 끼워팔기(cross-sell) 등을 통해 고객에 대한 제품 및 서비스를 강화한다.

신규고객 유치비용은 기존고객을 유지하는 것에 비해 훨씬 비용이 많이 드는 경우가 많다. 이유는 신규고객유치를 위해 중간 판매대리점에 보조금과 지원금을 지원하고 추가 광고비를 집행 때문에 그렇다. 따라서 고객을 이탈을 최소화하고 다르게 보면 고객 유지를 잘 해야하는 것도 같은 맥락에서 이해될 수 있다.

#### 제조사/유통사 관점

제조사/유통사에서 바라볼 때, 중요한 기능은 서비스에 대한 고객만족도, 제품범주에 있어 브래드 가치, 제품에 대한 고급성 등이 존재한다.

* 서비스에 대한 고객만족도(customer satisfaction)
* 제품범주에 대한 브랜드 통솔력(brand leadership)
* 제품에 대한 고급성(luxury)

#### 고객 관점 [^ml-pm]

[^ml-pm]: [Predictive Analytics: The Power to Predict Who Will Click, Buy, Lie, or Die](https://www.youtube.com/watch?v=YVJ5cbRRvNc)

고객이냐 고객이 아니냐가 중요한게 아니다. 미국 대선에서 공화당을 지지하느냐, 민주당을 지지하느냐가 예측 모형의 핵심이 아니라, 우리나라의 경우 무조건 새누리, 더민주인 사람에게 예측모형을 적용하는 것은 무의미하고, 어찌보녀 접촉했을 때만 반응하는 고객을 찾아내는 것이 문제의 핵심이 될 수 있다.

* Persuadables -- 목표고객으로 설정해서 접촉했기 때문에 마케팅 행사에 반응하는 고객
* Sure Things -- 목표고객으로 설정이 되든 말든 마케팅 행사에 반응하는 고객
* Lost Causes -- 목표고객으로 설정이 되든 말든 마케팅 행사에 반응하지 않는 고객
* Do Not Disturbs or Sleeping Dogs -- 목표고객으로 설정되었기 때문에 마케팅 행사에 더 반응하지 않는 고객

