#updated 2021
pg <- read.csv("~/Downloads/lotsPGA_git2.csv", stringsAsFactors = FALSE, skipNul=TRUE)
pgorig <- pg
#pg <- pg[,-1]
recpn <- c("Greens in Regulation Percentage", "Driving Accuracy Percentage", 
           "Longest Drives", "Driving Distance", "Total Driving", "Sand Save Percentage",
           "All-Around Ranking", "Ball Striking", "Strokes Gained: Putting",
           "Par 3 Performance", "Par 4 Performance", "Par 5 Performance", 
           "Front 9 Scoring Average","Back 9 Scoring Average")
colnames(pg)[c(13:26)] <- recpn
pg$X <- unlist(lapply(strsplit(pg$X, ":"), function(v) v[1]))
colnames(pg)[c(1,2,39,14, 15, 17, 22, 29, 31)] <- c("firstlast.i", "Date", "TO.PARSCORE", "GIR", "DRVGACC", "DRVDIST", "STROKESGAINEDPUTTING", "CourseID", "Tournament.Name")

#Cleaning
library(rvest)
library(jsonlite)
library(gtools)
library(readr)
library(data.table)
pg$TO.PARSCORE[pg$TO.PARSCORE=="E"] <- "0"
pg$TO.PARSCORE <- gsub(" ", "", pg$TO.PARSCORE)
pg$TO.PARSCORE <- as.numeric(pg$TO.PARSCORE)
pg$GIR <- gsub("%", "", pg$GIR)
pg$GIR <- as.numeric(pg$GIR)
pg$DRVGACC <- gsub("%", "", pg$DRVGACC)
pg$DRVGACC <- as.numeric(pg$DRVGACC)
pg2 <- as.data.table(pg)
pg2 <- pg2[finPos.fmt!="CNL"]
pg2 <- pg2[finPos.fmt!="W/D"]
pg2 <- pg2[finPos.fmt!="DNQ"]
pg2 <- pg2[finPos.fmt!="DNS"]
pg2 <- pg2[finPos.fmt!="DQ"]

#Feature Engineering
fivedaywin <- c(as.Date(Sys.Date()), as.Date(Sys.Date())+1, as.Date(Sys.Date())+2, as.Date(Sys.Date())+3, as.Date(Sys.Date())+4)
tournday <- as.character(fivedaywin[weekdays(fivedaywin)=="Thursday"])

pg2[, FinRank := frank(TO.PARSCORE, ties.method="min"), by=list(Date, Tournament.Name)]
pg2[, GIRRank := frank(-GIR, ties.method="min"), by=list(Date, Tournament.Name)]
pg2[, DrvAccRank := frank(-DRVGACC, ties.method="min"), by=list(Date, Tournament.Name)]
pg2[, DrvDistRank := frank(-DRVDIST, ties.method="min"), by=list(Date, Tournament.Name)]
pg2[, StrGainRank := frank(-STROKESGAINEDPUTTING, ties.method="min"), by=list(Date, Tournament.Name)]
pg2$Date <- as.Date(pg2$Date)
pg3 <- pg2

nm <- colnames(pg2)[40:44]
nm1 <- paste("lag1", nm, sep=".")
pg2[, (nm1) :=  shift(.SD), by=firstlast.i, .SDcols=nm]
#pg2[, (nm1) :=  frollmean(.SD, align="right", n=1), by=firstlast.i, .SDcols=nm]
pg2[, "DateDiff" :=  Date-shift(Date), by=firstlast.i]
pg2$DateDiff <- as.numeric(pg2$DateDiff)
nm <- c(nm, "DateDiff")
nm1 <- c(nm1, "DateDiff")
nm2 <- paste("lag2", nm, sep=".")
pg2[, (nm2) :=  frollmean(.SD, align="right", n=2), by=firstlast.i, .SDcols=nm1]
nm3 <- paste("lag3", nm, sep=".")
pg2[, (nm3) :=  frollmean(.SD, align="right", n=3), by=firstlast.i, .SDcols=nm1]
nm4 <- paste("lag4", nm, sep=".")
pg2[, (nm4) :=  frollmean(.SD, align="right", n=4), by=firstlast.i, .SDcols=nm1]
nm5 <- paste("lag5", nm, sep=".")
pg2[, (nm5) :=  frollmean(.SD, align="right", n=5), by=firstlast.i, .SDcols=nm1]
nm6 <- paste("lag6", nm, sep=".")
pg2[, (nm6) :=  frollmean(.SD, align="right", n=6), by=firstlast.i, .SDcols=nm1]
nm7 <- paste("lag7", nm, sep=".")
pg2[, (nm7) :=  frollmean(.SD, align="right", n=7), by=firstlast.i, .SDcols=nm1]


wlags <- pg2[,c(40,45:86)]
wlags <- na.omit(wlags)

#relatively fast
lmfit <- lm(FinRank~., data=wlags)
summary(lmfit)
#write.csv(sort(predict(lmfit, newdata=do.call("rbind", as.list(by(wlags,  newpg$pg.firstlast.i, tail, n=1))))), "~/Dropbox/DK/PGA data/lmweekpreds.csv")


#ALSO relatively fast
library(ranger)
rfrun <- ranger(FinRank~., data=wlags, num.trees=500, importance="impurity")
rfrun

#pull the latest row for each player to feed in for prediction
tournday <- as.Date(tournday)
nm <- colnames(pg3)[40:44]
nm1 <- paste("lag1", nm, sep=".")
pg3[, (nm1) :=  .SD, by=firstlast.i, .SDcols=nm]
#pg2[, (nm1) :=  frollmean(.SD, align="right", n=1), by=firstlast.i, .SDcols=nm]
pg3[, "DateDiff" :=  (c(Date, tournday)-shift(c(Date,tournday)))[-1], by=firstlast.i]
pg3$DateDiff <- as.numeric(pg3$DateDiff)
nm <- c(nm, "DateDiff")
nm1 <- c(nm1, "DateDiff")
nm2 <- paste("lag2", nm, sep=".")
pg3[, (nm2) :=  frollmean(.SD, align="right", n=2), by=firstlast.i, .SDcols=nm1]
nm3 <- paste("lag3", nm, sep=".")
pg3[, (nm3) :=  frollmean(.SD, align="right", n=3), by=firstlast.i, .SDcols=nm1]
nm4 <- paste("lag4", nm, sep=".")
pg3[, (nm4) :=  frollmean(.SD, align="right", n=4), by=firstlast.i, .SDcols=nm1]
nm5 <- paste("lag5", nm, sep=".")
pg3[, (nm5) :=  frollmean(.SD, align="right", n=5), by=firstlast.i, .SDcols=nm1]
nm6 <- paste("lag6", nm, sep=".")
pg3[, (nm6) :=  frollmean(.SD, align="right", n=6), by=firstlast.i, .SDcols=nm1]
nm7 <- paste("lag7", nm, sep=".")
pg3[, (nm7) :=  frollmean(.SD, align="right", n=7), by=firstlast.i, .SDcols=nm1]


preddat <- pg3[, .SD[.N], by=firstlast.i]
preddat2 <- as.data.frame(preddat[,c(1,45:86)])
rownames(preddat2) <- preddat2$firstlast.i

rfpreds <- predict(rfrun, data=na.omit(preddat2))
rfpreds2 <- as.data.frame(rfpreds$predictions)
rownames(rfpreds2) <- rownames(na.omit(preddat2))
rfpreds2[order(rfpreds2[,1]),]
write.csv(rfpreds2, "~/Downloads/rfweekpreds.csv")

lmpreds <- predict(lmfit, newdata=na.omit(preddat2))
names(lmpreds) <- rownames(na.omit(preddat2))
write.csv(lmpreds, "~/Downloads/lmweekpreds.csv")
