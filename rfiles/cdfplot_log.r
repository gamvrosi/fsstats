lidx <- 1;
leg.lab <- NULL;
leg.col <- c("red","red","red","blue4","blue4","blue4","olivedrab4","olivedrab4","olivedrab4","goldenrod2");
leg.lty <- c("solid","solid","solid","solid","solid","solid","solid","solid","solid","solid");
leg.lwd <- c(2,2,2,2,2,2,2,2,2,2);

name <- argv[1];
options <- argv[2:length(argv)]
counter = 0;
#max = 0
#min = 10000000000000
#
#count = 0
#for(i in 1:length(options)) {
#    data = read.table(options[i])
#    x <- data[ ,1]
#    x <- x [! x %in% c(0,0.0)]
#    if(max(x) > max) {
#        max = max(x)
#    }
#    if(min(x) < min) {
#        min = min(x)
#    }
#
#    if(length(x) > count) {
#        count = length(x)

name <- argv[1];
options <- argv[2:length(argv)]
counter = 0;
#max = 0
#min = 10000000000000
#
#count = 0
#for(i in 1:length(options)) {
#    data = read.table(options[i])
#    x <- data[ ,1]
#    x <- x [! x %in% c(0,0.0)]
#    if(max(x) > max) {
#        max = max(x)
#    }
#    if(min(x) < min) {
#        min = min(x)
#    }
#
#    if(length(x) > count) {
#        count = length(x)
#    }
#}
#

pdf(file=name)
plot(NULL, NULL, xlim=c(0.001,1), ylim=c(0,1), xlab="",ylab="", axes='F', log='x');

xtix <- c(0.0001);
for (i in 1:1000)
  xtix <- c(xtix, 2*xtix[i]);


axis(2, las=1, at=seq(0, 1, by=0.05), cex.axis=.7);
axis(1, las=1, at=xtix, cex.axis=.7);
mtext(text="Idle periods (us)",side=1,line=2.5)
mtext(text="Percentage of total time",side=2,line=2.5)
abline(h=seq(0, 1, by=0.05), col="gray50", lty=3, lwd=.7);
abline(v=xtix, col="gray50", lty=3, lwd=.7);

for (trace in options) {
  ffreqs <- read.csv(trace, header=FALSE);
  data <- as.matrix(ffreqs);
  rm(ffreqs);
  
  cat("- Computing CDF... ");
  sorted <- sort(data);
  cat("[sorted] ");
  samples <- length(sorted);
  total <- sum(as.numeric(sorted));
  frx <- seq(0.001, 1, 0.001);
  fry <- NULL;

  for (q in frx) {
    idx <- ceiling(q * samples);
    fry <- c(fry, sum(as.numeric(sorted[1:idx])) / total);
  }
  

  fry <- 1 - rev(fry);
  cat(" Done.\n");

  print(length(fry))
  lines(x=frx, y=fry, type='l', lty=leg.lty[lidx], lwd=leg.lwd[lidx], col=leg.col[lidx]);
  leg.lab <- c(leg.lab, paste("Total idle period = ", total, sep=""));

    lidx <- lidx + 1;
}

legend("bottomright","(x,y)",leg.lab, cex=1.0, col=leg.col, lty=leg.lty, lwd=leg.lwd);

dev.off()
cat(paste("Done\n\n"));
