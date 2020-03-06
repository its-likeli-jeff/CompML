# CompML
A short introductory workshop on kaggle and DFS. First, a brief explanation of the files in this project, in the approximate order that we'll be taking them...

Note that the various scripts are not at all optimized or well-commented. There are approximately 6 years of very lazy hacks to get the data, set it up, analyze it, and build DFS teams from that information, which I frankly never intended to share publicly. You are more than welcome to point out inefficiencies!


|Filename |Explanation |
|-------|-------|
|[CompML.pdf](CompML.pdf)  | Slides for the workshop, largely discussing Kaggle and introducing DFS |
|[lotsPGA.csv](lotsPGA.csv)| File containing tournament-level data for each PGA tour player scraped from PGAtour.com. Note: I will go over the script to scrape this in person in the workshop, but will not be posting it publicly |
|[FE_and_modeling.R](FE_and_modeling.R)| R script that will take the raw data, clean it, setup the features (feature engineering), and then fit a couple of basic models for predicting tournament performance |
|[optimization_workshop_script.R](optimization_workshop_script.R)| R script that will take the raw data, clean it, setup the features/inputs to the models, and then fit a couple of basic models for predicting tournament performance |
