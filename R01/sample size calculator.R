#sample size for zika follow up 2-5
#internda
library(pwr)

samplessize<-pwr.t.test(sig.level = 0.05, power = 0.80, d=-0.45,alternative = "less")

plot(samplessize)

# 1 -----------------------------------------------------------------------



nvals <- seq(100, 1000, length.out=200)
powvals <- sapply(nvals, function (x) power.t.test(n=x, delta=1)$power)
plot(nvals, powvals, xlab="n", ylab="power",
     main="Power curve for\n t-test with delta = 1",
     lwd=2, col="red", type="l")

deltas <- c(0.8, 0.4, 0.2)
plot(nvals, seq(0,1, length.out=length(nvals)), xlab="n", ylab="power",
     main="Power Curve for\nt-test with varying delta", type="n")
for (i in 1:3) {
  powvals <- sapply(nvals, function (x) power.t.test(n=x, delta=deltas[i])$power)
  lines(nvals, powvals, lwd=2, col=i)
}
legend("bottom", lwd=1, col=1:3, legend=c("0.8", "0.4", "0.2"),cex=.8,horiz=T,bg=NULL,bty="n")

# 2 -----------------------------------------------------------------------


install.packages("pwr2")
library(pwr2)

## Example 1
n <- seq(2, 30, by=4)
f <- 0.5
pwr.plot(n=n, k=5, f=f, alpha=0.05)

## Example 2
n <- 20
f <- seq(0.1, 1.0, length.out=10)
pwr.plot(n=n, k=5, f=f, alpha=0.05)

## Example 3
n <- seq(50, 1000, by=10)
f <- seq(0.1, .5, length.out=5)

pwr.plot(n=n, k=2, f=f, alpha=0.05)


# 3 -----------------------------------------------------------------------

# Plot sample size curves for detecting correlations of
# various sizes.

library(pwr)

# range of delta
d <- seq(.1,.5,0.01)
nr <- length(d)

# power values
p <-  seq(.7,.9,0.1)
np <- length(p)

# obtain sample sizes
samsize <- array(numeric(nr*np), dim=c(nr,np))
for (i in 1:np){
  for (j in 1:nr){
    result <- pwr.t.test(n = NULL, d = d[j],
                         sig.level = .05, power = p[i],
                         alternative = "greater")
    samsize[j,i] <- ceiling(result$n)
  }
}

# set up graph
xrange <- range(r)
yrange <- round(range(samsize))
colors <- rainbow(length(p))
plot(xrange, yrange, type="n",
     xlab="Cohens effect size (d)",
     ylab="Sample Size (n)" )

# add power curves
for (i in 1:np){
  lines(r, samsize[,i], type="l", lwd=2, col=colors[i])
}

# add annotation (grid lines, title, legend) 
abline(v=0, h=seq(0,yrange[2],50), lty=2, col="grey89")
abline(h=0, v=seq(xrange[1],xrange[2],.02), lty=2,
       col="grey89")
title("Sample Size Estimation for t test Studies\n
      Sig=0.05 (Less than) &  80% power")
legend("topright", lwd=1, col=1:3,fill=colors , as.character(p),cex=.8,horiz=F,bg=NULL,bty="n")
axis(side = 2, at = c(100,200,300,400,500,600,700,800,900))
axis(side = 1, at = c(0.15,0.25,0.35,0.45))


text(x=30,y=80,pos=4,label = "hello")


#power with 4:1 case to control
install.packages("powerAnalysis")
library(powerAnalysis)
power.t(es = 0.3, n = NULL, power = 0.8, sig.level = 0.5, ratio=4,type ="unequal",alternative="two.sided")
power.t(es = 0.3, n = NULL, power = 0.8, sig.level = 0.5, ratio=1,type ="paired",alternative="two.sided")



