# ================================================================================
# Data Validation Script
# ================================================================================
# This script checks if your data is ready for clustering analysis
# Run this before running clustering_analysis.R
# ================================================================================

validate_data <- function(data) {
  
  cat("\n=== DATA VALIDATION CHECK ===\n\n")
  
  # Check 1: Required columns
  cat("1. Checking required columns...\n")
  required_cols <- c("FC_base", "FC_induc", "IBDQ_base", "IBDQ_induc")
  missing_cols <- setdiff(required_cols, names(data))
  
  if (length(missing_cols) > 0) {
    cat("  ✗ FAILED: Missing required columns:", paste(missing_cols, collapse = ", "), "\n")
    return(FALSE)
  } else {
    cat("  ✓ PASSED: All required columns present\n")
  }
  
  # Check 2: Data types
  cat("\n2. Checking data types...\n")
  for (col in required_cols) {
    if (!is.numeric(data[[col]])) {
      cat("  ✗ FAILED:", col, "is not numeric\n")
      return(FALSE)
    }
  }
  cat("  ✓ PASSED: All required columns are numeric\n")
  
  # Check 3: Missing values
  cat("\n3. Checking for missing values...\n")
  missing_counts <- sapply(data[required_cols], function(x) sum(is.na(x)))
  total_missing <- sum(missing_counts)
  
  if (total_missing > 0) {
    cat("  ⚠ WARNING: Found", total_missing, "missing values:\n")
    for (col in names(missing_counts[missing_counts > 0])) {
      cat("    -", col, ":", missing_counts[col], "missing\n")
    }
    cat("  → You may need to impute missing values\n")
  } else {
    cat("  ✓ PASSED: No missing values\n")
  }
  
  # Check 4: Positive values for FC (required for log transformation)
  cat("\n4. Checking FC values (must be positive for log transformation)...\n")
  fc_cols <- c("FC_base", "FC_induc")
  for (col in fc_cols) {
    non_positive <- sum(data[[col]] <= 0, na.rm = TRUE)
    if (non_positive > 0) {
      cat("  ✗ FAILED:", col, "has", non_positive, "non-positive values\n")
      cat("    → Log transformation requires positive values\n")
      return(FALSE)
    }
  }
  cat("  ✓ PASSED: All FC values are positive\n")
  
  # Check 5: Outliers
  cat("\n5. Checking for extreme outliers...\n")
  outlier_info <- list()
  for (col in required_cols) {
    Q1 <- quantile(data[[col]], 0.25, na.rm = TRUE)
    Q3 <- quantile(data[[col]], 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    lower_bound <- Q1 - 3 * IQR
    upper_bound <- Q3 + 3 * IQR
    outliers <- sum(data[[col]] < lower_bound | data[[col]] > upper_bound, na.rm = TRUE)
    
    if (outliers > 0) {
      outlier_info[[col]] <- outliers
    }
  }
  
  if (length(outlier_info) > 0) {
    cat("  ⚠ WARNING: Found extreme outliers (beyond 3*IQR):\n")
    for (col in names(outlier_info)) {
      cat("    -", col, ":", outlier_info[[col]], "outliers\n")
    }
    cat("  → Consider using PAM or DBSCAN for robustness\n")
  } else {
    cat("  ✓ PASSED: No extreme outliers detected\n")
  }
  
  # Check 6: Sample size
  cat("\n6. Checking sample size...\n")
  n <- nrow(data)
  cat("  Sample size:", n, "\n")
  
  if (n < 30) {
    cat("  ✗ FAILED: Sample size too small (n < 30)\n")
    cat("    → Clustering results may be unreliable\n")
    return(FALSE)
  } else if (n < 100) {
    cat("  ⚠ WARNING: Small sample size (30 ≤ n < 100)\n")
    cat("    → Results should be interpreted with caution\n")
  } else {
    cat("  ✓ PASSED: Adequate sample size (n ≥ 100)\n")
  }
  
  # Check 7: Variance
  cat("\n7. Checking variance...\n")
  for (col in required_cols) {
    var_val <- var(data[[col]], na.rm = TRUE)
    if (var_val == 0 || is.na(var_val)) {
      cat("  ✗ FAILED:", col, "has zero or undefined variance\n")
      return(FALSE)
    }
  }
  cat("  ✓ PASSED: All variables have non-zero variance\n")
  
  # Check 8: Optional variables for regression
  cat("\n8. Checking optional variables for statistical analysis...\n")
  optional_cols <- c("Age", "Sex", "BMI", "Disease_Duration", "Outcome")
  present_optional <- intersect(optional_cols, names(data))
  
  if (length(present_optional) > 0) {
    cat("  ✓ Found optional columns:", paste(present_optional, collapse = ", "), "\n")
    cat("    → Baseline comparison and logistic regression can be performed\n")
  } else {
    cat("  ⚠ WARNING: No optional columns found\n")
    cat("    → Only clustering will be performed (no regression analysis)\n")
  }
  
  # Summary
  cat("\n=== VALIDATION SUMMARY ===\n")
  cat("Your data is ready for clustering analysis!\n")
  cat("\nNext steps:\n")
  cat("1. If there are missing values, consider imputation\n")
  cat("2. If there are outliers, PAM or DBSCAN may be more appropriate\n")
  cat("3. Run: source('clustering_analysis.R')\n\n")
  
  return(TRUE)
}

# Example usage:
# Load your data
# data <- read.csv("your_data.csv")
# validate_data(data)

# Or use the sample data
cat("To validate your data, run:\n")
cat('  data <- read.csv("your_data.csv")\n')
cat("  validate_data(data)\n\n")

cat("To test with sample data:\n")
cat('  sample_data <- read.csv("sample_data.csv")\n')
cat("  validate_data(sample_data)\n")
