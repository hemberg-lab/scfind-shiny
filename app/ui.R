library(shiny)

ui <- fluidPage(
    titlePanel("Scfind index"),
    sidebarLayout(
        sidebarPanel(
            textInput("geneList", label = h3("Gene List"), value = ""),
            uiOutput("geneCheckbox"),
            checkboxGroupInput("datasetCheckbox",
                               h3("Datasets"),
                               choices = object@datasets,
                               selected = object@datasets,
                               inline = T
                               ),
            dataTableOutput("queryOptimizer"),
            width = 14
        ),
        
        mainPanel(
            plotOutput("geneSupportHisto", height = 800),
            dataTableOutput("cellTypesData")
        )
    )

)
