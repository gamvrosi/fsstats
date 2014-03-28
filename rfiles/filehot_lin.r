lidx <- 1;
leg.lab <- NULL;
leg.col <- c("red","blue4","olivedrab4","goldenrod2");
leg.lty <- c("solid","solid","solid","solid");
leg.lwd <- c(2,2,2,2);

pdf(file="filehot_lin.pdf")

plot(NULL, NULL, xlim=c(0,1), ylim=c(0,1), xlab="",ylab="", axes='F');

xtix <- seq(0,1, by=0.05)

axis(2, las=1, at=seq(0, 1, by=0.05), cex.axis=.7);
axis(1, las=1, at=xtix, cex.axis=.7);
mtext(text="Fraction of files",side=1,line=2.5)
mtext(text="Fraction of accesses",side=2,line=2.5)
abline(h=seq(0, 1, by=0.05), col="gray50", lty=3, lwd=.7);
abline(v=xtix, col="gray50", lty=3, lwd=.7);

for (trace in c("~/git/fsstats/filehot1.counts", "~/git/fsstats/filehot2.counts", "~/git/fsstats/filehot3.counts")) {
  ffreqs <- read.csv(trace, header=FALSE);
  data <- as.matrix(ffreqs);
  rm(ffreqs);
  
  cat("- Computing CDF... ");
  sorted <- sort(data);
  cat("[sorted] ");
  samples <- length(sorted);
  total <- sum(sorted);
  frx <- seq(0, 1, 0.001);
  fry <- NULL;
  for (q in frx) {
    idx <- ceiling(q * samples);
    fry <- c(fry, sum(sorted[1:idx]) / total);
  }
  
  fry <- 1 - rev(fry);
  cat(" Done.\n");

  lines(x=frx, y=fry, type='l', lty=leg.lty[lidx], lwd=leg.lwd[lidx], col=leg.col[lidx]);
  leg.lab <- c(leg.lab, paste("Total files = ", total, sep=""));
  lidx <- lidx + 1;
}

legend("bottomright","(x,y)",leg.lab, cex=1.0, col=leg.col, lty=leg.lty, lwd=leg.lwd);

dev.off()
cat(paste("Done\n\n"));
