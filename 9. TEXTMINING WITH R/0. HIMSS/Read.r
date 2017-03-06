install.packages("pdftools")
library(pdftools)
library(tm)
library(dplyr)
library(qgraph)

files <- list.files(pattern = "pdf$")
txt_tmp <- pdf_text(files)
txt <- pdf_text(files[1])
txt <- gsub("[\r\n]", "", txt)

length(files)
txt <- c()
for(file in files){
  txt_tmp <- pdf_text(file)
  txt_tmp <- paste(txt_tmp,collapse="   ") 
  txt <- c(txt,txt_tmp)
}

txt <- gsub("[\r\n]", "", txt)
txt <- gsub("[^[:graph:]]"," ",txt)
txt <- gsub("will","",txt)
txt <- gsub("use","",txt)
txt <- gsub("can","",txt)
txt <- gsub("patients","patient",txt)
txt <- gsub("clinical","",txt)
txt <- gsub("new","",txt)
txt

review.corpus <- Corpus(VectorSource(txt))
tdm <- TermDocumentMatrix(review.corpus, control=list(wordLengths=c(2,10), removeNumbers=T, removePunctuation=T,stopwords=T))
tdm.matrix <- as.matrix(tdm)

#rownames(tdm.matrix)[1:20]
word.count <- rowSums(tdm.matrix)
word.order <- order(word.count,decreasing = T)
freq.words <- tdm.matrix[word.order[1:20],]
cooccur <- freq.words %*% t(freq.words)

qgraph(cooccur,
       labels=rownames(cooccur), # 가로세로 모두 단어다 그래서 colnames로 해도상관없다. 단어가 안짤리고 잘나온다. 
       diag=F, # 자기자신을 나타내는 대각선 부분을 없앤다. 
       layout='spring', # Node의 위치를 바꿀수있다. 
       edge.color='blue',
       vsize=log(diag(cooccur)))
