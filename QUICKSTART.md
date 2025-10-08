# Quick Start Guide

## Running the Clustering Analysis

### Option 1: Using Example Data (Testing)

The script includes example data generation, so you can run it immediately:

```r
# In R or RStudio
source("clustering_analysis.R")
```

This will:
- Generate 200 simulated patients
- Run all 5 clustering methods
- Create all visualizations
- Save results to your working directory

### Option 2: Using Your Own Data

#### Step 1: Prepare Your Data

Create an R data frame with required variables:

```r
# Required columns:
# - FC_base: Baseline fecal calprotectin (numeric)
# - FC_induc: Induction fecal calprotectin (numeric)
# - IBDQ_base: Baseline IBDQ score (numeric)
# - IBDQ_induc: Induction IBDQ score (numeric)
# - response: Treatment response (0 or 1)
# - age, sex, disease_duration (optional baseline characteristics)

# Example:
my_data <- read.csv("my_patient_data.csv")
```

#### Step 2: Modify the Script

Edit `clustering_analysis.R` and replace the example data section (lines 55-67):

```r
# BEFORE (example data):
set.seed(123)
n_patients <- 200
data_test <- data.frame(
  patient_id = 1:n_patients,
  FC_base = exp(rnorm(n_patients, mean = 5, sd = 1.5)),
  # ... rest of example data
)

# AFTER (your data):
# Load your data
data_test <- read.csv("my_patient_data.csv")
# OR
load("my_data.RData")
data_test <- my_study_data
```

#### Step 3: Run the Analysis

```r
source("clustering_analysis.R")
```

## Understanding the Output

### Console Output

The script prints progress for each method:
```
================================================================================
# K-MEANS CLUSTERING
================================================================================

--- K-means Clustering for BASE ---

Step 1: Determining optimal k using Elbow Method...
Optimal k by silhouette: 3
Selected optimal k: 3

Step 2: Performing K-means clustering with k = 3...
Cluster sizes:
  1   2   3 
 65  70  65

...
```

### Generated Files

After completion, check your working directory for:

1. **Plots** (20+ PNG files)
   - Clustering scatter plots
   - Parameter selection plots (elbow, silhouette, BIC, etc.)
   - Sankey diagrams

2. **Data Tables** (CSV files)
   - `data_with_all_clusters.csv` - Your data with all cluster assignments
   - `clustering_comparison.csv` - Summary of all methods
   - Pattern analysis tables for each method

3. **Statistical Results** (TXT files)
   - Logistic regression outputs for each method

## Quick Analysis Tips

### 1. Compare Methods

```r
# Load the results
results <- read.csv("data_with_all_clusters.csv")

# Compare cluster assignments
table(results$cluster_kmeans_base, results$cluster_gmm_base)

# Check consistency across methods
cor(results$cluster_kmeans_base, results$cluster_hierarchical_base)
```

### 2. Visualize Specific Patterns

```r
# Filter patients with specific pattern
stable_high <- results[results$pattern_group_kmeans == "Stable_High", ]

# Plot their baseline characteristics
library(ggplot2)
ggplot(stable_high, aes(x = age, y = FC_base)) +
  geom_point() +
  theme_bw()
```

### 3. Custom Analysis

```r
# Add your own analyses using the cluster assignments
# Example: Compare outcomes across clusters

library(dplyr)
results %>%
  group_by(cluster_kmeans_base) %>%
  summarise(
    n = n(),
    response_rate = mean(response, na.rm = TRUE),
    mean_age = mean(age, na.rm = TRUE),
    mean_FC = mean(FC_base, na.rm = TRUE)
  )
```

## Troubleshooting

### Issue: Script stops with error

**Solution**: Check the error message
- Missing packages? Run: `install.packages("package_name")`
- Data format issues? Ensure columns are numeric where expected
- Missing values? The script handles NAs, but check for excessive missingness

### Issue: Unexpected number of clusters

**Solution**: This is normal
- Different methods may find different numbers of clusters
- Review the parameter selection plots
- Consider your domain knowledge about expected subgroups

### Issue: Poor cluster separation

**Solution**: 
- Check data variability: `summary(data_test[, c("FC_base", "IBDQ_base")])`
- Try different standardization methods
- Consider additional variables for clustering

### Issue: Sankey diagram looks messy

**Solution**:
- Too many clusters? Some methods may create many small clusters
- Simplify by focusing on major patterns
- Customize the `create_combined_grouping()` function

## Next Steps

1. **Review all visualizations** - Look for consistent patterns across methods
2. **Compare statistical results** - Which pattern groups predict outcomes?
3. **Select the most interpretable method** - Balance statistical fit with clinical relevance
4. **Customize analyses** - Add method-specific investigations
5. **Validate findings** - Consider external validation if applicable

## Example: Complete Workflow

```r
# 1. Prepare your environment
setwd("/path/to/your/working/directory")

# 2. Load your data
my_data <- read.csv("patient_data.csv")

# 3. Update the script
# Edit clustering_analysis.R to load my_data

# 4. Run the complete analysis
source("clustering_analysis.R")

# 5. Wait for completion (may take 5-15 minutes depending on data size)

# 6. Review results
list.files(pattern = "\\.png$")  # List all plots
results <- read.csv("data_with_all_clusters.csv")
summary(results)

# 7. Compare methods
comparison <- read.csv("clustering_comparison.csv")
print(comparison)

# 8. Focus on best method (example: K-means)
# Review:
# - cluster_plot_K-means_base.png
# - cluster_plot_K-means_induc.png
# - sankey_K-means.png
# - baseline_table_K-means.csv
# - logistic_regression_K-means.txt

# 9. Custom follow-up analyses
# [Your specific analyses here]
```

## Getting Help

If you encounter issues:

1. Check the README.md for detailed documentation
2. Review error messages carefully
3. Verify your data format matches requirements
4. Open an issue on GitHub with:
   - Error message
   - Your data structure: `str(data_test)`
   - R version: `R.version.string`
   - Package versions: `sessionInfo()`
