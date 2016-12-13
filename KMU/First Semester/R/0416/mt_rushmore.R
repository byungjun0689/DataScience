setwd("d://RStudy/20160416/")

install.packages("jpeg")
library(jpeg)
mtrushBMP <- readJPEG("mount-rushmore-national-memorial.jpg")
str(mtrushBMP)
class(mtrushBMP)
dim(mtrushBMP)
range(mtrushBMP[1, ,1])
max(mtrushBMP)
min(mtrushBMP)

head(mtrushBMP)

View(mtrushBMP)

mtrushBMP[100:200,100:200,1] <- 50  # Red   # RGB라는게 3차원 숫자형태로 그림을 표시하는데 1이 R영역, 2가 G영역, 3이 B영역
mtrushBMP[100:200,100:200,2] <- 250  # Green  # 색상표와 다름 RGB순서가 다를 수도 있고 뭐 의미없음 
mtrushBMP[100:200,100:200,3] <- 250  # Blue


# you can save touched image file by way of target keyword of writeJPEG function

writeJPEG(mtrushBMP, target="a.jpg")

for (i in 1:dim(mtrushBMP)[1]) {
  if ( i %% 50 == 0) {
    mtrushBMP[i,,1] <- 1
    mtrushBMP[i,,2] <- 1
    mtrushBMP[i,,3] <- 1
  }
}

writeJPEG(mtrushBMP,target="mtrushJPG2.jpg")

for (y in 1:dim(mtrushBMP)[2]) {
  if ( y %% 50 == 0) {
    mtrushBMP[,y,1] <- 1
    mtrushBMP[,y,2] <- 1
    mtrushBMP[,y,3] <- 1
  }
}

writeJPEG(mtrushBMP,target="mtrushJPG_y.jpg")

