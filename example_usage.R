#!/usr/bin/env Rscript
# ============================================================================
# Example Usage of Cluster.R with Custom Data
# ============================================================================
# This script demonstrates how to adapt the Cluster.R script for your own data
# ============================================================================

cat("=== Cluster Analysis Example ===\n\n")
cat("This example shows how to use the clustering analysis scripts.\n\n")

# ============================================================================
# STEP 1: Prepare Your Data
# ============================================================================

cat("STEP 1: Preparing data...\n")

# Your data should have these columns at minimum:
# - ID: Patient identifier
# - FC_base: Fecal calprotectin at baseline
# - FC_induc: Fecal calprotectin at induction  
# - IBDQ_base: IBDQ score at baseline
# - IBDQ_induc: IBDQ score at induction
# - Response: Binary outcome (0/1) - optional
# - Additional baseline characteristics (Age, Sex, etc.) - optional

# Example: Load your data
# Option 1: From RData file
# load("path/to/your/data.RData")
# data_test <- your_data_object

# Option 2: From CSV file
# data_test <- read.csv("path/to/your/data.csv")

# Option 3: Use demo data (for this example)
set.seed(123)
n <- 100

data_test <- data.frame(
  ID = 1:n,
  FC_base = exp(rnorm(n, mean = 5, sd = 1.5)),
  FC_induc = exp(rnorm(n, mean = 4.5, sd = 1.5)),
  IBDQ_base = rnorm(n, mean = 150, sd = 30),
  IBDQ_induc = rnorm(n, mean = 170, sd = 25),
  Age = rnorm(n, mean = 40, sd = 15),
  Sex = sample(c("Male", "Female"), n, replace = TRUE),
  Response = sample(c(0, 1), n, replace = TRUE, prob = c(0.4, 0.6))
)

cat(sprintf("✓ Data loaded: %d patients\n", nrow(data_test)))
cat(sprintf("  Variables: %s\n", paste(names(data_test), collapse = ", ")))

# ============================================================================
# STEP 2: Log Transform and Standardize
# ============================================================================

cat("\nSTEP 2: Log transformation and standardization...\n")

# Log transformation
data_test$FC_base_log <- log(data_test$FC_base)
data_test$FC_induc_log <- log(data_test$FC_induc)

# Standardization function
standardize <- function(x) {
  (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
}

# Standardize
data_test$FC_base_log_std <- standardize(data_test$FC_base_log)
data_test$FC_induc_log_std <- standardize(data_test$FC_induc_log)
data_test$IBDQ_base_std <- standardize(data_test$IBDQ_base)
data_test$IBDQ_induc_std <- standardize(data_test$IBDQ_induc)

cat("✓ Variables transformed and standardized\n")

# ============================================================================
# STEP 3: Prepare Clustering Data
# ============================================================================

cat("\nSTEP 3: Preparing clustering datasets...\n")

cluster_data_base <- data_test[, c("FC_base_log_std", "IBDQ_base_std")]
cluster_data_induc <- data_test[, c("FC_induc_log_std", "IBDQ_induc_std")]

cat("✓ Clustering datasets ready\n")
cat(sprintf("  Base: %d rows, %d columns\n", nrow(cluster_data_base), ncol(cluster_data_base)))
cat(sprintf("  Induc: %d rows, %d columns\n", nrow(cluster_data_induc), ncol(cluster_data_induc)))

# ============================================================================
# STEP 4: Perform K-means Clustering (Example)
# ============================================================================

cat("\nSTEP 4: Performing K-means clustering...\n")

# Determine optimal k using elbow method
wss <- sapply(1:10, function(k) {
  kmeans(cluster_data_base, centers = k, nstart = 25)$tot.withinss
})

# Choose optimal k (you can adjust this based on the elbow plot)
optimal_k <- 3

# Perform clustering
set.seed(123)
kmeans_base <- kmeans(cluster_data_base, centers = optimal_k, nstart = 25)
kmeans_induc <- kmeans(cluster_data_induc, centers = optimal_k, nstart = 25)

# Add results to data
data_test$cluster_base <- kmeans_base$cluster
data_test$cluster_induc <- kmeans_induc$cluster

cat(sprintf("✓ K-means clustering complete (k=%d)\n", optimal_k))
cat(sprintf("  Base clusters: %s\n", paste(table(kmeans_base$cluster), collapse = ", ")))
cat(sprintf("  Induc clusters: %s\n", paste(table(kmeans_induc$cluster), collapse = ", ")))

# ============================================================================
# STEP 5: Analyze Transition Patterns
# ============================================================================

cat("\nSTEP 5: Analyzing transition patterns...\n")

# Create transition table
transition_table <- table(
  Base = data_test$cluster_base,
  Induc = data_test$cluster_induc
)

cat("\nTransition Matrix:\n")
print(transition_table)

# Calculate stable vs changed
stable <- sum(data_test$cluster_base == data_test$cluster_induc)
changed <- sum(data_test$cluster_base != data_test$cluster_induc)

cat(sprintf("\nStability Analysis:\n"))
cat(sprintf("  Stable: %d (%.1f%%)\n", stable, stable/nrow(data_test)*100))
cat(sprintf("  Changed: %d (%.1f%%)\n", changed, changed/nrow(data_test)*100))

# ============================================================================
# STEP 6: Create Pattern Groups
# ============================================================================

cat("\nSTEP 6: Creating pattern-based groups...\n")

data_test$pattern <- paste0(data_test$cluster_base, "→", data_test$cluster_induc)
data_test$stability <- ifelse(
  data_test$cluster_base == data_test$cluster_induc,
  "Stable",
  "Changed"
)

pattern_summary <- table(data_test$pattern)
cat("\nPattern Frequencies:\n")
print(sort(pattern_summary, decreasing = TRUE))

# ============================================================================
# STEP 7: Visualize Results
# ============================================================================

cat("\nSTEP 7: Creating visualizations...\n")

# Create output directory
if(!dir.exists("output")) dir.create("output")

# Load ggplot2
if(require("ggplot2", quietly = TRUE)) {
  
  # Scatter plot for base clustering
  p1 <- ggplot(data_test, aes(x = FC_base_log_std, y = IBDQ_base_std, 
                               color = as.factor(cluster_base))) +
    geom_point(size = 3, alpha = 0.6) +
    labs(title = "K-means Clustering - Baseline",
         x = "FC (log, standardized)",
         y = "IBDQ (standardized)",
         color = "Cluster") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  ggsave("output/example_scatter_base.png", p1, width = 8, height = 6)
  cat("✓ Saved: output/example_scatter_base.png\n")
  
  # Scatter plot for induc clustering
  p2 <- ggplot(data_test, aes(x = FC_induc_log_std, y = IBDQ_induc_std,
                               color = as.factor(cluster_induc))) +
    geom_point(size = 3, alpha = 0.6) +
    labs(title = "K-means Clustering - Induction",
         x = "FC (log, standardized)",
         y = "IBDQ (standardized)",
         color = "Cluster") +
    theme_minimal() +
    theme(legend.position = "bottom")
  
  ggsave("output/example_scatter_induc.png", p2, width = 8, height = 6)
  cat("✓ Saved: output/example_scatter_induc.png\n")
  
} else {
  cat("Note: ggplot2 not available for visualization\n")
}

# ============================================================================
# STEP 8: Save Results
# ============================================================================

cat("\nSTEP 8: Saving results...\n")

# Save data with cluster assignments
write.csv(data_test, "output/example_data_with_clusters.csv", row.names = FALSE)
cat("✓ Saved: output/example_data_with_clusters.csv\n")

# Save transition summary
write.csv(as.data.frame(transition_table), 
          "output/example_transition_matrix.csv", 
          row.names = FALSE)
cat("✓ Saved: output/example_transition_matrix.csv\n")

# ============================================================================
# NEXT STEPS
# ============================================================================

cat("\n=== NEXT STEPS ===\n")
cat("1. Use create_alluvial.R to create transition flow diagrams\n")
cat("2. Run the full Cluster.R script for all clustering methods\n")
cat("3. Perform baseline characteristics comparison\n")
cat("4. Conduct logistic regression analysis\n")
cat("\nFor alluvial diagram, run:\n")
cat("  Rscript create_alluvial.R\n")
cat("\nFor complete analysis with all methods, run:\n")
cat("  Rscript Cluster.R\n")
cat("\n=== Analysis Complete ===\n")
