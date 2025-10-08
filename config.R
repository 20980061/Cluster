# ============================================================================
# Clustering Analysis Configuration File
# ============================================================================
# Edit this file to customize your clustering analysis
# ============================================================================

# Working Directory
# Set this to where your data is located and where results should be saved
WORKING_DIR <- "/home/runner/work/Cluster/Cluster"

# Data File Configuration
# Uncomment and modify based on your data format

# Option 1: RData file
# DATA_FILE <- "my_data.RData"
# DATA_OBJECT <- "data_test"  # Name of the object in the RData file

# Option 2: CSV file
# DATA_FILE <- "my_data.csv"

# Option 3: Use example data (default)
USE_EXAMPLE_DATA <- TRUE

# ============================================================================
# Variable Names
# ============================================================================
# Specify the column names in your dataset
# Modify these if your column names are different

VAR_NAMES <- list(
  # Required for clustering
  FC_BASE = "FC_base",           # Fecal calprotectin at baseline
  FC_INDUC = "FC_induc",         # Fecal calprotectin at induction
  IBDQ_BASE = "IBDQ_base",       # IBDQ score at baseline
  IBDQ_INDUC = "IBDQ_induc",     # IBDQ score at induction
  
  # Required for outcome analysis
  RESPONSE = "response",         # Treatment response (0/1)
  
  # Optional baseline characteristics
  AGE = "age",
  SEX = "sex",
  DISEASE_DURATION = "disease_duration"
)

# ============================================================================
# Clustering Methods to Run
# ============================================================================
# Set to TRUE to run the method, FALSE to skip

RUN_METHODS <- list(
  KMEANS = TRUE,
  HIERARCHICAL = TRUE,
  GMM = TRUE,
  DBSCAN = TRUE,
  AFFINITY_PROPAGATION = TRUE
)

# ============================================================================
# Clustering Parameters
# ============================================================================

# K-means parameters
KMEANS_CONFIG <- list(
  MIN_K = 2,          # Minimum number of clusters to test
  MAX_K = 10,         # Maximum number of clusters to test
  N_START = 25,       # Number of random starts
  SEED = 123          # Random seed for reproducibility
)

# Hierarchical clustering parameters
HIERARCHICAL_CONFIG <- list(
  METHOD = "ward.D2", # Linkage method: "ward.D2", "complete", "average", "single"
  MIN_K = 2,          # Minimum number of clusters to test
  MAX_K = 8           # Maximum number of clusters to test
)

# GMM parameters
GMM_CONFIG <- list(
  MIN_G = 1,          # Minimum number of components
  MAX_G = 9           # Maximum number of components
)

# DBSCAN parameters
DBSCAN_CONFIG <- list(
  K = 4,              # k for k-NN distance
  EPS_QUANTILE = 0.90,# Quantile for automatic eps selection
  MIN_PTS = 4         # Minimum points to form a cluster
)

# Affinity Propagation parameters
AFFINITY_CONFIG <- list(
  R = 2               # Power for distance calculation
)

# ============================================================================
# Visualization Settings
# ============================================================================

VIZ_CONFIG <- list(
  # Plot dimensions
  PLOT_WIDTH = 8,
  PLOT_HEIGHT = 6,
  PLOT_DPI = 300,
  
  # Large plot dimensions (for dendrograms, etc.)
  LARGE_PLOT_WIDTH = 12,
  LARGE_PLOT_HEIGHT = 8,
  
  # Point size and transparency
  POINT_SIZE = 3,
  POINT_ALPHA = 0.6,
  
  # Color palette (set to NULL for default)
  COLOR_PALETTE = NULL,  # or c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00")
  
  # Theme
  THEME = "bw"  # Options: "bw", "minimal", "classic", "light"
)

# ============================================================================
# Analysis Settings
# ============================================================================

ANALYSIS_CONFIG <- list(
  # Missing value handling
  IMPUTE_METHOD = "mean",  # Options: "mean", "median", "remove"
  
  # Pattern grouping logic
  # Customize in the create_combined_grouping() function
  STABLE_LOW_CLUSTERS = c(1),      # Which clusters represent "stable low"
  STABLE_HIGH_CLUSTERS = c(2, 3),  # Which clusters represent "stable high"
  
  # Statistical testing
  ALPHA = 0.05,  # Significance level
  
  # Baseline table settings
  BASELINE_VARS = c("age", "sex", "disease_duration", "FC_base", "IBDQ_base", "response"),
  
  # Logistic regression
  INCLUDE_COVARIATES = FALSE,  # Set to TRUE to add age, sex, etc. as covariates
  COVARIATES = c("age", "sex")  # Variables to include as covariates if above is TRUE
)

# ============================================================================
# Output Settings
# ============================================================================

OUTPUT_CONFIG <- list(
  # Save individual plots
  SAVE_PLOTS = TRUE,
  
  # Save data with cluster assignments
  SAVE_CLUSTER_DATA = TRUE,
  CLUSTER_DATA_FILENAME = "data_with_all_clusters.csv",
  
  # Save pattern analysis
  SAVE_PATTERN_ANALYSIS = TRUE,
  
  # Save statistical results
  SAVE_BASELINE_TABLES = TRUE,
  SAVE_REGRESSION_RESULTS = TRUE,
  
  # Create summary report
  CREATE_SUMMARY = TRUE,
  SUMMARY_FILENAME = "clustering_summary_report.txt",
  
  # Prefix for all output files
  OUTPUT_PREFIX = "",  # e.g., "study1_" to prefix all files
  
  # Create subdirectories for organization
  USE_SUBDIRS = FALSE,
  PLOT_SUBDIR = "plots",
  TABLE_SUBDIR = "tables",
  RESULTS_SUBDIR = "results"
)

# ============================================================================
# Advanced Settings
# ============================================================================

ADVANCED_CONFIG <- list(
  # Parallel processing (if supported)
  USE_PARALLEL = FALSE,
  N_CORES = 2,
  
  # Verbose output
  VERBOSE = TRUE,
  
  # Save intermediate results
  SAVE_INTERMEDIATE = FALSE,
  
  # Random seed for all methods
  GLOBAL_SEED = 123
)

# ============================================================================
# Custom Functions
# ============================================================================

# You can define custom functions here that will be available in the main script

# Example: Custom distance metric
# custom_distance <- function(x, y) {
#   # Your custom distance calculation
#   sqrt(sum((x - y)^2))
# }

# Example: Custom pattern grouping logic
# custom_pattern_groups <- function(cluster_base, cluster_induc) {
#   # Your custom logic
#   pattern <- paste(cluster_base, cluster_induc, sep = "_")
#   # Return a factor with group labels
#   return(as.factor(pattern))
# }

# ============================================================================
# Validation
# ============================================================================

# Basic validation of configuration
validate_config <- function() {
  errors <- c()
  
  # Check that required variables are specified
  if(!USE_EXAMPLE_DATA) {
    if(!exists("DATA_FILE")) {
      errors <- c(errors, "DATA_FILE must be specified when USE_EXAMPLE_DATA is FALSE")
    }
  }
  
  # Check k ranges
  if(KMEANS_CONFIG$MIN_K >= KMEANS_CONFIG$MAX_K) {
    errors <- c(errors, "KMEANS_CONFIG: MIN_K must be less than MAX_K")
  }
  
  # Check at least one method is enabled
  if(!any(unlist(RUN_METHODS))) {
    errors <- c(errors, "At least one clustering method must be enabled")
  }
  
  # Print errors if any
  if(length(errors) > 0) {
    cat("Configuration Errors:\n")
    for(err in errors) {
      cat("  -", err, "\n")
    }
    stop("Please fix configuration errors before running analysis")
  }
  
  cat("Configuration validated successfully!\n")
  return(TRUE)
}

# ============================================================================
# Print Configuration Summary
# ============================================================================

print_config_summary <- function() {
  cat("\n")
  cat("================================================================================\n")
  cat("CLUSTERING ANALYSIS CONFIGURATION SUMMARY\n")
  cat("================================================================================\n\n")
  
  cat("Working Directory:", WORKING_DIR, "\n")
  cat("Use Example Data:", USE_EXAMPLE_DATA, "\n\n")
  
  cat("Methods to Run:\n")
  for(method in names(RUN_METHODS)) {
    if(RUN_METHODS[[method]]) {
      cat("  ✓", method, "\n")
    }
  }
  cat("\n")
  
  cat("Output Settings:\n")
  cat("  Save Plots:", OUTPUT_CONFIG$SAVE_PLOTS, "\n")
  cat("  Save Cluster Data:", OUTPUT_CONFIG$SAVE_CLUSTER_DATA, "\n")
  cat("  Create Summary:", OUTPUT_CONFIG$CREATE_SUMMARY, "\n")
  cat("\n")
  
  cat("================================================================================\n\n")
}

# ============================================================================
# End of Configuration
# ============================================================================

# Note: This configuration file is loaded by clustering_analysis.R
# You can also source it directly to test your settings:
# source("config.R")
# validate_config()
# print_config_summary()
