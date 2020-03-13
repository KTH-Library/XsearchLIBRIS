#' Retrieve records from LIBRIS Xsearch API
#'
#' The database used can be specified - the default is to use LIBRIS but "swepub" is also available
#'
#' @template xsearch-params
#' @param api_config a configuration setting for the search API including base URL etc, by default from config()
#'
#' @importFrom attempt stop_if_all stop_if_not
#' @importFrom purrr compact
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET http_type status_code
#' @importFrom progress progress_bar
#' @import tibble dplyr
#' @export
#'
#' @return results records returned from the search
#' @examples
#' \dontrun{
#' xsearch(query = "WAMK:\"film noir\"")
#' xsearch(query = "PERS:(vitruvius) SPR:swe")
#'
#' xsearch(query = "stolpverk SPR:swe", database = "swepub")$content %>%
#' dplyr::slice(1) %>%
#' dplyr::glimpse()
#' }
xsearch <- function(
  query = NULL, start = 1, n = 10,
  order = c("rank", "alphabetical", "-alphabetical", "chronological", "-chronological"),
  format_level = c("brief", "full"),
  holdings = FALSE,
  database = c("libris", "swepub"),
  api_config = NULL)
{
  query_args <- list(
    query = query, format = "json", start = start, n = n,
    order = match.arg(order),
    format_level = match.arg(format_level),
    holdings = holdings,
    database = match.arg(database)
  )

  check_internet()
  stop_if_all(args, is.null, "You need to specify at least one argument")
  stop_if_not(is.character(query) && nchar(query) > 0,
    msg = "Please provide a query, for syntax see http://librishelp.libris.kb.se/help/search_language_swe.jsp (no english translation available)")
  stop_if_not(n <= 200, msg = "Maximum is 200 for number of returned records")
  if (any(missing(api_config), is.null(api_config)))
      api_config <- config()

  resp <- GET(api_config$base_url, query = compact(query_args), api_config$ua)
  check_status(resp)
  if (http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- fromJSON(rawToChar(resp$content))

  if (status_code(resp) != 200) {
    stop(
      sprintf(
        "API request failed [%s]\n%s\n<%s>",
        status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }

  # TODO - parse nested json into tabular format, for now just remove compound values

  parse_results <- function(x) {
    x$xsearch$list %>%
      as.data.frame() %>%
      tibble::as_tibble() %>%
      dplyr::select_if(function(y) !is.list(y))
  }

  content <- parse_results(parsed)

  structure(
    list(
      content = content,
      query = query,
      from = parsed$xsearch$from,
      to = parsed$xsearch$to,
      count = parsed$xsearch$records
    ),
    class = "xsearch"
  )
}

#' Retrieve more records from LIBRIS Xsearch API in batches
#'
#' This function retrieves batches of record (paging through results) for
#' between 200 and 10000 records in one go, displays a progress bar while progressing
#' and then returns all results.
#'
#' The database used can be specified - the default is to use LIBRIS but "swepub" is also available
#' @inheritDotParams xsearch
#' @export
#' @importFrom rlang eval_tidy parse_quo current_env
#'
#' @return results records returned from the search
#' @examples
#' \dontrun{
#' xsearch_crawl(query = "corona", database = "swepub")
#' }
xsearch_crawl <- function(...) {
  res <- xsearch(...)
  n <- res$count

  if (n <= 10)
    return (res)

  if (n > 10 & n < 200) {
    res <- xsearch(..., n = n)
    return (res)
  }

  if (n >= 200 & n < 10000) {
    # nr of pages to fetch
    n_pages <- n %/% 200 + ifelse(n %% 200 > 0, 1, 0)

    i <- c(0, (1:(n_pages - 1)) * 200)

    calls <- sprintf("xsearch(start = %s, n = 200, ...)$content", i)
    message(sprintf("Fetching %s hits in %s batches of 200 records", n, n_pages))

    pb <- progress::progress_bar$new(
      format = "  downloading [:bar] :percent in :elapsed",
      total = n_pages, clear = FALSE, width= 60)

    call2df <- function(x) {
      pb$tick()
      Sys.sleep(0.01)
      force(eval_tidy(parse_quo(x, env = current_env()))) #%>%
      #as.data.frame() %>%
      #tibble::as_tibble() %>%
      #dplyr::select_if(function(y) !is.list(y))
    }

    batch <- calls %>% purrr::map_df(call2df)

    res <- structure(
      list(
        content = batch,
        query = sprintf("%s pages of xsearch data", n_pages),
        from = 1,
        to = n + 1,
        count = n + 1
      ),
      class = "xsearch"
    )
  } else {
    stop(sprintf("Too big batch, %s records, stopping", n), call. = FALSE)
  }

  return(res)
}

#' @export
print.xsearch <- function(x, ...) {
  stopifnot(inherits(x, 'xsearch'))
  cat(sprintf("<Xsearch for %s (n_hits=%s, showing %s..%s)>\n",
    x$query, x$count, x$from, x$to))
  print(tibble::as_tibble(x$content))
  invisible(x)
}

#' HTML for a LIBRIS search box that can be integrated in HTML (rmarkdown docs, etc)
#'
#' @return character string with HTML snippet
#' @importFrom htmltools HTML
#' @export
libris_searchbox_html <- function() {
  searchbox <- '<!-- BEGIN LIBRIS search box -->
    <div style="padding-bottom: 10px; background: #fff url(http://libris.kb.se/images/logo_vit3.gif) no-repeat 13px 16px; width: 300px;">
      <form style="padding: 12px 0 0 100px;" method="get" target="_blank" action="http://libris.kb.se/formatQuery.jsp?" accept-charset="UTF-8" onsubmit="window.open(\'http://libris.kb.se/formatQuery.jsp?language=\' + document.getElementById(\'LANG\').value + \'&SEARCH_ALL=\'+ encodeURIComponent(document.getElementById(\'LIBRIS_SEARCH3\').value),\'LIBRIS\'); return false;">
      <fieldset style="margin: 0; padding: 0; border: none;">
      <legend style="display: none;">Search LIBRIS</legend>
      <input name="SEARCH_ALL" id="LIBRIS_SEARCH3" type="text" style="vertical-align: bottom; margin: 0; padding: 0; font-size: 11px; width: 60%;" /> <input type="submit" value="Search" style="vertical-align: bottom; margin: 0; padding: 0; cursor: pointer; font-size: 11px;" />
      <input type="hidden" id="LANG" name="LANG" value="en" />
      </fieldset>
      </form>
    </div>
    <!-- END LIBRIS search box -->'
  HTML(searchbox)
}
