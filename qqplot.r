source("~/git/fsstats/qqppgen.r")

lidx <- 1;
leg.lab <- NULL;
leg.col <- c("red","blue4","olivedrab4","goldenrod2","red","blue4","olivedrab4","goldenrod2");
leg.lty <- c("solid","solid","solid","solid", "solid","solid","solid","solid","solid", "solid");
leg.lwd <- c(2,2,2,2,2,2,2,2,2,2);
### FIRST DO CDFS LIN ###################

name <- argv[1];
options <- argv[2:length(argv)]
counter = 0;

print("CDF PLOTTING BEGINS")
print("CDF LINEAR")
pdf(file=name)
plot(NULL, NULL, xlim=c(0,1), ylim=c(0,1), xlab="",ylab="", axes='F');

xtix <- seq(0,1, by=0.05)

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

############## CDF LOG SECTION ########
leg.lab <- NULL;
lidx <- 1;

print("CDF LOG")
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

print("QQ PLOTTING BEGINS")
############ QQ STUFF START HERE
name <- argv[1];
main <- argv[2];
options <- argv[3:length(argv)]
counter = 0;
# 
# gqqplot <- function (x, y, pout = seq(0,1,0.001), plot.it = TRUE, line = TRUE,
#                      xlab = deparse(substitute(x)),
#                      ylab = deparse(substitute(y)), ...)
# {
#   sx <- sort(x)
#   sy <- sort(y)
#   lenx <- length(sx)
#   leny <- length(sy)
#   
#   # Approximate values at the requested points
#   if (leny < lenx)
#     sx <- approx(1L:lenx, sx, n = leny)$y
#   if (leny > lenx)
#     sy <- approx(1L:leny, sy, n = lenx)$y
#   len <- length(sx)
#   sx <- sx[ceiling(pout * len)]
#   sy <- sy[ceiling(pout * len)]
#   
#   # TODO: beautify plotting code
#   if (plot.it) {
#     plot(sx, sy, xlab = "", ylab = "", ...)
#     mtext(text=paste(xlab, " quantiles", sep=""),side=1,line=2.5)
#     mtext(text=paste(ylab, " quantiles", sep=""),side=2,line=2.5)
#     abline(h=(seq(0,1,by=0.1)*max(sy)), col="gray50", lty=3, lwd=.7);
#     abline(v=(seq(0,1,by=0.1)*max(sx)), col="gray50", lty=3, lwd=.7);
#     mtext(text=paste("QQ Plot for ", ylab, sep=""),side=3,line=1);
#     #axis(2, las=1, at=pout*max(sy), cex.axis=.7);
#     #axis(1, las=1, at=pout*max(sx), cex.axis=.7);
#   }
#   
#   if(line)
#     abline(0, 1, col="red", lwd=0.5)
#   invisible(list(x = sx, y = sy))
# }

# Create main x dist to compare to everyone else
###########################
ffreqs <- read.csv(main, header=FALSE);
data <- as.matrix(ffreqs);
rm(ffreqs);

main_x <- data;
############################

# Compare main against all traces in option
for (trace in options) {
  ffreqs <- read.csv(trace, header=FALSE);
  data <- as.matrix(ffreqs);
#   xtix <- c(0.0001);
#   for (i in 1:1000)
#     xtix <- c(xtix, 2*xtix[i]);
#   xtix <- 1 - xtix;
  gqqplot(main_x, data, np=1000, xlab=main, ylab=trace)
  cat(" Done.\n");
  print("Computing Kolmogorov Smirnov value")
  print(trace)
  print(ks.test(main_x, data))
  print(paste("Completed comparison for trace", trace, sep=" "))
  
}

dev.off()
cat(paste("Done\n\n"));

