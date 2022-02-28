setwd("C:\\Users\\sma13\\OneDrive - stevens.edu\\factors")
rawcompq<-read.csv("RawCompQ.csv")
data.comp.fundq<-copy(rawcompq)
setDT(data.comp.fundq)
data.comp.fundq[,datadate:=ymd(datadate)]
data.comp.fundq[,year:=year(datadate)]
data.comp.fundq[,gvkey:=as.integer(gvkey)]
data.comp.fundq[,gvkey:=formatC(gvkey,width=6,flag='0')]
##create BEq
data.comp.fundq[,ps:=ifelse(is.na(pstkq),0,pstkq)]
data.comp.fundq[,txditc:=ifelse(is.na(txditcq)==TRUE,0,txditcq)]
data.comp.fundq[,seq:=ifelse(is.na(seqq),ifelse(is.na(ceqq+ps),(atq-ltq),ceqq+ps),seqq)]
data.comp.fundq[,beq:=seq+txditc-ps]
data.comp.fundq<-data.comp.fundq[beq>0]

save(data.comp.fundq,file="beqAdjusted_COMPQ.RData")
