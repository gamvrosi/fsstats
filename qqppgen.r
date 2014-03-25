qqplot <- function (x, y, plot.it = TRUE, xlab = deparse(substitute(x)), 
          ylab = deparse(substitute(y)), ...)
{
  # Let X[i] represent the i-th order statistic (the observation
  # that is observed to be the i-th highest value)
  # Let F be the CDF of the proposed distribution Y
  #
  # Y-axis: plot all the X[i] in _order_
  # X-axis: plot F^-1[(i-1/2)/n] = Quantile(X,p) = x[p * samples(X)]
  #   Q: Why do we subtract 0.5 in the nominator?
  #   A: For each theoretical quantile, we want the i-th ordered sample value.
  #      We subtract the quantity 0.5 so that we are exactly in the middle of
  #      the interval (i-1)/n and i/n. However, we'll stick with i/n here.
  # 
  # Note: Q-Q Plots tend to magnify deviations from the proposed distribution
  # on the tails
  #
  # How to read a Q-Q plot
  # ======================
  # Description of Point Pattern             => Possible Interpretation
  #
  # "all but a few points fall on a line"    => outliers in the data
  # "left end of pattern is below the line;
  #  right end of pattern is above the line" => long tails at both ends of
  #                                             the data distribution
  # "left end of pattern is above the line;
  #  right end of pattern is below the line" => short tails at both ends of
  #                                             the data distribution
  # "curved pattern with slope increasing
  #  from left to right"                     => data distribution is skewed to
  #                                             the right
  # "curved pattern with slope decreasing
  #  from left to right"                     => data distribution is skewed to
  #                                             the left
  # "staircase pattern (plateaus and gaps)   => data have been rounded or are
  #                                             discrete

  sx <- sort(x)
  sy <- sort(y)
  lenx <- length(sx)
  leny <- length(sy)

  # Approximate values at the requested points
  if (leny < lenx)
    sx <- approx(1L:lenx, sx, n = leny)$y
  if (leny > lenx)
    sy <- approx(1L:leny, sy, n = lenx)$y

  # TODO: beautify plotting code
  if (plot.it) 
    plot(sx, sy, xlab = xlab, ylab = ylab, ...)
  invisible(list(x = sx, y = sy))
}

ppoints <- function (n, a = ifelse(n <= 10, 3/8, 1/2)) 
{
  if (length(n) > 1L) 
    n <- length(n)
  if (n > 0) 
    (1L:n - a)/(n + 1 - 2 * a)
  else numeric()
}

ppplot <- function(x, pdist=pnorm, xlab=deparse(substitute(x)),
                   ylab="Probability", line=TRUE, lwd=2, pch=3, cex=0.7,
                   cex.lab=1, ...)
{
  DOTARGS <- as.list(substitute(list(...)))[-1]
  DOTARGS <- paste(names(DOTARGS), DOTARGS, sep="=", collapse=", ")
  
  PNAME <- deparse(substitute(pdist))
  pdist <- match.fun(pdist)
  
  # Let X[i] represent the i-th order statistic (the observation
  # that is observed to be the i-th highest value)
  # Let F be the CDF of the proposed distribution Y
  #  
  # Y-axis: estimated cumulative proportions of your empirical distribution are
  #   plotted. These are the ranks of your data transformed into proportions by
  #   one of the methods: rankit (most universal, and preferable for beta), Blom,
  #   Tukey or Van der Waerden. Basically, we plot (i-0.5)/n (which is found by
  #   using ppoints)
  y <- ppoints(length(x))
  # X-axis: expected cumulative probabilities of the theoretical distribution
  #   of your choice, corresponding to your observed values. Basically, we
  #   plot all the F[X[i]]
  pprobs <- pdist(sort(x), mean(x), sd(x), ...)
  # If the plotted points lie on X=Y diagonal, that means that the expected
  # theoretical probs and the estimated observed probs coincide which means that
  # your data follows the theoretical distribution.
  #
  # P-P plot addresses basically the same question as Q-Q plot, P-P being somewhat
  # more sensitive to discrepancies in the middle part of the distribution, Q-Q
  # in tails. Q-Q is generally preferred in the research community.
  
  # Plot the stuff
  plot(y, pprobs, axes=FALSE, type="n", xlab=xlab, ylab=ylab, xlim=c(0,1),
       ylim=c(0,1), cex.lab=cex.lab)
  box()
  
  probs <- seq(0,1,by=0.1) 
  axis(1)
  axis(2)

  # Add points to plot
  points(y, pprobs, pch=pch, cex=cex)
  
  if(line){
    # Draw a line from the 25th to the 75th quantile for comparison
    yl <- quantile(y, c(0.25, 0.75))
    pl <- quantile(pprobs, c(0.25, 0.75))
    slope <- diff(pl)/diff(yl)
    int <- pl[1] - slope * yl[1]
    abline(int, slope, col=1, lwd=lwd)
  }
}

