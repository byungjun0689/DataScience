# Lotte (Personal Project)

library(arules)
library(reshape2)

#Load Library & Data
lotte <- read.csv("lotte.csv")
lotte <- lotte[,-8]

colnames(lotte) <- c("seq","N1","N2","N3","N4","N5","N6")
# 회차 별 뽑힌 숫자. 확인
head(lotte[order(lotte$seq, decreasing = F),])

# Data Reshaping
## Transacition DataTransacition Data  형성을 위해  ReshapeReshape  ( MeltMelt 를  seqseq 를 기준으로 수행)
melt_lotte <- melt(lotte, id="seq") # seq(회차)를 기준으로 데이터 Melt

melt_lotte[melt_lotte$seq ==730,] # 확인.

# Pick data from DF
data <- melt_lotte[,c(1,3)] # seq, value

head(data[order(data$seq,decreasing = T),])

# Split Data with seq number
## ValueValue 를  SeqSeq 로  SplitSplit 한다.

head(split(data$value, data$seq))

# Make Transactions
trans <- as(split(data$value, data$seq), "transactions") #transactions 메소드 
trans 

# Inspect a transaction
inspect(trans[1:10])

options(repr.plot.width=4,repr.plot.height=2)
image(trans[1:10])

itemFrequency(trans, type="absolute")

round(itemFrequency(trans)[order(itemFrequency(trans), decreasing = TRUE)],2)

# Plotting items with support
itemFrequencyPlot(trans, topN = 20, main = "support top 20 items",cex.names=0.6)

# Making rules with transaction data, Lotte
rules <- apriori(trans[,-2],parameter = list(support=0.005,target="frequent itemsets"))

summary(rules)

inspect(rules[1:10])

# Top 10 of the Support
inspect(sort(rules, by = "support")[1:10]) 
# 2 Set of Rules
inspect(sort(rules, by = "support")[43:50]) 
# Find 3 Set of Rules
inspect(sort(rules[rules@quality$support >= 0.005 & rules@quality$support <= 0.00685], by = "support")[25:40])

df <- as.data.frame(inspect(sort(rules, by = "support")))

head(df[1000:10000,])

library(stringr)

df$items = str_replace(string = df$items,pattern = "\\{",replacement = "")
df$items = str_replace(string = df$items,pattern = "\\}",replacement = "")

head(df[1000:10000,])

# 4개 이상의 조합을 얻기 위한 지지도 하향 조정
rules2 <- apriori(trans[,-2],parameter = list(support=0.0005,target="frequent itemsets"))
summary(rules2)

inspect(sort(rules2[rules2@quality$support >= 0.001 & rules2@quality$support <= 0.0015], by = "support")[4870:4880])

# 1. 개별 지지도 상위 6개 선택
# 개별 확률의 곱으로 전체 확률을 표현.
prob <- 1
for(i in 1:6){
    #print(paste(df[i,1]," ",df[i,2]))
    #print(df[i,1])
    prob <- prob * df[i,2]
    print(paste("cusum : ",prob))
}
print(prob)

#2. 개별 항목 3개, 3개 집합 1개 선택
## 최상위 개별 선택 3개 항목
## {20} 0.1589041
## {40} 0.1561644
## {34} 0.1547945
# 3개 항목 최상위 위의 숫자를 제외한
## {19,25,28} 0.006849315
## 20,40,34,19,25,28
## 확률 : 0.0000263
# 3. 3개의 집단 2개 선택
## {19,25,28} 0.006849315
## {10,16,41} 0.006849315
## 확률 : 0.000049
# 4 + 2 Set 조합
## {3,9,22,42} 0.001369863
## {20,35} 0.02876712
## 확률 : 0.000042
