# Expected Output Files

When you run the clustering analysis script, the following files will be generated:

## Clustering Plots

### K-means Method
- `kmeans_elbow_base.png` - Elbow plot for determining optimal k at baseline
- `kmeans_elbow_induc.png` - Elbow plot for determining optimal k at induction
- `cluster_plot_K-means_base.png` - Scatter plot of baseline clusters
- `cluster_plot_K-means_induc.png` - Scatter plot of induction clusters
- `sankey_K-means.png` - Sankey diagram showing cluster transitions

### Hierarchical Clustering Method
- `hierarchical_dendrogram_base.png` - Dendrogram for baseline data
- `hierarchical_dendrogram_induc.png` - Dendrogram for induction data
- `hierarchical_silhouette_base.png` - Silhouette analysis for baseline
- `hierarchical_silhouette_induc.png` - Silhouette analysis for induction
- `cluster_plot_Hierarchical_base.png` - Scatter plot of baseline clusters
- `cluster_plot_Hierarchical_induc.png` - Scatter plot of induction clusters
- `sankey_Hierarchical.png` - Sankey diagram showing cluster transitions

### GMM Method
- `gmm_bic_base.png` - BIC plot for model selection at baseline
- `gmm_bic_induc.png` - BIC plot for model selection at induction
- `gmm_classification_base.png` - GMM classification plot at baseline
- `gmm_classification_induc.png` - GMM classification plot at induction
- `cluster_plot_GMM_base.png` - Scatter plot of baseline clusters
- `cluster_plot_GMM_induc.png` - Scatter plot of induction clusters
- `sankey_GMM.png` - Sankey diagram showing cluster transitions

### DBSCAN Method
- `dbscan_knn_base.png` - k-NN distance plot for epsilon selection at baseline
- `dbscan_knn_induc.png` - k-NN distance plot for epsilon selection at induction
- `cluster_plot_DBSCAN_base.png` - Scatter plot of baseline clusters
- `cluster_plot_DBSCAN_induc.png` - Scatter plot of induction clusters
- `sankey_DBSCAN.png` - Sankey diagram showing cluster transitions

### Affinity Propagation Method
- `cluster_plot_Affinity Propagation_base.png` - Scatter plot of baseline clusters
- `cluster_plot_Affinity Propagation_induc.png` - Scatter plot of induction clusters
- `sankey_Affinity_Propagation.png` - Sankey diagram showing cluster transitions

## Data Files

### Pattern Analysis Tables (CSV)
- `pattern_analysis_K-means.csv` - Transition patterns for K-means
- `pattern_analysis_Hierarchical.csv` - Transition patterns for Hierarchical
- `pattern_analysis_GMM.csv` - Transition patterns for GMM
- `pattern_analysis_DBSCAN.csv` - Transition patterns for DBSCAN
- `pattern_analysis_Affinity_Propagation.csv` - Transition patterns for Affinity Propagation

### Baseline Characteristics Tables (CSV)
- `baseline_table_K-means.csv` - Baseline characteristics by K-means pattern group
- `baseline_table_Hierarchical.csv` - Baseline characteristics by Hierarchical pattern group
- `baseline_table_GMM.csv` - Baseline characteristics by GMM pattern group
- `baseline_table_DBSCAN.csv` - Baseline characteristics by DBSCAN pattern group
- `baseline_table_Affinity_Propagation.csv` - Baseline characteristics by AP pattern group

### Main Output Files
- `data_with_all_clusters.csv` - Original data with all cluster assignments added
- `clustering_comparison.csv` - Summary comparison of all clustering methods

## Statistical Results Files

### Logistic Regression (TXT)
- `logistic_regression_K-means.txt` - Regression results for K-means pattern groups
- `logistic_regression_Hierarchical.txt` - Regression results for Hierarchical pattern groups
- `logistic_regression_GMM.txt` - Regression results for GMM pattern groups
- `logistic_regression_DBSCAN.txt` - Regression results for DBSCAN pattern groups
- `logistic_regression_Affinity_Propagation.txt` - Regression results for AP pattern groups

## Example Data Files (if using generate_example_data.R)
- `example_patient_data.csv` - Example patient dataset
- `example_patient_data.RData` - Example patient dataset in R format
- `data_dictionary.csv` - Data dictionary explaining variables
- `example_data_FC_comparison.png` - Visualization of FC baseline vs induction
- `example_data_IBDQ_comparison.png` - Visualization of IBDQ baseline vs induction

## File Organization

All files are generated in the working directory by default. The total number of files generated is approximately:
- **~25-30 PNG image files** (plots and visualizations)
- **~10-15 CSV files** (data tables and results)
- **~5 TXT files** (statistical output)

**Total: ~40-50 files**

## Interpreting Output Files

### Cluster Plots
- **Points**: Each point represents a patient
- **Colors**: Different colors represent different clusters
- **Axes**: X-axis shows FC (log-transformed and standardized), Y-axis shows IBDQ (standardized)
- **Interpretation**: Clusters that are well-separated indicate distinct patient subgroups

### Sankey Diagrams
- **Left side**: Clusters at baseline
- **Right side**: Clusters at induction
- **Flow width**: Proportional to number of patients transitioning
- **Colors**: Match baseline cluster assignments
- **Interpretation**: Shows how patients move between clusters over time

### Parameter Selection Plots

#### Elbow Plot (K-means)
- Shows total within-cluster sum of squares vs. number of clusters
- Look for the "elbow" point where the curve bends
- Optimal k is typically at the elbow

#### Silhouette Plot
- Shows average silhouette width vs. number of clusters
- Higher values indicate better-defined clusters
- Optimal k is at the maximum

#### BIC Plot (GMM)
- Shows Bayesian Information Criterion for different models
- Different lines represent different covariance structures
- Higher BIC indicates better model fit

#### k-NN Distance Plot (DBSCAN)
- Shows sorted k-nearest neighbor distances
- Look for the "knee" point in the curve
- Optimal epsilon is at the knee

### Pattern Analysis Tables
Contains three columns:
- **from**: Baseline cluster
- **to**: Induction cluster
- **count**: Number of patients with this transition

Sorted by count (most common patterns first)

### Baseline Tables
TableOne format showing:
- **Continuous variables**: Mean ± SD or Median [IQR]
- **Categorical variables**: n (%)
- **p-values**: Statistical significance of differences between groups

### Logistic Regression Results
Shows:
- **Coefficients**: Effect size for each pattern group
- **p-values**: Statistical significance
- **Odds Ratios with 95% CI**: Interpretation of effect on outcome

## Tips for Review

1. **Start with cluster plots**: Verify that clusters make visual sense
2. **Check parameter selection plots**: Confirm automatic selection was reasonable
3. **Review Sankey diagrams**: Identify major transition patterns
4. **Compare methods**: Look at clustering_comparison.csv to see consistency
5. **Focus on significant results**: Review logistic regression for pattern groups associated with outcomes
6. **Clinical interpretation**: Discuss results with domain experts to ensure biological plausibility
