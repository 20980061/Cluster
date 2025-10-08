# Troubleshooting Guide

This guide helps you solve common issues when running the clustering analysis.

## Installation Issues

### Problem: R is not installed

**Error message**: 
```
bash: R: command not found
```

**Solution**:

On Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install r-base r-base-dev
```

On macOS (with Homebrew):
```bash
brew install r
```

On Windows:
- Download from https://cran.r-project.org/
- Run installer

### Problem: Packages fail to install

**Error message**: 
```
Warning in install.packages : installation of package 'X' had non-zero exit status
```

**Solutions**:

1. **Install system dependencies** (Linux):
```bash
# For Ubuntu/Debian
sudo apt-get install libcurl4-openssl-dev libssl-dev libxml2-dev
sudo apt-get install libgsl-dev libgmp-dev
```

2. **Install from source** (if binary fails):
```r
install.packages("package_name", type = "source")
```

3. **Check R version**:
```r
R.version.string
# Should be 4.0 or higher
```

4. **Update packages**:
```r
update.packages(ask = FALSE)
```

### Problem: Permission denied when installing packages

**Solution**:

Create personal library directory:
```r
dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)
.libPaths(Sys.getenv("R_LIBS_USER"))
```

## Data Loading Issues

### Problem: Cannot find data file

**Error message**: 
```
Error: cannot open file 'my_data.csv': No such file or directory
```

**Solutions**:

1. **Check working directory**:
```r
getwd()  # See where R is looking
setwd("/path/to/your/data")  # Change if needed
```

2. **Use absolute path**:
```r
data <- read.csv("/full/path/to/my_data.csv")
```

3. **List files**:
```r
list.files()  # See what files are in current directory
```

### Problem: Data loaded but has wrong structure

**Error message**: 
```
Error in data$FC_base : object of type 'closure' is not subsettable
```

**Solutions**:

1. **Check data structure**:
```r
str(data_test)  # See structure
head(data_test)  # See first rows
names(data_test)  # See column names
```

2. **Verify column names match**:
```r
# Expected columns:
required_cols <- c("FC_base", "FC_induc", "IBDQ_base", "IBDQ_induc")
required_cols %in% names(data_test)
```

3. **Rename columns if needed**:
```r
names(data_test)[names(data_test) == "old_name"] <- "FC_base"
```

## Clustering Issues

### Problem: All points in one cluster

**Possible causes**:
- No variability in data
- Wrong standardization
- Inappropriate parameters

**Solutions**:

1. **Check data variability**:
```r
summary(data_test[, c("FC_base", "IBDQ_base")])
var(data_test$FC_base, na.rm = TRUE)
```

2. **Visualize raw data**:
```r
plot(data_test$FC_base, data_test$IBDQ_base)
```

3. **Check for constant columns**:
```r
sapply(data_test, function(x) length(unique(x)))
```

### Problem: Too many clusters

**Symptoms**: 
- DBSCAN creates 20+ clusters
- Affinity Propagation creates many small clusters

**Solutions**:

1. **For DBSCAN, increase eps**:
```r
# In the script, modify:
optimal_eps <- quantile(knn_dist, 0.95)  # Instead of 0.90
```

2. **For Affinity Propagation, adjust preference**:
```r
# Lower preference = fewer clusters
sim_matrix <- negDistMat(data, r = 2)
# Multiply diagonal by factor < 1
diag(sim_matrix) <- diag(sim_matrix) * 0.5
ap_result <- apcluster(sim_matrix)
```

### Problem: Clustering gives different results each time

**Cause**: Random initialization (K-means, GMM)

**Solution**: Set random seed before each analysis:
```r
set.seed(123)  # Same seed = same results
```

### Problem: GMM fails with error "degenerate covariance matrix"

**Cause**: Not enough variability or data too sparse

**Solutions**:

1. **Try simpler covariance structure**:
```r
bic_values <- mclustBIC(data, G = 1:9, modelNames = c("EII", "VII", "EEI"))
```

2. **Check for outliers**:
```r
boxplot(data)
```

3. **Remove outliers**:
```r
# Z-score outlier detection
z_scores <- scale(data)
data_clean <- data[!apply(abs(z_scores) > 3, 1, any), ]
```

## Visualization Issues

### Problem: Plots not saving

**Error message**: 
```
Error in ggsave(...) : Plot area is too small
```

**Solutions**:

1. **Check write permissions**:
```r
file.access(".", 2)  # Should return 0
```

2. **Specify larger dimensions**:
```r
ggsave("plot.png", width = 10, height = 8, dpi = 300)
```

3. **Save to different directory**:
```r
dir.create("plots")
ggsave("plots/plot.png", ...)
```

### Problem: Sankey diagram looks messy

**Cause**: Too many clusters or complex transitions

**Solutions**:

1. **Reduce number of clusters** (adjust k selection)

2. **Simplify pattern groups**:
```r
# Combine small clusters
cluster_simple <- ifelse(clusters %in% c(1,2), 1, 2)
```

3. **Filter rare transitions**:
```r
# Only show transitions with >5 patients
transitions_filtered <- transitions[transitions$count > 5, ]
```

### Problem: Points overlapping in scatter plots

**Solutions**:

1. **Add jitter**:
```r
geom_point(position = position_jitter(width = 0.1, height = 0.1))
```

2. **Increase transparency**:
```r
geom_point(alpha = 0.3)  # More transparent
```

3. **Use smaller points**:
```r
geom_point(size = 1)
```

## Memory Issues

### Problem: R runs out of memory

**Error message**: 
```
Error: cannot allocate vector of size X Mb
```

**Solutions**:

1. **Increase R memory limit** (Windows):
```r
memory.limit(size = 8000)  # 8 GB
```

2. **Remove large objects**:
```r
rm(large_object)
gc()  # Garbage collection
```

3. **Process in chunks**:
```r
# For very large datasets, cluster on sample first
sample_idx <- sample(1:nrow(data), size = 5000)
data_sample <- data[sample_idx, ]
# Then assign remaining points to nearest cluster
```

4. **Use less memory-intensive methods**:
- Skip Affinity Propagation for large n
- Use K-means instead of Hierarchical for n > 10,000

## Statistical Analysis Issues

### Problem: Baseline table shows NaN or Inf

**Cause**: All values identical in a group or too few observations

**Solutions**:

1. **Check group sizes**:
```r
table(data_imputed$pattern_group_kmeans)
```

2. **Remove groups with n < 5**:
```r
data_filtered <- data_imputed[
  data_imputed$pattern_group_kmeans %in% 
  names(which(table(data_imputed$pattern_group_kmeans) >= 5)), 
]
```

3. **Check for constant variables**:
```r
sapply(data_imputed[, baseline_vars], function(x) length(unique(x)))
```

### Problem: Logistic regression fails to converge

**Error message**: 
```
Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred
```

**Cause**: Perfect separation or very unbalanced groups

**Solutions**:

1. **Check outcome distribution**:
```r
table(data_imputed$response, data_imputed$pattern_group_kmeans)
```

2. **Combine small groups**:
```r
pattern_group_combined <- fct_collapse(pattern_group,
  "Stable" = c("Stable_Low", "Stable_High"),
  "Changed" = c("Improved", "Worsened")
)
```

3. **Use penalized regression**:
```r
library(glmnet)
# Lasso logistic regression
```

## Performance Issues

### Problem: Script takes too long to run

**Solutions**:

1. **Skip expensive methods**:
```r
# In config.R, set to FALSE:
RUN_METHODS$AFFINITY_PROPAGATION <- FALSE
RUN_METHODS$HIERARCHICAL <- FALSE  # If n > 5000
```

2. **Reduce parameter search range**:
```r
# Test fewer k values
KMEANS_CONFIG$MAX_K <- 6  # Instead of 10
```

3. **Sample data first**:
```r
# For testing, use smaller sample
data_test <- data_test[sample(1:nrow(data_test), 1000), ]
```

4. **Use parallel processing** (advanced):
```r
library(parallel)
cl <- makeCluster(detectCores() - 1)
# Use with functions that support parallel
```

## Output Issues

### Problem: Too many files generated

**Solution**: Organize into subdirectories:

```r
dir.create("plots")
dir.create("tables")
dir.create("results")

# Modify ggsave calls:
ggsave("plots/plot_name.png", ...)

# Modify write.csv calls:
write.csv(..., "tables/table_name.csv")
```

### Problem: Cannot find specific output file

**Solution**: List all generated files:

```r
# All PNG files
list.files(pattern = "\\.png$")

# All CSV files
list.files(pattern = "\\.csv$")

# Files containing "kmeans"
list.files(pattern = "kmeans")
```

## Interpretation Issues

### Problem: Different methods give very different results

**This is expected!** Different methods have different assumptions.

**What to do**:

1. **Compare cluster numbers**:
```r
comparison <- read.csv("clustering_comparison.csv")
print(comparison)
```

2. **Check cluster agreement**:
```r
# Compare K-means vs GMM
table(data_imputed$cluster_kmeans_base, data_imputed$cluster_gmm_base)
```

3. **Calculate adjusted Rand index**:
```r
library(mclust)
adjustedRandIndex(cluster1, cluster2)
# 1 = perfect agreement, 0 = random
```

4. **Focus on methods appropriate for your data**:
- Spherical clusters → K-means
- Different sizes/shapes → GMM or Hierarchical
- Arbitrary shapes → DBSCAN
- Unknown number → Affinity Propagation

### Problem: Pattern groups not associated with outcome

**Possible reasons**:
- Clusters not related to outcome
- Insufficient sample size
- Need different variables for clustering

**What to try**:

1. **Include additional variables**:
```r
cluster_data <- data[, c("FC_base_log_std", "IBDQ_base_std", "CRP_base_std")]
```

2. **Try different time points or changes**:
```r
cluster_data <- data[, c("FC_change", "IBDQ_change")]
```

3. **Check if any single variable predicts outcome**:
```r
glm(response ~ FC_base, data = data, family = binomial)
```

## Getting Help

If you still have issues:

1. **Check the error message carefully**
2. **Search for the error online** (often others had same issue)
3. **Check R and package versions**:
```r
sessionInfo()
```

4. **Create minimal reproducible example**:
```r
# Minimal code that shows the problem
set.seed(123)
small_data <- data[1:20, ]
# Try to reproduce error
```

5. **Open GitHub issue** with:
   - Error message
   - R version and OS
   - Minimal reproducible example
   - What you've already tried

## Common Error Messages and Solutions

| Error | Solution |
|-------|----------|
| "object not found" | Check spelling, load data first |
| "subscript out of bounds" | Check column names, verify data structure |
| "non-numeric argument" | Convert to numeric: `as.numeric(x)` |
| "missing values not allowed" | Check for NAs: `sum(is.na(x))`, impute |
| "infinite or missing values" | Check for Inf: `sum(is.infinite(x))` |
| "package not available" | Check CRAN, try older R version |
| "cannot allocate vector" | Reduce data size, increase memory |
| "singular matrix" | Check for multicollinearity, remove duplicates |

## Prevention Tips

1. **Always check your data first**:
```r
str(data)
summary(data)
head(data)
```

2. **Start with a small sample** to test

3. **Save intermediate results**:
```r
save(results, file = "intermediate_results.RData")
```

4. **Use version control** (git) to track changes

5. **Document your modifications** in comments

6. **Keep a log** of what you tried

## Still Stuck?

1. Read the TECHNICAL.md for methodology details
2. Check OUTPUTS.md for expected results
3. Review QUICKSTART.md for basic workflow
4. Look at the example data generation script
5. Ask for help with specific error messages
