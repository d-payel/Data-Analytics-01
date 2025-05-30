#  Hypotheis Testing and Exploratory Data Analysis on YULU Bike Share Demand
- **Objective**: Investigate factors affecting number of rides in the Yulu bike-sharing dataset and perform hypothesis testing to identify statistically significant variables.
- **Skills Used**:
  - Exploratory Data Analysis
  - Hypothesis Testing (Z-test, T-test, ANOVA)
  - Outlier detection, distribution analysis
- **Data Processing & Exploratory Analysis :**<br/>
  To make the dataset more interpretable and analysis-ready, I first restructured the raw datetime column by separating it into distinct date and time features.      This enabled both monthly and hourly trend analyses.<br/>
  The original dataset used numeric or binary codes for several categorical variables like season, holiday, and working day. I transformed these into more
  intuitive labels:
    - Season codes were relabeled as Spring, Summer, Fall, and Winter.
    - For holiday and working day, I combined the two binary flags to create a new feature: day_type, classifying each day as a Weekday, Weekend, or Holiday based        on its logic.
- **Rental Trends Across Months (2011–2012) :**<br/>
  By aggregating the data month-wise, I observed a clear seasonal pattern:
  - Ride counts consistently dip in January and peak mid-year, aligning with seasonal behavior.
  - The drop in January 2011 was more severe than in January 2012, and the peak in June 2012 was notably higher than June 2011.

  This suggests a recovery and growth in rental activity across the two years.

- **Growth in User Segments :**<br/>
  Analyzing the two user types over time:

  -Registered user rides increased by 70.43% from 2011 to 2012.
  -Casual user rides increased by 51.66% during the same period.
  -The faster growth in registered users suggests increasing brand loyalty or adoption of subscription-based access over time.

- ![**Daily Usage Behavior :**](hour_count.png)<br/>
  ![Plotting ride counts across the 24-hour clock revealed a bimodal distribution:](hour_count.png)

  - Morning peak at 8 AM

  - Evening peaks at 5–6 PM

  These patterns align with commute hours, highlighting that a major share of users leverage Yulu as a transport alternative for work or school during rush hours.

- **Key Insights**:
  - Duration of ride is dependent on time of day
  - Significant differences exist across user types and locations
  - Actionable suggestions for optimizing user engagement and fleet placement
