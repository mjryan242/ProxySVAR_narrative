
#####load packages
library(dplyr)
library(tidyr)
library(tidyverse)
library(tidytext)
library(ggplot2)
library("textmineR")
library("wordcloud2" )

###figures from the paper as at 8 October

####figure 1: NZ uncertainty index


uncert<-read.csv(file="Measures_FINAL_weighted.csv", header=TRUE, sep=",")
tail(uncert)

df_graph<-uncert


df_graph$Date<-as.Date(df_graph$Date, "%d/%m/%Y")


head(df_graph)


max_var<-max(df_graph$NZL_PC1 , na.rm = TRUE)
plot<-ggplot(df_graph, aes(x=Date, y=NZL_PC1, group=1)) + 
    geom_line() +  
  scale_size(range = c(1, 2), guide="none")+
 ##business cycles taken from Hall and McDermott pg 35 (Recessions based on Classical Business cycles)
 #   annotate("rect", fill = "gray", alpha = 0.5, 
   #     xmin = as.Date("1966-10-01", "%Y-%m-%d") , xmax = as.Date("1967-10-01", "%Y-%m-%d"),
    #    ymin = -Inf, ymax = Inf) +
    annotate("rect", fill = "gray", alpha = 0.5, 
        xmin = as.Date("1976-04-01", "%Y-%m-%d") , xmax = as.Date("1978-01-01", "%Y-%m-%d"),
        ymin = -Inf, ymax = Inf)+
    annotate("rect", fill = "gray", alpha = 0.5, 
        xmin = as.Date("1982-04-01", "%Y-%m-%d") , xmax = as.Date("1983-01-01", "%Y-%m-%d"),
        ymin = -Inf, ymax = Inf)+
    annotate("rect", fill = "gray", alpha = 0.5, 
        xmin = as.Date("1987-10-01", "%Y-%m-%d") , xmax = as.Date("1988-10-01", "%Y-%m-%d"),
        ymin = -Inf, ymax = Inf)+
    annotate("rect", fill = "gray", alpha = 0.5, 
        xmin = as.Date("1990-10-01", "%Y-%m-%d") , xmax = as.Date("1991-04-01", "%Y-%m-%d"),
        ymin = -Inf, ymax = Inf)+
    annotate("rect", fill = "gray", alpha = 0.5, 
        xmin = as.Date("1997-04-01", "%Y-%m-%d") , xmax = as.Date("1998-01-01", "%Y-%m-%d"),
        ymin = -Inf, ymax = Inf)+
    annotate("rect", fill = "gray", alpha = 0.5, 
        xmin = as.Date("2007-10-01", "%Y-%m-%d") , xmax = as.Date("2009-04-01", "%Y-%m-%d"),
        ymin = -Inf, ymax = Inf) +  


#Elections     
geom_vline(aes(xintercept = (as.Date("2017-07-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("2014-07-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("2011-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("2008-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("2005-07-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +

geom_vline(aes(xintercept = (as.Date("2002-07-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1999-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1996-10-10","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1993-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1990-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1987-07-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1984-07-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1981-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1978-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
geom_vline(aes(xintercept = (as.Date("1975-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
#geom_vline(aes(xintercept = (as.Date("1972-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
#geom_vline(aes(xintercept = (as.Date("1969-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +
#geom_vline(aes(xintercept = (as.Date("1966-10-01","%Y-%m-%d"))      ), colour = "grey23", linetype="dotdash") +




scale_x_date(date_breaks = "5 years", date_labels = "%Y-%m" ) + ylab("Index")+
   #     geom_smooth(aes(x=date, y=var))
 theme_bw()+ theme( axis.line.x = element_line(colour = 'gray', size = 0.15),panel.grid.major = element_blank(), panel.grid.minor = element_blank())
print(plot)

ggsave(filename="uncertainty_REST.pdf", plot=plot, width = 15, height = 10,device=cairo_pdf, units = "cm")

####figure 2: counts of uncertainty windows per year

theta_raw<-read.csv(file="theta.csv", header=TRUE, sep=",")
head(theta_raw)  #total number of uncertainty mentions

counts<-theta_raw%>%mutate(year=substr(id,7,10))%>%
group_by(year) %>%
tally()

class(counts$year)

plot_counts<-ggplot(counts, aes(x=year, y=n, group=1)) + 
    geom_line()+ ylab("Window count") + xlab("Year") +
  scale_x_discrete(breaks = seq(1975,2017,by=3 ))+theme_bw()+theme( axis.line.x = element_line(colour = 'gray', size = 0.15),panel.grid.major = element_blank(), panel.grid.minor = element_blank())
 ggsave(filename="uncertainty_counts_REST.pdf", plot=plot_counts, width = 15, height = 10,device=cairo_pdf, units = "cm")
  
###############################################
load(file = "70_topics.rda")
top_terms <- GetTopTerms(phi = m$phi, M = 20)
m$phi[ ,1]
dim(m$phi)
dat<-as.data.frame(top_terms)
top_terms_list<-unique(unlist(dat, use.names=FALSE))
top_terms_list <- top_terms_list[!top_terms_list %in% c("uncertain","uncertainties","uncertainty")]


mm<-as.data.frame(m$phi)
nms<-colnames(mm)
tmm<-as_tibble(cbind(nms,t(mm)))



#economy eg
df<-tmm %>% select("nms","t_41") %>% mutate(t_41=as.numeric(t_41)) %>% arrange(t_41 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 

View(df)


t_41<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )
library("htmlwidgets")
saveWidget(t_41,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_41_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))


#economy eg
df<-tmm %>% select("nms","t_1") %>% mutate(t_1=as.numeric(t_1)) %>% arrange(t_1 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 

View(df)


t_1<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )
library("htmlwidgets")
saveWidget(t_1,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_1_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))
#webshot("tmp.html","fig_1.pdf", delay =5,cliprect = c(100, 5, 200, 200))


#education eg (other)
df<-tmm %>% select("nms","t_6") %>% mutate(t_6=as.numeric(t_6)) %>% arrange(t_6 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 




t_6<-wordcloud2(data=df, size=0.7, color='black', shape='circle' )

saveWidget(t_6,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","t_6_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))


#compliance
df<-tmm %>% select("nms","t_70") %>% mutate(t_70=as.numeric(t_70)) %>% arrange(t_70 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 




t_70<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_70,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_70_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))

###
#additional topics
df<-tmm %>% select("nms","t_25") %>% mutate(t_25=as.numeric(t_25)) %>% arrange(t_25 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 



t_25<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_25,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_t25_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))


df<-tmm %>% select("nms","t_31") %>% mutate(t_31=as.numeric(t_31)) %>% arrange(t_31 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 



t_31<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_31,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_t31_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))

###

df<-tmm %>% select("nms","t_30") %>% mutate(t_30=as.numeric(t_30)) %>% arrange(t_30 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 



t_30<-wordcloud2(data=df, size=0.7, color='random-dark', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_30,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_t_30_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))


df<-tmm %>% select("nms","t_41") %>% mutate(t_41=as.numeric(t_41)) %>% arrange(t_41 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 



t_41<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_41,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_t41_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))

###

df<-tmm %>% select("nms","t_34") %>% mutate(t_34=as.numeric(t_34)) %>% arrange(t_34 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 



t_34<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_34,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_t_34_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))


df<-tmm %>% select("nms","t_37") %>% mutate(t_37=as.numeric(t_37)) %>% arrange(t_37 ) %>% 
filter( !nms %in% c("uncertain","uncertainties","uncertainty")) %>% top_n(20) 



t_37<-wordcloud2(data=df, size=0.7, color='black', shape='diamond' )



library(webshot)
webshot::install_phantomjs()


# save it in html
library("htmlwidgets")
saveWidget(t_37,"tmp.html",selfcontained = F)

# and in pdf
webshot("tmp.html","fig_t_37_REST.pdf", delay =5,cliprect = c(100, 5, 200, 200))

##########Figure 4: topic example

theta_raw<-read.csv(file="theta.csv", header=TRUE, sep=",")
theta_1<-as.data.frame(t(theta_raw[1,2:71 ]))


theta_1$Topic<-((c(1:70)))
colnames(theta_1)<-c("Probability", "Topic")
head(theta_1)




theta_1$Topic<-paste0("t_",theta_1$Topic)
class(theta_1$Probability)
theta_1<-theta_1 %>% filter(Probability>0.01)
plot_topic_example<-ggplot(data=theta_1, aes(x=Topic, y=Probability)) +
    geom_bar(stat="identity")+coord_flip()+
theme_bw()+ theme( axis.line.x = element_line(colour = 'gray', size = 0.15),panel.grid.major = element_blank(), panel.grid.minor = element_blank())


 ggsave(filename="topic_example_REST.pdf", plot=plot_topic_example, width = 15, height = 10,device=cairo_pdf, units = "cm")
  
