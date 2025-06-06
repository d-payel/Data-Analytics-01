#  Hypotheis Testing and Exploratory Data Analysis on YULU Bike Share Demand
- **Objective**: Investigate factors affecting number of rides in the Yulu bike-sharing dataset and perform hypothesis testing to identify statistically significant variables.
- **Skills Used**:
  - Exploratory Data Analysis
  - Hypothesis Testing (T-test, Levene's Test, ANOVA, Kruskal-Wallis Test, ChiSquare Test)
  - Outlier detection, distribution analysis
- **Data Processing & Exploratory Analysis :**<br/>
  To make the dataset more interpretable and analysis-ready, I first restructured the raw datetime column by separating it into distinct date and time features.      This enabled both monthly and hourly trend analyses.<br/>
  The original dataset used numeric or binary codes for several categorical variables like season, holiday, and working day. I transformed these into more
  intuitive labels:
    - Season codes were relabeled as Spring, Summer, Fall, and Winter.
    - For holiday and working day, I combined the two binary flags to create a new feature: day_type, classifying each day as a Weekday, Weekend, or Holiday based        on its logic.
- **Rental Trends Across Months (2011–2012) :**<br/>

  ![.](Plots/year_month.png)
  
  By aggregating the data month-wise, I observed a clear seasonal pattern:
  - Ride counts consistently dip in January and peak mid-year, aligning with seasonal behavior.
  - The drop in January 2011 was more severe than in January 2012, and the peak in June 2012 was notably higher than June 2011.

  This suggests a recovery and growth in rental activity across the two years.

- **Growth in User Segments :**<br/>

  Analyzing the two user types over time:
  
  -Registered user rides increased by 70.43% from 2011 to 2012.
  -Casual user rides increased by 51.66% during the same period.
  -The faster growth in registered users suggests increasing brand loyalty or adoption of subscription-based access over time.
  
 - **Correlation Pattern:** <br/>
  
    $~~~~~~~~~~~~~~~~$ ![.](Plots/scatter_reg.png)<br/>
    
    From scatter plot:<br/>
    - Observed a linear correlation between registered users and count, especially on weekdays.
    - This validates that registered users are primary contributors to weekday usage spikes.

- **Daily Usage Behavior :**<br/>

  ![..](Plots/hour_count.png)
  
  Plotting ride counts across the 24-hour clock revealed a bimodal distribution:
  
  - Morning peak at 8 AM
  - Evening peaks at 5–6 PM

  These patterns align with commute hours, highlighting that a major share of users leverage Yulu as a transport alternative for work or school during rush hours.
  
- **Outlier Detection & Statistical Analysis:** <br/>

  **Unusual Weather & Human Behavior** <br/>
  - Interestingly, 158 registered and 6 casual users rented bikes during heavy rain, ice-pellets, thunderstorms, and mist — exclusively on weekdays.
  This suggests certain user segments are highly commute-driven, even in extreme weather.

  **Outlier Detection:** <br/>
  
  Visual analysis (boxplots and scatter plots) indicated the presence of outliers in columns like windspeed, count, casual, and registered.<br/>
  Applied Z-score based outlier detection:
  - Windspeed column has 67 outliers (0.62%)
  - Count column has 147 outliers (1.35%)
  - Registered column has 235 outliers (2.16%) 
  - Casual has 292 outliers (2.68%)
  These outliers were retained in the dataset for further analysis, as they may represent genuine extreme cases (e.g., weather anomalies).<br/>
  
  **Seasonal Impact on Ride Count:** <br/> 
  - Boxplot comparisons revealed significant variance differences across seasons — especially between Spring/Winter vs Summer/Fall.<br/>
  
  ![.](Plots/box_plot_season.png)
  
  - To avoid assuming equal variances, used Kruskal-Wallis Test (a non-parametric alternative to ANOVA):
    - P-value: 2.48e-151
    - Strong evidence that ride count varies significantly across seasons

  **Comparing Summer vs Fall:** <br/>
  
    To check if ride behavior differs between Summer and Fall, tested variance first:
    - Levene’s Test P-value: 0.2505 --> Variance is similar
    - Proceeded with T-Test for mean difference:
      - T-Test P-value: 0.00027 --> Strong evidence that mean ride counts differ significantly between Summer and Fall
  
  **Impact of Day Type on Ride Demand:**
    - **Variance Check Across Day Types:**
    - Boxplots for Weekdays, Weekends, and Holidays showed visually similar spread in ride counts.
    - Confirmed using Levene’s Test:
      -  P-value: 0.997 --> Variances are statistically the same (homogeneity in variance holds) so moved forward with ANOVA test.
      - Proceeded with One-Way ANOVA to compare mean ride counts across day types.
        - ANOVA P-value: High(0.4641949837127587)
        - Failed to reject the null hypothesis.<br/>
  **Conclusion:** No statistically significant difference in ride demand across Weekdays, Weekends, and Holidays.
  **Weather Impact on Ride Counts:**
    - **Distribution & Variance Check:**
 
      ![.](Plots/box_plot_weather.png)
      
      - The fourth category of weather showed very low variance in ride counts, indicating concentrated user behavior.
      - For deeper statistical validation between Weather Type 1 and 2, conducted Levene’s Test:
        - P-value: 3.49e-10
        - No homogeneity of variance — cannot proceed with ANOVA.
      - Kruskal-Wallis Test Across Weather Types (As variances differed, used Kruskal-Wallis Test (non-parametric ANOVA alternative)):
        - P-value: 3.50e-44

    - **Conclusion:** Mean ride counts vary significantly across different weather types.
      
  **Season and Weather Dependency Check:**
  
    - **Chi-Square Test of Independence:**
      - Hypothesis: 
        - H₀: Weather and Season are independent,
        - H₁: Weather depends on Season
      - P-value: 1.55e-07
  
    - **Conclusion:** Weather and Season are statistically dependent — a crucial insight when forecasting ride demand based on seasonal weather patterns.
      
  **Additional Insight: Correlation Between Season and Demand:**
  
    - A Spearman correlation analysis between weather_season and rental_count returned a coefficient of -0.479, suggesting a moderate negative relationship.
    - This implies that certain season-weather combinations are consistently linked to lower bike rental demand.
    - While not indicative of a strong linear relationship, the correlation is still statistically meaningful and highlights weather_season as a potentially valuable feature in future predictive modeling efforts.<br/>
    
  ***Note:*** *While this project does not include a predictive model, identifying such relationships is crucial groundwork for future regression or time-series models.*


## **Correlation Heatmap**

$~~~~~~~~~~~~~~~~~~~~~~~~$<img src="Plots/correlation_features_heatmap.png" width=70% height=70%>
      
**Key Insight from Correlation Analysis:** 

  - Temperature (temp) shows a moderate positive correlation with rentals by casual users (~0.57), suggesting warmer weather boosts bike usage.
  - Total rental count (count) is strongly influenced by both registered and casual users, with registered having a near-perfect correlation (~0.99).
  - Humidity negatively correlates with rentals (−0.35), hinting at weather sensitivity.
  - Other features like windspeed and engineered features have minimal linear impact.<br/>
  
   *Further investigation (possibly nonlinear modeling) could improve predictive performance.*

## **User Type Testing and Statistical Analysis:**
  [Initial Observation from Pie Chart:](Plots/pie_reg_cas.png)<br/>
  
    - Registered Users: 81.2%
    - Casual Users: 18.8%
  → Registered users dominate the overall bike rental activity.
  
- **Box Plots were plotted for both user types across weekend, weekday, and holiday:**
  
    ![](Plots_2/reg_2.png)
    
    - Both original and outlier-removed data show visible variance differences among day types.
    - Variance is especially higher for casual users on weekends, indicating leisure behavior.
  - **Levene’s Test for Equal Variance**
    To check if group variances differ significantly:
    - Registered users across days → p-value ≈ 2.03e-45
    - Casual users across days → p-value ≈ 2.06e-287
    Both tests reject the null hypothesis — variances differ significantly.

  - **Investigating Rental Patterns: Registered vs Casual Users**

    The core objective of this analysis was to understand whether registered and casual users follow the same rental pattern across different day types — namely weekdays, weekends, and holidays.
    
    ![](Plots/bike_rentals_by_daytype_reg_users.png)
    
    **Registered Users: Strong Weekday Preference**
    - A bar plot initially showed a significantly higher number of rentals on weekdays for registered users compared to weekends or holidays.
    - To statistically verify this:<br/>
    ## **T-test Results for Registered Users:**
      
      ## Groups Compared $~~~~~~~~~~~~~~~~~~~~~~~~~~$ P-value $~~~~~~~~~~~~~~~~~~~~~~~~~~$ Interpretation
        weekend_reg vs holiday_reg                    0.1791                               No significant difference
        weekday_reg vs weekend_reg	                  9.95 × 10⁻³⁵	                       Significant difference

      **Conclusion:** Registered users rent significantly more on weekdays, likely driven by commuting needs. Weekends and holidays show similar, lower usage. This suggests these users are likely office commuters using YULU for daily travel.



		
- **Key Insights**:
  - Duration of ride is dependent on time of day
  - Significant differences exist across user types and locations
  - Actionable suggestions for optimizing user engagement and fleet placement
