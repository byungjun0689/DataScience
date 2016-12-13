install.packages("dplyr")
library("dplyr")



names(totalBike) 
tmpBike <- totalBike[,-c(2,3)]
## aggregate() 활용하는 것이랑 동일하지만. 속도가 빠르다 
## but strptime형태는 사용할 수 없어서 해당 컬럼은 삭제. 또는 형태를 바꿔야한다.
tmpBike %>% group_by(Member.Type) %>% summarize(N=n())  
tmpBike %>% group_by(year,quarter) %>% summarize(N=n())

