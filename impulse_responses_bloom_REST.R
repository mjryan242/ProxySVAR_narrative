library(dplyr)
library(tidyr)
library(tidyverse)
library(tidytext)
library(ggplot2)

setwd("C:\\Users\\mryan\\Desktop\\RQ2_proxySVAR\\forpaper")



SW <- read.csv(file = 'SVARIV_IR.csv')
Bloom <- read.csv(file = 'SVAR_IV_bloom.csv')
Periods<-seq(0,19, by=1)
###################################################




################################

ir<- function(i,name) {
ImpulseR<-as.data.frame(cbind(SW[1:20 ,i],(Bloom[1:20 ,i+6]),(Bloom[1:20 ,i+12]),(Bloom[1:20 ,i]),Periods))

var<-paste0(name)
colnames(ImpulseR)<-c("Proxy","L","H","Bloom","Periods" )

chart<-
      ggplot(ImpulseR, aes(x=Periods, y=Proxy,group=1)) +
      geom_line(size=1.0,colour="black", linetype = "dotted") + 

      scale_x_continuous('Periods') +   
     scale_y_continuous('Response') +
      geom_ribbon(aes(ymin = L, 
      ymax=H), colour="gray", fill="gray",alpha=0.1)+
       geom_hline(yintercept=0)+ggtitle(paste0("Response of ",var,"\n"))+
 geom_line(aes(y = Bloom), color = "black", linetype = "solid") +
theme(text = element_text(size=6))+ theme_bw()+ theme( axis.line.x = element_line(colour = 'gray', size = 0.15),text = element_text(size=6),panel.grid.major = element_blank(), panel.grid.minor = element_blank())
 print(chart)
name1<-paste0(name)
assign(paste0("chart",substr(name1,1,3)), chart, envir = .GlobalEnv)
}
ir(2,"Share prices")
ir(3,"Output gap")
ir(4,"Inflation")
ir(5,"Nominal IR")
ir(6,"RER")
ir(1,"Uncertainty")
chartOut

library(gridExtra)
IR_graphs_bloom<-grid.arrange(chartUnc, chartSha, chartOut,  chartInf,chartNom, chartRER, nrow = 3)

ggsave(filename="IR_graphs_bloom_REST.pdf", plot=IR_graphs_bloom, width = 10, height = 10,device=cairo_pdf, units = "cm")

