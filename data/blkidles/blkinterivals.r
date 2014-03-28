options <- argv
for(i in 1:length(options)) {
	data = read.table(options[i])
	x <- data[, 1]
	Fn <- ecdf(x)
	tt <-seq(0,100000, by=10)
	summary(Fn)
	pdf(file=paste("pdfs/blk_interivals", paste(options[i], ".pdf", sep=""), sep="_"))
	plot(Fn)
	plot(Fn(tt))
	dev.off()
}
