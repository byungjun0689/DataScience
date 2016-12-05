install.packages("fields")

library(kohonen)
library(RColorBrewer) # to use brewer.pal
library(fields) # to use designer.colors
install.packages("fields")
par(mfrow=c(1,1))
Hexagon <- function (x, y, unitcell = 1, col = col) {
  polygon(c(x, x, x + unitcell/2, x + unitcell, x + unitcell, 
            x + unitcell/2), c(y + unitcell * 0.125, 
                               y + unitcell * 0.875, 
                               y + unitcell * 1.125, 
                               y + unitcell * 0.875, 
                               y + unitcell * 0.125, 
                               y - unitcell * 0.125), 
          col = col, border=NA)
}

cdata <- read.delim("Cluster.txt", stringsAsFactors=FALSE)
cdata.n <- scale(subset(cdata, select=-c(ID)))

set.seed(1)
# 3x3을 만들겠다 => somgrid(3,3)
sm <- som(data = cdata.n, grid = somgrid(10, 10, "rectangular"))
str(sm)
sm$codes
plot(sm)
plot(sm,type="counts")
plot(sm,type="quality")


k = 6
somClusters <- kmeans(sm$codes, centers = k)



plot(0, 0, type = "n", axes = FALSE, xlim = c(0,sm$grid$xdim), ylim = c(0,sm$grid$ydim), xlab = "", ylab = "", asp = 1)
ColRamp <- rev(designer.colors(n=k, col=brewer.pal(k,"Set1")))
ColorCode <- rep("#FFFFFF", length(somClusters$cluster))
for (i in 1:length(somClusters$cluster))
  ColorCode[i] <- ColRamp[somClusters$cluster[i]]
offset <- 0.5
for (row in 1:sm$grid$ydim) {
  for (column in 0:(sm$grid$xdim-1))
    Hexagon(column + offset, row - 1, col = ColorCode[row + sm$grid$ydim * column])
  offset <- ifelse(offset, 0, 0.5)
}