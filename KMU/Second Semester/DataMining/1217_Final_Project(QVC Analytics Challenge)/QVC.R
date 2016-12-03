

customer <- read.csv("Customer master.csv")
orderlist <- read.csv("6 month history of customer orders.csv")
product <- read.csv("Product master.csv",stringsAsFactors = F)
air_product <- read.csv("Product airtime.csv")

customer$ZIP_CODE <- as.factor(customer$ZIP_CODE)
orderlist$ORDER_DATE <- as.POSIXlt(orderlist$ORDER_DATE,format="%Y-%m-%d")
orderlist$ORDER_TIME <- format(orderlist$ORDER_TIME,format="%H:%M:%S")

product <- product[,-c(5,6,7)]

  #as.POSIXlt(orderlist$ORDER_TIME, format="%H:%M:%S")

which(is.na(product$X))
head(product[!complete.cases(product),"X1"])

oridata <- product[product$x=="",]
new_df <- product[product$X!="",]
new_df2 <- new

product[product$X.2!="",]
str(product[product$X.2=="",])

product <- read.csv("Customer master.csv")

x2_product <- product[product$X.2!="",]
remain_x2_product <- product[product$X.2=="",]

x2_product$PACKING_SLIP_DESC <- paste0(x2_product$PACKING_SLIP_DESC,x2_product$MERCH_DIV_DESC,x2_product$BRAND_NAME,x2_product$X)
x2_product$MERCH_DIV_DESC <- x2_product$X.1
x2_product$BRAND_NAME <- x2_product$X.2
x2_product[,c(5,6,7)] <- ""
x2_product
remain_x2_product
product2 <- rbind(remain_x2_product,x2_product)

x1_product <- product2[product2$X.1!="",]
remain_x1_product <- product2[product2$X.1=="",]
x1_product$PACKING_SLIP_DESC <- paste0(x1_product$PACKING_SLIP_DESC,x1_product$MERCH_DIV_DESC,x1_product$BRAND_NAME)
x1_product$MERCH_DIV_DESC <- x1_product$X
x1_product$BRAND_NAME <- x1_product$X.1
x1_product[,c(5,6,7)] <- ""

product3 <- rbind(remain_x1_product,x1_product)

x_product <- product3[product3$X!="",]
remain_x_product <- product3[product3$X=="",]
x_product$PACKING_SLIP_DESC <- paste0(x_product$PACKING_SLIP_DESC,x_product$MERCH_DIV_DESC)
x_product$MERCH_DIV_DESC <- x_product$BRAND_NAME
x_product$BRAND_NAME <- x_product$X
x_product[,c(5,6,7)] <- ""
product4 <- rbind(remain_x_product,x_product)
colnames(product4)
product4 <- product4[,-c(5,6,7)]

write.csv(product4,"Product master2.csv")
