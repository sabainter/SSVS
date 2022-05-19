function(input, output, session) {
  hideTab("main_tabs", "analysis")

  ssvs_result <- reactiveVal()

  rawdata <- reactive({
    req(input$datafile)
    file_type <- tools::file_ext(input$datafile$datapath)

    if (file_type == "csv") {
      read.csv(input$datafile$datapath, header = TRUE)
    } else if (file_type == "xlsx" || file_type == "xls") {
      as.data.frame(readxl::read_excel(input$datafile$datapath, 1, col_names = TRUE))
    } else if (file_type == "sav") {
      foreign::read.spss(input$datafile$datapath, to.data.frame = TRUE, use.value.labels = FALSE)
    } else {
      shinyalert(
        "Unsupported file type",
        type = "error",
        closeOnClickOutside = TRUE
      )
      hideTab("main_tabs", "analysis")
      NULL
    }
  })

  data_desc <- reactive({
    df <- rawdata()
    req(df)

    desc_cols <- c("mean", "sd", "min", "max", "skew")
    desc <- as.data.frame(psych::describe(df))[, desc_cols]
    vars_class <- unname(sapply(df, class))
    vars_missing <- sapply(df, function(x) sum(is.na(x)))

    varlist <- cbind(
      colnames(df),
      desc,
      vars_class,
      vars_missing
    )
    colnames(varlist) <- c(
      "variable",
      desc_cols,
      "type",
      "na_values"
    )
    varlist
  })

  output$data_desc <- reactable::renderReactable({
    reactable::reactable(
      data_desc(),
      rownames = FALSE,
      searchable = TRUE,
      columns = list(
        variable = reactable::colDef(
          name = "Variable"
        ),
        mean = reactable::colDef(
          name = "Mean",
          format = reactable::colFormat(digits = 5)
        ),
        sd = reactable::colDef(
          name = "SD",
          format = reactable::colFormat(digits = 5)
        ),
        min = reactable::colDef(
          name = "Min"
        ),
        max = reactable::colDef(
          name = "Max"
        ),
        skew = reactable::colDef(
          name = "Skew",
          format = reactable::colFormat(digits = 5)
        ),
        type = reactable::colDef(
          name = "Type"
        ),
        na_values = reactable::colDef(
          name = "NA Values"
        )
      )
    )
  })

  observeEvent(rawdata(), {
    showTab("main_tabs", "analysis")
    shinyjs::hide("results_tabs")
    shinyjs::show("results_memo")

    updateSelectInput(session, "dependent", choices = colnames(rawdata()))
    shinyWidgets::updatePickerInput(session, "predictors", choices = colnames(rawdata()))
  })

  data_preclean <- reactive({
    req(rawdata())
    data <- rawdata()[, unique(c(input$dependent, input$predictors))]
  })

  complete_rows <- reactive({
    req(data_preclean())
    complete.cases(data_preclean())
  })

  data_postclean <- reactive({
    req(data_preclean())
    data_preclean()[complete_rows(), ]
  })

  output$missing_cases <- renderUI({
    req(sum(!complete_rows()) > 0)
    div(
      class = "message",
      glue(
        "Note: the data contains {sum(!complete_rows())} row{if (sum(!complete_rows()) > 1) 's' else ''} with missing values in the selected variables. ",
        "If you run the analysis, data in these rows will be ignored."
      )
    )
  })

  observe({
    shinyjs::toggleState("run", condition = (length(input$predictors) >= 2))
  })

  observeEvent(c(input$dependent, input$logistic, input$predictors, input$random_fixed, input$prior, input$nruns, input$burnin), {
    shinyjs::hide("results_tabs")
    shinyjs::show("results_memo")
  })

  observeEvent(input$run, {
    if (length(input$predictors) <= 1) {
      shinyalert(
        "You must choose at least two predictors",
        type = "error",
        closeOnClickOutside = TRUE
      )
      return()
    }

    if (input$random_fixed == "fix") {
      set.seed(820)
    }

    continuous <- (input$logistic == "continuous")

    shinyalert("Running SSVS analysis...",
      type = "warning",
      closeOnEsc = FALSE, showConfirmButton = FALSE
    )

    result <- try(
      SSVS::ssvs(
        data_postclean(),
        x = input$predictors,
        y = input$dependent,
        progress = FALSE,
        continuous = continuous,
        inprob = input$prior,
        runs = input$nruns,
        burn = input$burnin
      ),
      silent = TRUE
    )

    closeAlert()

    if (inherits(result, "try-error")) {
      shinyalert("Error in analysis", attr(result, "condition")$message,
        type = "error",
        closeOnClickOutside = TRUE
      )
      return()
    }

    shinyjs::hide("results_memo")
    shinyjs::show("results_tabs")

    ssvs_result(result)
  })

  ssvs_summary <- reactive({
    req(ssvs_result())
    summary(ssvs_result())
  })
  ssvs_plot <- reactive({
    req(ssvs_result())
    threshold <- if (input$show_threshold) 0.5 else NULL
    plot(ssvs_result(), threshold = threshold)
  })

  output$result_summary_text <- renderText({
    req(ssvs_result())

    glue::glue(
      "{scales::comma(input$nruns)} MCMC iterations run, results for ",
      "{scales::comma(input$nruns - input$burnin)} iterations post-warmup shown below for ",
      "{scales::comma(sum(complete_rows()))} complete cases"
    )
  })

  output$summary_table <- reactable::renderReactable({
    reactable::reactable(
      ssvs_summary(),
      rownames = FALSE,
      searchable = nrow(ssvs_summary()) > 10
    )
  })

  output$download_summary <- downloadHandler(
    "SSVS results.csv",
    function(file) {
      write.csv(ssvs_summary(), file)
    }
  )

  output$plot <- renderPlot({
    ssvs_plot()
  })

  output$download_plot <- downloadHandler(
    "SSVS plot.png",
    function(file) {
      ggplot2::ggsave(file, ssvs_plot())
    }
  )

  output$code <- renderText({

    ssvs_code <- glue(
      "response <- \"{input$dependent}\"\n",
      "predictors <- {paste(utils::capture.output(dput({input$predictors})), collapse = '')}\n",
      "result <- ssvs(",
      "data, ",
      "x = predictors, ",
      "y = response, ",
      "continuous = {as.character(input$logistic == 'continuous')}, ",
      "inprob = {input$prior}, ",
      "runs = {input$nruns}, ",
      "burn = {input$burnin}",
      ")"
    )

    plot_code <- glue(
      "plot(",
      "result, ",
      "threshold = {if (input$show_threshold) 0.5 else 'NULL'}, ",
      "legend = TRUE, ",
      "title = NULL, ",
      "color = TRUE",
      ")"
    )

    glue(
      "library(SSVS)\n",
      "{ssvs_code}\n",
      "{plot_code}"
    )
  })
}
