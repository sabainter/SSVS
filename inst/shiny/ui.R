helpIcon <- function(...) {
  span(
    class = "help-icon",
    "data-toggle" = "tooltip",
    "data-html" = "true",
    "?",
    title = paste(...)
  )
}

fluidPage(
  title = "SSVS",
  theme = bslib::bs_theme(4),
  lang = "en",

  tags$head(
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;700&family=Playfair+Display:wght@700&display=swap"
    ),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$script(src = "ssvs.js"),
    shinyjs::useShinyjs()
  ),

  div(
    id = "header",
    h2("SSVS"),
    img(src = "logo.png", id = "logo", alt = "Logo"),
    h3("An interactive web tool for performing stochastic search variable selection")
  ),

  tabsetPanel(
    id = "main_tabs",

    tabPanel(
      "Data",
      value = "data",
      icon = icon("table", "aria-hidden" = "true"),

      br(),
      fluidRow(
        column(
          width = 4,

          fileInput(
            "datafile",
            glue::glue("Choose File (max {FILE_UPLOAD_MB} MB)"),
            width = "75%",
            accept = c(
              "text/csv",
              "text/comma-separated-values,text/plain",
              ".csv",
              ".xls",
              ".xlsx",
              ".sav"
            )
          ),
          br(),

          div(
            class = "message",
            tags$strong("Pre-requisites and constraints"),
            p(
              "The requirements for SSVS are similar to requirements for standard regression analysis.",
              "Currently this application contains functionality for linear and logistic regression.",
              "Categorical predictors must be coded using an appropriate scheme (e.g. dummy coding).",
              "Any cases with missing data in any of the selected predictor variables will be excluded from the analysis (listwise deletion).",
              "There is currently no acceptable procedure for combining results from multiply imputed data sets.",
              "Check the table below to make sure your data imported correctly (e.g. check missing data codes)."
            ),
            p(
              "Because the priors have a fixed scale, predictors on different scales will differentially influence results.",
              "SSVSforPsych automatically standardizes the predictors selected for analysis."
            )
          )
        ),

        column(
          width = 8,
          reactable::reactableOutput("data_desc")
        )
      )
    ),

    tabPanel(
      "Analysis",
      value = "analysis",
      icon = icon("sliders-h", "aria-hidden" = "true"),

      br(),

      fluidRow(
        column(
          width = 6,

          tags$form(
            class = "analysis-form",

            fluidRow(
              column(
                6,

                h5("Main Options"),

                selectInput(
                  "dependent", "Dependent variable",
                  choices = NULL,
                  width = "100%"
                ),

                radioButtons(
                  "logistic",
                  tagList(
                    "The dependent variable is",
                    helpIcon(
                      "<p>If the dependent variable is continuous, the analysis will proceed using a standard Gibbs sampler.</p>",
                      "<p>If the dependent variable is binary, SSVS results will be provided using the logit.spike() function from the BoomSpikeSlab package.</p>"
                    ),
                  ),
                  c("Continuous" = "continuous", "Binary" = "binary"),
                  inline = TRUE,
                  width = "100%"
                ),

                shinyWidgets::pickerInput(
                  "predictors",
                  label = span("Candidate predictors"),
                  choices = NULL,
                  multiple = TRUE,
                  options = list(`actions-box` = TRUE, `none-selected-text` = "None selected"),
                  width = "100%"
                )
              ),

              column(
                6,

                h5("Additional Options"),


                div(
                  id = "additional_options",
                  sliderInput(
                    "prior",
                    label = tagList(
                      "Prior inclusion probablility",
                      helpIcon(
                        "<p>Prior inclusion probablility is applied to all predictors.",
                        "The prior inclusion probability reflects the belief that each predictor should be included in the model.</p>",
                        "<p>A prior probability of 0.5 (the default) reflects the belief that each predictor has an equal probability of being included or excluded.",
                        "Note that a value of 0.5 also implies a prior belief that the true model contains half of the candidate predictors.</p>",
                        "<p>As shown in Bainter et al. (2020), the prior inclusion probability will influence the magnitude of the marginal inclusion probabilities (MIPs),",
                        "but the relative pattern of MIPS is expected to remain fairly consistent.</p>"
                      )
                    ),
                    min = 0.1, max = 0.9, step = 0.1, value = 0.5, ticks = FALSE,
                    width = "100%"
                  ),

                  sliderInput(
                    "burnin",
                    label = tagList(
                      "Burn-in iterations",
                      helpIcon(
                        "<p>Burn-in iterations are the number of discarded warmup iterations used to achieve Markov chain Monte Carlo (MCMC) convergence.</p>",
                        "<p>You may increase the number of burn-in iterations if you are having convergence issues.</p>"
                      )
                    ),
                    min = 1000, max = 10000, step = 1000, value = 1000, ticks = FALSE,
                    width = "100%"
                  ),

                  sliderInput(
                    "nruns",
                    label = tagList(
                      "Total number of iterations",
                      helpIcon(
                        "The total number of iterations (inclusive of burn-in) indicates the number of models sampled. Results are based on the Total - Burn-in iterations."
                      )
                    ),
                    min = 10000, max = 20000, step = 1000, value = 10000, ticks = FALSE,
                    width = "100%"
                  ),

                  conditionalPanel(
                    "input.logistic == 'continuous'",
                    radioButtons(
                      "random_fixed",
                      label = tagList(
                        "Fixed or random start values",
                        helpIcon(
                          "<p>Fixed start values will result in a perfectly reproducible solution produced in each run.</p>",
                          "<p>Random start values allow for slight variations in results due to the randomness inherent in MCMC estimation.</p>",
                          "<p>Checking results with different starting values is a useful method for checking convergence.</p>"
                        )
                      ),
                      c("Fixed" = "fix", "Random" = "random"),
                      inline = TRUE,
                      width = "100%"
                    )
                  ),
                )
              )
            ),

            fluidRow(
              column(
                12,
                uiOutput("missing_cases"),
                actionButton(
                  "run",
                  label = "Run Analysis",
                  icon = icon("play"),
                  class = "btn-success btn-lg",
                  width = "100%"
                ),
                br()
              )
            )
          )
        ),

        column(
          width = 6,

          p(id = "results_memo", "Run analysis to get results"),

          div(
            id = "results_tabs",
            tabsetPanel(
              type = "pills",

              header = div(
                class = "download-buttons",
                downloadButton("download_summary", "Download results"),
                downloadButton("download_plot", "Download plot")
              ),

              tabPanel(
                title = "Table",
                value = "table",
                br(),
                textOutput("result_summary_text"),
                br(),
                reactable::reactableOutput("summary_table")
              ),
              tabPanel(
                title = "Plot",
                value = "plot",
                br(),
                checkboxInput("show_threshold", "Show threshold line at 0.5?", value = TRUE),
                plotOutput("plot"),
                p("To customize the plot, you can run the following code in an R session and modify any of the parameters (make sure to store the dataset in a variable called `data`)."),
                verbatimTextOutput("code")
              )
            )
          )
        )
      )
    ),

    tabPanel(
      "Info",
      value = "info",
      icon = icon("info", "aria-hidden" = "true"),
      br(),
      includeMarkdown("info.md")
    )
  )
)
