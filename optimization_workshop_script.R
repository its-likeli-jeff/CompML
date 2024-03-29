###pga for workshop
library(stringi)
library(stringdist)
#name cleaning
fixnames <- function(thefield, dk, fanduel){
  thefield <- trimws(thefield, "right")
  subfield <- as.character(thefield[!(thefield %in% dk$Name)])
  subdk <- dk$Name[(!(dk$Name %in% thefield)) & (dk$Position!="DST")]
  submat <- stringdistmatrix(subfield, subdk, method="jw")
  fullfram <- data.frame(NumName=as.character(subfield), DKName=as.character(subdk[apply(submat, 1, which.min)]), Dist=apply(submat, 1, min), stringsAsFactors = FALSE)
  replaced <- subfield[fullfram$Dist<.13]
  subfield[fullfram$Dist<.13] <- fullfram$DKName[fullfram$Dist<.13]
  thefield[!(thefield %in% dk$Name)] <- subfield
  ordfram <- fullfram[fullfram$Dist>=.13,]
  print(head(ordfram[order(ordfram$Dist),]))
  print("-------------------")
  print(cbind(replaced, fullfram$DKName[fullfram$Dist<.13]))
  print("-------------------")
  return(thefield)
}





weekpreds <- read.csv("~/Downloads/rfweekpreds.csv", stringsAsFactors = FALSE)
#weekpreds <- read.csv("~/Downloads/lmweekpreds.csv", stringsAsFactors = FALSE)

thefield <- weekpreds[,1]
odd <- weekpreds[,2]
dk2 <- read.csv("~/Downloads/DKSalaries.csv", header=TRUE, stringsAsFactors=FALSE )
thefield <- fixnames(thefield, dk2, fanduel=FALSE)


optimi <- "min"
dk <- dk2[dk2$Name %in% thefield,]

projs2 <- odd[match(dk$Name, thefield)]

library(lpSolve)

sallimit <- 50000
f.obj <- projs2
pcon <- rep(1, nrow(dk))
salcon <- dk$Salary
f.con <- cbind(pcon, salcon)
f.dir <- c("==", "<=")
f.rhs <- c(6, sallimit)


test<- lp(optimi, f.obj, f.con, f.dir, f.rhs, all.bin=TRUE, transpose.constraints=FALSE)
print(sort(dk[as.logical(test$solution),3]))

dkproj <- cbind(dk, projs2)
dkproj[order(projs2),c(3,6,10)]
