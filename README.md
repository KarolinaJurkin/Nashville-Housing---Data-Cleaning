# Nashville Housing - Data Cleaning Project


### Introduction

This project focuses on cleaning raw data in SQL. The main purpose of it is to showcase my skills in SQL.

### Resources and tools used

- Dataset was provided by [Alex Freberg](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx)
- Data Cleaning: Microsoft SQL Server
### Data cleaning

First step in my data cleaning process was to change the 'datetime' datatype of 'SaleDate' field to 'date'. I wrote a query using ALTER TABLE and ALTER COLUMN for that purpose.

Some of the 'PropertyAddress' values were null. Since they shared 'ParcelID' with rows with filled address field, I populated the null values with previously used addresses.
![image](https://github.com/KarolinaJurkin/Nashville-Housing---Data-Cleaning/assets/53952580/78edbbdf-d497-4280-8d77-df64df5c6034)
 
To do that I used SELF JOIN and joined the tables (A and B) by 'ParcelID' and by 'A.UniqueID <> B.UniqueID'. Then I added a condition to populate 'PropertyAddress' with CASE statement. The next step was to update my table and to check if it was completed correctly by comparing 'PropertyAddress' for the same parcels.

To make the address data more usable I needed to split it into seperate columns. To do this I added columns to the table and used CHARINDEX, LEFT and RIGHT to populate them with parts of the property address. For the owner address I used PARSENAME and nested it with REPLACE function to replace commas in the strings with periods. 

I decided to search for naming inconsistencies within 'LandUse' column. I grouped all types of parcels together to see distinct names and ordered them descendingly for ease of investigation. Here is a list of things I ended up changing:
- RESTURANT/CAFETERIA - fixed spelling mistake in RESTAURANT
- VACANT RES LAND, VACANT RESIDENTIAL LAND and VACANT RESIENTIAL LAND - grouped together as VACANT RESIDENTIAL LAND
What also caught my attention was GREENBELT and GREENBELT/RES GRRENBELT/RES. It can possibly be the same type of parcel, but I decided to not change it given I am not sure about it and have no possibility to ask anyone to confirm my suspicion. 

Next I checked distinct values of 'SoldAsVacant' and changed 'Y' into 'Yes' and 'N' into 'No' to keep consistent naming convention.

To remove duplicates I created a CTE and used ROW_NUMBER to identify duplicate rows. Then I deleted 104 rows that came as a result of my search.
