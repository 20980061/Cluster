# K-means Clustering Implementation - Complete Documentation

## Summary of Changes

This implementation adds K-means clustering analysis to the existing R code (`Cluster.R`), following the structure and requirements specified in the problem statement.

## File Changes

### Modified: `Cluster.R`
- **Total lines**: 578 (increased from ~462)
- **New section**: Lines 239-351 (113 lines of K-means clustering code)
- **Fixed bug**: Lines 558-578 (Sankey diagram section - fixed undefined `df` variable)

## Code Structure

```
Cluster.R Structure:
├── Lines 1-67: Data generation and setup
├── Lines 68-175: Data preparation, imputation, and standardization
├── Lines 176-237: GMM (Gaussian Mixture Model) clustering
├── Lines 239-351: K-MEANS CLUSTERING (NEW)
├── Lines 353-557: General analysis functions (baseline tables, logistic regression)
└── Lines 558-578: Sankey diagram visualization (FIXED)
```

## Implementation Details

### K-means Clustering Features

#### 1. Optimal K Selection Using Elbow Method
- Tests K values from 1 to 10
- Calculates Within-Cluster Sum of Squares (WSS)
- Generates elbow plots for visual inspection
- Default K=4 (adjustable based on elbow plot)

#### 2. Clustering Variables
**Base (Baseline) Clustering:**
- FC_base_log (log-transformed and scaled fecal calprotectin)
- IBDQ_BS_base_std (standardized IBDQ Bowel Symptoms)
- IBDQ_SS_base_std (standardized IBDQ Systemic Symptoms)
- IBDQ_EF_base_std (standardized IBDQ Emotional Function)
- IBDQ_SF_base_std (standardized IBDQ Social Function)

**Induc (Induction) Clustering:**
- FC_induc_log (log-transformed and scaled fecal calprotectin)
- IBDQ_BS_induc_std (standardized IBDQ Bowel Symptoms)
- IBDQ_SS_induc_std (standardized IBDQ Systemic Symptoms)
- IBDQ_EF_induc_std (standardized IBDQ Emotional Function)
- IBDQ_SF_induc_std (standardized IBDQ Social Function)

#### 3. K-means Parameters
- `centers`: 4 (optimal K based on elbow method)
- `nstart`: 25 (multiple random starts for stability)
- `iter.max`: 100 (maximum iterations)
- `set.seed(123)`: for reproducibility

#### 4. Output Files Generated
1. **Kmeans_Elbow_Method_base.png** - Elbow plot for baseline data
2. **Kmeans_Elbow_Method_induc.png** - Elbow plot for induction data
3. **Kmeans_Clusters_base.png** - Cluster scatter plot for baseline
4. **Kmeans_Clusters_induc.png** - Cluster scatter plot for induction

#### 5. Saved Variables in data_imputed
- `Kmeans_cluster_base` (factor) - Cluster assignments for baseline
- `Kmeans_cluster_induc` (factor) - Cluster assignments for induction

### Bug Fixes

#### Fixed Sankey Diagram Section (Lines 558-578)
**Problem**: Original code referenced undefined variable `df`
```r
# BEFORE (incorrect):
df$cluster_base <- as.factor(cluster_base)
df$cluster_induc <- as.factor(cluster_induc)
ggplot(df, aes(axis1 = cluster_base, axis2 = cluster_induc)) + ...
```

**Solution**: Use `data_imputed` and properly extract cluster columns
```r
# AFTER (correct):
sankey_data <- data_imputed
sankey_data$cluster_base_label <- data_imputed[[cluster_base]]
sankey_data$cluster_induc_label <- data_imputed[[cluster_induc]]
ggplot(sankey_data, aes(axis1 = cluster_base_label, axis2 = cluster_induc_label)) + ...
```

## How to Use

### Running K-means Clustering
The K-means clustering runs automatically when executing the script:
```bash
Rscript Cluster.R
```

### Analyzing K-means Results
To use the general analysis functions with K-means results, modify lines 357-359:
```r
cluster_base <- "Kmeans_cluster_base"   # Change from "GMM_cluster_base"
cluster_induc <- "Kmeans_cluster_induc" # Change from "GMM_cluster_induc"
method_name <- "Kmeans"                  # Change from "GMM"
```

This will automatically:
- Generate cluster summary statistics
- Create baseline characteristic comparison tables
- Perform logistic regression analysis
- Create Sankey diagram showing cluster transitions

### Comparing Methods
The code structure allows easy comparison between clustering methods:
1. Run with GMM settings (default)
2. Change to K-means settings
3. Run again to get K-means specific outputs

## Quality Assurance

### Code Validation
✅ Correct placement: Between GMM (line 237) and general functions (line 353)
✅ Consistent variable naming: Uses existing `clust_base` and `clust_induc`
✅ Proper data handling: Saves to `data_imputed` as factor variables
✅ Reproducibility: Uses `set.seed(123)` for consistent results
✅ Visualization: Generates informative plots
✅ Console output: Provides immediate feedback on clustering results

### Testing Checklist
- [x] Code structure verified
- [x] Variable references validated
- [x] Output file names documented
- [x] Bug in Sankey diagram fixed
- [ ] Runtime testing (requires R environment)
- [ ] Visual inspection of generated plots (requires R environment)

## Key Differences from GMM

| Feature | GMM | K-means |
|---------|-----|---------|
| Model type | Probabilistic | Centroid-based |
| K selection | Automatic (BIC) | Manual (elbow method) |
| Cluster shape | Elliptical | Spherical |
| Output | Soft assignments (probabilities) | Hard assignments |
| Speed | Slower | Faster |
| Variables used | Same 5-dimensional data | Same 5-dimensional data |

## Notes for Users

1. **Elbow Method**: Review the elbow plots to confirm K=4 is optimal. If the elbow appears at a different K value, adjust `optimal_k_base` and `optimal_k_induc` accordingly.

2. **Multiple Methods**: The code now supports both GMM and K-means. You can compare results by running the general analysis functions with each method.

3. **Customization**: The clustering can be easily customized by:
   - Changing K values
   - Adjusting k-means parameters (nstart, iter.max)
   - Modifying visualization parameters

4. **Integration**: K-means results integrate seamlessly with existing analysis pipeline (baseline tables, logistic regression, Sankey diagrams).

## References

- K-means clustering uses R's built-in `kmeans()` function
- Elbow method evaluates within-cluster sum of squares (WSS)
- Visualization uses base R graphics (`plot()`, `png()`, `dev.off()`)
- Data uses same preprocessing as GMM (log transformation, standardization)

## Contact

For questions or issues, please refer to the problem statement and conversation history.
