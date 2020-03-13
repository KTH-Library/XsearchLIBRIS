#' @param query text query as defined by the custom query language described here <http://librishelp.libris.kb.se/help/search_language_swe.jsp>
#'
#' Operators are: `AND, OR, NOT, ADJ, SAME, XOR`
#'
#' A short list of examples follow below.
#'
#' - author is Ludwig Wittgenstein: `forf:(Ludwig+Wittgenstein)`
#' - publications with title "Röda rummet": `TIT:"Röda rummet"`
#' - publications with a set of titles (experiment or experiments or experimental): `TIT=experiment OR TIT:experiments OR TIT:experimental`
#' - publications by Horatius Quintus: `PERS:(Horatius Quintus)`
#'
#' @param start integer that specifies the starting position in a hitlist from which records should be taken
#' @param n the number of records to be retrieved, to a maximum of 200
#' @param order sort order, one of "rank", "alphabetical", "-alphabetical",
#'   "chronological", "-chronological" where an opening hyphen stands for sorting in reverse order
#' @param format_level one of "brief" or "full", which specifies whether “see” or ”see also” links to authority forms (9XX fields) should be included.
#' @param holdings boolean defaulting to FALSE, specifies whether holding information should be included. Works only with the marcxml and mods formats.
#' @param database one of "libris" or "swepub"
