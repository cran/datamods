## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----setup--------------------------------------------------------------------
#  library(datamods)

## -----------------------------------------------------------------------------
#  # Using a supported language
#  options("datamods.i18n" = "fr")
#  
#  # Using a named list
#  options("datamods.i18n" = list(...))
#  
#  # Using a data.frame
#  options("datamods.i18n" = data.frame(label = c(...), translation = c(...)))
#  
#  # Using a CSV file
#  options("datamods.i18n" = "path/to/file.csv")

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = "fr")

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = "mk")

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = "pt")

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = "sq")

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = list(
#    "Import a dataset from an environment" = "Importer un jeu de données depuis l'environnement global",
#    "Select a data.frame:" = "Sélectionner un data.frame :",
#    ...
#  ))

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = data.frame(
#    label = c("Import a dataset from an environment", "Select a data.frame:", ...),
#    translation = c("Importer un jeu de données depuis l'environnement global", "Sélectionner un data.frame :", ...)
#  ))

## -----------------------------------------------------------------------------
#  options("datamods.i18n" = "path/to/file.csv")

## ---- echo=FALSE, eval=TRUE, comment=""---------------------------------------
cat(readLines(system.file("i18n", "fr.csv", package = "datamods"), encoding = "UTF-8"), sep = '\n')

