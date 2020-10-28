library(dplyr)
library(tidyr)
library(tidyverse)
library(tidytext)
library(ggplot2)

setwd("C:\\Users\\mryan\\Desktop\\RQ2_proxySVAR\\forpaper")



SW <- read.csv(file = 'SVARIV_IR.csv')
head(SW)


Periods<-seq(0,19, by=1)

ir<- function(i,name) {
ImpulseR<-as.data.frame(cbind(SW[1:20,i ],SW[1:20,i+6 ],SW[1:20,i+12 ],SW[1:20,i+18 ],SW[1:20,i+24 ],Periods))


var<-paste0(name)
colnames(ImpulseR)<-c("Proxy","L_weak","H_weak","L","H","Periods" )

      chart<-
      ggplot(ImpulseR, aes(x=Periods, y=Proxy,group=1)) +
      geom_line(size=1.0,colour="black") + 

      scale_x_continuous('Periods') +   
     scale_y_continuous('Response') +
      geom_ribbon(aes(ymin = L_weak, 
      ymax=H_weak), colour="grey", fill="grey",alpha=0.1)+
       geom_hline(yintercept=0)+ggtitle(paste0(var))+
 geom_line(aes(y = L), color = "black", linetype = "dotted")+
 geom_line(aes(y = H), color = "black", linetype = "dotted")+
theme(text = element_text(size=6))+ theme_bw()+ theme( axis.line.x = element_line(colour = 'gray', size = 0.15),text = element_text(size=6),panel.grid.major = element_blank(), panel.grid.minor = element_blank())
 print(chart)
name1<-paste0(name)
assign(paste0("chart",substr(name1,1,3)), chart, envir = .GlobalEnv)
}
ir(2,"Share prices")
ir(3,"Output gap")
ir(4,"Inflation")
ir(5,"Nominal 10yr Interest Rate")
ir(6,"Real Exchange Rate")
ir(1,"Uncertainty")
chartOut

library(gridExtra)
IR_graphs<-grid.arrange(chartUnc, chartSha, chartOut,  chartInf,chartNom, chartRea, nrow = 3)

ggsave(filename="IR_graphs_myproxy.pdf", plot=IR_graphs, width = 10, height = 10,device=cairo_pdf, units = "cm")

