options(warn = F)
options(echo = F)

cs <- read.delim("H(TSV)/HDS_Customers.tab", stringsAsFactors = F)
tr <- read.delim("H(TSV)/HDS_Transactions_MG.tab", stringsAsFactors = F)

tr.input <- tr[tr$net_amt >=0,]
tr.input <- tr.input[!tr.input$net_amt>=7200000,]

summary.value <- summary(tr.input$net_amt)


#판매 금액

tmp <- tr.input
cs.v8.2 <- tmp %>% mutate(grade1 = ifelse(net_amt < summary.value[[2]], 1,0),
                          grade2 = ifelse(net_amt >= summary.value[[2]] & net_amt < summary.value[[3]], 1,0),
                          grade3 = ifelse(net_amt >= summary.value[[3]] & net_amt < summary.value[[5]], 1,0),
                          grade4 = ifelse(net_amt >= summary.value[[5]] & net_amt < summary.value[[6]], 1,0),
                          grade5 = ifelse(net_amt >= summary.value[[6]] & is.na(net_amt), 1,0)) %>% 
  group_by(custid) %>% 
  summarize(grade1 = sum(grade1),
            grade2 = sum(grade2),
            grade3 = sum(grade3),
            grade4 = sum(grade4),
            grade5 = sum(grade5)) %>% mutate(cust.grd = apply(cs.v8.2[,-1],1,which.max))


tmp <- tr.input
cs.v8.3 <- tmp %>% mutate(Spring = ifelse(as.numeric(substr(sales_date,6,7)) <= 5 & as.numeric(substr(sales_date,6,7)) >= 3,1,0),
                          Summer = ifelse(as.numeric(substr(sales_date,6,7)) <= 8 & as.numeric(substr(sales_date,6,7)) >= 6,1,0),
                          Fall = ifelse(as.numeric(substr(sales_date,6,7)) <= 11 & as.numeric(substr(sales_date,6,7)) >= 9,1,0),
                          Winter = ifelse(as.numeric(substr(sales_date,6,7)) <= 2 & as.numeric(substr(sales_date,6,7)) >= 12,1,0)) %>% 
  group_by(custid) %>% 
  summarize(Spring = sum(Spring),
            Summer = sum(Summer),
            Fall = sum(Fall),
            Winter = sum(Winter)) %>% mutate(cust.grd = apply(cs.v8.3[,-1],1,which.max))