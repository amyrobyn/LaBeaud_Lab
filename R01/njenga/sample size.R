#k01
#install.packages("pwr")
library("pwr")

# households  -------------------------------------------------------
#Based on estimates of 45.4% care seeking rates (DHS stats compiler), to estimate the care seeking rates with 80% power 
#and 95% confidence, we will survey xx houses in each catchment area.
oneproportiontest<-pwr.p.test(h=0.454,sig.level=0.05,power=0.8)

# mosquito samples -------------------------------------------------------
#580 pools of 5-50 mosquito per site per season will achieve 80% power, 95% confidence 
#to determine if the infection rate is different from the expected mosquito infection rates estimates of 38.55 infected mosquitoes per 1000 mosquitoes(74). 
oneproportiontest<-pwr.p.test(h=0.03855,sig.level=0.05,power=0.8)
(oneproportiontest$n/50 + oneproportiontest$n/5)/2


#690 pools of 50 per site per season are required per site per clinic to detect a 5% difference across site and season. 
pwr.2p.test<-pwr.2p.test(h=0.05,sig.level=0.05,power=0.8)
(pwr.2p.test$n/50 + pwr.2p.test$n/5)/2



# samples at clinic -------------------------------------------------------
#sample size for two proportion test of equal n.
  pwr.2p.test(h=0.20,sig.level=0.05,power=0.8)
  pwr.2p.test(n=1200,sig.level=0.05, h=0.11)
  pwr.2p.test(n=1200,sig.level=0.05,power=0.8)
  pwr.2p.test(h=0.11,sig.level=0.05,power=0.8)
  pwr.2p.test(h=0.05,sig.level=0.05,power=0.8)
  #one proportion test.
  pwr.p.test(h=0.244,sig.level=0.05/2,power=0.8)
  160*2
  
640+1600+1600+848+8480+3840+3000
  
#two proportion different size
  pwr.2p2n.test(n1=1200, sig.level=0.05, n2=1200, power=.8, h1= .11)
  
  power.prop.test(p1=0.12, p2=0.15, power=0.8, sig.level=0.05)#sample size for two proportion test of equal n.
  pwr.2p.test(h=0.20,sig.level=0.05,power=0.8)
  pwr.2p.test(n=1200,sig.level=0.05, h=0.11)
  pwr.2p.test(n=1200,sig.level=0.05,power=0.8)
  pwr.2p.test(h=0.11,sig.level=0.05,power=0.8)
  pwr.2p.test(h=0.05,sig.level=0.05,power=0.8)
  #one proportion test.
  pwr.p.test(h=0.244,sig.level=0.05,power=0.8)
  #two proportion different size
  pwr.2p2n.test(n1=1200, sig.level=0.05, n2=1200, power=.8, h1= .11)
  
  power.prop.test(p1=0.12, p2=0.15, power=0.8, sig.level=0.05)
  
  

  # range of h
  h <- seq(.1,.2,.01)
  nr <- length(h)
  
  # power values
  p <- seq(.4,.9,.1)
  np <- length(p)
  
  
  # obtain sample sizes
  samsize <- array(numeric(nr*np), dim=c(nr,np))
  for (i in 1:np){
    for (j in 1:nr){
      result <- pwr.2p.test(h = h[j],
                           sig.level = .05, 
                           power = p[i],
                           alternative = "two.sided")
      samsize[j,i] <- ceiling(result$n)
    }  # set up graph
    windows(width=10, height=8)
  xrange <- range(h)
  yrange <- round(range(samsize))
  colors <- rainbow(length(p))
  plot(xrange, yrange, type="n",
       xlab="Effect Size (h)",
       ylab="Sample Size (n)" )
  
  # add power curves
  for (i in 1:np){
    lines(h, samsize[,i], type="l", lwd=2, col=colors[i])
  }
  
  # add annotation (grid lines, title, legend) 
  abline(v=0, h=seq(0,yrange[2],50), lty=2, col="grey89")
  abline(h=0, v=seq(xrange[1],xrange[2],.02), lty=2,
         col="grey89")
  title("Sample Size Estimation for Proportion Studies\n
        Sig=0.05 (Two-tailed)")
  legend("topright", title="Power", as.character(p),
         fill=colors)
  }
  
  
  