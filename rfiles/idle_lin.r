counts <- c("../data/idle/interivals_msr1",
			"../data/idle/interivals_msr2",
            "../data/idle/interivals_msr3");

doload <- FALSE;
doload_fb <- FALSE;
docdfs <- FALSE;
docdfs_fb <- FALSE;
# dofit <- FALSE;
dofbench <- FALSE;
doplot <- TRUE;
doplot_fb <- TRUE;

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

# Load filebench data
if (doload_fb) {
	cat("Loading and sorting filebench data... ");
	hotpcent <- c("25", "50", "75", "100");
	utils <- seq(0, 20, 10);
	fdata <- list();
	for (h in hotpcent) {
		for (u in utils) {
			eval(parse(text=paste("fdata[[length(fdata) + 1]] <- ",
								  "sort(as.vector(read.table(\"../data/fbench/wsv_h",
								  h, "_u", u, "_xx_idles.dat\")[,1]))",
								  sep="")))
			tmp <- fdata[[length(fdata)]]
			tmp <- tmp[which(tmp < 10.0)]
			fdata[[length(fdata)]] <- tmp
		}
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
  	total <- sum(as.numeric(data[[i]]));
    cat(paste("[",i,"] ", sep=""));
    
    ecdfs[[i]] <- c(0);
    pidx <- 1
    psum <- 0
    for (q in frx) {
      if (q) {
        idx <- ceiling(q * samples);
        psum <- psum + sum(as.numeric(data[[i]][pidx:idx]))
        ecdfs[[i]] <- c(ecdfs[[i]], psum / total);
        pidx <- idx+1
      }
    }
    ecdfs[[i]] <- 1 - rev(ecdfs[[i]]);
  }
  cat(" Done.\n");
}

# Compute filebench CDFs
if (docdfs_fb) {
	frx <- seq(0, 1, 0.001);
	
	cat("Computing CDFs... ");
	fecdfs <- list();
	for (i in seq(1, length(fdata))) {
		samples <- length(fdata[[i]]);
		total <- sum(as.numeric(fdata[[i]]));
		cat(paste("[",i,"] ", sep=""));
		
		fecdfs[[i]] <- c(0);
		pidx <- 1
		psum <- 0
		for (q in frx) {
			if (q) {
				idx <- ceiling(q * samples);
				psum <- psum + sum(as.numeric(fdata[[i]][pidx:idx]))
				fecdfs[[i]] <- c(fecdfs[[i]], psum / total);
				pidx <- idx+1
			}
		}
		fecdfs[[i]] <- 1 - rev(fecdfs[[i]]);
	}
	cat(" Done.\n");
}

# # Fit distribution, and plot generated data
# if (dofit) {
#   frx <- seq(0, 1, 0.001);
# 
# 	cat ("Computing fitted CDFs... ");
# 	fobjs <- list();
# 	fdata <- list();
# 	fcdfs <- list();
# 	for (i in seq(1, length(data))) {
# 		cat(paste("[",i," (fit) ", sep=""));
# 		fobjs[[i]] <- fitdistr(data[[i]], dgamma, list(shape=1, rate=0.1),
# 							   lower=0.01);
# 
# 		cat(paste("(dens) ", sep=""));
# 		fdata[[i]] <- dgamma(min(data[[i]]):max(data[[i]]),
# 							 shape=fobjs[[i]]$estimate["shape"],
# 							 rate=fobjs[[i]]$estimate["rate"]);
# 		
# 		samples <- length(fdata[[i]]);
# 		total <- sum(fdata[[i]]);
# 		
# 		cat(paste("(cdfs)]", sep=""));
# 		fcdfs[[i]] <- c(0);
# 		for (q in frx) {
# 			if (q) {
# 				idx <- ceiling(q * samples);
# 				fcdfs[[i]] <- c(fcdfs[[i]], sum(fdata[[i]][1:idx]) / total);
# 			}
# 		}
# 		
# 		fcdfs[[i]] <- 1 - rev(fcdfs[[i]]);
# 	}
# 	cat(" Done.\n");
# }

if (dofbench) {
  histbs <- 10;
  #frx <- seq(0, 1, 0.001);
  
  cat("Printing histograms in filebench format:\n");
  for (i in seq(1, length(data))) {
    cat(paste("define randvar name=$name", i, ", type=tabular, min=",
              min(data[[i]]), ", round=1, randtable={\n", sep=""));
    
    # We assume that the data is _sorted_
    samples <- length(ecdfs[[i]]);
    total <- sum(as.numeric(ecdfs[[i]]));
    for (b in seq(1, histbs)) {
      idx <- ceiling((b/histbs) * samples);
      pidx <- floor(((b-1)/histbs) * samples) + 1;
      cat(paste("  {", ceiling(100/histbs), ",",
                floor(ecdfs[[i]][pidx]*100), ",",
                floor(ecdfs[[i]][idx]*100), "}", sep=""));
      if (b != histbs)
        cat(",");
      cat("\n");
    }
    cat("}\n");
  }
}

# Plot the CDFs
xstep <- 0.05;
ystep <- 0.05;

llabels <- NULL;
lcolors <- c("red","blue4","olivedrab4"); #,"goldenrod2");
ltypes <- c("solid","solid","solid","solid");
lwidths <- c(2,2,2,2);

if (doplot)
  pdf(file="busyness_lin.pdf");

plot(NULL, NULL, xlim=c(0,1), ylim=c(0,1), xlab="", ylab="", axes='F');
xtix <- seq(0,1, by=xstep)
axis(2, las=1, at=seq(0, 1, by=ystep), cex.axis=.7);
axis(1, las=1, at=xtix, cex.axis=.7);
mtext(text="Fraction of total idle time", side=1, line=2.5)
mtext(text="Fraction of idle periods", side=2, line=2.5)
abline(h=seq(0, 1, by=ystep), col="gray50", lty=3, lwd=.7);
abline(v=xtix, col="gray50", lty=3, lwd=.7);

cat("Plotting CDFs... ");
for (i in seq(1, length(ecdfs))) {
  lines(x=frx, y=ecdfs[[i]], type='l', lty=ltypes[i], lwd=lwidths[i],
        col=lcolors[i]);
  # 	lines(x=frx, y=fcdfs[[i]], type='l', lty="dashed", lwd=lwidths[i],
  # 		  col=lcolors[i]);
  # llabels <- c(llabels, paste("Total idle period (us) = ", sum(as.numeric(data[[i]])), sep=""));
  llabels <- c(llabels, paste("MSR trace #", i, sep=""));
}

if (doplot_fb) {
	for (i in seq(1, length(fecdfs))) {
		lines(x=frx, y=fecdfs[[i]], type='l', lty="solid", lwd=2, col="black");
	}
	llabels <- c(llabels, paste("Filebench runs (sample)", sep=""));
	lcolors <- c(lcolors, "black");
	lwidths <- c(lwidths, 2);
	ltypes <- c(ltypes, "solid");
}

legend("bottomright", "(x,y)", llabels, cex=1.0, col=lcolors, lty=ltypes,
       lwd=lwidths);

if (doplot)
  dev.off();
