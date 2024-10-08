
#' @title Import data from a file
#'
#' @description Let user upload a file and import data
#'
#' @inheritParams import-globalenv
#' @param preview_data Show or not a preview of the data under the file input.
#' @param file_extensions File extensions accepted by [shiny::fileInput()], can also be MIME type.
#' @param layout_params How to display import parameters : in a dropdown button or inline below file input.
#'
#' @template module-import
#'
#' @export
#'
#' @name import-file
#'
#' @importFrom shiny NS fileInput actionButton icon
#' @importFrom htmltools tags tagAppendAttributes css tagAppendChild
#' @importFrom shinyWidgets pickerInput numericInputIcon textInputIcon dropMenu
#' @importFrom phosphoricons ph
#' @importFrom toastui datagridOutput2
#'
#' @example examples/from-file.R
import_file_ui <- function(id,
                           title = TRUE,
                           preview_data = TRUE,
                           file_extensions = c(".csv", ".txt", ".xls", ".xlsx", ".rds", ".fst", ".sas7bdat", ".sav"),
                           layout_params = c("dropdown", "inline")) {

  ns <- NS(id)

  if (!is.null(layout_params)) {
    layout_params <- match.arg(layout_params)
  }

  if (isTRUE(title)) {
    title <- tags$h4(
      i18n("Import a file"),
      class = "datamods-title"
    )
  }


  params_ui <- fluidRow(
    column(
      width = 6,
      numericInputIcon(
        inputId = ns("skip_rows"),
        label = i18n("Rows to skip before reading data:"),
        value = 0,
        min = 0,
        icon = list("n ="),
        size = "sm",
        width = "100%"
      ),
      tagAppendChild(
        textInputIcon(
          inputId = ns("na_label"),
          label = i18n("Missing values character(s):"),
          value = ",NA",
          icon = list("NA"),
          size = "sm",
          width = "100%"
        ),
        shiny::helpText(ph("info"), i18n("if several use a comma (',') to separate them"))
      )
    ),
    column(
      width = 6,
      textInputIcon(
        inputId = ns("dec"),
        label = i18n("Decimal separator:"),
        value = ".",
        icon = list("0.00"),
        size = "sm",
        width = "100%"
      ),
      textInputIcon(
        inputId = ns("encoding"),
        label = i18n("Encoding:"),
        value = "UTF-8",
        icon = phosphoricons::ph("text-aa"),
        size = "sm",
        width = "100%"
      )
    )
  )

  file_ui <- tagAppendAttributes(
    fileInput(
      inputId = ns("file"),
      label = i18n("Upload a file:"),
      buttonLabel = i18n("Browse..."),
      placeholder = i18n("No file selected"),
      accept = file_extensions,
      width = "100%"
    ),
    class = "mb-0"
  )
  if (identical(layout_params, "dropdown")) {
    file_ui <- tags$div(
      style = css(
        display = "grid",
        gridTemplateColumns = "1fr 50px",
        gridColumnGap = "10px"
      ),
      file_ui,
      tags$div(
        class = "shiny-input-container",
        tags$label(
          class = "control-label",
          `for` = ns("dropdown_params"),
          "...",
          style = css(visibility = "hidden")
        ),
        shinyWidgets::dropMenu(
          actionButton(
            inputId = ns("dropdown_params"),
            label = ph("gear", title = "Parameters"),
            width = "50px",
            class = "px-1"
          ),
          params_ui
        )
      )
    )
  }
  tags$div(
    class = "datamods-import",
    html_dependency_datamods(),
    title,
    file_ui,
    if (identical(layout_params, "inline")) params_ui,
    tags$div(
      class = "hidden",
      id = ns("sheet-container"),
      pickerInput(
        inputId = ns("sheet"),
        label = i18n("Select sheet to import:"),
        choices = NULL,
        width = "100%"
      )
    ),
    tags$div(
      id = ns("import-placeholder"),
      alert(
        id = ns("import-result"),
        status = "info",
        tags$b(i18n("No file selected:")),
        sprintf(i18n("You can import %s files"), paste(file_extensions, collapse = ", ")),
        dismissible = TRUE
      )
    ),
    if (isTRUE(preview_data)) {
      datagridOutput2(outputId = ns("table"))
    },
    uiOutput(
      outputId = ns("container_confirm_btn"),
      style = "margin-top: 20px;"
    ),
    tags$div(
      style = css(display = "none"),
      checkboxInput(
        inputId = ns("preview_data"),
        label = NULL,
        value = isTRUE(preview_data)
      )
    )
  )
}


#' @inheritParams import_globalenv_server
#' @param read_fns Named list with custom function(s) to read data:
#'  * the name must be the extension of the files to which the function will be applied
#'  * the value must be a function that can have 5 arguments (you can ignore some of them, but you have to use the same names),
#'    passed by user through the interface:
#'    + `file`: path to the file
#'    + `sheet`: for Excel files, sheet to read
#'    + `skip`: number of row to skip
#'    + `dec`: decimal separator
#'    + `encoding`: file encoding
#'    + `na.strings`: character(s) to interpret as missing values.
#'
#' @export
#'
#' @importFrom shiny moduleServer
#' @importFrom htmltools tags tagList
#' @importFrom shiny reactiveValues reactive observeEvent removeUI req
#' @importFrom shinyWidgets updatePickerInput
#' @importFrom readxl excel_sheets
#' @importFrom rio import
#' @importFrom rlang exec fn_fmls_names is_named is_function
#' @importFrom tools file_ext
#' @importFrom utils head
#' @importFrom toastui renderDatagrid2 datagrid
#'
#' @rdname import-file
import_file_server <- function(id,
                               btn_show_data = TRUE,
                               show_data_in = c("popup", "modal"),
                               trigger_return = c("button", "change"),
                               return_class = c("data.frame", "data.table", "tbl_df", "raw"),
                               reset = reactive(NULL),
                               read_fns = list()) {

  if (length(read_fns) > 0) {
    if (!is_named(read_fns))
      stop("import_file_server: `read_fns` must be a named list.", call. = FALSE)
    if (!all(vapply(read_fns, is_function, logical(1))))
      stop("import_file_server: `read_fns` must be list of function(s).", call. = FALSE)
  }

  trigger_return <- match.arg(trigger_return)
  return_class <- match.arg(return_class)

  module <- function(input, output, session) {

    ns <- session$ns
    imported_rv <- reactiveValues(data = NULL, name = NULL)
    temporary_rv <- reactiveValues(data = NULL, name = NULL, status = NULL)

    observeEvent(reset(), {
      temporary_rv$data <- NULL
      temporary_rv$name <- NULL
      temporary_rv$status <- NULL
    })

    output$container_confirm_btn <- renderUI({
      if (identical(trigger_return, "button")) {
        button_import()
      }
    })

    observeEvent(input$file, {
      if (isTRUE(is_excel(input$file$datapath))) {
        updatePickerInput(
          session = session,
          inputId = "sheet",
          choices = readxl::excel_sheets(input$file$datapath)
        )
        showUI(paste0("#", ns("sheet-container")))
      } else {
        hideUI(paste0("#", ns("sheet-container")))
      }
    })

    observeEvent(list(
      input$file,
      input$sheet,
      input$skip_rows,
      input$dec,
      input$encoding,
      input$na_label
    ), {
      req(input$file)
      # req(input$skip_rows)
      extension <- tools::file_ext(input$file$datapath)
      if (isTRUE(extension %in% names(read_fns))) {
        parameters <- list(
          file = input$file$datapath,
          sheet = input$sheet,
          skip = input$skip_rows,
          dec = input$dec,
          encoding = input$encoding,
          na.strings = split_char(input$na_label)
        )
        parameters <- parameters[which(names(parameters) %in% fn_fmls_names(read_fns[[extension]]))]
        imported <- try(rlang::exec(read_fns[[extension]], !!!parameters), silent = TRUE)
        code <- call2(read_fns[[extension]], !!!modifyList(parameters, list(file = input$file$name)))
      } else {
        if (is_excel(input$file$datapath)) {
          req(input$sheet)
          parameters <- list(
            file = input$file$datapath,
            which = input$sheet,
            skip = input$skip_rows,
            na = split_char(input$na_label)
          )
        } else if (is_sas(input$file$datapath)) {
          parameters <- list(
            file = input$file$datapath,
            skip = input$skip_rows,
            encoding = input$encoding
          )
        } else {
          parameters <- list(
            file = input$file$datapath,
            skip = input$skip_rows,
            dec = input$dec,
            encoding = input$encoding,
            na.strings = split_char(input$na_label)
          )
        }
        imported <- try(rlang::exec(rio::import, !!!parameters), silent = TRUE)
        code <- call2("import", !!!modifyList(parameters, list(file = input$file$name)), .ns = "rio")
      }

      if (inherits(imported, "try-error")) {
        imported <- try(rlang::exec(rio::import, !!!parameters[1]), silent = TRUE)
        code <- call2("import", !!!list(file = input$file$name), .ns = "rio")
      }

      if (inherits(imported, "try-error") || NROW(imported) < 1) {

        toggle_widget(inputId = "confirm", enable = FALSE)
        insert_error(mssg = i18n(attr(imported, "condition")$message))
        temporary_rv$status <- "error"
        temporary_rv$data <- NULL
        temporary_rv$name <- NULL
        temporary_rv$code <- NULL

      } else {

        toggle_widget(inputId = "confirm", enable = TRUE)

        insert_alert(
          selector = ns("import"),
          status = "success",
          make_success_alert(
            imported,
            trigger_return = trigger_return,
            btn_show_data = btn_show_data,
            extra = if (isTRUE(input$preview_data)) i18n("First five rows are shown below:")
          )
        )
        temporary_rv$status <- "success"
        temporary_rv$data <- imported
        temporary_rv$name <- input$file$name
        temporary_rv$code <- code
      }
    }, ignoreInit = TRUE)

    observeEvent(input$see_data, {
      show_data(temporary_rv$data, title = i18n("Imported data"), type = show_data_in)
    })

    output$table <- renderDatagrid2({
      req(temporary_rv$data)
      datagrid(
        data = head(temporary_rv$data, 5),
        theme = "striped",
        colwidths = "guess",
        minBodyHeight = 250
      )
    })

    observeEvent(input$confirm, {
      imported_rv$data <- temporary_rv$data
      imported_rv$name <- temporary_rv$name
      imported_rv$code <- temporary_rv$code
    })

    if (identical(trigger_return, "button")) {
      return(list(
        status = reactive(temporary_rv$status),
        name = reactive(imported_rv$name),
        code = reactive(imported_rv$code),
        data = reactive(as_out(imported_rv$data, return_class))
      ))
    } else {
      return(list(
        status = reactive(temporary_rv$status),
        name = reactive(temporary_rv$name),
        code = reactive(temporary_rv$code),
        data = reactive(as_out(temporary_rv$data, return_class))
      ))
    }
  }

  moduleServer(
    id = id,
    module = module
  )
}

# utils -------------------------------------------------------------------

is_excel <- function(path) {
  isTRUE(tools::file_ext(path) %in% c("xls", "xlsx"))
}

is_sas <- function(path) {
  isTRUE(tools::file_ext(path) %in% c("sas7bdat"))
}

