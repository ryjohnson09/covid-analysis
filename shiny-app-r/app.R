library(shiny)
library(bslib)
library(pins)
library(httr2)
library(jsonlite)
library(tidyverse)
library(bsicons)
library(glue)
library(scales)

# Setup ---------------------------------------------------------

# Read in Data
board <- pins::board_connect()
covid_data <- pin_read(board, "publisher1/covid_data") %>% 
  tibble() %>%
  mutate(date = ymd(date)) %>% 
  mutate(month_day = format(date, "%b %d")) %>% 
  mutate(years_date = as.Date(month_day, "%b %d"))

api_url <- "https://woodoo-orangutan.staging.eval.posit.co/cnct/covid-predict/predict"

state_province <- covid_data$province_state[1]

# UI -----------------------------------------------------------

ui <- page_sidebar(
  title = glue("Covid Dashboard - {state_province}"),
  sidebar = sidebar(
    dateInput("date", "Select Date:", value = "2022-01-01")
  ),
  layout_columns(
    fill = FALSE,
    value_box(
      title = "Total Reported Cases:",
      value = comma(max(covid_data$state_count)),
      showcase = bsicons::bs_icon("bug")
    ),
    value_box(
      title = "Single Day Max Cases:",
      value = comma(max(covid_data$new_cases)),
      showcase = bsicons::bs_icon("calendar-day")
    ),
    value_box(
      title = "Predicted Cases:",
      value = textOutput("pred"),
      showcase = bsicons::bs_icon("graph-up")
      )
    ),
  card(
    full_screen = TRUE,
    plotOutput("covid_plot")
  )
)

# Server ------------------------------------------------------
server <- function(input, output) {
  
  # Convert Date to year number for API query
  year_day_number <- reactive({
    as.numeric(strftime(input$date, format = "%j"))
  })
  
  
  # Output predicted cases
  output$pred <- renderText({
    # Set parameters
    params <- data.frame(
      DayOfYear = year_day_number()
    )
    
    # Get API response
    response <- request(api_url) %>% 
      req_body_json(params) %>% 
      req_perform() %>% 
      resp_body_json()
    
    # Return response
    round(response$predict[[1]])
  })
    
  
  # Convert date to number
  date_number <- reactive({
    as.Date(format(input$date, "%b %d"), "%b %d")
  })
    
  # Output Plot
  output$covid_plot <- renderPlot({
    ggplot(data = covid_data, aes(x = years_date, y = new_cases)) + 
      geom_point(size = 3, alpha = 0.8) +
      labs(x = "Day of Year",
           y = "New Covid Cases",
           title = glue("New Cases per Day in {state_province}"),
           subtitle = "From Jan 2020 to March 2023") +
      scale_x_date(date_labels = "%b %d") +
      scale_y_continuous(labels = comma_format()) +
      geom_vline(xintercept = as.Date(format(date_number(), "%b %d"), "%b %d"),
                 linewidth = 2, linetype = "dashed", color = "#9A4665") +
      theme_minimal() +
      theme(
        axis.text = element_text(size = 15),
        plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 15, face = "bold")
      )
  })
}

# Shiny App ----------------------------------------------------

shinyApp(ui, server)