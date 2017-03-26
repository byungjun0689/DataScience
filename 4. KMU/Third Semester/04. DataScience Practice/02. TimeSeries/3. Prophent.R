library(dynlm)

beverage <- read.csv('2week/beverage.csv')


arima(beverage$shipment, c(1,1,0))  # p = 1, d= 1, q = 0

m.a = arima(beverage$shipment, c(1,1,0),
            seasonal = list(order = c(0, 0, 1), period = 12))  # 12개월 단위 MA(1)
m.a


install.packages("prophet")
library(prophet)
# 추세와 계절효과에 관심이 많다. 
# 휴일 추가 가능.
# 이상점 등, 문제가 있었던 데이트가 있는 경우 날려버린다 그냥. 

# 트랜드 
# 선형 트렌드와 로지스틱 트렌드 2가지가 가능.
# 트렌드가 변하는 점(change point)을 자동 추정
# sparsity parameter(r): 트렌드가 얼마나 자주 변하는지
# r = 0 트렌드가 불변
# 커질 수록 자주 변함.
# pip install fbprophet 으로 설치.
# DataFrame (DS시간, 데이터)
df <- data.frame(ds = as.Date(as.yearmon(beverage$date)),
                 y = beverage$shipment)

df

m <- prophet(df) # n_changepoints 를 옵션을 통해 changepoints갯수를 정할 수 있다.
m
# changepoint.prior.scale 옵션을 통해서 영향도를 높일수도있고 줄일 수도있다. overfitting, Underfitting 
# changepoints = c(as.Date('2014-01-01') 를 박아주면 그날 변화가 나타날거라고 예상하고 

future <- make_future_dataframe(m,periods = 12, freq='month') # 12개월 단위로, 12 week로 하면 12주 치를 예측
forecast = predict(m,future)
plot(m,forecast) # 점이 실제 데이터 파란선이 학습한 값들. 옅은 파란색은 오차구간. 

prophet_plot_components(m, forecast) # 분해를 해준다. 데이터가 월단위 데이터라서 그렇다. 주단위로 있을려면 일다누이로 있어야 한다. 

# 변화점(change point)
m$params$k #기본 성장률 전 구간에 걸쳐서 얼마나 성장하는 추세인가. 1개월마다 평균적으로 0.27씩 성장한다. 
m$changepoints #변화점


# 휴일데이터를 DataFrame으로 만들어서 넣어줄수가 있다. 
# 추가적인 데이터를 넣을 수는 없지만, 예를 들어 기록적을 더웠던 날을 holiday에 넣는다면 가능하다. 



m$params$delta
# 1992-07-01년에는 변화가 거의 없다.  평균적으로 0.27인데.
m$params$delta[1,1] # 1.85528e-09 
plot(m$changepoints,m$params$delta) # 트렌드 그래프와 비교해서 보면 좋다 


par(mfrow=c(1,1))
prophet_plot_components(m, forecast)
plot(m$changepoints,m$params$delta)

# 광고 효과가 있는지 없는 볼때 가속이 되었는지 아닌지 보면 알수있다. 
