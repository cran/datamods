## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup--------------------------------------------------------------------
#  library(datamods)

## -----------------------------------------------------------------------------
#  # UI
#  import_globalenv_ui("myid")
#  
#  # Server
#  imported <- import_globalenv_server("myid")

## -----------------------------------------------------------------------------
#  # UI
#  import_file_ui("myid")
#  
#  # Server
#  imported <- import_file_server("myid")

## -----------------------------------------------------------------------------
#  # UI
#  import_copypaste_ui("myid")
#  
#  # Server
#  imported <- import_copypaste_server("myid")

## -----------------------------------------------------------------------------
#  # UI
#  import_googlesheets_ui("myid")
#  
#  # Server
#  imported <- import_googlesheets_server("myid")

## -----------------------------------------------------------------------------
#  # UI
#  import_url_ui("myid")
#  
#  # Server
#  imported <- import_url_server("myid")

## -----------------------------------------------------------------------------
#  library(shiny)
#  library(datamods)
#  
#  ui <- fluidPage(
#    tags$h3("Import data with copy & paste"),
#    fluidRow(
#      column(
#        width = 4,
#        import_copypaste_ui("myid")
#      ),
#      column(
#        width = 8,
#        tags$b("Imported data:"),
#        verbatimTextOutput(outputId = "status"),
#        verbatimTextOutput(outputId = "data")
#      )
#    )
#  )
#  
#  server <- function(input, output, session) {
#  
#    imported <- import_copypaste_server("myid")
#  
#    output$status <- renderPrint({
#      imported$status()
#    })
#    output$data <- renderPrint({
#      imported$data()
#    })
#  
#  }
#  
#  shinyApp(ui, server)

## -----------------------------------------------------------------------------
#  observeEvent(input$launch_modal, {
#    import_modal(
#      id = "myid",
#      title = "Import data to be used in application"
#    )
#  })

## -----------------------------------------------------------------------------
#  # UI
#  validation_ui("validation", display = "inline")
#  
#  # Server
#  results <- validation_server(
#    id = "validation",
#    data = dataset,
#    n_row = ~ . > 20, # more than 20 rows
#    n_col = ~ . >= 3, # at least 3 columns
#    rules = myrules
#  )
#  
#  # Rules are defined as follow:
#  myrules <- validator(
#    is.character(Manufacturer) | is.factor(Manufacturer),
#    is.numeric(Price),
#    Price > 12, # we should use 0 for testing positivity, but that's for the example
#    !is.na(Luggage.room),
#    in_range(Cylinders, min = 4, max = 8),
#    Man.trans.avail %in% c("Yes", "No")
#  )
#  # Add some labels
#  label(myrules) <- c(
#    "Variable Manufacturer must be character",
#    "Variable Price must be numeric",
#    "Variable Price must be strictly positive",
#    "Luggage.room must not contain any missing values",
#    "Cylinders must be between 4 and 8",
#    "Man.trans.avail must be 'Yes' or 'No'"
#  )
#  # you can also add a description()

## -----------------------------------------------------------------------------
#  # UI
#  filter_data_ui("filtering", max_height = "500px")
#  
#  # Server
#  res_filter <- filter_data_server(
#    id = "filtering",
#    data = reactive(mtcars),
#    name = reactive("mtcars"),
#    vars = reactive(names(mtcars)),
#    widget_num = "slider",
#    widget_date = "slider",
#    label_na = "Missing"
#  )

## -----------------------------------------------------------------------------
#  # UI
#  sample_ui("myID")
#  
#  # Server
#  result_sample <- sample_server("myID", reactive(iris))

## -----------------------------------------------------------------------------
#  # UI
#  edit_data_ui(id = "id")
#  
#  # Server
#    res_edited <- edit_data_server(
#      id = "id",
#      data_r = reactive(demo_edit),
#      add = TRUE,
#      update = TRUE,
#      delete = TRUE,
#      download_csv = TRUE,
#      download_excel = TRUE,
#      file_name_export = "datas",
#      var_edit = c("name", "job", "credit_card_provider", "credit_card_security_code"),
#      var_mandatory = c("name", "job")
#    )

