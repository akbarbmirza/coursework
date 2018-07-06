library(shiny)

# Define UI ----
ui <- fluidPage(
  
  titlePanel(h2("My Shiny App")),
  
  sidebarLayout(
    sidebarPanel(
      h3("Installation"),
      p("Shiny is available on CRAN, so you can install it in the usual way from your R console:"),
      code("install.packages(\"shiny\")"),
      br(), br(), br(),
      p("Shiny is a product of ", a("RStudio"))
    ),
    mainPanel(
      h1("Introducing Shiny"),
      p("Shiny is a new package from RStudio that makes it <em>incredibly<em> easy to build interactive web applications with R."),
      br(),
      p("For an introduction and live examples, visit the ", a("Shiny homepage.")),
      br(), br(),
      h3("Features"),
      HTML("<ul><li>Build useful web applications with only a few lines of code -- no JavaScript</li><li>Shiny applications are automatically 'live' in the same way that <b>spreadsheets</b> are live. Outputs change instantly as users modify inputs, without requiring a reload of the browser.</li></ul>")
    )
  )
  
)

# Define server logic ----
server <- function(input, output) {
  
  
}

shinyApp(ui, server)
