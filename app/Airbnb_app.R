library(shiny)
library(DT)
library(tidyverse)
library(ggstance)
library(broom)
library(ggthemes)
library(leaflet)
library(shinythemes)
library(tigris)
library(sp)
library(maptools)
library(httr)
library(rgdal)
library(ui)
library(rsconnect)
library(plotly)

# Karan
airbnb <- read_csv("../data/AB_NYC_2019.csv")
airbnbd <- airbnb
airbnb %>%
  dplyr::select(-latitude, -longitude) ->
  airbnbR


# Marzuq
airbnb_price <- read_rds("../data/airbnb_price.RDS")
glimpse(airbnb_price)
nysub <- read_rds("../data/clean_sub.RDS")
glimpse(nysub)

# Amy
head(airbnb)
names(airbnb)[5] <- "borough"
airbnb <- airbnb%>%
  select(id, name, host_id, borough, latitude, longitude, room_type, price, number_of_reviews)%>%
  mutate(id = as.factor(id),
         host_id = as.factor(host_id))
borough <- c("Brooklyn", "Manhattan", "Queens", "Staten Island", "Bronx")
room_type <- c("Private room", "Entire home/apt", "Shared room")
pal <- colorFactor(c("#FF5A5F", "#00A699","#767676"), domain = c("Entire home/apt", "Private room","Shared room"))
max(airbnb$price)
min(airbnb$price)
max(airbnb$number_of_reviews)
min(airbnb$number_of_reviews)

ui <- fluidPage(shinythemes::themeSelector(),
                fluidRow(
                  column(4,
                         titlePanel("New York City Airbnb")
                  ),
                  column(4
                  ),
                  column(4,
                         tags$img(src = "airbnb.png",  height = "60")
                  )
                ),
                tabsetPanel(
                  tabPanel("Dataset",
                           dataTableOutput("dt")
                  ),
                  tabPanel("Histograms",
                           sidebarLayout(
                             sidebarPanel(
                               varSelectInput("univar", "Variable to Plot", data = airbnbR, selected = "price"),
                               checkboxInput("unilog", "Log X"),
                               sliderInput("unibins", "Bins", min = 1, max = 100, value = 20),
                               numericInput("uninull", "Null Value", value = 0),
                               tableOutput("unitest_results")
                             ),
                             mainPanel(
                               plotOutput("hist")
                             )
                           )
                  ),
                  tabPanel("Plots",
                           sidebarLayout(
                             sidebarPanel(
                               varSelectInput("var1", "Variable X", data = airbnbR, selected = "neighbourhood_group"),
                               checkboxInput("var1log", "Log X"),
                               varSelectInput("var2", "Variable Y", data = airbnbR, selected = "price"),
                               checkboxInput("var2log", "Log Y"),
                               checkboxInput("ols", "OLS Line")
                             ),
                             mainPanel(
                               plotOutput("scatter")
                             )
                           )
                  ),
                  tabPanel(
                    "Price/Subway Map",
                    sidebarLayout(
                      sidebarPanel(
                        selectInput("var",
                                    label = "Airbnb or Subway?",
                                    choices = list("Airbnb", "Subway"), 
                                    selected = "Airbnb")
                      ),
                      mainPanel(
                        leafletOutput("PriceMap")
                      )
                    )
                  ),
                  tabPanel(
                    "Price/Distance Relationship",
                    sidebarLayout(
                      sidebarPanel(
                        checkboxInput("logx", "Log the Distance Variable"),
                        checkboxInput("logy", "Log the Price Variable"),
                        tableOutput("lmt"),
                        tableOutput("minT"),
                        tableOutput("maxT")
                      ),
                      mainPanel(
                        plotOutput("PDplot")
                      )
                    )
                  ),
                  tabPanel("Rental Finder",
                           div(class="outer",
                               leafletOutput("map"),
                               absolutePanel(
                                 column(3, checkboxGroupInput("borough","Neighborhood:",
                                                              choices = borough,
                                                              selected = borough),
                                        checkboxGroupInput("room_type","Room Type:",
                                                           choices = room_type,
                                                           selected = room_type),
                                        sliderInput("price", "Budget:", min = 0,  
                                                    max = 10000, value = c(0, 3000), step = 50),
                                        sliderInput("review", "Number of Reviews:", min = 0,
                                                    max = 629, value = c(0,200), step = 10)),
                                 column(5, plotOutput("plot1")),
                                 column(4, plotOutput("plot2")))
                           )
                  ),
                  tabPanel("Reference", textOutput("ref1"),
                           textOutput("ref2"),
                           textOutput("ref3")
                  )
                )
)


server <- function(input, output, session) {
  output$hist <- renderPlot({
    pl <- ggplot(airbnbR, aes(x = !!input$univar)) +
      theme_bw()
    
    if (is.numeric(airbnbR[[input$univar]])) {
      pl <- pl + geom_histogram(bins = input$unibins, fill = "light blue", color = "black")
      if (input$unilog) {
        pl <- pl + scale_x_log10()
      }
    } else {
      pl <- pl + geom_bar(fill = "light blue", color = "black")
    }
    
    pl
  })
  
  output$unitest_results <- renderTable({
    if (input$unilog & is.numeric(airbnbR[[input$univar]])) {
      airbnbR %>%
        mutate(logvar = log2(!!input$univar + 0.5)) -> temp
      t.test(temp[["logvar"]], mu = input$uninull) %>%
        tidy() %>%
        select(`P-value` = p.value,
               Lower = conf.low,
               Upper = conf.high)
    } else if (is.numeric(airbnbR[[input$univar]])) {
      t.test(airbnbR[[input$univar]], mu = input$uninull) %>%
        tidy() %>%
        select(`P-value` = p.value,
               Lower = conf.low,
               Upper = conf.high)
    } else {
      "Not a numeric"
    }
  })
  
  output$scatter <- renderPlot({
    airbnbR %>%
      ggplot(aes(x = !!input$var1, y = !!input$var2)) +
      theme_bw() ->
      pl
    if (is.numeric(airbnbR[[input$var1]]) & is.numeric(airbnbR[[input$var2]])) {
      pl <- pl + geom_point(color = "#FF5A5F")
    } else if (!is.numeric(airbnbR[[input$var1]]) & is.numeric(airbnbR[[input$var2]])) {
      pl <- pl + geom_boxplot(fill = "#00A699")
    } else if (is.numeric(airbnbR[[input$var1]]) & !is.numeric(airbnbR[[input$var2]])) {
      pl <- pl + geom_boxploth(fill = "#00A699")
    } else {
      pl <- pl + geom_jitter()
    }
    
    if (input$var1log & is.numeric(airbnbR[[input$var1]])) {
      pl <- pl + scale_x_log10()
    }
    
    if (input$var2log & is.numeric(airbnbR[[input$var2]])) {
      pl <- pl + scale_y_log10()
    }
    
    if (input$ols & is.numeric(airbnbR[[input$var1]]) & is.numeric(airbnbR[[input$var2]])) {
      pl <- pl + geom_smooth(se = FALSE, method = "lm")
    }
    
    pl
  })
  
  output$dt <- renderDataTable({
    airbnbd
  }, 
  options = list(pageLength = 10)
  )
  
  output$PriceMap <- renderLeaflet({
    if (input$var == "Airbnb") {
      leaflet(airbnb_price) %>%
        addTiles() %>%
        setView(-74.00, 40.71, zoom = 12)%>%
        addMarkers(clusterOptions = markerClusterOptions(), 
                   popup = ~paste("-Listing: ", name, 
                                  "-Subway Distance (miles): ", near_sub,
                                  sep = "<br/>"),
                   label = ~paste("Price: $",price))
    } else if (input$var == "Subway") {
      leaflet(nysub) %>%
        addTiles() %>%
        setView(-74.00, 40.71, zoom = 12)%>%
        addMarkers(clusterOptions = markerClusterOptions(), 
                   label = ~as.character(str_c("Subway Station: ", NAME)),
                   popup = ~as.character(str_c("Subway Line: ", LINE)))
    }
  })
  
  output$lmt <- renderTable({
    if (input$logx == TRUE & input$logy == FALSE) {
      newlm <- lm(price ~ log(near_sub), airbnb_price)
    } else if (input$logx == FALSE & input$logy == TRUE) {
      newlm <- lm(log(price + 1 - min(price)) ~ near_sub, airbnb_price)
    } else if (input$logx == TRUE & input$logy == TRUE) {
      newlm <- lm(log(price + 1 - min(price)) ~ log(near_sub), airbnb_price)
    } else {
      newlm <- lm(price ~ near_sub, airbnb_price)
    }
    tidy(newlm, conf.int = TRUE) %>%
      select(term, estimate, p.value) 
  })
  
  output$minT <- renderTable({
    airbnb_price %>%
      select("Min Price" = price) %>%
      arrange(`Min Price`) %>%
      head(n = 5) -> c1
    airbnb_price %>%
      select("Min Distance" = near_sub) %>%
      arrange(`Min Distance`) %>%
      head(n = 5) -> c2
    airbnb_price %>%
      mutate(pricel = log10(price + 1 - min(price))) %>%
      select("Min Price" = pricel) %>%
      arrange(`Min Price`) %>%
      head(n = 5) -> c3
    airbnb_price %>%
      mutate(near_subl = log10(near_sub)) %>%
      select("Min Distance" = near_subl) %>%
      arrange(`Min Distance`) %>%
      head(n = 5) -> c4
    
    if (input$logx == TRUE & input$logy == FALSE) {
      bind_cols(c4, c1)
    } else if (input$logx == FALSE & input$logy == TRUE) {
      bind_cols(c2, c3)
    } else if (input$logx == TRUE & input$logy == TRUE) {
      bind_cols(c4, c3)
    } else {
      bind_cols(c2, c1)
    }
  })
  
  output$maxT <- renderTable({
    airbnb_price %>%
      select("Max Price" = price) %>%
      arrange(-`Max Price`) %>%
      head(n = 5) -> c_1
    airbnb_price %>%
      select("Max Distance" = near_sub) %>%
      arrange(-`Max Distance`) %>%
      head(n = 5) -> c_2
    airbnb_price %>%
      mutate(pricel = log10(price + 1 - min(price))) %>%
      select("Max Price" = pricel) %>%
      arrange(-`Max Price`) %>%
      head(n = 5) -> c_3
    airbnb_price %>%
      mutate(near_subl = log10(near_sub)) %>%
      select("Max Distance" = near_subl) %>%
      arrange(-`Max Distance`) %>%
      head(n = 5) -> c_4
    
    if (input$logx == TRUE & input$logy == FALSE) {
      bind_cols(c_4, c_1)
    } else if (input$logx == FALSE & input$logy == TRUE) {
      bind_cols(c_2, c_3)
    } else if (input$logx == TRUE & input$logy == TRUE) {
      bind_cols(c_4, c_3)
    } else {
      bind_cols(c_2, c_1)
    }
  })
  
  output$PDplot <- renderPlot({
    airbnb_price %>%
      ggplot(aes(x=near_sub, y=price)) +
      geom_smooth(method = "lm", se = FALSE, color = "black") +
      geom_point(aes(color = neighbourhood_group)) +
      ylab("Rental Price (USD)") +
      xlab("Distance from Nearest Subway Station (Miles)") +
      labs(color = "Neighborhood") +
      theme_bw() -> pl
    
    airbnb_price %>%
      ggplot(aes(x=near_sub, y=log10(price + 1 - min(price)))) +
      geom_smooth(method = "lm", se = FALSE, color = "black") +
      geom_point(aes(color = neighbourhood_group)) +
      ylab("Rental Price (USD)") +
      xlab("Distance from Nearest Subway Station (Miles)") +
      labs(color = "Neighborhood") +
      theme_bw() -> nl
    
    airbnb_price %>%
      ggplot(aes(x=log10(near_sub), y=price)) +
      geom_smooth(method = "lm", se = FALSE, color = "black") +
      geom_point(aes(color = neighbourhood_group)) +
      ylab("Rental Price (USD)") +
      xlab("Distance from Nearest Subway Station (Miles)") +
      labs(color = "Neighborhood") +
      theme_bw() -> ol
    
    airbnb_price %>%
      ggplot(aes(x=log10(near_sub), y=log10(price + 1 - min(price)))) +
      geom_smooth(method = "lm", se = FALSE, color = "black") +
      geom_point(aes(color = neighbourhood_group)) +
      ylab("Rental Price (USD)") +
      xlab("Distance from Nearest Subway Station (Miles)") +
      labs(color = "Neighborhood") +
      theme_bw() -> ql
    
    if (input$logx == TRUE & input$logy == FALSE) {
      ol
    } else if (input$logx == FALSE & input$logy == TRUE) {
      nl
    } else if (input$logx == TRUE & input$logy == TRUE) {
      ql
    } else {
      pl 
    }
  })
  
  mapdata <- reactive({
    airbnb %>%
      filter(borough %in% input$borough,
             room_type %in% input$room_type,
             price >= input$price[1],
             price<= input$price[2],
             number_of_reviews >=input$review[1],
             number_of_reviews <=input$review[2])
  })
  
  output$map <- renderLeaflet({
    leaflet(mapdata()) %>%
      setView(lng = -73.94197, lat = 40.73638, zoom = 12) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addTiles()%>%
      addMarkers(clusterOptions = markerClusterOptions(),
                 popup = ~paste("Neighborhood:", borough,
                                "Room Type:", room_type,
                                "Budget:", price,
                                "Number of Reviews:", number_of_reviews,
                                sep = "<br/>"))
  })
  
  output$plot1 <- renderPlot({
    mapdata()%>%
      ggplot(aes(x = borough, y = price)) +
      geom_boxplot(fill = "#FF5A5F") +
      theme_bw() +
      xlab("Neighborhood") +
      ylab("Price") +
      scale_y_log10()
  })
  
  output$plot2 <- renderPlot({
    mapdata()%>%
      ggplot(aes(x = room_type, y = price)) +
      geom_boxplot(fill = "#00A699") +
      theme_bw() +
      xlab("Room Type") +
      ylab("Price") +
      scale_y_log10()
  })
  
  output$ref1 <- renderText("https://nycdatascience.com/blog/student-works/how-airbnb-is-in-nyc-interactive-data-visualization-in-r/")
  output$ref2 <- renderText("https://rstudio.github.io/leaflet/markers.html")
  output$ref3 <- renderText("https://usbrandcolors.com/airbnb-colors/")
}

shinyApp(ui, server)
