# Cross Vaildation ####

library(caret)
cb <- read.delim("../1022_Decision Tree_2//Hshopping.txt", stringsAsFactors=FALSE)
cb$반품여부 <- factor(cb$반품여부)

set.seed(1)
flds <- createFolds(cb$반품여부, k=5, list=T, returnTrain=F)
str(flds)

# 나머지는 PDF #### 

flds[[1]]
