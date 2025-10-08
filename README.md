# Cluster Analysis Project

## Overview

This project implements comprehensive clustering analysis in R using multiple methods including K-means, Hierarchical Clustering, Gaussian Mixture Models (GMM), DBSCAN, and Affinity Propagation. The analysis focuses on identifying patient subgroups based on biomarker patterns at baseline and during induction treatment.

## Features

### Clustering Methods Implemented

1. **K-means Clustering**
   - Parameter selection using Elbow method and Silhouette analysis
   - Automatic optimal k determination
   - Visualization of clustering results

2. **Hierarchical Clustering**
   - Dendrogram visualization
   - Optimal cluster number selection using Silhouette analysis
   - Ward's linkage method

3. **Gaussian Mixture Model (GMM)**
   - BIC-based model selection
   - Automatic component number determination
   - Probabilistic cluster assignment

4. **DBSCAN (Density-Based Spatial Clustering)**
   - k-NN distance plot for epsilon selection
   - Noise point detection
   - Automatic parameter tuning

5. **Affinity Propagation**
   - Automatic cluster number determination
   - No need to specify k in advance
   - Exemplar-based clustering

### Analysis Features

- **Data Preprocessing**
  - Log transformation of FC (Fecal Calprotectin) values
  - Standardization of all clustering variables
  - Missing value imputation

- **Dual Timepoint Analysis**
  - Clustering at baseline (FC_base_log + IBDQ_base)
  - Clustering at induction (FC_induc_log + IBDQ_induc)

- **Pattern Change Analysis**
  - Sankey diagrams showing cluster transitions
  - Transition matrices and proportions
  - Common pattern identification

- **Statistical Analysis**
  - Baseline characteristic comparison tables
  - Logistic regression for outcome prediction
  - Pattern group associations with treatment response

## Installation

### Prerequisites

- R (version 4.0 or higher)
- RStudio (recommended but not required)

### Required R Packages

The script will automatically install required packages if they are not present:

```r
required_packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "cluster",        # Clustering algorithms
  "factoextra",     # Cluster visualization
  "mclust",         # GMM clustering
  "dbscan",         # DBSCAN clustering
  "apcluster",      # Affinity Propagation
  "ggalluvial",     # Sankey diagram
  "tableone",       # Baseline tables
  "caret",          # Machine learning utilities
  "pROC",           # ROC analysis
  "gridExtra",      # Multiple plots
  "dendextend",     # Dendrogram customization
  "NbClust"         # Optimal cluster number
)
```

## Usage

### Quick Start

1. **Clone or download this repository**

```bash
git clone https://github.com/20980061/Cluster.git
cd Cluster
```

2. **Prepare your data**

The script expects a data frame with the following variables:
- `FC_base`: Fecal Calprotectin at baseline
- `FC_induc`: Fecal Calprotectin at induction
- `IBDQ_base`: Inflammatory Bowel Disease Questionnaire score at baseline
- `IBDQ_induc`: IBDQ score at induction
- `response`: Treatment response outcome (0/1)
- Additional baseline variables: `age`, `sex`, `disease_duration`, etc.

3. **Modify the data loading section**

Replace the example data generation code (lines 55-67) with your actual data:

```r
# Example: Load from RData file
setwd("your/data/path")
load("your_data_file.RData")
data_test <- your_data_object

# OR: Load from CSV
data_test <- read.csv("your_data.csv")
```

4. **Run the analysis**

In R or RStudio:

```r
source("clustering_analysis.R")
```

Or from command line:

```bash
Rscript clustering_analysis.R
```

### Using the Script with Your Data

#### Step 1: Prepare Your Data

Ensure your data frame contains at least:

```r
# Required variables for clustering:
- FC_base (numeric)
- FC_induc (numeric)
- IBDQ_base (numeric)
- IBDQ_induc (numeric)

# Required for logistic regression:
- response (binary: 0/1)

# Optional baseline characteristics:
- age (numeric)
- sex (factor or character)
- disease_duration (numeric)
- ... other baseline variables
```

#### Step 2: Configure the Script

Edit the data loading section in `clustering_analysis.R`:

```r
# Replace lines 55-67 with your data loading code
# Example:
setwd("/home/runner/work/Cluster/Cluster")
load("my_study_data.RData")
data_test <- my_data
```

#### Step 3: Run Analysis

The script will automatically:
1. Transform and standardize your data
2. Perform all 5 clustering methods on both timepoints
3. Generate visualizations
4. Conduct statistical analyses
5. Save all results

## Output Files

The script generates the following outputs:

### Visualizations (PNG files)

For each clustering method:
- `cluster_plot_[method]_base.png` - Scatter plot of baseline clusters
- `cluster_plot_[method]_induc.png` - Scatter plot of induction clusters
- `sankey_[method].png` - Sankey diagram showing cluster transitions
- Method-specific plots (e.g., elbow plots, dendrograms, BIC plots)

### Data Files (CSV files)

- `data_with_all_clusters.csv` - Original data with all clustering results
- `pattern_analysis_[method].csv` - Transition pattern tables
- `baseline_table_[method].csv` - Baseline characteristics by pattern group
- `clustering_comparison.csv` - Summary comparison of all methods

### Results Files (TXT files)

- `logistic_regression_[method].txt` - Logistic regression output for each method

## Interpreting Results

### Clustering Results

Each clustering method generates:
1. **Optimal number of clusters** - Determined by method-specific criteria
2. **Cluster assignments** - Saved in the main dataset
3. **Visual representations** - Scatter plots with color-coded clusters

### Pattern Analysis

The Sankey diagrams show:
- **Flow width** - Number of patients transitioning between clusters
- **Colors** - Baseline cluster assignments
- **Common patterns** - Most frequent transition pathways

### Statistical Outputs

- **Baseline tables** - Compare patient characteristics across pattern groups
- **Logistic regression** - Association between patterns and treatment response
- **Transition matrices** - Detailed breakdown of cluster changes

## Customization

### Adjusting Clustering Parameters

You can modify clustering parameters in each function:

```r
# K-means: Change range of k values to test
wss <- sapply(1:10, function(k) { ... })  # Change 1:10 to your desired range

# Hierarchical: Change linkage method
hc <- hclust(dist_matrix, method = "ward.D2")  # Options: "complete", "average", etc.

# GMM: Change range of components
bic_values <- mclustBIC(data, G = 1:9)  # Change 1:9 to your desired range

# DBSCAN: Modify minPts
dbscan_result <- dbscan(data, eps = optimal_eps, minPts = 4)  # Change minPts
```

### Custom Pattern Groups

Modify the `create_combined_grouping()` function to define custom pattern groups:

```r
# Example: Custom grouping logic
combined_group <- case_when(
  cluster_base == cluster_induc & cluster_base == 1 ~ "Stable_Low",
  cluster_base == cluster_induc & cluster_base > 1 ~ "Stable_High",
  as.numeric(cluster_induc) > as.numeric(cluster_base) ~ "Improved",
  as.numeric(cluster_induc) < as.numeric(cluster_base) ~ "Worsened",
  TRUE ~ "Other"
)
```

## Troubleshooting

### Common Issues

1. **Missing packages**
   - The script auto-installs packages, but if issues occur, manually install:
   ```r
   install.packages(c("tidyverse", "cluster", "factoextra", "mclust", "dbscan", "apcluster", "ggalluvial", "tableone"))
   ```

2. **Memory errors with large datasets**
   - Consider sampling your data or running methods sequentially
   - Close other applications to free up RAM

3. **No variation in clustering results**
   - Check if your data has sufficient variability
   - Verify standardization is working correctly
   - Try different numbers of clusters manually

4. **Errors in pattern analysis**
   - Ensure baseline and induction clusters have compatible numbering
   - Check for missing values in cluster assignments

## Example Workflow

```r
# 1. Load the script
source("clustering_analysis.R")

# 2. The script will:
#    - Load and preprocess data
#    - Run K-means clustering
#    - Run Hierarchical clustering
#    - Run GMM clustering
#    - Run DBSCAN clustering
#    - Run Affinity Propagation
#    - Generate all visualizations
#    - Perform statistical analyses
#    - Save all results

# 3. Review outputs in the working directory

# 4. Examine specific results
head(data_imputed)  # View data with cluster assignments
table(data_imputed$cluster_kmeans_base)  # Check cluster sizes

# 5. Custom analyses
# You can add your own analyses using the clustering results
```

## Citation

If you use this code in your research, please cite:

```
[Your citation information here]
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For questions or issues, please open an issue on GitHub or contact:
- GitHub: https://github.com/20980061/Cluster

## Acknowledgments

- R Core Team for the R software
- Package developers for clustering and visualization tools
- Contributors to this project