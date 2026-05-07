# Quick Start Guide

## Installation

1. **Install R** (if not already installed):
   ```bash
   # On Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install r-base r-base-dev
   
   # On macOS
   brew install r
   
   # On Windows
   # Download from https://cran.r-project.org/
   ```

2. **Install required R packages**:
   ```r
   # Open R and run:
   install.packages(c(
     "tidyverse", "cluster", "factoextra", "mclust", 
     "dbscan", "apcluster", "ggalluvial", "gridExtra", 
     "mice", "tableone"
   ))
   ```

## Quick Start

### 1. Basic Alluvial Diagram

To create a simple alluvial diagram showing cluster transitions:

```bash
Rscript create_alluvial.R
```

This will generate:
- `output/alluvial_diagram.png` or `output/transition_diagram.png` (depending on package availability)
- `output/pattern_frequency.png` - bar chart of transition patterns
- `output/transition_summary.txt` - statistical summary

### 2. Example Workflow

To see a complete example workflow with K-means clustering:

```bash
Rscript example_usage.R
```

This demonstrates:
- Data preparation
- Log transformation and standardization
- K-means clustering
- Transition pattern analysis
- Visualization creation

### 3. Full Clustering Analysis

To run all 5 clustering methods with complete analysis:

```bash
Rscript Cluster.R
```

**Note**: This may take 10-30 minutes depending on your system and whether packages need to be installed.

## Using Your Own Data

### Option 1: Modify the script directly

Edit the data loading section in any script (lines ~40-52):

```r
# Replace the demo data generation with:
setwd("your/working/directory")
load("your_data.RData")
data_test <- your_data_object

# Or load from CSV:
data_test <- read.csv("your_data.csv")
```

### Option 2: Use R interactively

```r
# Start R
R

# Load your data
source("example_usage.R")  # This loads functions
load("your_data.RData")

# Use the functions on your data
# ... follow the steps in example_usage.R
```

## Expected Data Format

Your dataset should include these columns:

| Column | Type | Description |
|--------|------|-------------|
| `ID` | Numeric/Character | Patient identifier |
| `FC_base` | Numeric | Fecal calprotectin at baseline |
| `FC_induc` | Numeric | Fecal calprotectin at induction |
| `IBDQ_base` | Numeric | IBDQ score at baseline |
| `IBDQ_induc` | Numeric | IBDQ score at induction |
| `Response` | Binary (0/1) | Treatment response (optional) |
| `Age` | Numeric | Patient age (optional) |
| `Sex` | Factor | Patient sex (optional) |

Additional baseline characteristics can be added as needed.

## Output Files

All outputs are saved to the `output/` directory:

### Clustering Evaluation
- `*_elbow_*.png` - Elbow plots for K-means
- `*_dendrogram_*.png` - Dendrograms for hierarchical
- `*_bic_*.png` - BIC plots for GMM
- `*_knn_*.png` - kNN distance plots for DBSCAN

### Clustering Results
- `*_scatter_base.png` - Baseline clustering scatter plots
- `*_scatter_induc.png` - Induction clustering scatter plots

### Transition Visualizations
- `alluvial_*.png` - Alluvial flow diagrams
- `transition_diagram.png` - Alternative transition heatmap
- `pattern_frequency.png` - Bar chart of pattern frequencies

### Statistical Analysis
- `baseline_table_*.txt` - Baseline characteristics tables
- `logistic_model*.txt` - Logistic regression summaries
- `odds_ratios_*.csv` - Odds ratios with confidence intervals
- `transition_summary.txt` - Overall transition statistics
- `data_with_clusters.csv` - Complete dataset with cluster assignments

## Interpreting the Alluvial Diagram

The alluvial diagram visualizes patient flow between clusters:

```
Baseline          Induction
Clusters          Clusters

   1  ─────────→    1
      \  ───→        
       \ /           2
        X            
       / \           
   2  ─────────→    3
   
   3  ─────────→
```

- **Width of flows**: Proportional to number of patients
- **Colors**: Distinguished by baseline cluster
- **Stable patterns**: Same cluster at both timepoints (e.g., 1→1)
- **Changed patterns**: Different clusters (e.g., 1→2, 2→3)

## Troubleshooting

### Package Installation Issues

If you encounter errors installing packages:

```r
# Try specifying a different CRAN mirror
install.packages("package_name", repos = "https://cloud.r-project.org/")

# Or install system dependencies first (Ubuntu/Debian):
sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev
```

### ggalluvial Not Available

If the `ggalluvial` package is not available, the scripts will automatically create alternative visualizations using base R graphics.

To get the best alluvial diagrams, install from source:

```r
install.packages("ggalluvial")
```

### Memory Issues

For large datasets (>10,000 rows), you may need to:

1. Increase R memory limit:
   ```r
   # Increase to 16GB
   memory.limit(16000)  # Windows only
   ```

2. Process subsets:
   ```r
   # Use a random sample
   data_subset <- data_test[sample(1:nrow(data_test), 5000), ]
   ```

### Running Time

Expected running times (on typical hardware):

- `create_alluvial.R`: 10-30 seconds
- `example_usage.R`: 10-30 seconds  
- `Cluster.R` (all methods): 10-30 minutes (first run with package installation)
- `Cluster.R` (subsequent runs): 2-5 minutes

## Support

For issues or questions:

1. Check that all required packages are installed
2. Verify your data has the required columns
3. Review the error messages for missing dependencies
4. Consult the R documentation: `?function_name`

## References

- K-means: MacQueen, J. (1967)
- Hierarchical: Ward, J. H. (1963)
- GMM: Fraley, C., & Raftery, A. E. (2002)
- DBSCAN: Ester, M., et al. (1996)
- Affinity Propagation: Frey, B. J., & Dueck, D. (2007)
- Alluvial diagrams: `ggalluvial` package by Brunson (2020)
