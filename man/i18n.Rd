% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/i18n.R
\name{i18n}
\alias{i18n}
\alias{i18n_translations}
\title{Internationalization}
\usage{
i18n(x, translations = i18n_translations())

i18n_translations(package = packageName(parent.frame(2)))
}
\arguments{
\item{x}{Label to translate.}

\item{translations}{Either a \code{list} or a \code{data.frame} with translations.}

\item{package}{Name of the package where the function is called, use \code{NULL} outside a package.
It will retrieve option \code{"i18n.<PACKAGE>"} (or \code{"i18n"} if no package) to returns appropriate labels.}
}
\value{
\code{i18n()} returns a \code{character}, \code{i18n_translations()} returns a \code{list} or a \code{data.frame}.
}
\description{
Simple mechanism to translate labels in a Shiny application.
}
\examples{
library(datamods)

# Use with an objet
my.translations <- list(
  "Hello" = "Bonjour"
)
i18n("Hello", my.translations)

# Use with options()
options("i18n" = list(
  "Hello" = "Bonjour"
))
i18n("Hello")

# With a package
options("datamods.i18n" = "fr")
i18n("Browse...", translations = i18n_translations("datamods"))
# If you call i18n() from within a function of your package
# you don't need second argument, e.g.:
# i18n("Browse...")
}
