## Queue-Simulator ui.R

## Initialize ####
library(shiny)
library(simmer)
library(MASS)
library(ggplot2)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Call Centre: Discrete-Event Simulator"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
          
          p("This simulator generates calls and queue times for one business day
            using the three variables you set below. 
            Up to 1000 calls over 10 hours enter the queue and are
            served as soon as the next agent becomes available, or immediately if
            the queue is empty. Press 'Simulate Again' to see how the same scenario 
            can play out differently day-to-day."),
          
          p("The simulation will stop taking calls
            when the last will only be served at the end of the day. Try to
            'break' the system and see what it takes to overwhelm your call
            centre."),
          
          
          br(),
          
            sliderInput("agents",
                        "Number of Agents:",
                        min = 1,
                        max = 10,
                        value = 3),
            
            sliderInput("arrival",
                        "Arrival Rate (calls per hour):",
                        min = 1,
                        max = 60,
                        value = 30),
            
            sliderInput("service",
                        "Average Service Time (minutes):",
                        min = 1,
                        max = 10,
                        value = 5),
            actionButton("sim", "Simulate Again"),
          
          
          p(" "),
          
          br(),
          
          tags$div(
            "To see a complete year's time series of calls, download the dataset on ",
            tags$a(href="https://www.kaggle.com/datasets/donovanbangs/call-centre-queue-simulation",
                   "Kaggle.")
          ),
          
          br(),
          
          tags$div(
          "The simulation is performed with package
            `simmer` (Ucar et al., 2019). Refer to their ",
          tags$a(href="https://r-simmer.org/",
          "website "),
          "for details on how the discrete-event simulations are performed."),
          
          br(),
          
          p("Ucar I, Smeets B, Azcorra A (2019). “simmer: Discrete-Event Simulation for R.” Journal of Statistical Software, 90(2), 1–30.")
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("simmerPlot", height = 600)
        )
    )
))
