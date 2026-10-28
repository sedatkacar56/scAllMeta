#' Browse All Metadata Columns in an Interactive Page
#'
#' @description
#' Builds a single self-contained HTML page that shows every metadata column of
#' a Seurat object, with counts, percentages and bars for each value, and opens
#' it in your browser or RStudio Viewer. Use it instead of \code{\link{allMetaTables}}
#' when the object has many columns.
#'
#' @param seurat_obj A Seurat object, or any data frame of per-cell metadata.
#' @param file Character or \code{NULL}. Where to save the HTML page. Default
#'   \code{NULL}: a temporary file.
#' @param open Logical. Open the page after writing it. Default
#'   \code{interactive()}.
#' @param max_levels Integer. Largest number of values listed per categorical
#'   column. The rest are summarised in a note. Default \code{100}.
#' @param numeric_min Integer. A numeric column with more unique values than this
#'   is shown as a summary and histogram instead of a table. Default \code{50}.
#' @param title Character or \code{NULL}. Page title. Default: the name of the
#'   object you passed.
#'
#' @return Invisibly returns the path of the HTML file.
#'
#' @details
#' The page has a column list with search on the left. The first entry, Overview,
#' lists every column with its type, number of unique values and share of
#' missing values. Click a column to see its values sorted by count, filter
#' them, sort them A to Z, or download them as CSV. Percentages are shares of
#' all cells, including \code{NA}. The page needs no internet connection and no
#' extra packages.
#'
#' @examples
#' \dontrun{
#' allMetaView(seurat_obj)
#'
#' # save the page to share it
#' allMetaView(seurat_obj, file = "metadata_overview.html")
#' }
#'
#' @seealso \code{\link{allMetaTables}}
#'
#' @export
allMetaView <- function(seurat_obj, file = NULL, open = interactive(),
                        max_levels = 100, numeric_min = 50, title = NULL) {

  if (is.null(title)) title <- paste(deparse(substitute(seurat_obj))[1], "metadata")
  md <- if (is.data.frame(seurat_obj)) seurat_obj else seurat_obj@meta.data
  n_cells <- nrow(md)

  cols <- lapply(colnames(md), function(nm) {
    x <- md[[nm]]
    n_na <- sum(is.na(x))
    n_unique <- length(unique(x[!is.na(x)]))

    if (is.numeric(x) && n_unique > numeric_min) {
      v <- x[is.finite(x)]
      q <- stats::quantile(v, c(0.25, 0.5, 0.75), names = FALSE)
      h <- graphics::hist(v, breaks = 30, plot = FALSE)
      return(list(
        name = nm, type = "numeric", n_unique = n_unique, n_na = n_na,
        stats = list(min = .num(min(v)), q1 = .num(q[1]), median = .num(q[2]),
                     mean = .num(mean(v)), q3 = .num(q[3]), max = .num(max(v))),
        hist = list(breaks = as.list(signif(h$breaks[c(1, length(h$breaks))], 4)),
                    counts = as.list(h$counts))
      ))
    }

    tb <- sort(table(x), decreasing = TRUE)
    shown <- utils::head(tb, max_levels)
    levels <- lapply(seq_along(shown), function(i)
      list(v = names(shown)[i], n = as.numeric(shown[i]), na = FALSE))
    if (n_na > 0) levels <- c(levels, list(list(v = "NA", n = n_na, na = TRUE)))
    list(name = nm, type = "categorical", n_unique = n_unique, n_na = n_na,
         levels = levels, hidden_levels = max(length(tb) - length(shown), 0),
         hidden_cells = as.numeric(sum(tb) - sum(shown)))
  })

  payload <- .json(list(n_cells = n_cells, columns = cols))
  tpl <- readLines(system.file("template", "viewer.html", package = "allmeta"),
                   encoding = "UTF-8", warn = FALSE)
  tpl <- paste(tpl, collapse = "\n")
  html <- sub("__DATA__", gsub("\\", "\\\\", payload, fixed = TRUE), tpl)
  html <- gsub("__TITLE__", .esc_html(title), html, fixed = TRUE)

  if (is.null(file)) file <- tempfile("allmeta_", fileext = ".html")
  con <- file(file, "w", encoding = "UTF-8")
  on.exit(close(con))
  writeLines(html, con)
  if (open) utils::browseURL(normalizePath(file))
  invisible(file)
}

# Format a number for display on the page.
.num <- function(x) format(signif(x, 4), scientific = FALSE, trim = TRUE, big.mark = ",")

.esc_html <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;", s, fixed = TRUE)
  gsub(">", "&gt;", s, fixed = TRUE)
}

# Minimal JSON writer so the package needs no extra dependency.
.json <- function(x) {
  if (is.null(x)) return("null")
  if (is.list(x)) {
    if (!is.null(names(x))) {
      return(paste0("{", paste0(vapply(names(x), .jstr, ""), ":",
                                vapply(x, .json, ""), collapse = ","), "}"))
    }
    return(paste0("[", paste(vapply(x, .json, ""), collapse = ","), "]"))
  }
  if (is.character(x)) return(.jstr(x))
  if (is.logical(x)) return(ifelse(is.na(x), "null", tolower(as.character(x))))
  if (is.na(x)) return("null")
  sprintf("%.10g", x)
}

.jstr <- function(s) {
  s <- gsub("\\", "\\\\", s, fixed = TRUE)
  s <- gsub("\"", "\\\"", s, fixed = TRUE)
  s <- gsub("\n", "\\n", s, fixed = TRUE)
  s <- gsub("\r", "\\r", s, fixed = TRUE)
  s <- gsub("\t", "\\t", s, fixed = TRUE)
  s <- gsub("<", "\\u003c", s, fixed = TRUE)
  paste0("\"", s, "\"")
}
