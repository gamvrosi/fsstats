library(fitdistrplus)
brk <- as.numeric(argv[1])
options <- argv[2:length(argv)]
cols <- c("blue", "red", "green", "orange", "skyblue", "violet", "darkblue", "black")
pdf(file="fittingMSR.pdf")
for(i in 1:length(options)) {
  print(options[i])
  data = read.table(options[i])
  x <- data[ ,1]
  print(length(x))
  x2 <- x[which(x > brk)]
  print(length(x2))
  Fn <- fitdist(x2, 'lnorm')
  print(summary(Fn))
  plot(Fn, col=cols[i%%length(cols)])
  Fn <- fitdist(x2, 'weibull')
  print(summary(Fn))
  plot(Fn, col=cols[i%%length(cols)])
}
dev.off()
