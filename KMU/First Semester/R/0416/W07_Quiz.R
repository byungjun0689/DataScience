paste(c("X","Y"), 1:10, sep="")

c("x","y")[rep(c(1,2,2,1), times=4)]

fruit <- c(5, 10, 1, 20)
names(fruit) <- c("orange", "banana", "apple", "peach")
lunch <- fruit[c("apple","orange")]
lunch

c("NA", NA, NaN)

is.na(c("NA", NA, NaN))
is.na(NULL)
is.na("NA")
is.na(NA)
is.na(NaN)
is.na(c("NA", NA, NaN))
is.na(c(NaN, NA))
c(NaN, NA)

x <- 1:10
which(x[x>5])


x <- matrix(1:16, 4)
x
names(x) <- paste("x",1:5, sep="")
names(x)
length(names(x))
colnames(x) <- paste("x",1:5, sep="")
rownames(x) <- paste("y",1:4, sep="")
colSums(x)
rowSums(x)

x
solve(x)
?matrix
?dimnames

myArray <- array(60:1, dim=c(4,5,3)) 
myArray

shortArray <- array(60:1, dim=c(4,5,2)) 
shortArray

fourdimArray <- array(1:120, dim=c(4,5,3,2)) 
fourdimArray

myMatrix <- matrix(1:19, nrow=4, ncol=5)
myMatrix

letterVector <- LETTERS
smallcaseVector <- letters
letterMatrix <- cbind(letterVector, smallcaseVector)
class(letterMatrix)

rowLetterMatrix <- rbind(letterVector, smallcaseVector)
class(rowLetterMatrix)
rowLetterMatrix
