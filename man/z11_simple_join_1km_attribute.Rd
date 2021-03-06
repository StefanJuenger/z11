% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/z11_simple_join_1km_attribute.R
\name{z11_simple_join_1km_attribute}
\alias{z11_simple_join_1km_attribute}
\title{Simple join of data with census 1 km attributes}
\usage{
z11_simple_join_1km_attribute(
  data,
  inspire_column,
  attribute,
  all = FALSE,
  ...
)
}
\arguments{
\item{data}{input data}

\item{attribute}{Name of the census variable which is aimed to be merged with
input data (used for calling \code{z11::z11_get_1km_attribute()})}

\item{all}{logical; should all census attributes be merged? default: `FALSE`}

\item{...}{arguments passed to \code{z11::z11_get_1km_attribute()}}

\item{inspire_colum}{Character string for column name in input data
containing the inspire ID}
}
\description{
Merge input data with census 1 km data by simple matching of INSPIRE IDs
}
