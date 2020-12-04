# Introduction
The `z11` package provides an `R`-interface to the geospatial raster data of the German Census 2011. `z11` can be used to list all available attributes from the Census (1 km²attributes and 1-hectare attribute) and import them either as [simple features](https://r-spatial.github.io/sf/) spatial points object or as [raster](https://cran.r-project.org/web/packages/raster/index.html) object with the resolution of the corresponding attribute. I felt that such a package may be of interest for other userRs since the Census data 'only' exists as [CSV data dump on the internet](https://www.zensus2011.de/DE/Home/Aktuelles/DemografischeGrunddaten.html). However, to use them in a Geographic Information System (GIS), the data must be prepared, which is time-consuming and computationally demanding. As such, the package aims to fill the gap of making the data easily accessible by providing a straightforward method.

Generally, the German Census 2011 data are available under a [Data licence Germany – attribution – version 2.0](https://www.govdata.de/dl-de/by-2-0) and can be manipulated and openly shared. **Yet, as part of this package, use them at your own risk and do not take the results of the functions for granted.**

# Installing and Loading the Package

~~~{r}
remotes::install_github("StefanJuenger/z11")
~~~

The functions in the package rely on data prepared in [another repository](https://github.com/StefanJuenger/z11data). If you want to work locally, please download them first and follow the instructions of the manual.

After installing, the package can be loaded using `R`'s standard method:

~~~{r}
library(z11)
~~~

For more details, please refer to [this package vignette](https://stefanjuenger.github.io/z11/articles/using-z11.html).
