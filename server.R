# Queue-Simulator server.R

## Initialize ####
library(shiny)
library(shinydashboard)
library(dplyr)
library(simmer)
library(MASS)
library(zoo)
library(ggplot2)

# Set Random Seed ####
set.seed(42)

# Suppress Warnings and Messages
options(warn=-1)
options(verbose = FALSE)

shinyServer(function(input, output) {

  # Queue Simulator ####
  ## Call Data Simulator####
  call.data <- reactive({
    
    ### Inputs ####
    service_rate <- input$service
    arrival_rate <- input$arrival / 60
    agents <- input$agents
    standard <- input$standard
    
    ### Simulation ####
    customer <-
      trajectory("Customer's path") %>%
      seize("counter") %>%
      timeout(function() {rexp(1, 1/service_rate)}) %>%
      release("counter")
    
    bank <-
      simmer("bank") %>%
      add_resource("counter", agents) %>%
      add_generator("Customer", customer, function() {c(0,rexp(1000, arrival_rate), -1)})
    
    bank %>% run(until = 600)
    
    result <-
      bank %>%
      get_mon_arrivals() %>%
      transform(waiting_time = round(end_time - start_time - activity_time, 2))
    
    result <- result %>%
      mutate(rollmean = rollmean(waiting_time, 11, fill = NA, align = "center"))
    
  }) %>%
    bindEvent(input$sim,
              input$service,
              input$arrival,
              input$agents,
              ignoreNULL = TRUE,
              ignoreInit = FALSE)
  
  
  
  
  ## Plotting ####
  observeEvent(input$sim, ignoreNULL = FALSE, ignoreInit = FALSE, {
    
    output$simmerPlot <- renderPlot({
      
      if(nrow(call.data()) >= 11 ){
        call.data() %>%
          ggplot(aes(start_time, waiting_time)) +
          geom_hline(aes(yintercept = input$standard / 60, color = "Service Standard"), size = 2) +
          geom_line(data = call.data(), aes(x = start_time, y=rollmean, color = "Rolling Average"),
                    size = 2, show.legend = TRUE) +
          scale_color_manual("Legend", values = c("Rolling Average" = "firebrick",
                                                  "Service Standard" = "gray")) +
          geom_point() +
          labs(x = "Start Time (Minutes)",
               y = "Time in Queue (Minutes)",
               legend = "") +
          xlim(c(0,600)) +
          theme_classic() +
          theme(axis.title = element_text(size = 16, face = "bold"),
                plot.title = element_text(size = 16, face = "bold"),
                axis.text = element_text(size = 12, face = "bold"),
                legend.title = element_blank(),
                legend.text = element_text(size = 14, face = "bold"),
                legend.position = c(.10, .95))
      } else {
        call.data() %>%
          ggplot(aes(start_time, waiting_time)) +
          geom_hline(aes(yintercept = input$standard / 60, color = "Service Standard"), size = 2) +
          scale_color_manual("Legend", values = c("Rolling Average" = "firebrick",
                                                  "Service Standard" = "gray")) +
          geom_point() +
          labs(x = "Start Time (Minutes)",
               y = "Time in Queue (Minutes)",
               legend = "") +
          xlim(c(0,600)) +
          theme_classic() +
          theme(axis.title = element_text(size = 16, face = "bold"),
                plot.title = element_text(size = 16, face = "bold"),
                axis.text = element_text(size = 12, face = "bold"),
                legend.title = element_blank(),
                legend.text = element_text(size = 14, face = "bold"),
                legend.position = c(.10, .95))
      }
      
      
    })
  })
  
  
  
  ## Performance Table ####
  output$simmerTable <- renderDataTable({
    call.data() %>%
      mutate(meets_standard = waiting_time <= (input$standard / 60)) %>%
      summarize(total_calls = n(),
                met_standard = paste(round((sum(meets_standard / n() * 100)), 2), "%"),
                avg_wait = paste(round(mean(waiting_time*60), 0), "sec"),
                max_wait = paste(round(max(waiting_time*60), 0), "sec")
      ) %>%
      datatable(
        rownames = FALSE,
        colnames = c("Total Calls" = "total_calls",
                     "Avg. Wait" = "avg_wait",
                     "Max. Wait" = "max_wait",
                     "Met Standard" = "met_standard"),
        options = list(
          'dom' = 't',
          columnDefs = list(list(className = 'dt-center', targets = 0:3)),
          ordering = FALSE)
      )
  })
  
  
  ## KPI valueBoxes ####
  output$totalCalls_box <- renderValueBox(
    call.data() %>%
      summarize(total_calls = n()) %>%
      valueBox("Total Calls")
  )
  
  output$metStandard_box <- renderValueBox(
    call.data() %>%
      mutate(meets_standard = waiting_time <= (input$standard / 60)) %>%
      summarize(met_standard = paste(round((sum(meets_standard / n() * 100)), 1), "%")) %>%
      valueBox("Met Standard")
  )
  
  
  output$percentile80_box <- renderValueBox(
    call.data() %>%
      summarize(percentile80 = paste(round(quantile(waiting_time * 60, probs = 0.8), 0), "sec")) %>%
      valueBox("80th Percentile")
  )
  
  output$avgCall_box <- renderValueBox(
    call.data() %>%
      summarize(avg_wait = paste(round(mean(waiting_time*60), 0), "sec")) %>%
      valueBox("Average Wait")
  )
  
  output$maxCall_box <- renderValueBox(
    call.data() %>%
      summarize(max_wait = paste(round(max(waiting_time*60), 0), "sec")) %>%
      valueBox("Maximum Wait")
  )
})
