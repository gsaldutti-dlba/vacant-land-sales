# Vacant Land Sales App

####Updates
### Data last updated: 2/24/23


This app visualizes vacant land sales in the City of Detroit from 2011-2022, and calculates square foot price for sales. It also calculates neighborhood median sales prices for Commercial, Residential and Industrially zoned vacant land.

## Using this app

This app should be used as an aid in determining accurate market pricing for vacant land sales. 

It is possible that errors exist in the underlying data, causing incorrect valuations for neighborhood medians or for individual properties. 

This tool should be used alongside other methods. 

## Notes on the Data

Data for this app comes from the Open Data Portal for the City of Detroit [Property Sales](https://data.detroitmi.gov/datasets/detroitmi::property-sales-1/about).

Attempts have been made to capture ONLY vacant land sales, but be aware that structures may still exist in the data set. 

The data contains all property sales history since 2011. In an attempt to capture an accurate market price for vacant land, a number of filters have been applied to the data:

* Properties indicated by the city of Detroit as structures are not included
* Sales that exceed $1000 are not included
* Sales where the grantor is the DLBA and where the property sold is indicated as a structure by the DLBA are not included
* Sales where properties are indicated as vacant lots, but sold before a DLBA indicated demolition are not included 
* Sales where the grantee is indicated as DLBA are not included

### Multi-parcel sales

In cases of multi-parcel sales, the sales price for each individual property is recorded as the total price of the entire transaction. This requires identifying multi-parcel sales and dividing the entire sales price by the total number of properties in the sale bundle. 

Because multi-parcel sales were not always accurately recorded, multi-parcel sales were determined by grouping each transaction by sales date, sales price and neighborhood. 

The price/sq ft for identified groups were calculated by summing the total square footage of all properties in the bundle and dividing by the total sales price, leaving an aggregate square footage price for the entire bundle.

### Vacant properties within multi-parcel bundles that include structures

Cases in which vacant land and structures were bundled in a single sale have been excluded from the data (for the time being).

As the sale price is applied to every property in the bundle, it is difficult to derive the actual price of the vacant land independent of the effect of the structure included in the bundle. 

A more robust way of estimating these values is being explored.  


### Neighborhood Medians

The neighborhood [median](https://owl.purdue.edu/owl/research_and_citation/using_research/writing_with_statistics/descriptive_statistics.html) is calculated dynamically depending on user inputs for Property Class and Date Range. 

These medians should not include any values for properties that have been filtered according to the filters outlined above. 

In general, neighborhoods with higher sales counts should have a more accurate neighborhood median. 

However, there is a still a possibility that there are errors present in the data. 




## Questions or requests
Please contact the RnA team for questions regarding this tool, problems or requests for features. 

