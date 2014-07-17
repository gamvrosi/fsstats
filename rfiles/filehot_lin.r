counts <- c("../data/filehot1.counts", "../data/filehot2.counts",
			"../data/filehot3.counts");

doload <- FALSE;
docdfs <- FALSE;
doplot <- FALSE;

# Load and sort data
if (doload) {
	cat("Loading and sorting data... \n");
	data <- list();
	for (f in counts) {
		cat(paste("  [", f, "]\n", sep=""));
		data[[length(data)+1]] <- sort(as.matrix(read.csv(f, header=FALSE)));
	}
	cat(" Done.\n");
}

# Compute CDFs
if (docdfs) {
	frx <- seq(0, 1, 0.001);
	
	cat("Computing CDFs... ");
	ecdfs <- list();
	for (i in seq(1, length(data))) {
		samples <- length(data[[i]]);
		total <- sum(data[[i]]);
		cat(paste("[",i,"] ", sep=""));
		
		ecdfs[[i]] <- c(0);
		for (q in frx) {
			if (q) {
				idx <- ceiling(q * samples);
				ecdfs[[i]] <- c(ecdfs[[i]], sum(data[[i]][1:idx]) / total);
			}
		}
		
		ecdfs[[i]] <- 1 - rev(ecdfs[[i]]);
	}
	cat(" Done.\n");
}

# Plot the CDFs
xstep <- 0.05;
ystep <- 0.05;
	
llabels <- NULL;
lcolors <- c("red","blue4","olivedrab4","goldenrod2");
ltypes <- c("solid","solid","solid","solid");
lwidths <- c(2,2,2,2);

if (doplot)
	pdf(file="filehot_lin.pdf");
	
plot(NULL, NULL, xlim=c(0,1), ylim=c(0,1), xlab="", ylab="", axes='F');
xtix <- seq(0,1, by=xstep)
axis(2, las=1, at=seq(0, 1, by=ystep), cex.axis=.7);
axis(1, las=1, at=xtix, cex.axis=.7);
mtext(text="Fraction of files", side=1, line=2.5)
mtext(text="Fraction of accesses", side=2, line=2.5)
abline(h=seq(0, 1, by=ystep), col="gray50", lty=3, lwd=.7);
abline(v=xtix, col="gray50", lty=3, lwd=.7);
	
cat("Plotting CDFs... ");
for (i in seq(1, length(ecdfs))) {
	lines(x=frx, y=ecdfs[[i]], type='l', lty=ltypes[i], lwd=lwidths[i],
		  col=lcolors[i]);
	llabels <- c(llabels, paste("Total files = ", sum(data[[i]]), sep=""));
}
	
legend("bottomright", "(x,y)", llabels, cex=1.0, col=lcolors, lty=ltypes,
	   lwd=lwidths);

if (doplot)
	dev.off();

# fitdistr(data[[1]], dgamma, list(shape=1, rate=0.1), lower=0.01)

