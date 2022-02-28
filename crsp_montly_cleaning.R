setwd("C:\\Users\\sma13\\OneDrive - stevens.edu\\newwork")
library(tidyverse); library(zoo)
library(data.table); library(lubridate)
library(RPostgres)
library(roll)
library(reshape)

&!siccd%in%(6000:6999)

load("RawMonthlyCRSPDownloadFromWRDS.Rdata")
rawcrsp<-RawMonCRSP
setDT(rawcrsp)
##convert to lowercase
setnames(rawcrsp,colnames(rawcrsp),tolower(colnames(rawcrsp)))
##exchcd and shrcd filters
crsp.m<-rawcrsp[exchcd%in%1:3&shrcd%in%(10:11)]
##change variable format to int
crsp.m[,c("permco","permno","shrcd","exchcd"):=list(as.integer(permco),as.integer(permno),as.integer(shrcd),as.integer(exchcd))]
##Convert data format
crsp.m[,date:=ymd(date)]
crsp.m[,date:=ceiling_date(date,"m") - 1]
##
crsp.m<-crsp.m[!is.na(prc)]
crsp.m[,ret:=as.numeric(ret)]
crsp.m[,ret:=ifelse(is.na(ret),0,ret)]
crsp.m[,prc:=abs(prc)]

crsp.m<-unique(crsp.m)
crsp.m[,jdate:=date]
##delisting return adjusted
crsp.m[,dlret:=ifelse(is.na(as.numeric(dlret))==TRUE,0,as.numeric(dlret))]
crsp.m[,retadj:=(1+ret)*(1+dlret)-1]
crsp.m[,me:=abs(prc)*shrout]
crsp.m<-crsp.m[order(jdate,permco,me)]

### Aggregate Market Cap ###
# sum of me across different permno belonging to same permco a given date
crsp_summe<-crsp.m[,sum(na.omit(me)),by=.(jdate,permco)]
setnames(crsp_summe,"V1","me")
# largest mktcap within a permco/date
crsp_maxme<-crsp.m[,ifelse(length(permno)>=2,max(na.omit(me)),me),by=.(jdate,permco)]
setnames(crsp_maxme,"V1","me")
# join by jdate/maxme to find the permno
crsp1<-crsp_maxme[crsp.m,on=.(jdate,permco,me),nomatch=0 ]
# drop me column and replace with the sum me
crsp1[,me:=NULL]
# join with sum of me to get the correct market cap info
setkeyv(crsp1,c("jdate","permco"))
setkeyv(crsp_summe,c("jdate","permco"))
crsp2<-crsp1[crsp_summe,nomatch=0]
# sort by permno and date and also drop duplicates
crsp2<-unique(crsp2,by=c("permno","jdate"))
crsp2[,year:=year(jdate)]
crsp2[,month:=month(jdate)]
crsp<-crsp2
save(crsp,file="60_22_CRSP_Fex&Dadjusted.RData")
