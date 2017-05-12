
# 데이터 전처리 및 정제의 중요성

기계학습 알고리즘이 학습을 얼마나 잘 하느냐는 전적으로 **데이터의 품질** 과 **데이터에 담긴 정보량** 에 달려있다. 따라서, 가능하면 정보를 잃지 않으면서 기계학습 알고리즘이 학습할 환경을 구비하는 것이 핵심이다.

* 데이터에서 결측값을 제거하고, 결측값을 **대치(impute)** 한다.
* 범주형 데이터를 기계학습 알고리즘이 소화할 수 있는 형태로 변형한다.

## 1. 결측값 

결측값(missing value)은 보통 빈칸으로 내버려두거나, `NaN`(Not a Number) 혹은 `NA` (Not Applicable, Not Available)로 표기하여 자리를 차지해 둔다. 결측값을 자동으로 알아서 학습하는 기계학습 알고리즘은 아직 존재하지 않기 때문에 통상 결측값을 제거하거나, EM 알고리즘 등을 통해 대치하는 기법을 많이 사용한다.


```python
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
```

한글을 `pandas`에서 처리하는데... `sys.setdefaultencoding("utf-8")` 설정을 사전에 하고 들어간다.
`csv_dat` 변수에 결측값이 들어간 데이터를 생성하고, 판다스에 넣어 데이터프레임을 생성하고 작업을 진행한다.
결측값은 `NaN`으로 파이썬에서 표시된다.


```python
import pandas as pd
from io import StringIO
csv_dat = '''가열,나열,다열,라열,마열
1.0,2.0,3.0,4.0,3.0
5.0,6.0,,8.0, 4.0
0.0,11.0,12.0,,7.0
1.0,7.5,3.0,7.0,3.0'''
csv_dat = unicode(csv_dat) # 파이썬 2.7 계열인 경우 필요하다.
df = pd.read_csv(StringIO(csv_dat))
df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>가열</th>
      <th>나열</th>
      <th>다열</th>
      <th>라열</th>
      <th>마열</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1.0</td>
      <td>2.0</td>
      <td>3.0</td>
      <td>4.0</td>
      <td>3.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>5.0</td>
      <td>6.0</td>
      <td>NaN</td>
      <td>8.0</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.0</td>
      <td>11.0</td>
      <td>12.0</td>
      <td>NaN</td>
      <td>7.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1.0</td>
      <td>7.5</td>
      <td>3.0</td>
      <td>7.0</td>
      <td>3.0</td>
    </tr>
  </tbody>
</table>
</div>



### 1.1. 결측값 제거

데이터프레임에 들어있는 값의 현황을 파악하려면, `df.values` 명령어를 사용하고, 결측값 갯수는 `df.isnull().sum()` 명령어로 확인한다.

결측값을 제거하는 메쏘드는 `df.dropna()`가 있고, 행방향 혹은 열방향 기준으로 결측값을 제거할 경우 인자로 `axis=0`, `axis=1`를 `df.dropna(axis=1)`와 같이 넣어준다.

`.dropna()` 메쏘드 인자로 `thresh=3`, `subset=['나열']`, `how='all'`과 같이 추가적인 설정을 통해 결측값 개수와 상황에 따라 제어를 한다.


```python
df.dropna()
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>가열</th>
      <th>나열</th>
      <th>다열</th>
      <th>라열</th>
      <th>마열</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1.0</td>
      <td>2.0</td>
      <td>3.0</td>
      <td>4.0</td>
      <td>3.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1.0</td>
      <td>7.5</td>
      <td>3.0</td>
      <td>7.0</td>
      <td>3.0</td>
    </tr>
  </tbody>
</table>
</div>




```python
df.dropna(axis=1)
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>가열</th>
      <th>나열</th>
      <th>마열</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>1.0</td>
      <td>2.0</td>
      <td>3.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>5.0</td>
      <td>6.0</td>
      <td>4.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.0</td>
      <td>11.0</td>
      <td>7.0</td>
    </tr>
    <tr>
      <th>3</th>
      <td>1.0</td>
      <td>7.5</td>
      <td>3.0</td>
    </tr>
  </tbody>
</table>
</div>



### 1.2. 결측값 대치

결측값이 있을 때마다 날려버리게 되면 깔끔하지만, 댓가가 따른다. 결측값 제거에 따라 남아있는 관측점 혹은 변수가 줄어들게 되어 데이터를 통해 수집한 정보가 모두 사라지는 문제점이 있다. 결측값을 대치함으로써 정보를 잃지 않으면서 가능하면 많은 관측점과 변수를 통해 통상 기계학습 알고리즘을 개발한다.

`sklearn.preprocessing` 라이브러리에서 `Imputer` 함수를 사용해서 결측값을 대치하는데, 인자로 `missing_values=`에 결측값 대상을 정의하고, `strategy=`에 평균으로 대치하면 `mean`, 중위값으로 대치하면 `median`, 범주형 자료의 경우는 가장 많은 최빈치로 `most_frequent`를 넣어주고, 행기준이면, `axis=0`, 열기준이면 `axis=1`로 설정한다.

Imputer 클래스는 중요한 두가지 메쏘드를 갖는데, 첫번째 메쏘드가 `.fit` 메쏘드로 데이터프레임을 입력받아 결측값을 채워넣을 적합모형을 생성한다. 이번 경우에는 단순하지만, 평균이 이곳에 해당된다. 두번째 메쏘드는 `.transform` 으로 생성된 적합모형을 적용할 데이터프레임으로 여기서는 결측값이 들어있는 데이터프레임이다. 물론 `.fit`과 `.transform`은 동일한 모양을 가져야만 한다.


```python
from sklearn.preprocessing import Imputer
imp_mean = Imputer(missing_values='NaN', strategy='mean', axis=0)
imp_mean = imp_mean.fit(df)
imp_mean_dat = imp_mean.transform(df.values)
imp_mean_dat
```




    array([[  1.        ,   2.        ,   3.        ,   4.        ,   3.        ],
           [  5.        ,   6.        ,   6.        ,   8.        ,   4.        ],
           [  0.        ,  11.        ,  12.        ,   6.33333333,   7.        ],
           [  1.        ,   7.5       ,   3.        ,   7.        ,   3.        ]])



## 2. 범주형 자료 처리


숫자형 데이터 말고도, 범주형 데이터도 중요한 자료형이다. 범주형자료에는 순서가 있는 범주형 자료와 순서가 없는 범주형자료로 구분된다. **명목형(Nominal)** 으로 불리는 순서가 없는 범주형 자료는 남자, 여자와 같은 자료형이 포함되고, **순서형(Ordinal)** 으로 불리는 순서가 있는 범주형 자료는 군대 계급같은 자료형이 포함된다. 


```python
import pandas as pd
df = pd.DataFrame([
        ['서울','대위','175','75','1중대'],
        ['부산','중위','165','85','2중대'],
        ['성남','소위','180','70','1중대']        
    ])
df.columns = ['고향','계급','키', '몸무게','소속']
df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>고향</th>
      <th>계급</th>
      <th>키</th>
      <th>몸무게</th>
      <th>소속</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>서울</td>
      <td>대위</td>
      <td>175</td>
      <td>75</td>
      <td>1중대</td>
    </tr>
    <tr>
      <th>1</th>
      <td>부산</td>
      <td>중위</td>
      <td>165</td>
      <td>85</td>
      <td>2중대</td>
    </tr>
    <tr>
      <th>2</th>
      <td>성남</td>
      <td>소위</td>
      <td>180</td>
      <td>70</td>
      <td>1중대</td>
    </tr>
  </tbody>
</table>
</div>



판다스 데이터프레임에 변수가 4개 있고, `고향`변수는 명목형으로 순서가 없고, `계급`변수는 순서를 갖는 범주형 자료다. `키`, `몸무게`는 숫자형 변수로 다양한 자료형을 담을 수 있는 자료구조가 데이터프레임이기도 하다.

### 2.1. 범주형 자료에 정수 매핑

계급을 기계학습 알고리즘을 적용시킬 수 있도록 자동으로 변환하는 방식은 없기 때문에 매핑규칙을 부여해야한다. 예를 들어, $소위+2=중위+1=대위$ 라는 규칙을 적용해 본다. 여기서 소위를 `1`로 기본값으로 둔다.


```python
rank_mapping = {
    '소위' : 1,
    '중위' : 2,
    '대위' : 3
}
df['계급'] = df['계급'].map(rank_mapping)
df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>고향</th>
      <th>계급</th>
      <th>키</th>
      <th>몸무게</th>
      <th>소속</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>서울</td>
      <td>3</td>
      <td>175</td>
      <td>75</td>
      <td>1중대</td>
    </tr>
    <tr>
      <th>1</th>
      <td>부산</td>
      <td>2</td>
      <td>165</td>
      <td>85</td>
      <td>2중대</td>
    </tr>
    <tr>
      <th>2</th>
      <td>성남</td>
      <td>1</td>
      <td>180</td>
      <td>70</td>
      <td>1중대</td>
    </tr>
  </tbody>
</table>
</div>



원래대로 되돌릴 경우 키와 값을 바꿔 다시 적용시키면 원래 값으로 환원된다.


```python
inv_rank_mapping = {v: k for k, v in rank_mapping.items()}
df['계급'] = df['계급'].map(inv_rank_mapping)
df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>고향</th>
      <th>계급</th>
      <th>키</th>
      <th>몸무게</th>
      <th>소속</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>서울</td>
      <td>대위</td>
      <td>175</td>
      <td>75</td>
      <td>1중대</td>
    </tr>
    <tr>
      <th>1</th>
      <td>부산</td>
      <td>중위</td>
      <td>165</td>
      <td>85</td>
      <td>2중대</td>
    </tr>
    <tr>
      <th>2</th>
      <td>성남</td>
      <td>소위</td>
      <td>180</td>
      <td>70</td>
      <td>1중대</td>
    </tr>
  </tbody>
</table>
</div>



### 2.2. 범주에 자동 표식

범주형 자료에 정수를 매핑하여 표식을 하는 기법이 기계학습 알고리즘 개발에 흔히 사용된다. 
대부분의 기계학습 알고리즘이 범주형 자료를 처음 마주하게 되면 자동으로 정수를 내부적으로 할당하게 되지만, 명시적으로 데이터 전처리과정에서 확실히 해두는 것이 향후 있을지도 모를 문제를 방지시키는 역할을 한다.


```python
import numpy as np
company_mapping = {label:idx for idx, label in 
                  enumerate(np.unique(df['소속']))}
company_mapping
```




    {0: 0, 1: 1}




```python
df['소속'] = df['소속'].map(company_mapping)
df
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>고향</th>
      <th>계급</th>
      <th>키</th>
      <th>몸무게</th>
      <th>소속</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>서울</td>
      <td>대위</td>
      <td>175</td>
      <td>75</td>
      <td>0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>부산</td>
      <td>중위</td>
      <td>165</td>
      <td>85</td>
      <td>1</td>
    </tr>
    <tr>
      <th>2</th>
      <td>성남</td>
      <td>소위</td>
      <td>180</td>
      <td>70</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>



많이 사용되는 기능이기 때문에, `LabelEncoder`라는 클래스를 활용하여 범주에 표식을 쉽게 할 수 있다. R에서는 이런 기능이 **요인(factor)**에 상응하고 정말 통계 및 기계학습에 많이 사용된다.

`.fit_transform` 메쏘드는 앞에서 `.fit`, `.transform` 각각 실행한 것으로 한번에 묶어서 실행하는 일종의 단축키 역할을 한다. `company_lbl.inverse_transform(orig_y)` 메쏘드는 역으로 원래 표식으로 되돌릴 때 사용한다.


```python
from sklearn.preprocessing import LabelEncoder
company_lbl = LabelEncoder()
orig_y = company_lbl.fit_transform(df['소속'].values)
orig_y
```




    array([0, 1, 0], dtype=int64)



### 2.3. 명목형 변수 One-hot 인코딩

통계학에서 실험계획법 혹은 고급 회귀분석에서 범주형 변수를 가변수를 설정한 경험이 있다면 친숙한 개념일 수 있다. 기계학습 알고리즘 개발에서는 이를 **One-Hot 인코딩** 이라고 부른다.

`고향`변수에는 개념적으로 정수같은 순서가 존재하지 않는다. 따라서, `LabelEncoder`를 사용할 경우 말도 안되는 변수가 생성될 수 있다. 이것을 회피하는 것이 통계학에서 가변수(Dummy Variable)를 도입하면 그런 문제를 피할 수 있다.

`OneHotEncoder` 클래스를 사용해도 되고, 판다스에서 제공하는 `.get_dummier` 메소드를 사용해도 좋다.


```python
# from sklearn.preprocessing import OneHotEncoder
# ht_ohe = OneHotEncoder(categorical_features=[0])
# ht_ohe.fit_transform(df).toarray()

import pandas as pd
pd.get_dummies(df[['고향']])
```




<div>
<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>고향_부산</th>
      <th>고향_서울</th>
      <th>고향_성남</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>0.0</td>
      <td>1.0</td>
      <td>0.0</td>
    </tr>
    <tr>
      <th>1</th>
      <td>1.0</td>
      <td>0.0</td>
      <td>0.0</td>
    </tr>
    <tr>
      <th>2</th>
      <td>0.0</td>
      <td>0.0</td>
      <td>1.0</td>
    </tr>
  </tbody>
</table>
</div>



## 변수 표준화

측정단위에 따라 기계학습 알고리즘이 왜곡되는 현상을 방지하고자 변수를 정규화, 표준화, 척도를 조정한다. 예를 들어, 온도를 섭씨와 화씨로 측정하는 경우 이를 보정하지 않으면 변수의 중요도가 아닌 측정단위에 따라 기계학습이 원하지 않는 학습을 할 수 있다.
이를 "**[피쳐 척도조정(Feature Scaling)](https://en.wikipedia.org/wiki/Feature_scaling)**" 이라고 부른다. 최소최대 척도조정은 다음과 같다.

$$x_{최소-최대}' = \frac{x - x_{min}}{x_{max} - x_{min}}$$

최소최대 척도조정결과는 $[0,1]$의 값을 갖게 된다. 하지만, 이항회귀모형, SVM 등 많은 기계학습 모형이 중심이 0, 표준편차가 1인 정규분포를 따르게 변수를 갖추면, 알고리즘의 학습 수렴속도를 높이고, 수렴에 걸리는 시간을 줄이는 등 기계학습에 도움이 되고, 특히, 이상점에 대한 정보도 갖게 되는 장점도 있다. 

$$x_{표준정규}' = \frac{x' -\mu_x}{\sigma_x}$$


```python
# 최소-최대 척도조정
from sklearn.preprocessing import MinMaxScaler
mmscaler = MinMaxScaler()
x_dat_scaling = mmscaler.fit_transform(x_dat)

# 정규 표준화 척도조정
from sklearn.preprocessing import StandardScaler
stdscaler = StandardScaler()
x_dat_std = stdscaler.fit_transform(x_dat)
```


```python

```
