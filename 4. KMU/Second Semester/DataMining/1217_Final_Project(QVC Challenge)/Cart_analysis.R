install.packages("plotrix")

###############################################################################
## Title: Shopping Cart Analysis
## Version: 1.0
## Autor: Josep Curto
## Description: Shopping Cart Analysis
## Source: http://analyzecore.com
###############################################################################

# loading libraries
library(dplyr)
library(reshape2)
library(plotrix)
library(scales)
library(googleVis)
library(dplyr)
library(TraMineR)

# Shopping cart analysis – Multi-layer pie chart

# creating an example of orders

set.seed(15)
df <- data.frame(orderId=sample(c(1:1000), 5000, replace=TRUE),
                 product=sample(c('NULL','a','b','c','d'), 5000, replace=TRUE,
                                prob=c(0.15, 0.65, 0.3, 0.15, 0.1)))
df <- df[df$product!='NULL', ]

# removing duplicates
df <- df[!duplicated(df), ]

# arranging data set
df <- df %>%
  arrange(orderId, product)

# creating product's matrix
prod.matrix <- dcast(df, orderId ~ product, fun.aggregate = NULL)

prod.matrix <- prod.matrix %>%
  mutate(cart = paste(a, b, c, d, sep='')) # check all product names

prod.matrix$cart <- gsub('NA', '', prod.matrix$cart)

# calculating number of product's combinations
comb <- prod.matrix %>%
  group_by(cart) %>%
  summarise(num=n())

# calculating number of products in combinations
comb$l <- sapply(comb$cart, nchar)

# calculating total number of orders/carts
tot <- sum(comb$num)

# spliting orders for sets with 1 product and more than 1 product
one.prod <- comb[comb$l==1,]
sev.prod <- comb[comb$l!=1,]

# arranging several products' data set
sev.prod <- arrange(sev.prod, desc(l))

# defining parameters for pie chart
iniR <- 0.2 # initial radius
all.colors <- list(NO='white', a='#fec44f', b='#fc9272', c='#a1d99b', d='#fee0d2') # palette
colors <- all.colors[ c(1:(nrow(one.prod)+1))] # set of colors

# 0 circle: blank
pie(1, radius=iniR, init.angle=90, col=c('white'), border = NA, labels='', edges=300)

# drawing circles from last to 2nd
for (i in nrow(one.prod):1) {
  p <- grep(one.prod$cart[i], sev.prod$cart)
  col <- rep('NO', times=nrow(sev.prod))
  col[p] <- one.prod$cart[i]
  floating.pie(0,0,c(sev.prod$num, tot-sum(sev.prod$num)), radius=(2+i)*iniR, startpos=pi/2, col=as.character(colors[ c(col, 'NO')]), border="#44aaff")
}

# 1 circle: orders with 1 product
floating.pie(0,0,c(tot-sum(one.prod$num),one.prod$num), radius=2*iniR, startpos=pi/2, col=as.character(colors[ c('NO',one.prod$cart)]), border="#44aaff")

# legend
legend(1.5, 2*iniR, gsub("_"," ",names(colors)[-1]), col=as.character(colors[-1]), pch=19, bty='n', ncol=1)

# creating a table with the stats
stat.tab <- comb %>%
  select(-l) %>%
  mutate(share=num/tot) %>%
  arrange(desc(num))

stat.tab$share <- percent(stat.tab$share) # converting values to percents

# adding a table with the stats
addtable2plot(-2.5, -1.5, stat.tab, bty="n", display.rownames=FALSE,
              hlines=FALSE, vlines=FALSE, title="The stats")

p


# Shopping cart analysis – Sankey diagram ####

# creating an example of orders
set.seed(15)
df <- data.frame(orderId=c(1:1000),
                 clientId=sample(c(1:300), 1000, replace=TRUE),
                 prod1=sample(c('NULL','a'), 1000, replace=TRUE, prob=c(0.15, 0.5)),
                 prod2=sample(c('NULL','b'), 1000, replace=TRUE, prob=c(0.15, 0.3)),
                 prod3=sample(c('NULL','c'), 1000, replace=TRUE, prob=c(0.15, 0.2)))

# combining products
df$cart <- paste(df$prod1, df$prod2, df$prod3, sep=';')
df$cart <- gsub('NULL;|;NULL', '', df$cart)
df <- df[df$cart!='NULL', ]

df <- df %>%
  select(orderId, clientId, cart) %>%
  arrange(clientId, orderId, cart)

orders <- df %>%
  group_by(clientId) %>%
  mutate(n.ord = paste('ord', c(1:n()), sep=''))

orders <- dcast(orders, clientId ~ n.ord, value.var='cart', fun.aggregate = NULL)

orders <- orders %>%
  select(ord1, ord2, ord3, ord4, ord5)

orders.plot <- data.frame(from = character(0), to = character(0), n=integer(0))

for (i in 2:ncol(orders)) {
  
  ord.cache <- orders %>%
    group_by(orders[ , i-1], orders[ , i]) %>%
    summarise(n=n())
  
  colnames(ord.cache)[1:2] <- c('from', 'to')
  
  # adding tags to carts
  ord.cache$from <- paste(ord.cache$from, '(', i-1, ')', sep='')
  ord.cache$to <- paste(ord.cache$to, '(', i, ')', sep='')
  
  orders.plot <- rbind(orders.plot, data.frame(ord.cache))
  
}

plot(gvisSankey(orders.plot, from='from', to='to', weight='n',
                options=list(height=900, width=1800, sankey="{link:{color:{fill:'lightblue'}}}")))

# Shopping cart analysis – Deep Analysis ####

# creating an example of shopping carts
set.seed(10)
data <- data.frame(orderId=sample(c(1:1000), 5000, replace=TRUE),
                   product=sample(c('NULL','a','b','c'), 5000, replace=TRUE,
                                  prob=c(0.15, 0.65, 0.3, 0.15)))
order <- data.frame(orderId=c(1:1000),
                    clientId=sample(c(1:300), 1000, replace=TRUE))
sex <- data.frame(clientId=c(1:300),
                  sex=sample(c('male', 'female'), 300, replace=TRUE, prob=c(0.40, 0.60)))
date <- data.frame(orderId=c(1:1000),
                   orderdate=sample((1:90), 1000, replace=TRUE))
orders <- merge(data, order, by='orderId')
orders <- merge(orders, sex, by='clientId')
orders <- merge(orders, date, by='orderId')
orders <- orders[orders$product!='NULL', ]
orders$orderdate <- as.Date(orders$orderdate, origin="2012-01-01")
rm(data, date, order, sex)

# combining products to the cart

df <- orders %>%
  arrange(product) %>%
  select(-orderId) %>%
  unique() %>%
  group_by(clientId, sex, orderdate) %>%
  summarise(cart=paste(product,collapse=";")) %>%
  ungroup()

max.date <- max(df$orderdate)+1
ids <- unique(df$clientId)
df.new <- data.frame()

for (i in 1:length(ids)) {
  df.cache <- df %>%
    filter(clientId==ids[i])
  
  ifelse(nrow(df.cache)==1,
         av.dur <- 30,
         av.dur <- round(((max(df.cache$orderdate) - min(df.cache$orderdate))/(nrow(df.cache)-1))*1.5, 0))
  
  df.cache <- rbind(df.cache, data.frame(clientId=df.cache$clientId[nrow(df.cache)],
                                         sex=df.cache$sex[nrow(df.cache)],
                                         orderdate=max(df.cache$orderdate)+av.dur,
                                         cart='nopurch'))
  
  ifelse(max(df.cache$orderdate) > max.date,
         df.cache$orderdate[which.max(df.cache$orderdate)] <- max.date,
         NA)
  
  df.cache$to <- c(df.cache$orderdate[2:nrow(df.cache)]-1, max.date)
  
  # order# for Sankey diagram
  df.cache <- df.cache %>%
    mutate(ord = paste('ord', c(1:nrow(df.cache)), sep=''))
  
  df.new <- rbind(df.new, df.cache)
}
# filtering dummies
df.new <- df.new %>%
  filter(cart!='nopurch' | to != orderdate)
rm(order, df, df.cache, i, ids, max.date, av.dur)

##### Sankey diagram #######

df.sankey <- df.new %>%
  select(clientId, cart, ord)

df.sankey <- dcast(df.sankey, clientId ~ ord, value.var='cart', fun.aggregate = NULL)

df.sankey[is.na(df.sankey)] <- 'unknown'

####

# chosing a length of sequence
df.sankey <- df.sankey %>%
  select(ord1, ord2, ord3, ord4)

# replacing NAs after 'nopurch' for 'nopurch'
df.sankey[df.sankey[, 2]=='nopurch', 3] <- 'nopurch'
df.sankey[df.sankey[, 3]=='nopurch', 4] <- 'nopurch'

df.sankey.plot <- data.frame(from = character(0), to = character(0), n=integer(0))

for (i in 2:ncol(df.sankey)) {
  
  df.sankey.cache <- df.sankey %>%
    group_by(df.sankey[ , i-1], df.sankey[ , i]) %>%
    summarise(n=n())
  
  colnames(df.sankey.cache)[1:2] <- c('from', 'to')
  
  # adding tags to carts
  df.sankey.cache$from <- paste(df.sankey.cache$from, '(', i-1, ')', sep='')
  df.sankey.cache$to <- paste(df.sankey.cache$to, '(', i, ')', sep='')
  
  df.sankey.plot <- rbind(df.sankey.plot, data.frame(df.sankey.cache))
}

plot(gvisSankey(df.sankey.plot, from='from', to='to', weight='n',
                options=list(height=900, width=1800, sankey="{link:{color:{fill:'lightblue'}}}")))

rm(df.sankey, df.sankey.cache, df.sankey.plot, i)



####  

df.new <- df.new %>%
  # chosing a length of sequence
  filter(ord %in% c('ord1', 'ord2', 'ord3', 'ord4')) %>%
  select(-ord)

# converting dates to numbers
min.date <- as.Date(min(df.new$orderdate), format="%Y-%m-%d")
df.new$orderdate <- as.numeric(df.new$orderdate-min.date+1)
df.new$to <- as.numeric(df.new$to-min.date+1)


df.form <- seqformat(df.new, id='clientId', begin='orderdate', end='to', status='cart',
                     from='SPELL', to='STS', process=FALSE)

df.seq <- seqdef(df.form, left='DEL', right='unknown', xtstep=10, void='unknown') # xtstep - step between ticks (days)
summary(df.seq)

df.feat <- unique(df.new[ , c('clientId', 'sex')])

# distribution analysis
seqdplot(df.seq, border=NA, withlegend='right')
seqdplot(df.seq, border=NA, group=df.feat$sex) # distribution based on gender

seqstatd(df.seq)

# the 10 most frequent sequences
seqfplot(df.seq, border=NA, withlegend='right')
# the 10 most frequent sequences based on gender
seqfplot(df.seq, group=df.feat$sex, border=NA)

# returning the frequency stats
seqtab(df.seq) # frequency table
seqtab(df.seq[, 1:30]) # frequency table for 1st month

# mean time spent in each state
seqmtplot(df.seq, title='Mean time', withlegend='right')
seqmtplot(df.seq, group=df.feat$sex, title='Mean time')

statd <- seqistatd(df.seq) #function returns for each sequence the time spent in the different states
apply(statd, 2, mean) #We may be interested in the mean time spent in each state

# calculating entropy
df.ient <- seqient(df.seq)
hist(df.ient, col='cyan', main=NULL, xlab='Entropy') # plot an histogram of the within entropy of the sequences
# entrophy distribution based on gender
df.ent <- cbind(df.seq, df.ient)
boxplot(Entropy ~ df.feat$sex, data=df.ent, xlab='Gender', ylab='Sequences entropy', col='cyan')


# Shopping cart analysis – Customer Analysis

# CLUSTERING
library(cluster)
df.om <- seqdist(df.seq, method='OM', indel=1, sm='TRATE', with.missing=TRUE) # computing the optimal matching distances
clusterward <- agnes(df.om, diss=TRUE, method="ward") # building a Ward hierarchical clustering
df.cl4 <- cutree(clusterward, k=4) # cut the tree for creating 4 clusters
cl4.lab <- factor(df.cl4, labels=paste("Cluster", 1:4)) # creating label with the number of cluster for each customer

# distribution chart
seqdplot(df.seq, group=cl4.lab, border=NA)
# frequence chart
seqfplot(df.seq, group=cl4.lab, pbarw=T, border=NA)
# mean time plot
seqmtplot(df.seq, group=cl4.lab, border=NA)

seqrplot(df.seq, group=cl4.lab, dist.matrix=df.om, trep=0.35, border=NA)


# Shopping cart analysis – Sequence of events

df.evseq <- seqecreate(df.seq, tevent='state') # converting state object to event sequence
head(df.evseq)

df.subseq <- seqefsub(df.evseq, pMinSupport=0.01) # searching for frequent event subsequences
plot(df.subseq[1:10], col="cyan", ylab="Frequency", xlab="Subsequences", cex=1.5) # plotting

time.constraint <- seqeconstraint(maxGap=10, windowSize=30) # creating variable with conditions
df.subseq.time.constr <- seqefsub(df.evseq, pMinSupport=0.01, constraint=time.constraint) # searching for frequent event subsequences
plot(df.subseq.time.constr[1:10], col="cyan", ylab="Frequency", xlab="Subsequences", cex=1.5) # plotting

discrseq <- seqecmpgroup(df.subseq, group=df.feat$sex) # searching for frequent sequences that are related to gender
head(discrseq)
plot(discrseq[1:10], cex=1.5) # plotting 10 frequent subsequences
plot(discrseq[1:10], ptype="resid", cex=1.5) # plotting 10 residuals

rules <- TraMineR:::seqerules(df.subseq) # searching for rules
head(rules)

str(rules)
a <- rules$Rules
b <- rules$Support
c <- rules$Conf
t <- data.frame(rules=a,support=b,conf=c)
t
