# New York Airbnb 2019

New York is one of the most popular spots for tourists around the world. Airbnb has been changing the way tourists travel. Therefore, our team would like to explore the Airbnbs in New York City in 2019. Our project will start with exploratory data analysis followed by spatial analysis among all the rental locations, rental pricing, and the distance of subway stations in a Shiny App.

Our Shiny Dashboard gives a visual interactive presentation of the main AirBnb dataset. There is a univariate analyses (tab: Histogram) where we can visually understand how the different variables from the main dataset are spread by using histograms and bar plots along with one sample t-test for all the individual variables. Then, there is a bivariate analyses (tab: Plot) which shows the comparison between any two variables from the data set which we want to show.

With our Shiny dashboard, we can visually understanding where the rentals are, how much each rental costs and what are the influencial factors to the rental price. We have also incooperated the NY subway dataset with our AirBnB dataset so that we can see if there is any association between rental prices and the distance between a rental unit and the distance of a subway station.

In addition to the analysis, we have created a rental finder function which will help visitors search the units based on their preference. The tourists can review and select the rentals that they are interested in with ease.

- Our dataset:
   - Airbnb listings and metrics in NYC, NY, USA (2019): https://www.kaggle.com/dgomonov/new-york-city-airbnb-open-data
      - There are total 48,895 observations with 16 variables of rental and host id, rental name, neigourhood group, neighbourhood, longtitude, latitude, room type, price, minimum_nights, number of reviews received, most recent review date, number of reviews per month, calculated amount of listing per host and the number of day in availibility for booking in 2019.
   - Subway Stations in New York City https://data.cityofnewyork.us/Transportation/Subway-Stations/arq3-7z49
	 - There are 473 observations in the NY subway dataset with 6 variables of URL of each location's URL page, object ID, location name, longtitude, latitude, the lines in each location and note which includes the train schedules.
    
- The scripts we have used during the process:
   - RMarkdown: In the analysis folder, the files titled "CombinedProgress" are the main files.
   - Shiny App: In the app folder, the "app.R" file is the main one.

*This project was done by Karan Dassi, Marzuq Khan, and Amy Lu*





