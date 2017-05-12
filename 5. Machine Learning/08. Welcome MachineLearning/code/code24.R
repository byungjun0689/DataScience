P = matrix(c(0.8,0.9,0.2,0.1) , nrow = 2 , ncol = 2)
probs <- c()
initial_prob = c(1,0) #최초의 상태 

for(i in 1:7) {
  next_prob <- initial_prob %*% P
  probs <- rbind(probs , next_prob) 
  next_prob -> initial_prob
}
colnames(probs) <- c("무사고" , "사고") ; probs

cases <- c()
#통신사 
for(K1 in 1:20) {
  S1 <- 30-K1
  K2 <- 20-K1
  S2 <- 30-S1
  
  cases <- rbind(cases , c(K1 , S1 , K2 , S2))
}
cases

transition <- c() 
for(k in 1:20) {
  case <- cases[k,]
  front <- (case[2]*case[3]) / ((case[1] + case[2])*(case[3] + case[4]))
  end <- (case[1]*case[4]) / ((case[1] + case[2])*(case[3] + case[4]))
  reflect <- (case[1]*case[3]) / ((case[1] + case[2])*(case[3] + case[4])) + 
    (case[2]*case[4]) / ((case[1] + case[2])*(case[3] + case[4]))
  
  transition <- rbind(transition , c(front , end , reflect)) 
}
transition[20,2] <- 1
transition[20,3] <- 0
colnames(transition) <- c("front" , "end" , "reflect")

transition

trans_mat <- matrix(0 , nrow = 21 , ncol =21) 
trans_mat[1,2] <- 1 
trans_mat[21,20] <- 1
for(j in 1:20) { 
  probs <- transition[j,] 
  trans_mat[j+1,j+1] <- probs["reflect"]
  if(j<=19) trans_mat[j+1,j+2] <- probs["front"]
  if(j<=20) trans_mat[j+1,j] <- probs["end"]
}
trans_mat

init_prob <- rep(0,21) ; init_prob[11] <- 1
probs <- c()

for(year in 1:10) {
  next_prob <- init_prob %*% trans_mat
  probs <- rbind(probs , next_prob)
  next_prob -> init_prob
  
}
probs[10,]

#
trans_mat <- matrix(0 , nrow = 16 , ncol = 16)
trans_mat[1,1] <- 1 
trans_mat[16,16] <- 1
p <- 0.6 

for(i in 2:15) {
  trans_mat[i,i+1] <- p 
  trans_mat[i,i-1] <- 1 - p 
}
trans_mat

init_prob <- rep(0,16) ; init_prob[8] <- 1
probs <- c()

for(year in 1:20) {
  next_prob <- init_prob %*% trans_mat
  probs <- rbind(probs , next_prob)
  next_prob -> init_prob
  
}
probs[20,]


