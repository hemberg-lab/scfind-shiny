
library(scfind)
library(shiny)
library(DT)
library(data.table)
library(ggplot2)

options(shiny.maxRequestSize=200*1024^2)

# A read-only data set that will load once, when Shiny starts, and will be
# available to each user session
object <- loadObject("www/mca.rds")

server <- function(input, output, session)
{
    gene.list <- reactive({
        text <- gsub("\\s", "", input$geneList)
        gene.list.input <- unlist(strsplit(text, ","))
        print(gene.list.input)
        gene.list.input
    })

    checkbox.selection <- reactive({
        
        selected.index <- input$queryOptimizer_rows_selected
        if (!is.null(selected.index))
        {
            available.queries <-  recommended.queries()
            selected.query <- available.queries[selected.index, 'Query']
            print(paste0('selected query', selected.query))
            genes <-  unlist(strsplit(gsub("\\s", "", selected.query), ","))
        }
        else
        {
            if (is.null(input$geneCheckbox))
            {
                genes <- gene.list()
            }
            else
            {
                genes <- input$geneCheckbox
            }
        }
        print(genes)
        genes
        ## updateSelectInput(session, "geneCheckbox", selected  = genes)
    })

    output$geneCheckbox <- renderUI({
        
        ## Select genes
        checkboxGroupInput("geneCheckbox", h4("Select Genes"), choices = gene.list(), selected = checkbox.selection(), inline = T)
    })
    
    recommended.queries <- reactive({
        
        selected.genes <- gene.list()
        selected.datasets <- input$datasetCheckbox
        if (length(selected.genes) != 0)
        {
            available.queries <-  markerGenes(object, selected.genes, selected.datasets)
        }
        else
        {
            available.queries <- c()
        }
        available.queries <- as.data.table(available.queries)
        available.queries
    })


    output$queryOptimizer <- renderDataTable({
        
        datatable(recommended.queries(), selection = 'single')
    })

    cell.types <- reactive({
        selection <- checkbox.selection()
        
        if (length(selection) != 0){
            df <- query.result.as.dataframe(findCellTypes(object, selection, input$datasetCheckbox))
            df
        }
        else
        {
            data.frame(cell_type = c(), cell_id = c())
        }
    })

    gene.support <- reactive({
        gene.selection <- gene.list()
        dataset.selection <- input$datasetCheckbox
        gene.support <- as.data.frame(object@index$genesSupport(gene.selection, dataset.selection))
        dimnames(gene.support)[[2]] <- 'support'
        gene.support$genes <- rownames(gene.support)
        gene.support
    })
    
    output$cellTypesData <- renderDataTable({                
        df <- cell.types()
        datatable(phyper.test(object, df, input$datasetCheckbox), selection = 'single')
        
    })
    
    output$geneSupportHisto <- renderPlot({
        ## Render a barplot
        ## print(length(input$geneCheckbox))
        ## print(input$geneCheckbox)
        df <- gene.support()
        print(df)
        if (nrow(df) != 0)
        {
            g <- ggplot(df, aes(x=genes, y= support)) +
                xlab("Gene") +
                ylab("Cells") +
                geom_col(color = "blue") +
                coord_flip() +
                theme_minimal()
        }
        else
        {
            g <- plot(0,type='n',axes=FALSE,ann=FALSE)
        }
        g
    })

    output$object <- reactive({
        return(object)
    })

    # make output variables visible for the client side
    outputOptions(output, "object", suspendWhenHidden = FALSE)

    session$onSessionEnded(function() {
        stopApp()
    })
}
