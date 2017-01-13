product <- read.csv("Product master.csv",stringsAsFactors = F)

x2_product <- product[product$X.2!="",]
remain_x2_product <- product[product$X.2=="",]

x2_product$PACKING_SLIP_DESC <- paste0(x2_product$PACKING_SLIP_DESC,x2_product$MERCH_DIV_DESC,x2_product$BRAND_NAME,x2_product$X)
x2_product$MERCH_DIV_DESC <- x2_product$X.1
x2_product$BRAND_NAME <- x2_product$X.2
x2_product[,c(5,6,7)] <- ""
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



pm3 <- read.csv("Product master3.csv",stringsAsFactors = F)
tmp_pm3 <- pm3[pm3$MERCH_DIV_DESC!="#REF!",]
head(tmp_pm3)
pdid <- as.data.frame(tmp_pm3$PRODUCT_ID)
names(pdid)[1] <- "PRODUCT_ID"
pdid <- left_join(pdid,product,by="PRODUCT_ID")

pm3 <- rbind(tmp_pm3,pdid)

