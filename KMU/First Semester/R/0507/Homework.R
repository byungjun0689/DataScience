

load("smpl_lda_df.RData")
data <- smpl_lda_df
for(i in 1:nrow(data)){
  data[i,"Ntopic"] <-length(which(data[i,]>0))
  data[i,"Tname"] <- paste(colnames(data)[which(data[i,1:20]!=0)],collapse=' ')
}
sampleData <- data[,21:22]
write.csv(sampleData,"HomeworkUsingFor.csv",row.names = T)


load("smpl_lda_df.RData")
data <- smpl_lda_df
countPos = function(x){
  length(which(x>0))
}
pasteTopic = function(x){
  paste(rownames(as.data.frame(which(x!=0))),collapse = ' ')
}
tmp <- data.frame(Ntopic = apply(data,1, countPos),Tname = apply(data,1,pasteTopic))
write.csv(tmp,"HomeworkUsingApply.csv", row.names = T)
