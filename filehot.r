plot_log <- function(file) {
ffreqs <- read.csv(file, header=FALSE);
data <- as.matrix(ffreqs);
rm(ffreqs);

#print(sum(freqs));

cat("- Calculating fraction of time per fraction of intervals... ");
sorted <- sort(data);
samples <- length(sorted);
total_time <- sum(sorted);
fridle <- seq(0, 1, 0.0001);
frtime <- NULL;
for (q in fridle) { # the fractions of intervals we'll be checking
    fridx <- ceiling(q * samples)
    frtime <- c(frtime, sum(sorted[1:fridx]) / total_time);
}
frtime <- 1 - rev(frtime);
cat(" Done.\n");
line(x=fridle, y=frtime, type='l', lwd=2, col="green",
     axes=FALSE, xlab="", ylab="", log="x");
}

cat("- Plotting… ");
pdf(file="filehot_log.pdf")
plot(NULL, NULL, ylim=c(0,1), xlim=c(0,1),
     axes=FALSE, xlab="", ylab="", log="x");
xtix <- c(0.0001);
for (i in 1:1000)
  xtix <- c(xtix, 2*xtix[i]);
axis(2, las=1, at=seq(0, 1, by=0.05), cex.axis=.7);
axis(1, las=1, at=xtix, cex.axis=.7);
mtext(text=paste("Fraction of files (total = ", total_time, ")", sep=""),side=1,line=2.5)
mtext(text="Fraction of accesses",side=2,line=2.5)
abline(h=seq(0, 1, by=0.05), col="gray50", lty=3, lwd=.7);
abline(v=xtix, col="gray50", lty=3, lwd=.7);

# plot(x=fridle, y=frtime, type='l', lwd=2, col="green",
#      axes=FALSE, xlab="", ylab="", );
# axis(2, las=1, at=seq(0, 1, by=0.05), cex.axis=.7);
# axis(1, las=1, at=seq(0, 1, by=0.05), cex.axis=.7);
# mtext(text=paste("Fraction of files (total = ", total_time, ")", sep=""),side=1,line=2.5)
# mtext(text="Fraction of accesses",side=2,line=2.5)
# abline(h=seq(0, 1, by=0.05), col="gray50", lty=3, lwd=.7);
# abline(v=seq(0, 1, by=0.05), col="gray50", lty=3, lwd=.7);


dev.off()
cat(paste("Done\n\n"));
