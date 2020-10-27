library(dplyr)
library(tidyr)
library(tidyverse)
library(tidytext)
library(ggplot2)
library("topicmodels")
library("SnowballC")

library("textmineR")
setwd("C:\\Users\\Administrator\\Desktop\\awsmed\\rds")

#code from: https://towardsdatascience.com/beginners-guide-to-lda-topic-modelling-with-r-e57a5a8e7a25
memory.limit(size = 100000)
rm(list=ls())
load(file = "hansard_1893_2017.RData")
tail(hansard_1893_2017,20)
names(hansard_1893_2017)

startx<-1975
endx<-2017
###take a year
year_lu<-seq(from=startx, to=endx, by=1)



hansard_subset<-filter(hansard_1893_2017, year %in% year_lu)
table(hansard_subset$year)

###fixes a few mistakes in original database
hansard_subset%>%filter(year==2016)%>% filter(text=="Fifty-second Parliament")

#from pdf 725.001 wrong PM  [only run if years include 2016]
min725<-min(which(hansard_subset$document_id == "725.001.pdf", arr.ind=TRUE))
hansard_subset$party[min725:nrow(hansard_subset)]<-"Labour"
hansard_subset$pm[min725:nrow(hansard_subset)]<-"Jacinda Ardern"

#from pdf 720.010 wrong year
min720<-min(which(hansard_subset$document_id == "720.010.pdf", arr.ind=TRUE))
hansard_subset$year[min720:nrow(hansard_subset)]<-2017

View(hansard_subset %>% group_by(year) %>% tally())

rm(hansard_1893_2017)
head(hansard_subset)
ls()

####text cleaning
text_cleaning_tokens <- hansard_subset %>% 
  tidytext::unnest_tokens(word, text)
text_cleaning_tokens$word <- gsub('[[:digit:]]+', '', text_cleaning_tokens$word)
text_cleaning_tokens$word <- gsub('[[:punct:]]+', '', text_cleaning_tokens$word)
text_cleaning_tokens <- text_cleaning_tokens %>% filter(!(nchar(word) == 1))%>% 
  anti_join(stop_words)
tokens <- text_cleaning_tokens %>% filter(!(word==""))

head(text_cleaning_tokens)

tokens <- tokens %>% mutate(ind = row_number())
head(tokens)
rm(text_cleaning_tokens, hansard_subset )
count_words<-tokens %>% group_by(document_id) %>% tally()
write.csv(count_words, paste0( "NZ_word_counts_proxy",startx,"_",endx,".csv"))



ls()
###create window
df<-(which(tokens == "uncertain" | tokens == "uncertainty"| tokens == "uncertainties", arr.ind=TRUE))[ ,1]

#creates a unique id
df_year<-tokens %>% filter(ind %in%  df) %>%mutate(id1 = paste0("NZ_id_",year ,"_",document_id,ind)) %>% select("id1") 

##creates a second id to match with (this second id mimics the id created by the
#text-mining package
df_year$seqid<-seq(0,(length(df)-1), by=1)
df_year$id2<-paste0("word",df_year$seqid)
df_year$id2<-ifelse(df_year$id2=="word0","word",df_year$id2)
head(df_year)


nword<-20
windows_nonneg <- function(.x) {
 
(tokens[ c((.x-nword):(.x+nword)), 6])
  
}


uncertain_tokens<-map_dfc(df, windows_nonneg)

uncertain_tokens<-uncertain_tokens%>%gather(id,word,1:ncol(uncertain_tokens))%>% mutate(ind = row_number())

###links mention of uncertainty back to unique id made above
uncertain_tokens<-left_join(uncertain_tokens,df_year, , by = c("id" = "id2"))%>%
select(-c("id","seqid")) %>% mutate(id=id1) %>% select(-c("id1"))

#now each mention is row and each columns is a word associated with that mention
tokens_new <- uncertain_tokens %>% group_by(id) %>% mutate(ind = row_number()) %>%
  tidyr::spread(key = ind, value = word)
View(tokens_new)

#tokens [is.na(tokens)] <- ""

#making words into a string
tokens_new2 <- tidyr::unite(tokens_new, text,-id,sep =" " )
tokens_new2$text <- trimws(tokens_new2$text)
View(tokens_new2)
write.csv(tokens_new2,"tokens.csv")


tail(tokens_new2$id)
saveRDS(tokens_new2, file = paste0("NZ_Proxy",startx,"_",endx,".rds"))

#tokens<-readRDS(file="NZ_Proxy1975_2017.rds" )
#counts of uncertainty mentions by year
uncertain_n<-tokens_new2%>% mutate(year=substr(id,7,18))%>%group_by(year)%>%tally()
tail(uncertain_n)



write.csv(uncertain_n, paste0( "NZ_uncertainty_counts_svar",startx,"_",endx,".csv"))

#########this code does the topic modelling
#tokens<-readRDS(file="NZ_Proxy1975_2017.rds" )  #saved version
tokens<-tokens_new2
rm(tokens_new2)

dtm <- CreateDtm(tokens$text, 
                 doc_names = tokens$id, 
                 ngram_window = c(1, 2))
#explore the basic frequency
tf <- TermDocFreq(dtm = dtm)
original_tf <- tf %>% select(term, term_freq,doc_freq)
rownames(original_tf) <- 1:nrow(original_tf)
dim(original_tf)
# Eliminate words appearing less than 2 times or in more than half of the
# documents
vocabulary <- tf$term[ tf$term_freq > 1 & tf$doc_freq < nrow(dtm) / 2 ]
dtm = dtm
write.csv(original_tf, "NZproxy_original_tf.csv" )
rm(tokens)


set.seed(12346)
k_list <- seq(30, 80, by = 10)
model_dir <- paste0("models_", digest::digest(vocabulary, algo = "sha1"))
if (!dir.exists(model_dir)) dir.create(model_dir)
model_list <- TmParallelApply(X = k_list, FUN = function(k){
  filename = file.path(model_dir, paste0(k, "_topics.rda"))
  
  if (!file.exists(filename)) {
    m <- FitLdaModel(dtm = dtm, k = k, iterations = 500, burnin = 150)
    m$k <- k
    m$coherence <- CalcProbCoherence(phi = m$phi, dtm = dtm, M = 5)
    save(m, file = filename)
  } else {
    load(filename)
  }
  
  m
}, export=c("dtm", "model_dir")) # export only needed for Windows machines
#model tuning
#choosing the best model
coherence_mat <- data.frame(k = sapply(model_list, function(x) nrow(x$phi)), 
                            coherence = sapply(model_list, function(x) mean(x$coherence)), 
                            stringsAsFactors = FALSE)
ggplot(coherence_mat, aes(x = k, y = coherence)) +
  geom_point() +
  geom_line(group = 1)+
  ggtitle("Best Topic by Coherence Score") + theme_minimal() +
  scale_x_continuous(breaks = seq(1,80,1)) + ylab("Coherence")

model <- model_list[which.max(coherence_mat$coherence)][[ 1 ]]
model$top_terms <- GetTopTerms(phi = model$phi, M = 20)
topn_wide <- as.data.frame(model$top_terms)

write.csv(topn_wide, "nzproxytop20_wide2.csv" )


model$topic_linguistic_dist <- CalcHellingerDist(model$phi)
model$hclust <- hclust(as.dist(model$topic_linguistic_dist), "ward.D")
model$hclust$labels <- paste(model$hclust$labels, model$labels[ , 1])
plot(model$hclust)


###need to id which topic most likely to map to which "document"


#theta is the probability of a document being about a topic
theta<-(model$theta)
write.csv(theta, "theta.csv")
###


