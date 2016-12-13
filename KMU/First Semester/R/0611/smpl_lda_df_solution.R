load("smpl_lda_df.RData")
head(smpl_lda_df)

table(smpl_lda_df$Ntopic)

which(smpl_lda_df[1,] > 0)
order(smpl_lda_df[1,], decreasing=T)
which(smpl_lda_df[4,] > 0)

for (i in 1:dim(smpl_lda_df)[1]) {
  smpl_lda_df$Ntopic[i] <- length(which(smpl_lda_df[i,1:20] > 0)) 
}

smpl_lda_df$Ntopic[4]

for (i in 1:dim(smpl_lda_df)[1]) {
  dummy <- NULL
  for(j in 1:smpl_lda_df$Ntopic[i]) {
    orderdummy <- order(smpl_lda_df[i,1:20], decreasing=T)
    dummy <-paste(dummy,names(smpl_lda_df)[orderdummy[j]])
  }
  smpl_lda_df$Tname[i] <- dummy
}

answer <- data.frame(smpl_lda_df[,c("Ntopic","Tname")])
head(answer)
write.csv(answer, file="answer_unho_chang.csv")

