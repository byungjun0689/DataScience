source('Reco.R')
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#S

library(shiny)

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  
  # Application title
  titlePanel("하...샤이니...."),
  
  # Sidebar with a slider input for number of bins 
   
  sidebarLayout(
    sidebarPanel(
      selectInput("custID",
                  "Choose a Customer ID:",
                  choices = order_df[!duplicated(order_df$CUSTOMER_NBR),1]),
      submitButton("Update View")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h4("Recommand"),
      verbatimTextOutput("getCategoryRecommand")
    )
  )
))


# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
  
  # output$distPlot <- renderPlot({
  #   # generate bins based on input$bins from ui.R
  #   x    <- faithful[, 2]
  #   bins <- seq(min(x), max(x), length.out = input$bins + 1)
  # 
  #   # draw the histogram with the specified number of bins
  #   hist(x, breaks = bins, col = 'darkgray', border = 'white')
  # })
})

# Run the application 
shinyApp(ui = ui, server = server)

