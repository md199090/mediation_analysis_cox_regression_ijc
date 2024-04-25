install.packages('mma')
install.packages("readstata13")

library(tidyverse)
library(readstata13)
library(mma)
library(foreign)
library(haven)
library(dplyr)
library(ggplot2)

class(data)
str(data)

##data <- read_dta("C:\\Users\lung_2018_forR9.dta")
data <- read.dta13("lung_2018_forR9.dta")
names(data)

pred=data[,3]
status<-data$event
y=Surv(data$fu365days, status)

x6=data[,c(7:12)] 
x <- list(x6)

# Create an empty list to store the results
temp.cox <- vector("list", length(x))

library(mma)
x13.mma<-mma(x6,y,pred,contmed = 1, binmed = c(2:4), binref = c(0,0,0),alpha = 1, alpha2 = 1, n = 100 , n2 = 10, type = "lp" ) 


tiff(paste0("temp.coxp_al1.tiff"))
print(summary(x13.mma))
dev.off()

pdf(paste0("temp.coxp_al1.pdf"))
print(summary(x13.mma))
dev.off()

tiff(paste0("temp.coxRRp_al1.tiff"))
print(summary(x13.mma, RE=T))
dev.off()

pdf(paste0("temp.coxRRp_al1.pdf"))
print(summary(x13.mma, RE=T))
dev.off()

#df<-summary((temp.cox$a.binx$estimation))
write.table(temp.cox$a.binx$estimation, file = paste0("summary.txt"))
write.table(temp.cox$a.binx$estimation$ie, file = paste0("summary.txt"), append = TRUE)
write.table(temp.cox$a.binx$bootsresults$ie$pred, file = paste0("summary.txt"), append = TRUE)
write.table(temp.cox$a.binx$bootsresults$ie, file = paste0("summary.txt"), append = TRUE)
write.table(temp.cox$a.binx$bootsresults$te, file = paste0("summary.txt"), append = TRUE)
write.table(temp.cox$a.binx$bootsresults$de, file = paste0("summary.txt"), append = TRUE)