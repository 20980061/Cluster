# ============================================================================
# Clustering Analysis Script
# ============================================================================
# This script performs comprehensive clustering analysis with multiple methods
# including K-means, Hierarchical Clustering, GMM, DBSCAN, and Affinity Propagation
# 
# Author: Auto-generated
# Date: 2024
# ============================================================================

# Set working directory
setwd("/home/runner/work/Cluster/Cluster")

# ============================================================================
# Package Installation and Loading
# ============================================================================

# List of required packages
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

# Install and load packages
for(pkg in required_packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# ============================================================================
# Data Loading and Preprocessing
# ============================================================================

# NOTE: Users should replace this section with their actual data loading
# The following creates example data for demonstration
# 
# To use your own data, uncomment and modify the following:
# setwd("your/data/path")
# load("your_data_file.RData")
# data_test <- your_data_object

# Generate example data (REMOVE THIS WHEN USING REAL DATA)
set.seed(123)
n_patients <- 200

data_test <- data.frame(
  patient_id = 1:n_patients,
  FC_base = exp(rnorm(n_patients, mean = 5, sd = 1.5)),
  FC_induc = exp(rnorm(n_patients, mean = 4.5, sd = 1.5)),
  IBDQ_base = rnorm(n_patients, mean = 120, sd = 30),
  IBDQ_induc = rnorm(n_patients, mean = 140, sd = 25),
  age = rnorm(n_patients, mean = 40, sd = 12),
  sex = sample(c("Male", "Female"), n_patients, replace = TRUE),
  disease_duration = rnorm(n_patients, mean = 5, sd = 3),
  response = sample(c(0, 1), n_patients, replace = TRUE, prob = c(0.4, 0.6))
)

# Handle missing values (simple imputation - modify as needed)
data_imputed <- data_test
for(col in names(data_imputed)) {
  if(is.numeric(data_imputed[[col]])) {
    data_imputed[[col]][is.na(data_imputed[[col]])] <- mean(data_imputed[[col]], na.rm = TRUE)
  }
}

# ============================================================================
# Log Transformation and Standardization
# ============================================================================

# Log transformation of FC values (add small constant to handle zeros)
data_imputed$FC_base_log <- log(data_imputed$FC_base + 0.1)
data_imputed$FC_induc_log <- log(data_imputed$FC_induc + 0.1)

# Standardization function
standardize <- function(x) {
  return((x - mean(x)) / sd(x))
}

# Standardize variables for clustering
data_imputed$FC_base_log_std <- standardize(data_imputed$FC_base_log)
data_imputed$FC_induc_log_std <- standardize(data_imputed$FC_induc_log)
data_imputed$IBDQ_base_std <- standardize(data_imputed$IBDQ_base)
data_imputed$IBDQ_induc_std <- standardize(data_imputed$IBDQ_induc)

# Prepare clustering datasets
cluster_data_base <- data_imputed[, c("FC_base_log_std", "IBDQ_base_std")]
cluster_data_induc <- data_imputed[, c("FC_induc_log_std", "IBDQ_induc_std")]

# ============================================================================
# Helper Functions
# ============================================================================

# Function to save clustering results
save_cluster_results <- function(clusters, method_name, timepoint) {
  col_name <- paste0("cluster_", method_name, "_", timepoint)
  data_imputed[[col_name]] <<- as.factor(clusters)
  return(col_name)
}

# Function to create scatter plot
plot_clusters <- function(data, clusters, method_name, timepoint) {
  df <- data.frame(
    x = data[, 1],
    y = data[, 2],
    cluster = as.factor(clusters)
  )
  
  x_label <- ifelse(timepoint == "base", "FC_base (log, standardized)", "FC_induc (log, standardized)")
  y_label <- ifelse(timepoint == "base", "IBDQ_base (standardized)", "IBDQ_induc (standardized)")
  
  p <- ggplot(df, aes(x = x, y = y, color = cluster)) +
    geom_point(size = 3, alpha = 0.6) +
    labs(
      title = paste(method_name, "Clustering -", toupper(timepoint)),
      x = x_label,
      y = y_label,
      color = "Cluster"
    ) +
    theme_bw() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      legend.position = "right"
    )
  
  print(p)
  
  # Save plot
  filename <- paste0("cluster_plot_", method_name, "_", timepoint, ".png")
  ggsave(filename, plot = p, width = 8, height = 6, dpi = 300)
  
  return(p)
}

# Function to create Sankey diagram
create_sankey_diagram <- function(cluster_base, cluster_induc, method_name) {
  df <- data.frame(
    base = as.factor(cluster_base),
    induc = as.factor(cluster_induc)
  )
  
  p <- ggplot(df, aes(axis1 = base, axis2 = induc)) +
    geom_alluvium(aes(fill = base), width = 1/12, alpha = 0.7) +
    geom_stratum(width = 1/12, fill = "white", color = "black") +
    geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 4) +
    scale_x_discrete(limits = c("base", "induc"),
                     labels = c("Baseline", "Induction")) +
    labs(
      title = paste(method_name, "- Cluster Changes from Baseline to Induction"),
      y = "Number of Patients",
      fill = "Baseline Cluster"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      legend.position = "right"
    )
  
  print(p)
  
  # Save plot
  filename <- paste0("sankey_", method_name, ".png")
  ggsave(filename, plot = p, width = 10, height = 6, dpi = 300)
  
  return(p)
}

# Function to analyze pattern changes
analyze_pattern_changes <- function(cluster_base, cluster_induc, method_name) {
  # Create transition matrix
  transition_table <- table(Base = cluster_base, Induc = cluster_induc)
  
  cat("\n", paste0(rep("=", 80), collapse = ""), "\n")
  cat(method_name, "- Pattern Change Analysis\n")
  cat(paste0(rep("=", 80), collapse = ""), "\n\n")
  
  cat("Transition Matrix:\n")
  print(transition_table)
  
  cat("\n\nTransition Proportions (%):\n")
  prop_table <- prop.table(transition_table, margin = 1) * 100
  print(round(prop_table, 2))
  
  # Common patterns
  cat("\n\nMost Common Transitions:\n")
  transitions <- data.frame(
    from = rep(rownames(transition_table), ncol(transition_table)),
    to = rep(colnames(transition_table), each = nrow(transition_table)),
    count = as.vector(transition_table)
  )
  transitions <- transitions[order(-transitions$count), ]
  print(head(transitions, 10))
  
  # Save results
  filename <- paste0("pattern_analysis_", method_name, ".csv")
  write.csv(transitions, filename, row.names = FALSE)
  
  return(transitions)
}

# Function to create combined grouping based on patterns
create_combined_grouping <- function(cluster_base, cluster_induc, method_name) {
  # Define pattern groups based on stability and direction
  pattern <- paste(cluster_base, cluster_induc, sep = "_")
  
  # You can customize this logic based on your needs
  # Example: stable high, stable low, improved, worsened
  combined_group <- case_when(
    cluster_base == cluster_induc & cluster_base %in% c(1) ~ "Stable_Low",
    cluster_base == cluster_induc & cluster_base %in% c(2, 3) ~ "Stable_High",
    as.numeric(cluster_induc) > as.numeric(cluster_base) ~ "Improved",
    as.numeric(cluster_induc) < as.numeric(cluster_base) ~ "Worsened",
    TRUE ~ "Other"
  )
  
  col_name <- paste0("pattern_group_", method_name)
  data_imputed[[col_name]] <<- as.factor(combined_group)
  
  return(combined_group)
}

# Function to create baseline characteristics table
create_baseline_table <- function(group_var, method_name) {
  vars <- c("age", "sex", "disease_duration", "FC_base", "IBDQ_base", "response")
  
  # Select only variables that exist in the dataset
  vars_exist <- vars[vars %in% names(data_imputed)]
  
  if(length(vars_exist) > 0 && group_var %in% names(data_imputed)) {
    table_one <- CreateTableOne(
      vars = vars_exist,
      strata = group_var,
      data = data_imputed,
      test = TRUE
    )
    
    cat("\n", paste0(rep("=", 80), collapse = ""), "\n")
    cat(method_name, "- Baseline Characteristics by Pattern Group\n")
    cat(paste0(rep("=", 80), collapse = ""), "\n\n")
    print(table_one, showAllLevels = TRUE)
    
    # Save table
    filename <- paste0("baseline_table_", method_name, ".csv")
    write.csv(print(table_one), filename)
  }
}

# Function to perform logistic regression
perform_logistic_regression <- function(group_var, method_name) {
  if(group_var %in% names(data_imputed) && "response" %in% names(data_imputed)) {
    # Simple logistic regression
    formula_str <- paste("response ~", group_var)
    model <- glm(as.formula(formula_str), data = data_imputed, family = binomial())
    
    cat("\n", paste0(rep("=", 80), collapse = ""), "\n")
    cat(method_name, "- Logistic Regression Results\n")
    cat(paste0(rep("=", 80), collapse = ""), "\n\n")
    print(summary(model))
    
    # Calculate OR and CI
    or_ci <- exp(cbind(OR = coef(model), confint(model)))
    cat("\n\nOdds Ratios and 95% CI:\n")
    print(or_ci)
    
    # Save results
    filename <- paste0("logistic_regression_", method_name, ".txt")
    sink(filename)
    print(summary(model))
    cat("\n\nOdds Ratios and 95% CI:\n")
    print(or_ci)
    sink()
  }
}

# ============================================================================
# 1. K-MEANS CLUSTERING
# ============================================================================

cat("\n\n")
cat(paste0(rep("#", 80), collapse = ""), "\n")
cat("# K-MEANS CLUSTERING\n")
cat(paste0(rep("#", 80), collapse = ""), "\n\n")

# Function to perform K-means clustering
perform_kmeans <- function(data, timepoint) {
  cat("\n--- K-means Clustering for", toupper(timepoint), "---\n\n")
  
  # 1. Elbow method to determine optimal k
  cat("Step 1: Determining optimal k using Elbow Method...\n")
  wss <- sapply(1:10, function(k) {
    kmeans(data, centers = k, nstart = 25)$tot.withinss
  })
  
  # Plot elbow curve
  elbow_df <- data.frame(k = 1:10, wss = wss)
  p_elbow <- ggplot(elbow_df, aes(x = k, y = wss)) +
    geom_line(size = 1) +
    geom_point(size = 3) +
    labs(
      title = paste("Elbow Method for K-means -", toupper(timepoint)),
      x = "Number of Clusters (k)",
      y = "Total Within-Cluster Sum of Squares"
    ) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  
  print(p_elbow)
  ggsave(paste0("kmeans_elbow_", timepoint, ".png"), plot = p_elbow, width = 8, height = 6, dpi = 300)
  
  # Calculate optimal k (using elbow detection - second derivative)
  # Simple approach: use k=3 as default (can be adjusted based on elbow plot)
  optimal_k <- 3
  
  # Alternative: use silhouette method
  sil_width <- sapply(2:8, function(k) {
    km <- kmeans(data, centers = k, nstart = 25)
    ss <- silhouette(km$cluster, dist(data))
    mean(ss[, 3])
  })
  
  optimal_k_sil <- which.max(sil_width) + 1
  cat("Optimal k by silhouette:", optimal_k_sil, "\n")
  
  # Use silhouette-based k
  optimal_k <- optimal_k_sil
  cat("Selected optimal k:", optimal_k, "\n\n")
  
  # 2. Perform K-means with optimal k
  cat("Step 2: Performing K-means clustering with k =", optimal_k, "...\n")
  set.seed(123)
  kmeans_result <- kmeans(data, centers = optimal_k, nstart = 25)
  
  cat("Cluster sizes:\n")
  print(table(kmeans_result$cluster))
  cat("\n")
  
  # 3. Save results
  cat("Step 3: Saving clustering results...\n")
  col_name <- save_cluster_results(kmeans_result$cluster, "kmeans", timepoint)
  
  # 4. Visualize
  cat("Step 4: Creating visualizations...\n")
  plot_clusters(data, kmeans_result$cluster, "K-means", timepoint)
  
  return(list(clusters = kmeans_result$cluster, optimal_k = optimal_k))
}

# Perform K-means for both timepoints
kmeans_base <- perform_kmeans(cluster_data_base, "base")
kmeans_induc <- perform_kmeans(cluster_data_induc, "induc")

# 5. Sankey diagram
cat("\nStep 5: Creating Sankey diagram for pattern changes...\n")
create_sankey_diagram(kmeans_base$clusters, kmeans_induc$clusters, "K-means")

# 6. Pattern analysis
cat("\nStep 6: Analyzing pattern changes...\n")
analyze_pattern_changes(kmeans_base$clusters, kmeans_induc$clusters, "K-means")

# 7. Combined grouping
cat("\nStep 7: Creating combined pattern grouping...\n")
pattern_group <- create_combined_grouping(kmeans_base$clusters, kmeans_induc$clusters, "kmeans")

# 8. Baseline table
cat("\nStep 8: Creating baseline characteristics table...\n")
create_baseline_table("pattern_group_kmeans", "K-means")

# 9. Logistic regression
cat("\nStep 9: Performing logistic regression...\n")
perform_logistic_regression("pattern_group_kmeans", "K-means")

# ============================================================================
# 2. HIERARCHICAL CLUSTERING
# ============================================================================

cat("\n\n")
cat(paste0(rep("#", 80), collapse = ""), "\n")
cat("# HIERARCHICAL CLUSTERING\n")
cat(paste0(rep("#", 80), collapse = ""), "\n\n")

# Function to perform Hierarchical clustering
perform_hierarchical <- function(data, timepoint) {
  cat("\n--- Hierarchical Clustering for", toupper(timepoint), "---\n\n")
  
  # 1. Compute distance matrix
  cat("Step 1: Computing distance matrix...\n")
  dist_matrix <- dist(data, method = "euclidean")
  
  # Perform hierarchical clustering
  hc <- hclust(dist_matrix, method = "ward.D2")
  
  # Plot dendrogram
  cat("Step 2: Creating dendrogram...\n")
  png(paste0("hierarchical_dendrogram_", timepoint, ".png"), width = 1200, height = 800, res = 150)
  plot(hc, main = paste("Dendrogram - Hierarchical Clustering -", toupper(timepoint)),
       xlab = "Patients", ylab = "Height", sub = "")
  abline(h = mean(hc$height[length(hc$height) - 2:4]), col = "red", lty = 2)
  dev.off()
  
  # 2. Determine optimal number of clusters using silhouette
  cat("Step 3: Determining optimal number of clusters using silhouette...\n")
  sil_scores <- sapply(2:8, function(k) {
    clusters <- cutree(hc, k = k)
    ss <- silhouette(clusters, dist_matrix)
    mean(ss[, 3])
  })
  
  optimal_k <- which.max(sil_scores) + 1
  cat("Optimal k by silhouette:", optimal_k, "\n\n")
  
  # Plot silhouette scores
  sil_df <- data.frame(k = 2:8, score = sil_scores)
  p_sil <- ggplot(sil_df, aes(x = k, y = score)) +
    geom_line(size = 1) +
    geom_point(size = 3) +
    labs(
      title = paste("Silhouette Analysis - Hierarchical -", toupper(timepoint)),
      x = "Number of Clusters (k)",
      y = "Average Silhouette Width"
    ) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  
  print(p_sil)
  ggsave(paste0("hierarchical_silhouette_", timepoint, ".png"), plot = p_sil, width = 8, height = 6, dpi = 300)
  
  # 3. Cut tree to get clusters
  cat("Step 4: Cutting dendrogram with k =", optimal_k, "...\n")
  clusters <- cutree(hc, k = optimal_k)
  
  cat("Cluster sizes:\n")
  print(table(clusters))
  cat("\n")
  
  # 4. Save results
  cat("Step 5: Saving clustering results...\n")
  col_name <- save_cluster_results(clusters, "hierarchical", timepoint)
  
  # 5. Visualize
  cat("Step 6: Creating visualizations...\n")
  plot_clusters(data, clusters, "Hierarchical", timepoint)
  
  return(list(clusters = clusters, optimal_k = optimal_k))
}

# Perform Hierarchical clustering for both timepoints
hc_base <- perform_hierarchical(cluster_data_base, "base")
hc_induc <- perform_hierarchical(cluster_data_induc, "induc")

# Sankey diagram and analysis
create_sankey_diagram(hc_base$clusters, hc_induc$clusters, "Hierarchical")
analyze_pattern_changes(hc_base$clusters, hc_induc$clusters, "Hierarchical")
pattern_group_hc <- create_combined_grouping(hc_base$clusters, hc_induc$clusters, "hierarchical")
create_baseline_table("pattern_group_hierarchical", "Hierarchical")
perform_logistic_regression("pattern_group_hierarchical", "Hierarchical")

# ============================================================================
# 3. GAUSSIAN MIXTURE MODEL (GMM) CLUSTERING
# ============================================================================

cat("\n\n")
cat(paste0(rep("#", 80), collapse = ""), "\n")
cat("# GAUSSIAN MIXTURE MODEL (GMM) CLUSTERING\n")
cat(paste0(rep("#", 80), collapse = ""), "\n\n")

# Function to perform GMM clustering
perform_gmm <- function(data, timepoint) {
  cat("\n--- GMM Clustering for", toupper(timepoint), "---\n\n")
  
  # 1. Determine optimal number of components using BIC
  cat("Step 1: Determining optimal number of components using BIC...\n")
  bic_values <- mclustBIC(data, G = 1:9)
  
  # Plot BIC
  png(paste0("gmm_bic_", timepoint, ".png"), width = 1000, height = 800, res = 150)
  plot(bic_values, main = paste("BIC for GMM -", toupper(timepoint)))
  dev.off()
  
  cat("BIC summary:\n")
  print(summary(bic_values))
  cat("\n")
  
  # 2. Fit GMM with optimal parameters
  cat("Step 2: Fitting GMM with optimal parameters...\n")
  gmm_result <- Mclust(data, x = bic_values)
  
  cat("Optimal number of components:", gmm_result$G, "\n")
  cat("Model type:", gmm_result$modelName, "\n")
  cat("Cluster sizes:\n")
  print(table(gmm_result$classification))
  cat("\n")
  
  # 3. Save results
  cat("Step 3: Saving clustering results...\n")
  col_name <- save_cluster_results(gmm_result$classification, "gmm", timepoint)
  
  # 4. Visualize
  cat("Step 4: Creating visualizations...\n")
  plot_clusters(data, gmm_result$classification, "GMM", timepoint)
  
  # Additional GMM-specific plots
  png(paste0("gmm_classification_", timepoint, ".png"), width = 1000, height = 800, res = 150)
  plot(gmm_result, what = "classification", main = paste("GMM Classification -", toupper(timepoint)))
  dev.off()
  
  return(list(clusters = gmm_result$classification, optimal_k = gmm_result$G))
}

# Perform GMM for both timepoints
gmm_base <- perform_gmm(cluster_data_base, "base")
gmm_induc <- perform_gmm(cluster_data_induc, "induc")

# Sankey diagram and analysis
create_sankey_diagram(gmm_base$clusters, gmm_induc$clusters, "GMM")
analyze_pattern_changes(gmm_base$clusters, gmm_induc$clusters, "GMM")
pattern_group_gmm <- create_combined_grouping(gmm_base$clusters, gmm_induc$clusters, "gmm")
create_baseline_table("pattern_group_gmm", "GMM")
perform_logistic_regression("pattern_group_gmm", "GMM")

# ============================================================================
# 4. DBSCAN CLUSTERING
# ============================================================================

cat("\n\n")
cat(paste0(rep("#", 80), collapse = ""), "\n")
cat("# DBSCAN CLUSTERING\n")
cat(paste0(rep("#", 80), collapse = ""), "\n\n")

# Function to perform DBSCAN clustering
perform_dbscan <- function(data, timepoint) {
  cat("\n--- DBSCAN Clustering for", toupper(timepoint), "---\n\n")
  
  # 1. Determine optimal eps using k-NN distance plot
  cat("Step 1: Determining optimal eps using k-NN distance plot...\n")
  knn_dist <- kNNdist(data, k = 4)
  knn_dist_sorted <- sort(knn_dist)
  
  # Plot k-NN distance
  knn_df <- data.frame(index = 1:length(knn_dist_sorted), dist = knn_dist_sorted)
  p_knn <- ggplot(knn_df, aes(x = index, y = dist)) +
    geom_line() +
    labs(
      title = paste("k-NN Distance Plot (k=4) -", toupper(timepoint)),
      x = "Points sorted by distance",
      y = "4-NN Distance"
    ) +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
  
  print(p_knn)
  ggsave(paste0("dbscan_knn_", timepoint, ".png"), plot = p_knn, width = 8, height = 6, dpi = 300)
  
  # Automatically select eps (use knee point approximation)
  # Simple approach: use quantile
  optimal_eps <- quantile(knn_dist, 0.90)
  cat("Selected eps:", optimal_eps, "\n\n")
  
  # 2. Perform DBSCAN
  cat("Step 2: Performing DBSCAN with eps =", optimal_eps, "and minPts = 4...\n")
  dbscan_result <- dbscan(data, eps = optimal_eps, minPts = 4)
  
  cat("Number of clusters (excluding noise):", max(dbscan_result$cluster), "\n")
  cat("Cluster sizes:\n")
  print(table(dbscan_result$cluster))
  cat("Note: Cluster 0 represents noise points\n\n")
  
  # Convert cluster 0 (noise) to a separate cluster for visualization
  clusters_adjusted <- dbscan_result$cluster
  clusters_adjusted[clusters_adjusted == 0] <- max(clusters_adjusted) + 1
  
  # 3. Save results
  cat("Step 3: Saving clustering results...\n")
  col_name <- save_cluster_results(clusters_adjusted, "dbscan", timepoint)
  
  # 4. Visualize
  cat("Step 4: Creating visualizations...\n")
  plot_clusters(data, clusters_adjusted, "DBSCAN", timepoint)
  
  return(list(clusters = clusters_adjusted, optimal_eps = optimal_eps))
}

# Perform DBSCAN for both timepoints
dbscan_base <- perform_dbscan(cluster_data_base, "base")
dbscan_induc <- perform_dbscan(cluster_data_induc, "induc")

# Sankey diagram and analysis
create_sankey_diagram(dbscan_base$clusters, dbscan_induc$clusters, "DBSCAN")
analyze_pattern_changes(dbscan_base$clusters, dbscan_induc$clusters, "DBSCAN")
pattern_group_dbscan <- create_combined_grouping(dbscan_base$clusters, dbscan_induc$clusters, "dbscan")
create_baseline_table("pattern_group_dbscan", "DBSCAN")
perform_logistic_regression("pattern_group_dbscan", "DBSCAN")

# ============================================================================
# 5. AFFINITY PROPAGATION CLUSTERING
# ============================================================================

cat("\n\n")
cat(paste0(rep("#", 80), collapse = ""), "\n")
cat("# AFFINITY PROPAGATION CLUSTERING\n")
cat(paste0(rep("#", 80), collapse = ""), "\n\n")

# Function to perform Affinity Propagation clustering
perform_affinity_propagation <- function(data, timepoint) {
  cat("\n--- Affinity Propagation Clustering for", toupper(timepoint), "---\n\n")
  
  # 1. Compute similarity matrix
  cat("Step 1: Computing similarity matrix...\n")
  sim_matrix <- negDistMat(data, r = 2)
  
  # 2. Perform Affinity Propagation
  cat("Step 2: Performing Affinity Propagation (auto-determining number of clusters)...\n")
  ap_result <- apcluster(sim_matrix)
  
  cat("Number of clusters found:", length(ap_result@clusters), "\n")
  cat("Cluster sizes:\n")
  cluster_assignments <- rep(0, nrow(data))
  for(i in 1:length(ap_result@clusters)) {
    cluster_assignments[ap_result@clusters[[i]]] <- i
  }
  print(table(cluster_assignments))
  cat("\n")
  
  # 3. Save results
  cat("Step 3: Saving clustering results...\n")
  col_name <- save_cluster_results(cluster_assignments, "affinity", timepoint)
  
  # 4. Visualize
  cat("Step 4: Creating visualizations...\n")
  plot_clusters(data, cluster_assignments, "Affinity Propagation", timepoint)
  
  return(list(clusters = cluster_assignments, n_clusters = length(ap_result@clusters)))
}

# Perform Affinity Propagation for both timepoints
ap_base <- perform_affinity_propagation(cluster_data_base, "base")
ap_induc <- perform_affinity_propagation(cluster_data_induc, "induc")

# Sankey diagram and analysis
create_sankey_diagram(ap_base$clusters, ap_induc$clusters, "Affinity_Propagation")
analyze_pattern_changes(ap_base$clusters, ap_induc$clusters, "Affinity_Propagation")
pattern_group_ap <- create_combined_grouping(ap_base$clusters, ap_induc$clusters, "affinity")
create_baseline_table("pattern_group_affinity", "Affinity_Propagation")
perform_logistic_regression("pattern_group_affinity", "Affinity_Propagation")

# ============================================================================
# SUMMARY AND COMPARISON
# ============================================================================

cat("\n\n")
cat(paste0(rep("#", 80), collapse = ""), "\n")
cat("# CLUSTERING METHODS COMPARISON\n")
cat(paste0(rep("#", 80), collapse = ""), "\n\n")

# Create comparison table
comparison_df <- data.frame(
  Method = c("K-means", "Hierarchical", "GMM", "DBSCAN", "Affinity Propagation"),
  Clusters_Base = c(kmeans_base$optimal_k, hc_base$optimal_k, gmm_base$optimal_k,
                    max(dbscan_base$clusters), ap_base$n_clusters),
  Clusters_Induc = c(kmeans_induc$optimal_k, hc_induc$optimal_k, gmm_induc$optimal_k,
                     max(dbscan_induc$clusters), ap_induc$n_clusters)
)

cat("Number of Clusters Identified by Each Method:\n")
print(comparison_df)

# Save comparison
write.csv(comparison_df, "clustering_comparison.csv", row.names = FALSE)

# Save final dataset with all clustering results
write.csv(data_imputed, "data_with_all_clusters.csv", row.names = FALSE)

cat("\n\n")
cat(paste0(rep("=", 80), collapse = ""), "\n")
cat("ANALYSIS COMPLETE!\n")
cat("All results have been saved to the working directory.\n")
cat(paste0(rep("=", 80), collapse = ""), "\n\n")

cat("Generated files:\n")
cat("- Clustering plots (PNG files)\n")
cat("- Sankey diagrams (PNG files)\n")
cat("- Pattern analysis tables (CSV files)\n")
cat("- Baseline characteristic tables (CSV files)\n")
cat("- Logistic regression results (TXT files)\n")
cat("- Final dataset with all clusters: data_with_all_clusters.csv\n")
cat("- Clustering comparison: clustering_comparison.csv\n")
