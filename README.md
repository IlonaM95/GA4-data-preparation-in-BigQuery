# GA4 data preparation in BigQuery
***Preparation of 4 tables in BigQuery, using a public dataset from GA4, for further analysis in BI systems.***
<br>
<br>
## Overview
This project involves preparing 4 different tables in BigQuery, using the public dataset *ga4_obfuscated_sample_ecommerce* from Google Analytics 4 for the *Google Merchandise Store*.
The purpose is to create data tables for further analysis, data visualization, and reporting in BI systems. Based on these tables, a sales funnel can be created, for example. Below is an example of a sales funnel visualisation in Tableau Public for another dataset used in one of my other projects:

[Link to interactive report in Tableau Public](https://public.tableau.com/views/OnboardingFunnel_17296001028170/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

![Tableau_Public_funnel](https://github.com/user-attachments/assets/0b80a345-5ac7-4462-8429-139f49f576e9)

The queries are available in this repository.
<br>
<br>

## Detailed description of queries and resulting tables

### Table 1 - General event data
This query aims to retrieve a table with general information about events, users and sessions in GA4 for the year 2021 as a basis for creating reports in BI systems.

**Resulting table columns:**
- 'event_timestamp' - date and time of the event
- 'user_pseudo_id' - anonymous user ID in GA4
- 'session_id' - session ID in GA4
- 'event_name' - name of the event
- 'country' - user's country
- 'device_category' - user's device category
- 'source' - source of the website visit
- 'medium' - medium through which the website was visited
- 'campaign_name' - name of the ad campaign

**Included events:**
- 'session_start'
- 'view_item'
- 'add_to_cart'
- 'begin_checkout'
- 'add_shipping_info'
- 'add_payment_info'
- 'purchase'

![1_Data_preparation](https://github.com/user-attachments/assets/a1157b52-5fc2-4e87-a924-799a905913cd)


### Table 2 - Conversion calculations by date and traffic channel
This query aims to calculate conversions and retrieve a table with information on conversions from the start of the website session to purchase completion.

**Resulting table columns:**
- 'event_date' - date of session start, derived from 'event_timestamp'
- 'source', 'medium', 'campaign' - sources of website traffic
- conversion metrics for each date and traffic channel:
  - 'user_sessions_count' - number of unique sessions for unique users
  - 'visit_to_cart' - number of users who added a product to the cart
  - 'visit_to_checkout' - number of users who started the checkout process
  - 'visit_to_purchase' - number of users who completed a purchase

![2_Conversion_calculation](https://github.com/user-attachments/assets/3fc413c6-581f-4445-9ce8-42bba645676b)


### Table 3 - Conversion Rate comparison for different landing pages
This query calculates 3 different metrics for each unique landing page based on data from 2019.

**Resulting table columns:**
- 'page_path' - landing page path derived from 'page_location'
- conversion metrics for each unique landing page:
  - 'unique_user_sessions' - number of unique sessions started by unique users
  - 'total_purchases' - number of purchases
  - 'visit_to_purchase' - number of users who completed a purchase
  - 'conversion_rate_purchases' - ratio of users who made a purchase to all users who started a session on the page

![3_Landing_page_conversions](https://github.com/user-attachments/assets/9e83e1e9-ce24-4775-afaa-2b89c5409bb8)


### Table 4 - Correlation between user engagement and purchases
This query aims to create a table where the engagement time for each unique session of each unique user is calculated, as well as whether the user was engaged and if they made a purchase. The table is then used to calculate the correlation between user engagement and purchases.

**Intermediate table columns:**
- 'user_sessions_id' - unique session ID for unique users
- 'engagement_time_min' - total engagement time during the session in minutes
- 'session_engaged' - whether the user was engaged in the session (1 for yes, 0 for no)
- 'purchase' - whether a purchase was made (1 for yes, 0 for no)

![4_User_engagement](https://github.com/user-attachments/assets/e6391fb5-60ce-4fc1-8ce6-71dd7ac27b00)


**Final table:**
- 'corr_engaged_purchase' - correlation coefficient between 'session_engaged' and 'purchase'
- 'corr_time_purchase' - correlation coefficient between 'engagement_time_min' and 'purchase'

![4_Correlation](https://github.com/user-attachments/assets/8cf6428f-2ddb-4084-b583-1a16f4a636a3)

**Correlation assessment:**
- No correlation was found between user engagement ('session_engaged') and purchase completion ('purchase') during the session.
- A low positive correlation was found between user engagement time ('engagement_time_min') and purchase completion ('purchase') during the session.
