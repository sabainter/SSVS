FILE_UPLOAD_MB <- 20

options(shiny.maxRequestSize = FILE_UPLOAD_MB * 1024 ^ 2)

library(shiny)
library(glue)
library(shinyalert)
library(SSVS)
library(reactable)
