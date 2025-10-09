# K-means Clustering Implementation Summary

## Overview
K-means clustering has been successfully implemented in `Cluster.R` (lines 239-351), positioned between GMM clustering and general analysis functions as requested.

## Implementation Details

### Location in Code
- **GMM Clustering**: Lines 176-237
- **K-means Clustering**: Lines 239-351 (NEW)
- **General Analysis Functions**: Lines 353+

### Features Implemented

#### 1. Elbow Method for Optimal K Selection
- Evaluates K values from 1 to 10
- Calculates Within-Cluster Sum of Squares (WSS) for each K
- Generates elbow plots for visual inspection:
  - `Kmeans_Elbow_Method_base.png` - for baseline data
  - `Kmeans_Elbow_Method_induc.png` - for induction data

#### 2. K-means Clustering for Base (Baseline) Data
- **Input variables** (5 dimensions):
  - `FC_base_log` - Log-transformed and scaled FC at baseline
  - `IBDQ_BS_base_std` - Standardized IBDQ Bowel Symptoms at baseline
  - `IBDQ_SS_base_std` - Standardized IBDQ Systemic Symptoms at baseline
  - `IBDQ_EF_base_std` - Standardized IBDQ Emotional Function at baseline
  - `IBDQ_SF_base_std` - Standardized IBDQ Social Function at baseline

- **Parameters**:
  - `centers = 4` (optimal K, can be adjusted based on elbow plot)
  - `nstart = 25` (multiple random starts for stability)
  - `iter.max = 100` (maximum iterations)
  - `set.seed(123)` (reproducibility)

- **Output**:
  - Cluster labels saved to: `data_imputed$Kmeans_cluster_base`
  - Cluster centers displayed in console
  - Visualization: `Kmeans_Clusters_base.png`

#### 3. K-means Clustering for Induc (Induction) Data
- **Input variables** (5 dimensions):
  - `FC_induc_log` - Log-transformed and scaled FC at induction
  - `IBDQ_BS_induc_std` - Standardized IBDQ Bowel Symptoms at induction
  - `IBDQ_SS_induc_std` - Standardized IBDQ Systemic Symptoms at induction
  - `IBDQ_EF_induc_std` - Standardized IBDQ Emotional Function at induction
  - `IBDQ_SF_induc_std` - Standardized IBDQ Social Function at induction

- **Parameters**: Same as base clustering
- **Output**:
  - Cluster labels saved to: `data_imputed$Kmeans_cluster_induc`
  - Cluster centers displayed in console
  - Visualization: `Kmeans_Clusters_induc.png`

#### 4. Visualization Outputs
The implementation generates 4 PNG files:
1. **Kmeans_Elbow_Method_base.png** - WSS vs K plot for baseline data
2. **Kmeans_Elbow_Method_induc.png** - WSS vs K plot for induction data
3. **Kmeans_Clusters_base.png** - Scatter plot of clusters (first 2 dimensions) with centroids for baseline
4. **Kmeans_Clusters_induc.png** - Scatter plot of clusters (first 2 dimensions) with centroids for induction

#### 5. Data Storage
- Cluster labels are stored as factor variables:
  - `data_imputed$Kmeans_cluster_base`
  - `data_imputed$Kmeans_cluster_induc`
- These can be used with the general analysis functions that follow (baseline comparison tables, logistic regression, etc.)

## Usage with General Analysis Functions

The K-means clustering results can be analyzed using the existing general analysis framework by changing the cluster variable selection:

```r
# To analyze K-means results instead of GMM:
cluster_base <- "Kmeans_cluster_base"
cluster_induc <- "Kmeans_cluster_induc"
method_name <- "Kmeans"
```

This will automatically:
- Generate cluster summary statistics
- Create baseline characteristic comparison tables
- Perform logistic regression analysis
- Create visualization plots

## Code Structure

```r
## ==================== K-means聚类 ====================

#=============== K-means聚类 - 基线期 (base) ===============
# 1. Elbow method for K selection
# 2. K-means clustering with optimal K
# 3. Save results and visualize

#=============== K-means聚类 - 诱导期 (induc) ===============
# 1. Elbow method for K selection
# 2. K-means clustering with optimal K
# 3. Save results and visualize
```

## Key Features

✅ Follows the same structure as GMM clustering
✅ Uses elbow method for objective K selection
✅ Performs clustering on both base and induc datasets
✅ Saves results to `data_imputed` for downstream analysis
✅ Generates informative visualizations
✅ Includes console output for immediate feedback
✅ Positioned correctly between GMM and general analysis functions
✅ Uses the same standardized variables as defined in the data preparation section

## Next Steps

When running the code:
1. Review the elbow plots to confirm K=4 is optimal (adjust if needed)
2. The clustering results will be automatically saved
3. Use the general analysis functions to compare K-means vs GMM results
4. Generate Sankey diagrams to visualize cluster transitions from base to induc
