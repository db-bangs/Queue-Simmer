# Queue-Simulator server.R

## Initialize ####
library(shiny)
library(simmer)
library(MASS)
library(ggplot2)

shinyServer(function(input, output) {

    output$simmerPlot <- renderPlot({
      
      service_rate <- input$service
      arrival_rate <- input$arrival / 60
      agents <- input$agents
      
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
      
      result %>%
        ggplot(aes(start_time, waiting_time)) +
        geom_point() +
        labs(title = paste("Avg Wait: ", round(mean(result$waiting_time),2), " minutes", " | ",
                           "Max Wait: ", round(max(result$waiting_time),2), " minutes", sep = ""),
             x = "Start Time (Minutes)",
             y = "Time in Queue") +
        xlim(c(0,600)) +
        theme_classic() +
        theme(axis.title = element_text(size = 16, face = "bold"),
              plot.title = element_text(size = 16, face = "bold"),
              axis.text = element_text(size = 12, face = "bold"))
      
  })
    
  observeEvent(input$sim, {
    
    output$simmerPlot <- renderPlot({
      
      service_rate <- input$service
      arrival_rate <- input$arrival / 60
      agents <- input$agents
      
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
      
      result %>%
        ggplot(aes(start_time, waiting_time)) +
        geom_point() +
        labs(title = paste("Avg Wait: ", round(mean(result$waiting_time),2), " minutes", " | ",
                           "Max Wait: ", round(max(result$waiting_time),2), " minutes", sep = ""),
             x = "Start Time (Minutes)",
             y = "Time in Queue") +
        xlim(c(0,600)) +
        theme_classic() +
        theme(axis.title = element_text(size = 16, face = "bold"),
              plot.title = element_text(size = 16, face = "bold"),
              axis.text = element_text(size = 12, face = "bold"))
      
    })
  })
})
