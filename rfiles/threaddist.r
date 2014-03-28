require(graphics)
data = read.table("../data/threaddist.txt")
x <- data[, 2]
Fn <- ecdf(x)
summary(Fn)
e <- sort(x,decreasing=TRUE)
ce <- e/sum(e)
cedist <- ce
for (i in 2:length(ce)) {
    cedist[i] <- cedist[i-1] + cedist[i]
}
sdata = data[order(data$V2, decreasing=TRUE),]
brk = 20 #should be picked from distribution
top = sdata[1:brk, ]
