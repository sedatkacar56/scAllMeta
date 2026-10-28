#' Print Summary Tables for All Seurat Object Metadata Columns
#'
#' @description
#' Iterates over all columns in a Seurat object's metadata and prints a
#' frequency table for each one. Columns with more than 50 unique values
#' (e.g. continuous metrics) are flagged as not applicable, and columns
#' with 21–50 unique values are capped at the top 20 most frequent entries
#' to keep output readable.
#'
#' @param seurat_obj A Seurat object. Must contain a populated \code{meta.data}
#'   slot with at least one column.
#'
#' @return Invisibly returns \code{NULL}. The function is called for its
#'   side effect of printing to the console.
#'
#' @details
#' The function applies the following rules per column:
#' \itemize{
#'   \item \strong{> 50 unique values}: Prints "Not applicable" along with the
#'     total number of unique values. Typical for continuous variables such as
#'     \code{nCount_RNA} or \code{percent.mt}.
#'   \item \strong{21–50 unique values}: Prints the top 20 most frequent
#'     categories sorted in decreasing order, along with a note indicating
#'     how many unique values exist in total.
#'   \item \strong{<= 20 unique values}: Prints the full frequency table.
#'     Typical for categorical variables such as \code{seurat_clusters} or
#'     \code{orig.ident}.
#' }
#'
#' @examples
#' \dontrun{
#' library(Seurat)
#'
#' # Basic usage
#' allMetaTables(seurat_obj)
#'
#' # Useful for a quick QC check after integration or annotation
#' allMetaTables(integrated_seurat)
#' }
#'
#' @seealso
#' \code{\link[base]{table}}, \code{\link[Seurat]{Seurat-class}}
#'
#' @export
allMetaTables <- function(seurat_obj) {
  
  metadata <- seurat_obj@meta.data
  cols <- colnames(metadata)
  
  for (col in cols) {
    cat("\n", rep("=", 40), "\n", sep = "")
    cat("Column:", col, "\n")
    cat(rep("=", 40), "\n", sep = "")
    
    n_unique <- length(unique(metadata[[col]]))
    
    if (n_unique > 50) {
      cat("Not applicable (", n_unique, "unique values)\n")
      
    } else if (n_unique > 20) {
      cat("Showing 20 of", n_unique, "unique values:\n")
      tbl <- table(metadata[[col]])
      tbl_sorted <- sort(tbl, decreasing = TRUE)
      print(tbl_sorted[1:20])
      
    } else {
      print(table(metadata[[col]]))
    }
  }
}
