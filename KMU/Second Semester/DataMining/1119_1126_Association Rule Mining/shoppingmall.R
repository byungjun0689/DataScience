

data <- read.delim("shoppingmall.txt",stringsAsFactors = F)
st <- as.matrix(data[,-1])
trans <- as(st,"transactions")



inspect(trans[1:2])
#transactionInfo(trans[size(trans) > 1])
# size(trans) each transaction length
#transactionInfo(trans[size(trans) > 20])

image(trans[1:5])
image(sample(trans, 100, replace = FALSE), main = "matrix diagram")

itemFrequency(trans, type="absolute") # table과 동일한결과가 나온다. 
itemFrequency(trans)[order(itemFrequency(trans), decreasing = TRUE)]

itemFrequencyPlot(trans, support=0.01, cex.names=0.8)
itemFrequencyPlot(trans, topN = 20, main = "support top 20 items")

rules <- apriori(trans, parameter=list(support=0.01, confidence=0.8))
# rules <- apriori(trans, parameter=list(support=0.2, confidence=0.8), appearance=list(rhs="스포츠",default="lhs"))
summary(rules)


inspect(rules)
inspect(sort(rules, by = "lift")[1:30])

write.PMML(rules.target, file = "arules.xml")

# rule_df <- as(rules, "data.frame")
# head(rule_df)


##### Visualize Association Rules using arulesViz package

install.packages("arulesViz") 
library(arulesViz)

plot(rules)
plot(sort(rules, by = "lift")[1:20], method = "grouped")
plot(rules, method = "graph", control = list(type="items"))

#빈번한 아이템이 많은지.
rules <- apriori(trans, parameter=list(support=0.01, target="frequent itemsets"))

#최대 빈발아이템을 찾는것이 과제 목적 