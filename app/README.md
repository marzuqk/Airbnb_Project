# About the App

Karan worked on the first 3 tabs which show some general exploratory data analysis applications

Marzuq worked on the next 2 tabs to show the relationship between Price of airbnb's and the distance from subways.

Amy worked on the last 2 tabs to be able to filter airbnb options based on the factors most customers may look for such as budget, neighborhood, listing type, and number of reviews.

## An Explanation of Marzuq's Tabs

- I had to incorporate the new york city subway data set for both of these tabs and link them together with our main airbnb dataset, but not with a traditional join
- We linked the dataset with the help of the pdist package that the professor told us about and used it to calculate the euclidean distance {sqrt((lat1 - lat2)^2+(long1 - long2)^2)}  between each Airbnb listing and every subway station and selected the the minimum value as the output
	+ Around New York the distance between a degree of longitude is about 53 miles and 1 degree of latitude is around 69 miles so taking the euclidean distance of that, starting from 0, would be about 87
	+ I multiplied the values we have for distance by 87 which gave a good estimate of the distance in miles, but I cannot say it is 100% accurate
	+ I saved the distance values, between latitude and longitude, as a column and used that for the map
- The overview shows the number of listings in that general location
- You can zoom in to any point in New York city and hover over a marker to see the price of the airbnb listing
- If you click the marker, it shows you the name of the listing and the distance to the closest subway station in miles

- To switch the selection, just click subway
- This overview shows the number of subway stations in that general area
- You can zoom in to any point in New York city and hover over a marker to see which subway station is located there
- If you click on a marker it shows the subway line it is
The main purpose of these 2 maps is to show the prices of airbnb listings and the distance to subway stations, for tourists planning to generally figure out if they will be using the subway at all based on their distance from them or even subway lines they are near

The next tab is for those interested in finding out if there is any correlation between prices airbnb listings and their distance to subway stations.
- The plot does seem to show that listings farther from subway stations also seem to have lower prices
- By the difference in color you can tell that properties on Staten Island are generally farther from the subway, followed by properties in Queens which tend to be the next furthest
- The other 3, Bronx, Brooklym, Manhattan, tend to be near subway stations and have a lot more variability in their pricing
- Since the estimate is a negative value for near_sub (the distance to subway stations) and the p-value is nearly 0, there does seem to be a correlation between prices and distance
	+ The variability in price is very high though so logging the variables helps make it more linear
Conclusion: The distance from subway stations can be considered related when looking at those 2 as the only variables, but it is also clear that other variables play a role, such as the neighborhood and probably, most of all, the property being offered.

## An Explanation of Amy's Tabs

After exploring the relationship between rental pricing and the distance to the subway stations, our group has also created a rental finder function within our app. The function can help the visitors do research on the potential rentals based on their preferences. 
On the top part is an interactive map of New York City. You can zoom in & out to explore the region or the units you are interested in. Each dot includes detailed information of the unit. We have also created two boxplots below the map for a quicker view of pricing in different scenarios for comparison.
We segment out the preference into 4 categories:

Neighborhoods: we did notice that, in general, most rental units are clustering in Manhattan area and then Brooklyn which is kind of expecting as they have the most popular attractions and leisure activities that visitors can explore.

Room Types: unsurprisingly, renting the entire unit is most likely to be costly compare to private or shared room. 

Pricing: rental pricing in New York is interesting as it could be as low as $50 per night toward $3000 per night in the most premium locations.

Number of reviews: people believe that in most cases, higher volume of the reviews could mean higher chance of good rental units, so we include this information in our app.

Here is an example after we create a filter:

Select neighborhood: Manhattan & Queens

Select room type: entire home/ apt

Select budget: $0-$200

Select number of reviews: 250 – 400

You can see the units after filtering and how the pricing changed within the plots as well
 
We also have the last tab for the references we used while working on this project.

Thank you!
