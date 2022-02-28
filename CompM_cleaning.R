setwd("C:\\Users\\sma13\\OneDrive - stevens.edu\\factors")
rawcomp<-read.csv("RawCompm.csv")
data.comp.funda<-copy(rawcomp)
setDT(data.comp.funda)
data.comp.funda[,datadate:=ymd(datadate)]
data.comp.funda[,gvkey:=as.integer(gvkey)]
data.comp.funda[,gvkey:=formatC(gvkey,width=6,flag='0')]
data.comp.funda[,year:=substr(datadate,1,4)]

data.comp.funda[,ps:=ifelse(is.na(pstkrv)==TRUE,ifelse(is.na(pstkl),pstk, pstkl), pstkrv)]
data.comp.funda[,txditc:=ifelse(is.na(txditc)==TRUE,0,txditc)]
data.comp.funda[,seq:=ifelse(is.na(seq),ifelse(is.na(ceq+pstk),(at-lt),ceq+pstk),seq)]
# create book equity
data.comp.funda[,be:=seq+txditc-ps]
data.comp.funda[,be:=ifelse(be>0,be,NA)]
data.comp.funda<-data.comp.funda[be>0]

save(data.comp.funda,file="beqAdjusted_COMPM.RData")


# 
# data.comp.funda[,se:=ifelse(is.na(seq)==FALSE,seq,ifelse(is.na(ceq+pstk)==FALSE,ceq+pstk,at-lt))]
# data.comp.funda[,ps:=ifelse(is.na(pstkrv)==TRUE, pstkl, pstkrv)]
# data.comp.funda[,ps:=ifelse(is.na(ps)==TRUE, pstk, ps)]
# data.comp.funda[,ps:=ifelse(is.na(ps)==TRUE, 0, ps)]
# data.comp.funda[,be:=se+ifelse(is.na(txditc)==FALSE,txditc,0)-ps]