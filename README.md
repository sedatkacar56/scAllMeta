# allmeta

One call to see every column of your Seurat metadata.

`allMetaTables()` prints a frequency table for each column in `seurat_obj@meta.data`, so you can check clusters, samples, annotations and labels in one glance after integration, annotation or any metadata change.

## Installation

```r
# install.packages("remotes")
remotes::install_github("sedatkacar56/allmeta")
```

Works with any [Seurat](https://satijalab.org/seurat/) object. The package itself has no required dependencies.

## Usage

```r
library(allmeta)

allMetaTables(seurat_obj)
```

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

## Rules

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
