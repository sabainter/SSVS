#' Run an interactive analysis tool (Shiny app) that lets you perform SSVS in a browser
#' @export
launch <- function() {
  shiny::runApp(
    system.file("shiny", package = "SSVS"),
    display.mode = "normal",
    launch.browser = TRUE
  )
}
