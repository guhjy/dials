% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/merge.R
\name{merge.model_spec}
\alias{merge.model_spec}
\alias{merge.param_grid}
\title{Merge parameter grid values into a parsnip object}
\usage{
\method{merge}{model_spec}(x, y, ...)

\method{merge}{param_grid}(x, y, ...)
}
\arguments{
\item{x, y}{A combination of one \pkg{parsnip} model object (that has class
\code{model_spec}) and one parameter grid resulting from \code{grid_regular} or
\code{grid_random}. As long as this combination is present, the assignment to
\code{x} and \code{y} isn't restricted.}

\item{...}{Not currently used.}
}
\value{
A list containing updated model objects.
}
\description{
\pkg{parsnip} contains model objects that have consistent names with
\pkg{dials}. \code{merge} can be used to easily update any of the main parameters
in a \pkg{parsnip} model.
}
