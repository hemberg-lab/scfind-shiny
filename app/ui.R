library(shiny)

ui <- fluidPage(
    titlePanel("Scfind index"),
    sidebarLayout(
        sidebarPanel(
            textInput("geneList", label = h3("Gene List"), value = ""),
            uiOutput("geneCheckbox"),
            uiOutput("datasets")
            dataTableOutput("queryOptimizer"),
            width = 14
        ),
        
        mainPanel(
            plotOutput("geneSupportHisto", height = 800),
            dataTableOutput("cellTypesData")
        )
    )

)
