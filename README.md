# scAllMeta

One call to see every column of your Seurat metadata.

- `allMetaView()` opens an interactive page in your browser: a searchable column list, counts, percentages and bars for every value, histograms for numeric columns, and CSV download. Best for objects with many columns.
- `allMetaTables()` prints a frequency table for each column in the console.

Use them to check clusters, samples, annotations and labels in one glance after integration, annotation or any metadata change.

## Installation

```r
# install.packages("remotes")
remotes::install_github("sedatkacar56/scAllMeta")
```

Works with any [Seurat](https://satijalab.org/seurat/) object. The package itself has no required dependencies.

## Usage

```r
library(scAllMeta)

# interactive page (recommended for many columns)
allMetaView(seurat_obj)

# save the page to share it
allMetaView(seurat_obj, file = "metadata_overview.html")

# console tables
allMetaTables(seurat_obj)
```

### allMetaView() page

- **Overview** lists every column with its type, number of unique values and share of missing values. Click a row to open that column.
- **Categorical columns** show each value with its cell count, percentage of all cells and a bar. You can filter values, sort by count or A to Z, and download the table as CSV. `NA` is shown as its own grey row.
- **Compare two columns:** type another column name in the "Compare with" box and the table becomes a contingency table, like `table(column, other_column)`. Rows are the values of the open column, columns are the values of the other one, and each cell shows the number of cells with a percentage (of the column, the row, or all cells; or counts only). A TOTAL row and column are added, `NA` has its own row and column, and the table can be downloaded as CSV. Counts are computed in your browser from every cell.
- **Layouts:** the **Layout** switch at the top right changes the look. *Aurora* (default) is a dark, high-contrast theme, *Light* is a clean white theme, and *Classic* copies the colors of a `gt` contingency table (yellow row labels, light-blue counts, orange percentages, green header, red TOTAL row). Your choice is remembered in the browser.
- **Heatmap:** in a comparison table, the **Heatmap** button colors every cell from the smallest to the largest value, so differences stand out. It is on by default in Aurora and Light and off in Classic. A legend shows the range. **% in separate columns** puts each percentage in its own column next to its count.
- **Numeric columns** (more than `numeric_min` unique values, default 50) show min, quartiles, mean, max and a histogram.
- Lists up to `max_levels` values per column (default 100) and says how many cells are in the values not shown.
- Only columns with up to `compare_max_levels` values (default 100) can be compared. Each one adds about 1 byte per cell to the file before compression, so for a very large object use `compare = FALSE` for a small page without the comparison feature.
- The page is one HTML file. It needs no internet connection and no extra packages, and follows your light or dark mode.

### allMetaTables() output

Example output:

```
========================================
Column: orig.ident
========================================

 sample1  sample2 
    5210     4873 

========================================
Column: nCount_RNA
========================================
Not applicable ( 9876 unique values)
```

## allMetaTables() rules

| Unique values in the column | What is printed |
|---|---|
| 20 or fewer | the full frequency table |
| 21 to 50 | the top 20 most frequent values, with a note of the total |
| more than 50 | "Not applicable" and the number of unique values (typical for continuous metrics such as `nCount_RNA` or `percent.mt`) |

- The function only prints. It returns `NULL` invisibly and never changes your object.
- `NA` counts as a value when counting unique values, but `table()` does not list `NA` by default.

## Acknowledgements

Alhamdulillah. Developed by Dr. Sedat Kacar.

## License

MIT, see `LICENSE.md`.
