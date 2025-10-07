# Cluster Analysis for FC and IBDQ Data

## Overview

This repository contains a comprehensive R script for performing clustering analysis on FC (Fecal Calprotectin) and IBDQ (Inflammatory Bowel Disease Questionnaire) data at baseline and induction timepoints.

## Features

### Clustering Methods Implemented

The script implements 5 common clustering methods suitable for 2-variable clustering:

1. **K-means Clustering**
   - Parameter selection: Elbow method for optimal k
   - Creates within-cluster sum of squares plots
   
2. **Hierarchical Clustering**
   - Parameter selection: Silhouette analysis
   - Creates dendrograms with cluster boundaries
   
3. **PAM (Partitioning Around Medoids)**
   - Parameter selection: Silhouette analysis
   - More robust to outliers than K-means
   
4. **Gaussian Mixture Model (GMM)**
   - Parameter selection: BIC (Bayesian Information Criterion)
   - Probabilistic clustering approach
   
5. **DBSCAN (Density-Based Spatial Clustering)**
   - Parameter selection: k-NN distance plot for eps
   - Can identify noise points and clusters of arbitrary shape

### Analysis Pipeline

For each clustering method, the script performs:

1. **Parameter Optimization**: Uses method-specific criteria to determine optimal parameters
2. **Clustering**: Applies clustering with optimal parameters
3. **Result Storage**: Saves cluster assignments to the dataset
4. **Visualization**: Creates scatter plots showing cluster assignments
5. **Pattern Analysis**: Analyzes transition patterns from baseline to induction
6. **Statistical Analysis**: Performs baseline comparison and logistic regression

## Data Structure

### Input Variables

The script expects data with the following variables:

- `FC_base`: Fecal Calprotectin at baseline (will be log-transformed)
- `FC_induc`: Fecal Calprotectin at induction (will be log-transformed)
- `IBDQ_base`: IBDQ score at baseline
- `IBDQ_induc`: IBDQ score at induction

### Additional Variables for Analysis

- `Age`: Patient age
- `Sex`: Patient sex (Male/Female)
- `BMI`: Body Mass Index
- `Disease_Duration`: Duration of disease
- `Outcome`: Binary outcome variable for logistic regression

### Generated Variables

The script creates:

- `FC_base_log`, `FC_induc_log`: Log-transformed FC values
- Cluster assignments for each method (e.g., `kmeans_cluster1`, `kmeans_cluster2`)
- Pattern variables showing transitions (e.g., `kmeans_pattern`)
- `pattern_group`: Grouped patterns (Stable_Low, Improved, Worsened, Stable_High)

## Usage

### Prerequisites

Install required R packages:

```r
install.packages(c("tidyverse", "cluster", "factoextra", "mclust", 
                   "dbscan", "ggplot2", "gridExtra", "tableone"))
```

### Running the Analysis

1. **Prepare your data**: Replace the sample data generation code (lines 32-48) with your actual data loading:

```r
# Replace this section with your data loading
data_raw <- read.csv("your_data_file.csv")
```

2. **Run the script**:

```r
source("clustering_analysis.R")
```

3. **Review outputs**: The script generates multiple files in the working directory

## Output Files

### Plots

- **Elbow plots**: `kmeans_elbow_Cluster1_Base.png`, `kmeans_elbow_Cluster2_Induc.png`
- **Dendrograms**: `hierarchical_dendrogram_*.png`
- **Silhouette plots**: `hierarchical_silhouette_*.png`, `pam_silhouette_*.png`
- **BIC plots**: `gmm_bic_*.png`
- **k-NN distance plots**: `dbscan_knn_*.png`
- **Scatter plots**: `*_cluster1_scatter.png`, `*_cluster2_scatter.png` for each method
- **Transition plots**: `*_transitions.png` showing pattern changes
- **Forest plot**: `forest_plot_pattern_groups.png`

### Tables

- `baseline_characteristics_table.csv`: Baseline characteristics by pattern group
- `logistic_regression_results.csv`: Logistic regression results with ORs and CIs

### Data

- `data_with_clustering_results.csv`: Complete dataset with all clustering results

### Summary

- `clustering_analysis_summary.txt`: Text summary of the entire analysis

## Clustering Results

### Two-Stage Clustering

The analysis performs clustering at two timepoints:

- **Cluster 1**: Based on standardized `FC_base_log` and `IBDQ_base`
- **Cluster 2**: Based on standardized `FC_induc_log` and `IBDQ_induc`

### Pattern Analysis

The script analyzes how patients transition between clusters from baseline to induction, creating pattern groups:

- **Stable_Low**: Remained in low-risk cluster (e.g., 1→1)
- **Improved**: Moved to lower-risk cluster (e.g., 2→1, 3→1)
- **Worsened**: Moved to higher-risk cluster (e.g., 1→2, 1→3)
- **Stable_High**: Remained in high-risk cluster (e.g., 3→3)

### Statistical Analysis

The script performs:

1. **Baseline Characteristics Comparison**: Compares baseline variables across pattern groups using `CreateTableOne`
2. **Logistic Regression**: 
   - Univariate analysis: Pattern groups vs. outcome
   - Multivariate analysis: Adjusted for age, sex, BMI, and disease duration

## Customization

### Adjusting Cluster Numbers

To modify the maximum number of clusters tested, change the `max_k` parameter in function calls:

```r
kmeans_cluster1 <- perform_kmeans_clustering(cluster1_data, "Cluster1_Base", max_k = 8)
```

### Changing DBSCAN Parameters

Adjust the `eps` and `minPts` values in the `perform_dbscan_clustering` function:

```r
eps_value <- 0.3  # Change this value based on k-NN plot
minPts_value <- 5  # Minimum points to form a cluster
```

### Modifying Pattern Groups

Edit the `create_pattern_groups` function to define custom pattern groupings based on clinical interpretation.

## Notes

- All FC values are log-transformed before clustering
- All variables are standardized (z-score) before clustering
- The script uses `set.seed(123)` for reproducibility
- Missing values should be handled before running the script (imputation code provided as placeholder)

## License

This code is provided for research and educational purposes.