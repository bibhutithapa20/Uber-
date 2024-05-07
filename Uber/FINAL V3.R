library(shiny)
library(dplyr)
library(readr)
library(ggplot2)
library(leaflet)


# Set working directory
#setwd('~/Documents/Uber')

all_data <- readRDS("all_data.rds")

# Define UI
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

# Define server logic
server <- function(input, output) {
  
  # Process data and create plots
  output$plot <- renderPlot({
    if (input$plot_type == "Trips Every Hour") {
      trips_by_hour <- all_data %>%
        mutate(hour = format(Date_Time, "%H")) %>%
        group_by(hour) %>%
        summarize(total_trips = n())
      
      ggplot(trips_by_hour, aes(x = hour, y = total_trips)) +
        geom_bar(stat = "identity", fill = "skyblue") +
        labs(x = "Hour of Day", y = "Total Trips", title = "Trips Every Hour") +
        theme_minimal()
    } else if (input$plot_type == "Trips by Day of Month") {
      trips_by_day <- all_data %>%
        mutate(day = format(Date_Time, "%d")) %>%
        group_by(day) %>%
        summarize(total_trips = n())
      
      ggplot(trips_by_day, aes(x = day, y = total_trips)) +
        geom_bar(stat = "identity", fill = "lightgreen") +
        labs(x = "Day of Month", y = "Total Trips", title = "Trips by Day of Month") +
        theme_minimal()
    } else if (input$plot_type == "Trips by Base and Month") {
      ggplot(all_data, aes(x = Base, fill = factor(format(Date_Time, "%m")))) +
        geom_bar(position = "dodge") +
        labs(x = "Base", y = "Total Trips", title = "Trips by Base and Month") +
        scale_fill_discrete(name = "Month") +
        theme_minimal()
    } else if (input$plot_type == "Hourly Heatmap") {
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
    } else if (input$plot_type == "Trips by Day and Month") {
      trips_by_day_month <- all_data %>%
        mutate(day = format(Date_Time, "%d"),
               month = format(Date_Time, "%m")) %>%
        group_by(month, day) %>%
        summarize(total_trips = n())
      
      ggplot(trips_by_day_month, aes(x = day, y = total_trips, fill = month)) +
        geom_bar(stat = "identity", position = "dodge") +
        labs(x = "Day of Month", y = "Total Trips", title = "Trips by Day and Month") +
        scale_fill_discrete(name = "Month") +
        theme_minimal()
    } else if (input$plot_type == "Monthly Heatmap") {
      month_week_heatmap <- all_data %>%
        mutate(week = format(Date_Time, "%W")) %>%
        group_by(month, week) %>%
        summarize(total_trips = n())
      
      ggplot(month_week_heatmap, aes(x = week, y = month, fill = total_trips)) +
        geom_tile() +
        labs(x = "Week of Year", y = "Month", fill = "Total Trips") +
        scale_fill_gradient(low = "white", high = "blue") +
        theme_minimal()
    } else if (input$plot_type == "Geospatial Map") {
      leaflet() %>%
        addTiles() %>%
        addMarkers(data = all_data,
                   lng = ~Lon, lat = ~Lat,
                   popup = ~paste("Base:", Base, "<br>",
                                  "Date/Time:", Date_Time)) %>%
        setView(lng = -73.9808, lat = 40.7648, zoom = 10) # Set the view to New York City
    }
  })

  # Explanation of each plot
  output$plot_explanation <- renderText({
    explanation <- switch(input$plot_type,
                          "Trips Every Hour" = "This plot showcases the total number of Uber trips made during each hour of the day. It reveals peak hours of activity, helping to understand when demand for Uber services is highest and lowest throughout the day. This information can be crucial for drivers to plan their schedules effectively and for Uber to optimize its service provision. Per visual for uber data, the 16th to 18th hour is where volume is the heighest, hence it can be a decision maker for uber riders to provide their service during this time. ",
                          "Trips by Day of Month" = "This visualization displays the total number of Uber trips made on each day of the month. It provides insights into the variation of demand across different days, helping to identify trends such as weekly patterns or specific days with higher or lower activity. Understanding these patterns can assist in resource allocation and service planning. Per Uber data  ",
                          "Trips by Base and Month" = "This plot illustrates the total number of Uber trips originating from each base, categorized by month. It helps to identify the popularity of different bases across various months, revealing areas of high demand and potential areas for expansion or adjustment of service coverage. Understanding base-specific demand variations can aid in strategic decision-making for resource allocation.",
                          "Hourly Heatmap" = "The heatmap visualizes the distribution of Uber trips throughout the hours of the day and days of the month. It provides a comprehensive view of when and how frequently trips occur, highlighting busy periods and periods of relative inactivity. This information can be invaluable for optimizing driver deployment and service availability to meet fluctuating demand.",
                          "Trips by Day and Month" = "This plot shows the total number of Uber trips made on each day of the month, categorized by month. It offers a detailed understanding of daily trip patterns across different months, revealing any monthly variations or consistent trends. Identifying such patterns can help in developing targeted promotional strategies or operational adjustments to meet varying demand levels.",
                          "Monthly Heatmap" = "The heatmap visualizes the distribution of Uber trips throughout the weeks of the year and months. It provides a macro-level view of trip density over time, highlighting seasonal trends and long-term patterns. Analyzing these trends can inform strategic decisions related to service expansion, marketing campaigns, and infrastructure planning.",
                          "Geospatial Map" = "This map displays the locations of Uber pickups, with markers indicating the base and date/time of each trip. It offers a visual representation of trip origins, allowing for spatial analysis of demand hotspots and coverage areas. Understanding the geographical distribution of trips is essential for optimizing driver routing, identifying underserved areas, and improving overall service efficiency."
    )
    return(explanation)
  })
}

# Authenticate with shinyapps.io (Only required once)
#rsconnect::setAccountInfo(name='your_shinyapps.io_account_name', 
 #                         token='your_shinyapps.io_token', 
  #                        secret='your_shinyapps.io_secret')

# Deploy the Shiny app
#rsconnect::deployApp(appDir = ".", appName = "Uber")
  # Run the application
  shinyApp(ui = ui, server = server)
