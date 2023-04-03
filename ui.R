## Queue-Simulator ui.R

## Initialize ####
library(shiny)
library(shinydashboard)
library(dplyr)
library(simmer)
library(MASS)
library(ggplot2)

# Set Random Seed ####
set.seed(42)

# Suppress Warnings and Messages
options(warn=-1)
options(verbose = FALSE)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Call Centre Queue: Discrete-Event Simulator"),

    sidebarLayout(
      sidebarPanel(
        
        ### Introduction Text ####
        p("This simulator generates calls and queue times for one business day.
            Up to 1000 calls over 10 hours enter the queue and are
            served as soon as the next agent becomes available, or immediately if
            the queue is empty."),
        
        p("Use the sliders below to set the service standard and parameters
                                for your call centre. Simulate again and again to see how a scenario
                                will play out differently each day."),
        
        ### Controls ####
        #### Service Standard Slider ####
        sliderInput("standard",
                    "Service Standard (Seconds):",
                    min = 0,
                    max = 240,
                    value = 120,
                    step = 10),
        
        #### Number of Agents Slider ####
        sliderInput("agents",
                    "Number of Agents:",
                    min = 1,
                    max = 10,
                    value = 3),
        
        #### Arrival Rate Slider ####
        sliderInput("arrival",
                    "Arrival Rate (calls per hour):",
                    min = 0,
                    max = 60,
                    value = 30),
        
        #### Service Time Slider ####
        sliderInput("service",
                    "Average Service Time (minutes):",
                    min = 1,
                    max = 10,
                    value = 5),
        
        #### Simulation Action ####
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
          "View the source code on ",
          tags$a(href = "https://github.com/db-bangs/Queue-Simmer",
                 "GitHub.")
        ),
        
        br(),
        
        tags$div(
          "The simulation is created with package
            `simmer` (Ucar et al., 2019). Refer to their ",
          tags$a(href="https://r-simmer.org/",
                 "website "),
          "for details on how the discrete-event simulations are performed."),
        
        br(),
        
        p("Ucar I, Smeets B, Azcorra A (2019). “simmer: Discrete-Event Simulation for R.” Journal of Statistical Software, 90(2), 1–30."),
        
        br(),
        
        tags$div(
          "Shiny App by ",
          tags$a(href = "https://github.com/db-bangs",
                 "Donovan Bangs "),
          "- last updated January 29, 2023")
      ),
      
      ### Main Panel ####
      mainPanel(
        #### KPI Boxes ####
        fluidRow(
          valueBox("", subtitle = "", width = 1),
          valueBoxOutput("totalCalls_box", width = 2),
          valueBoxOutput("metStandard_box", width = 2),
          valueBoxOutput("avgCall_box", width = 2),
          valueBoxOutput("percentile80_box", width = 2),
          valueBoxOutput("maxCall_box", width = 2),
          align = 'center'
        ),
        #### KPI Table ####
        #dataTableOutput("simmerTable"),
        #### Plot ####
        plotOutput("simmerPlot", height = 600)
      )
    )
))
