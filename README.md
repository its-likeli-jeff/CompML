# CompML
A short introductory workshop on kaggle and DFS. First, a brief explanation of the files in this project, in the approximate order that we'll be taking them...

Note that the various scripts are not at all optimized or well-commented. There are approximately 6 years of very lazy hacks to get the data, set it up, analyze it, and build DFS teams from that information, which I have boiled down to a consumable size for a 1.5 hour workshop --- but frankly never intended to share publicly. 

You are more than welcome to point out inefficiencies and improvements to both slides and code!


|Filename |Explanation |
|-------|-------|
|[CompML.pdf](CompML.pdf)  | Slides for the workshop, largely discussing Kaggle and introducing DFS |
|[lotsPGA.csv](lotsPGA.csv)| File containing tournament-level data for each PGA tour player scraped from PGAtour.com. Note: I will go over the script to scrape this in person in the workshop, but will not be posting it publicly. While PGAtour.com does not place restrictions on scraping according to their robots.txt file, I always err against poking the proverbial bear... |
|[FE_and_modelling.R](FE_and_modelling.R)| R script that will take the raw data, clean it, setup the features (feature engineering), and then fit a couple of basic models for predicting tournament performance |
|[lmweekpreds.csv](lmweekpreds.csv)| Tournament rank predictions (for this week prior to the tournament starting) using the linear model from the R script above |
|[rfweekpreds.csv](lmweekpreds.csv)| Tournament rank predictions (for this week prior to the tournament starting) using the random forest model from the R script above |
|[optimization_workshop_script.R](optimization_workshop_script.R)| R script that takes predicted performance and uses an integer (binary) programming solver in R to provide an 'optimal' team under the salary cap constraints|
