#histograms

for (i in list) { # Loop over loop.vector
  
  # store data in column.i as x
  x <- df[,i]
  
  pdf(paste("test1",i,".pdf",sep=""))
  
  # Plot histogram of x
  hist(x,
       main = paste("Histogram", i),
       xlab = "Scores", 
       breaks=110)
  dev.off()
  
}
