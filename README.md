
<!-- README.md is generated from README.Rmd. Please edit that file -->

# XsearchLIBRIS

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of XsearchLIBRIS is to provide access to search results from
LIBRIS Xsearch API directly in R.

LIBRIS is an online search service of the National Library of Sweden.
Search national, academic, and several public libraries of Sweden for
books, periodicals, articles, maps, posters, printed music, electronic
resources, and more.

## Installation

You can install the latest version of XsearchLIBRIS from GitHub with:

``` r
#install.packages("devtools")
install_github("KTH-Library/XsearchLIBRIS", dependencies = TRUE)
```

## Example

The database used can be specified - the default is to use LIBRIS but
“swepub” is also available.

This is a basic example which shows you how make a search:

``` r
library(XsearchLIBRIS)
suppressPackageStartupMessages(library(dplyr))
library(knitr)

# search and display first two hits for "film noir"
kable(xsearch(query = "WAMK:\"film noir\"")$content %>% slice(1:2))
```

| identifier                                 | title                                                       | type | language | description                                                   | creator                  | publisher | date |
| :----------------------------------------- | :---------------------------------------------------------- | :--- | :------- | :------------------------------------------------------------ | :----------------------- | :-------- | :--- |
| <http://libris.kb.se/bib/q145b4zln539zndk> | Hong Kong neo-noir                                          | book | eng      | Imported from: zcat.oclc.org:210/OLUCWorldCat (Do not remove) | NA                       | NA        | NA   |
| <http://libris.kb.se/bib/2br62c3l0v6b86xv> | Classic French noir : gender and the cinema of fatal desire | book | eng      | Imported from: zcat.oclc.org:210/OLUCWorldCat (Do not remove) | Walker-Morrison, Deborah | NA        | NA   |

``` r
 
# search for publications by Vitruvius in Swedish
"PERS:(vitruvius) SPR:swe" %>% 
  xsearch() %>% 
  .$content %>%
  kable()
```

| identifier                         | title                                       | creator                      | type            | language | description              | relation      |
| :--------------------------------- | :------------------------------------------ | :--------------------------- | :-------------- | :------- | :----------------------- | :------------ |
| <http://libris.kb.se/bib/11641320> | Om arkitektur : tio böcker                  | Vitruvius, århundradet f.Kr. | book            | swe      | NA                       | NA            |
| <http://libris.kb.se/bib/7678737>  | Om arkitektur : tio böcker                  | Vitruvius, århundradet f.Kr. | book            | swe      | NA                       | NA            |
| <http://libris.kb.se/bib/12624220> | Om arkitektur \[Ljudupptagning\] tio böcker | Vitruvius Pollio, Marcus     | sound recording | swe      | MTM MarcRecordId: 121712 | Om arkitektur |

``` r

# search SwePub for publications about timber framing in Swedish
xsearch(query = "stolpverk SPR:swe", database = "swepub") %>%
  .$content %>% 
  mutate(summary = paste(
    # generate summary snippet in markdown format
    sprintf("[%s](%s)", identifier, sprintf("%s (%s:%s)", title, type, relation)),
    sprintf("\n%s...", substr(description, 1, 250)))
  ) %>%
  select(`Search hit summaries` = summary) %>%
  kable()
```

| Search hit summaries                                                                                                                                                                                                                                        |
| :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [http://swepub.kb.se/bib/swepub:oai:gup.ub.gu.se/172151](Hantverk%20på%20Japanska?%20Om%20att%20mötas%20och%20utbildas%20i%20handling%20\(article:Bygnadskultur\))                                                                                          |
| Vad skiljer en japansk stolpverkskonstruktion från en norsk? Vilka timringstraditioner förekommer på den engelska landsbygden? Och hur gör man för att lära av varandra när man samtidigt ska bygga ett hus? Det är frågor som hantverksdoktoranden Ulrik … |
| [http://swepub.kb.se/bib/swepub:oai:gup.ub.gu.se/138736](Stolpverket%20i%20logen%20i%20Maglö%20\(article:Bebyggelsehistorisk%20tidskrift\))                                                                                                                 |
| The timber-framed parts of buildings and the technical aspects of how the buildings were constructed are rarely addressed in scientific papers on the history of built environments. In Scandinavia architects, art historians, archaeologists and ethnolo… |
