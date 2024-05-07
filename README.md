# Uber Assignment 
## Contributor 
- Bibhuti Thapa

## Introductions 
In this analysis, we explore Uber trip data to gain insights into trip patterns and trends, aiding in operational decisions and service optimization.

## Data Dictionary
### Main Columns
- **Date/Time:** Date and time of the trip
- **Base:** Uber base code
- **Lat:** Latitude of pickup location
- **Lon:** Longitude of pickup location

## Install Packages and Library
```
library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(leaflet)
```
## Data Loading and Preparation
We load and prepare the Uber trip data for analysis, including binding all the monthly data into one dataframe and formatting the date/time column.
```
all_data <- readRDS("all_data.rds")
```

### Shiny App
We have developed a Shiny app to visualize and interact with the Uber trip data, allowing users to explore various aspects of trip patterns.

This part of the code defines the user interface (UI) layout for the Shiny web application. Let's break it down:

- fluidPage(): This function creates a page layout that automatically adjusts to the size of the user's screen or browser window.
- titlePanel(): This function creates a title at the top of the page. In this case, it sets the title to "Uber Trips Analysis".
- sidebarLayout(): This function creates a layout with a sidebar panel on the left and a main panel on the right.
- sidebarPanel(): Inside the sidebar layout, this function creates a sidebar panel where users can interact with the application. It contains a selectInput() widget, which creates a - -- dropdown menu (select element in HTML) labeled "Select plot type". Users can choose from different plot types listed in the choices argument.
- mainPanel(): Inside the sidebar layout, this function creates the main panel where the output of the selected plot will be displayed. It contains two elements: plotOutput("plot") and - textOutput("plot_explanation"). These are placeholders where the plots and their explanations will be rendered based on user input.

```
ui <- fluidPage(
  titlePanel("Uber Trips Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("plot_type", "Select plot type", 
                  choices = c("Trips Every Hour", "Trips by Day of Month", "Trips by Base and Month",
                              "Hourly Heatmap", "Trips by Day and Month", "Monthly Heatmap",
                              "Geospatial Map"))
    ),
    mainPanel(
      plotOutput("plot"),
      textOutput("plot_explanation")
    )
  )
)

```
## server() Function: 
This function defines the server-side logic of the Shiny application. It takes two arguments: input and output.
```
server <- function(input, output) {

```
### Output Rendering: 
This line sets up a reactive expression for rendering plots in the Shiny app. The output is named plot
```
output$plot <- renderPlot({

```
## Conditional Plotting: 
This if statement checks the user's input selection (input$plot_type) to determine which plot to generate.
```
if (input$plot_type == "Trips Every Hour") {

```
## Data Processing: 
This code segment processes the Uber trips data (all_data). It calculates the total number of trips made during each hour of the day (Trips Every Hour plot type).
```
trips_by_hour <- all_data %>%
  mutate(hour = format(Date_Time, "%H")) %>%
  group_by(hour) %>%
  summarize(total_trips = n())

```
## Plot Generation: 
Here, a bar plot is created using ggplot2 based on the processed data (trips_by_hour). It visualizes the total number of trips made during each hour of the day.
```
ggplot(trips_by_hour, aes(x = hour, y = total_trips)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(x = "Hour of Day", y = "Total Trips", title = "Trips Every Hour") +
  theme_minimal()

```
## Conditional Branching: 
This else if statement checks if the user selected the "Trips by Day of Month" plot type.
```
} else if (input$plot_type == "Trips by Day of Month") {

```
## Data Processing (Different Plot Type):
Similar to the previous block, this segment calculates the total number of trips made on each day of the month (Trips by Day of Month plot type).
```
trips_by_day <- all_data %>%
  mutate(day = format(Date_Time, "%d")) %>%
  group_by(day) %>%
  summarize(total_trips = n())

```
## Plot Generation (Different Plot Type):
This code creates a bar plot showing the total trips made on each day of the month, with aesthetics customized for the "Trips by Day of Month" plot.
```
ggplot(trips_by_day, aes(x = day, y = total_trips)) +
  geom_bar(stat = "identity", fill = "lightgreen") +
  labs(x = "Day of Month", y = "Total Trips", title = "Trips by Day of Month") +
  theme_minimal()

```
# PLOTS 
## Uber Trips Analysis 
### Trips Every Hour:
- Description: This plot showcases the total number of Uber trips made during each hour of the day. It reveals peak hours of activity, helping to understand when demand for Uber services is highest and lowest throughout the day. This information can be crucial for drivers to plan their schedules effectively and for Uber to optimize its service provision.
- Explanation: Per visual for Uber data, the 16th to 18th hour is where volume is the highest, hence it can be a decision-maker for Uber riders to provide their service during this time.
```
# Code for Trips Every Hour plot
trips_by_hour <- all_data %>%
  mutate(hour = format(Date_Time, "%H")) %>%
  group_by(hour) %>%
  summarize(total_trips = n())

ggplot(trips_by_hour, aes(x = hour, y = total_trips)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(x = "Hour of Day", y = "Total Trips", title = "Trips Every Hour") +
  theme_minimal()
```
### Trips by Day of the Month
- Description: This visualization displays the total number of Uber trips made on each day of the month. It provides insights into the variation of demand across different days, helping to identify trends such as weekly patterns or specific days with higher or lower activity.
- Explanation: Per Uber data, the 30th day of the month has the highest rides, and the 31st day of the month has the least. It is important to consider that there are limited numbers of months that have the 31st day.
```
# Code for Trips by Day of Month plot
trips_by_day <- all_data %>%
  mutate(day = format(Date_Time, "%d")) %>%
  group_by(day) %>%
  summarize(total_trips = n())

ggplot(trips_by_day, aes(x = day, y = total_trips)) +
  geom_bar(stat = "identity", fill = "lightgreen") +
  labs(x = "Day of Month", y = "Total Trips", title = "Trips by Day of Month") +
  theme_minimal()

```
### Trips by Base of the Month
- Description: This plot illustrates the total number of Uber trips originating from each base, categorized by month. It helps to identify the popularity of different bases across various months, revealing areas of high demand and potential areas for expansion or adjustment of service coverage.
- Explanation: Understanding base-specific demand variations can aid in strategic decision-making for resource allocation.
```
# Code for Trips by Base and Month plot
ggplot(all_data, aes(x = Base, fill = factor(format(Date_Time, "%m")))) +
  geom_bar(position = "dodge") +
  labs(x = "Base", y = "Total Trips", title = "Trips by Base and Month") +
  scale_fill_discrete(name = "Month") +
  theme_minimal()

```
### Hourly Heatmap
- Description: The heatmap visualizes the distribution of Uber trips throughout the hours of the day and days of the month. It provides a comprehensive view of when and how frequently trips occur, highlighting busy periods and periods of relative inactivity.
- Explanation: This information can be invaluable for optimizing driver deployment and service availability to meet fluctuating demand.
```
# Code for Hourly Heatmap plot
hour_day_heatmap <- all_data %>%
  mutate(hour = format(Date_Time, "%H"),
         day = format(Date_Time, "%d")) %>%
  group_by(hour, day) %>%
  summarize(total_trips = n())

ggplot(hour_day_heatmap, aes(x = hour, y = day, fill = total_trips)) +
  geom_tile() +
  labs(x = "Hour of Day", y = "Day of Month", fill = "Total Trips") +
  scale_fill_gradient(low = "white", high = "blue") +
  theme_minimal()

```
### Monthly Heatmap
- Description: The heatmap visualizes the distribution of Uber trips throughout the weeks of the year and months. It provides a macro-level view of trip density over time, highlighting seasonal trends and long-term patterns.
- Explanation: Analyzing these trends can inform strategic decisions related to service expansion, marketing campaigns, and infrastructure planning.
```
# Code for Monthly Heatmap plot
month_week_heatmap <- all_data %>%
  mutate(week = format(Date_Time, "%W")) %>%
  group_by(month, week) %>%
  summarize(total_trips = n())

ggplot(month_week_heatmap, aes(x = week, y = month, fill = total_trips)) +
  geom_tile() +
  labs(x = "Week of Year", y = "Month", fill = "Total Trips") +
  scale_fill_gradient(low = "white", high = "blue") +
  theme_minimal()

```
### Geospatial Map
- Description: This map displays the locations of Uber pickups, with markers indicating the base and date/time of each trip. It offers a visual representation of trip origins, allowing for spatial analysis of demand hotspots and coverage areas.
- Explanation: Understanding the geographical distribution of trips is essential for optimizing driver routing, identifying underserved areas, and improving overall service efficiency.

```
# Code for Geospatial Map plot
sample_df <- all_data %>% sample_n(100000, replace = FALSE)
leaflet(sample_df) %>%
  addTiles() %>%
  addMarkers(data = all_data,
             lng = ~Lon, lat = ~Lat,
             popup = ~paste("Base:", Base, "<br>",
                            "Date/Time:", Date_Time)) %>%
  setView(lng = -73.9808, lat = 40.7648,

```
### Shiny App Initialization:
The function initializes the Shiny web application by combining the user interface (UI) and server logic. It creates an interactive dashboard where users can select plot types and view dynamic visualizations generated by the server in response to their input.
```
shinyApp(ui = ui, server = server)


