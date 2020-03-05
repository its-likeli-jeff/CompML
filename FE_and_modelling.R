pg <- read.csv("~/Downloads/lotsPGA.csv", stringsAsFactors = FALSE)
pgorig <- pg
colnames(pg)[13:26] <- recpn
pg$X <- unlist(lapply(strsplit(pg$X, ":"), function(v) v[1]))
colnames(pg)[c(1,2,38,13, 14, 16, 21, 30)] <- c("firstlast.i", "Date", "TO.PARSCORE", "GIR", "DRVGACC", "DRVDIST", "STROKESGAINEDPUTTING", "Tournament.Name")


#Cleaning and Feature Engineering
finrank <- girrank <- drvgaccrank <- drvdistrank <- strgainrank <- rep(NA, length=nrow(pg))
madecut <- !pg$finPos.fmt=="CUT"
pg$TO.PARSCORE[pg$TO.PARSCORE=="E"] <- "0"
pg$TO.PARSCORE <- gsub(" ", "", pg$TO.PARSCORE)
pg$TO.PARSCORE <- as.numeric(pg$TO.PARSCORE)
pg$GIR <- gsub("%", "", pg$GIR)
pg$GIR <- as.numeric(pg$GIR)
pg$DRVGACC <- gsub("%", "", pg$DRVGACC)
pg$DRVGACC <- as.numeric(pg$DRVGACC)
for(i in unique(pg$Date)){
  pgdum <- pg[pg$Date==i,]
  for(j in unique(pgdum$Tournament.Name)){
    pgdum2 <- pgdum[pgdum$Tournament.Name==j,]
    ind <- as.numeric(row.names(pgdum2))
    finrank[ind] <- rank(pgdum2$TO.PARSCORE, ties.method = "min")
    girrank[ind] <- rank(-pgdum2$GIR, ties.method="min")
    drvgaccrank[ind] <- rank(-pgdum2$DRVGACC, ties.method="min")
    drvdistrank[ind] <- rank(-pgdum2$DRVDIST, ties.method="min")
    strgainrank[ind] <- rank(-pgdum2$STROKESGAINEDPUTTING, ties.method="min")
  }
}


newpg <- data.frame(pg$firstlast.i, pg$Date, pg$Tournament.Name, finrank, girrank, drvgaccrank, strgainrank, drvdistrank, madecut)
newpg$pg.Date <- as.Date(newpg$pg.Date, format="%m/%d/%Y")
newpg <- newpg[-grep("\\(", newpg$pg.Tournament.Name),]
newpg <- newpg[-grep("Match", newpg$pg.Tournament.Name),]
#summary(lm(finrank~girrank+drvgaccrank+strgainrank+drvdistrank))

library(zoo)
#remove solo tourney players
if(any(table(newpg$pg.firstlast.i)==1)){
  newpg <- newpg[-which(newpg$pg.firstlast.i %in% names(which(table(newpg$pg.firstlast.i)==1))),]
  row.names(newpg) <- 1:nrow(newpg)
}
lagfinrank <- laggir <- lagdrva <- lagstrg <- lagdrvd <- lagdays <- rep(NA, nrow(newpg))
lagmat <- lagmat2 <- lagmat3 <- lagmat4 <- lagmat5 <- lagmat6 <- lagmat7 <- data.frame(lagfinrank, laggir, lagdrva, lagstrg, lagdrvd, lagdays)
#setup lags, first sort
newpg2 <- rep(NA, 9)
fivedaywin <- c(as.Date(Sys.Date()), as.Date(Sys.Date())+1, as.Date(Sys.Date())+2, as.Date(Sys.Date())+3, as.Date(Sys.Date())+4)
tournday <- as.character(fivedaywin[weekdays(fivedaywin)=="Thursday"])
for(i in unique(newpg$pg.firstlast.i)){
  playpg <- newpg[newpg$pg.firstlast.i==i,]
  playpg <- playpg[order(playpg$pg.Date),]
  newpg2 <- rbind(newpg2, playpg, c(as.character(i), tournday, rep(NA,7)))
} 
#newpg <- na.omit(newpg)

newpg <- newpg2[-1,]
row.names(newpg) <- 1:nrow(newpg)
for(i in unique(newpg$pg.firstlast.i)){
  cat(i, "\r", sep="")
  playpg <- newpg[newpg$pg.firstlast.i==i,]
    lagmat[as.numeric(row.names(playpg)),] <- rbind(rep(NA, 6), cbind(playpg[1:(nrow(playpg)-1),4:8], diff(playpg$pg.Date)))
}

lagmat <- apply(lagmat, 2, as.numeric)

for(i in unique(newpg$pg.firstlast.i)){
  cat(i, "\r", sep="")
  playpg <- newpg[newpg$pg.firstlast.i==i,]
    try(lagmat2[as.numeric(row.names(playpg)),] <- rollapply(lagmat[as.numeric(row.names(playpg)),] ,2, mean, by=1, align="right", fill=NA, by.column=TRUE), silent=TRUE)
    try(lagmat3[as.numeric(row.names(playpg)),] <- rollapply(lagmat[as.numeric(row.names(playpg)),] ,3, mean, by=1, align="right", fill=NA, by.column=TRUE), silent=TRUE)
    try(lagmat4[as.numeric(row.names(playpg)),] <- rollapply(lagmat[as.numeric(row.names(playpg)),] ,4, mean, by=1, align="right", fill=NA, by.column=TRUE), silent=TRUE)
    try(lagmat5[as.numeric(row.names(playpg)),] <- rollapply(lagmat[as.numeric(row.names(playpg)),] ,5, mean, by=1, align="right", fill=NA, by.column=TRUE), silent=TRUE)
    try(lagmat6[as.numeric(row.names(playpg)),] <- rollapply(lagmat[as.numeric(row.names(playpg)),] ,6, mean, by=1, align="right", fill=NA, by.column=TRUE), silent=TRUE)
    try(lagmat7[as.numeric(row.names(playpg)),] <- rollapply(lagmat[as.numeric(row.names(playpg)),] ,7, mean, by=1, align="right", fill=NA, by.column=TRUE), silent=TRUE)
}

wlags <- data.frame(newpg$finrank, lagmat, lagmat2, lagmat3, lagmat4, lagmat5, lagmat6, lagmat7, stringsAsFactors = FALSE)


#relatively fast
lmfit <- lm(as.numeric(newpg.finrank)~., data=wlags)
summary(lmfit)
#write.csv(sort(predict(lmfit, newdata=do.call("rbind", as.list(by(wlags,  newpg$pg.firstlast.i, tail, n=1))))), "~/Dropbox/DK/PGA data/lmweekpreds.csv")


#SEVERAL HOURS! approx 8+ on my desktop
library(randomForest)
rfrun <- randomForest(as.numeric(newpg.finrank)~., data=na.omit(wlags))
#write.csv(sort(predict(rfrun, newdata=do.call("rbind", as.list(by(wlags,  newpg$pg.firstlast.i, tail, n=1))))), "~/Dropbox/DK/PGA data/rfweekpreds.csv")


