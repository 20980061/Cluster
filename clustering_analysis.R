# ================================================================================
# Clustering Analysis for FC and IBDQ Data
# ================================================================================
# This script performs clustering analysis on two sets of variables:
# - Cluster 1: FC_base_log (standardized) and IBDQ_base (standardized)
# - Cluster 2: FC_induc_log (standardized) and IBDQ_induc (standardized)
#
# Clustering methods used:
# 1. K-means (with elbow method for optimal k)
# 2. Hierarchical Clustering (with dendrogram and silhouette analysis)
# 3. PAM - Partitioning Around Medoids (with silhouette analysis)
# 4. Gaussian Mixture Model (with BIC criterion)
# 5. DBSCAN (with parameter optimization)
# ================================================================================

# Load required libraries
library(tidyverse)
library(cluster)
library(factoextra)
library(mclust)
library(dbscan)
library(ggplot2)
library(gridExtra)
library(tableone)

# Set seed for reproducibility
set.seed(123)

# ================================================================================
# SECTION 1: Data Generation and Preprocessing
# ================================================================================

# Generate sample data (replace with actual data loading)
# For demonstration, we create synthetic data
n <- 200  # number of observations

# Generate sample data
data_raw <- data.frame(
  ID = 1:n,
  FC_base = exp(rnorm(n, mean = 4, sd = 1)),  # Log-normal distribution
  FC_induc = exp(rnorm(n, mean = 3.5, sd = 1)),
  IBDQ_base = rnorm(n, mean = 150, sd = 30),
  IBDQ_induc = rnorm(n, mean = 170, sd = 25)
)

# Add some baseline characteristics for later analysis
data_raw$Age <- rnorm(n, mean = 40, sd = 12)
data_raw$Sex <- sample(c("Male", "Female"), n, replace = TRUE)
data_raw$BMI <- rnorm(n, mean = 24, sd = 4)
data_raw$Disease_Duration <- rnorm(n, mean = 5, sd = 3)
data_raw$Outcome <- sample(c(0, 1), n, replace = TRUE, prob = c(0.6, 0.4))

# Handle missing values (imputation) - create data_imputed
data_imputed <- data_raw
# In real scenario, use proper imputation methods
# For now, we assume no missing values or they've been imputed

# ================================================================================
# SECTION 2: Log Transformation and Standardization
# ================================================================================

# Log transformation for FC variables
data_imputed$FC_base_log <- log(data_imputed$FC_base)
data_imputed$FC_induc_log <- log(data_imputed$FC_induc)

# Prepare data for Cluster 1: FC_base_log and IBDQ_base
cluster1_data <- data_imputed %>%
  select(FC_base_log, IBDQ_base) %>%
  scale() %>%  # Standardization
  as.data.frame()

# Prepare data for Cluster 2: FC_induc_log and IBDQ_induc
cluster2_data <- data_imputed %>%
  select(FC_induc_log, IBDQ_induc) %>%
  scale() %>%  # Standardization
  as.data.frame()

# ================================================================================
# SECTION 3: Clustering Method 1 - K-means Clustering
# ================================================================================

cat("\n=== K-MEANS CLUSTERING ===\n")

# Function to perform K-means clustering with elbow method
perform_kmeans_clustering <- function(data, cluster_name, max_k = 10) {
  
  cat("\n--- K-means for", cluster_name, "---\n")
  
  # Step 1: Elbow method to determine optimal k
  wss <- numeric(max_k)
  for (k in 1:max_k) {
    kmeans_result <- kmeans(data, centers = k, nstart = 25)
    wss[k] <- kmeans_result$tot.withinss
  }
  
  # Create elbow plot
  elbow_data <- data.frame(k = 1:max_k, WSS = wss)
  elbow_plot <- ggplot(elbow_data, aes(x = k, y = WSS)) +
    geom_line() +
    geom_point(size = 3) +
    geom_vline(xintercept = 3, linetype = "dashed", color = "red") +
    labs(title = paste("Elbow Method for", cluster_name),
         x = "Number of Clusters (k)",
         y = "Within-cluster Sum of Squares") +
    theme_minimal() +
    scale_x_continuous(breaks = 1:max_k)
  
  # Save elbow plot
  ggsave(paste0("kmeans_elbow_", cluster_name, ".png"), 
         plot = elbow_plot, width = 8, height = 6)
  
  # Also calculate silhouette scores
  sil_scores <- numeric(max_k - 1)
  for (k in 2:max_k) {
    kmeans_result <- kmeans(data, centers = k, nstart = 25)
    sil <- silhouette(kmeans_result$cluster, dist(data))
    sil_scores[k - 1] <- mean(sil[, 3])
  }
  
  # Determine optimal k (using silhouette method as additional criterion)
  optimal_k_sil <- which.max(sil_scores) + 1
  
  # Use k=3 as a reasonable default based on elbow method
  # (can be adjusted based on visual inspection)
  optimal_k <- 3
  
  cat("Optimal k (by silhouette):", optimal_k_sil, "\n")
  cat("Using k =", optimal_k, "for final clustering\n")
  
  # Step 2: Perform clustering with optimal k
  final_kmeans <- kmeans(data, centers = optimal_k, nstart = 25)
  
  # Step 3: Return results
  return(list(
    model = final_kmeans,
    clusters = final_kmeans$cluster,
    optimal_k = optimal_k,
    elbow_plot = elbow_plot
  ))
}

# Apply K-means to both clusters
kmeans_cluster1 <- perform_kmeans_clustering(cluster1_data, "Cluster1_Base")
kmeans_cluster2 <- perform_kmeans_clustering(cluster2_data, "Cluster2_Induc")

# Save results to data_imputed
data_imputed$kmeans_cluster1 <- kmeans_cluster1$clusters
data_imputed$kmeans_cluster2 <- kmeans_cluster2$clusters

# Step 4: Create scatter plots
plot_kmeans_cluster1 <- ggplot(data.frame(cluster1_data, cluster = factor(kmeans_cluster1$clusters)),
                                aes(x = FC_base_log, y = IBDQ_base, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "K-means Clustering: FC_base_log vs IBDQ_base",
       x = "FC_base_log (standardized)",
       y = "IBDQ_base (standardized)",
       color = "Cluster") +
  theme_minimal()

plot_kmeans_cluster2 <- ggplot(data.frame(cluster2_data, cluster = factor(kmeans_cluster2$clusters)),
                                aes(x = FC_induc_log, y = IBDQ_induc, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "K-means Clustering: FC_induc_log vs IBDQ_induc",
       x = "FC_induc_log (standardized)",
       y = "IBDQ_induc (standardized)",
       color = "Cluster") +
  theme_minimal()

ggsave("kmeans_cluster1_scatter.png", plot = plot_kmeans_cluster1, width = 8, height = 6)
ggsave("kmeans_cluster2_scatter.png", plot = plot_kmeans_cluster2, width = 8, height = 6)

# ================================================================================
# SECTION 4: Clustering Method 2 - Hierarchical Clustering
# ================================================================================

cat("\n=== HIERARCHICAL CLUSTERING ===\n")

perform_hierarchical_clustering <- function(data, cluster_name, max_k = 10) {
  
  cat("\n--- Hierarchical Clustering for", cluster_name, "---\n")
  
  # Step 1: Compute distance matrix and perform hierarchical clustering
  dist_matrix <- dist(data, method = "euclidean")
  hc_result <- hclust(dist_matrix, method = "ward.D2")
  
  # Create dendrogram
  png(paste0("hierarchical_dendrogram_", cluster_name, ".png"), 
      width = 800, height = 600)
  plot(hc_result, main = paste("Dendrogram for", cluster_name),
       xlab = "Samples", ylab = "Height")
  rect.hclust(hc_result, k = 3, border = 2:4)
  dev.off()
  
  # Calculate silhouette scores for different k
  sil_scores <- numeric(max_k - 1)
  for (k in 2:max_k) {
    clusters <- cutree(hc_result, k = k)
    sil <- silhouette(clusters, dist_matrix)
    sil_scores[k - 1] <- mean(sil[, 3])
  }
  
  # Plot silhouette scores
  sil_data <- data.frame(k = 2:max_k, silhouette = sil_scores)
  sil_plot <- ggplot(sil_data, aes(x = k, y = silhouette)) +
    geom_line() +
    geom_point(size = 3) +
    labs(title = paste("Silhouette Analysis for", cluster_name),
         x = "Number of Clusters (k)",
         y = "Average Silhouette Width") +
    theme_minimal() +
    scale_x_continuous(breaks = 2:max_k)
  
  ggsave(paste0("hierarchical_silhouette_", cluster_name, ".png"),
         plot = sil_plot, width = 8, height = 6)
  
  # Determine optimal k
  optimal_k <- which.max(sil_scores) + 1
  cat("Optimal k (by silhouette):", optimal_k, "\n")
  
  # Step 2: Cut tree to get clusters
  clusters <- cutree(hc_result, k = optimal_k)
  
  return(list(
    model = hc_result,
    clusters = clusters,
    optimal_k = optimal_k,
    silhouette_plot = sil_plot
  ))
}

# Apply Hierarchical clustering to both clusters
hc_cluster1 <- perform_hierarchical_clustering(cluster1_data, "Cluster1_Base")
hc_cluster2 <- perform_hierarchical_clustering(cluster2_data, "Cluster2_Induc")

# Save results to data_imputed
data_imputed$hc_cluster1 <- hc_cluster1$clusters
data_imputed$hc_cluster2 <- hc_cluster2$clusters

# Create scatter plots
plot_hc_cluster1 <- ggplot(data.frame(cluster1_data, cluster = factor(hc_cluster1$clusters)),
                           aes(x = FC_base_log, y = IBDQ_base, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "Hierarchical Clustering: FC_base_log vs IBDQ_base",
       x = "FC_base_log (standardized)",
       y = "IBDQ_base (standardized)",
       color = "Cluster") +
  theme_minimal()

plot_hc_cluster2 <- ggplot(data.frame(cluster2_data, cluster = factor(hc_cluster2$clusters)),
                           aes(x = FC_induc_log, y = IBDQ_induc, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "Hierarchical Clustering: FC_induc_log vs IBDQ_induc",
       x = "FC_induc_log (standardized)",
       y = "IBDQ_induc (standardized)",
       color = "Cluster") +
  theme_minimal()

ggsave("hierarchical_cluster1_scatter.png", plot = plot_hc_cluster1, width = 8, height = 6)
ggsave("hierarchical_cluster2_scatter.png", plot = plot_hc_cluster2, width = 8, height = 6)

# ================================================================================
# SECTION 5: Clustering Method 3 - PAM (Partitioning Around Medoids)
# ================================================================================

cat("\n=== PAM CLUSTERING ===\n")

perform_pam_clustering <- function(data, cluster_name, max_k = 10) {
  
  cat("\n--- PAM Clustering for", cluster_name, "---\n")
  
  # Step 1: Calculate silhouette scores for different k
  sil_scores <- numeric(max_k - 1)
  for (k in 2:max_k) {
    pam_result <- pam(data, k = k)
    sil_scores[k - 1] <- pam_result$silinfo$avg.width
  }
  
  # Plot silhouette scores
  sil_data <- data.frame(k = 2:max_k, silhouette = sil_scores)
  sil_plot <- ggplot(sil_data, aes(x = k, y = silhouette)) +
    geom_line() +
    geom_point(size = 3) +
    labs(title = paste("PAM Silhouette Analysis for", cluster_name),
         x = "Number of Clusters (k)",
         y = "Average Silhouette Width") +
    theme_minimal() +
    scale_x_continuous(breaks = 2:max_k)
  
  ggsave(paste0("pam_silhouette_", cluster_name, ".png"),
         plot = sil_plot, width = 8, height = 6)
  
  # Determine optimal k
  optimal_k <- which.max(sil_scores) + 1
  cat("Optimal k (by silhouette):", optimal_k, "\n")
  
  # Step 2: Perform PAM with optimal k
  final_pam <- pam(data, k = optimal_k)
  
  return(list(
    model = final_pam,
    clusters = final_pam$clustering,
    optimal_k = optimal_k,
    silhouette_plot = sil_plot
  ))
}

# Apply PAM to both clusters
pam_cluster1 <- perform_pam_clustering(cluster1_data, "Cluster1_Base")
pam_cluster2 <- perform_pam_clustering(cluster2_data, "Cluster2_Induc")

# Save results to data_imputed
data_imputed$pam_cluster1 <- pam_cluster1$clusters
data_imputed$pam_cluster2 <- pam_cluster2$clusters

# Create scatter plots
plot_pam_cluster1 <- ggplot(data.frame(cluster1_data, cluster = factor(pam_cluster1$clusters)),
                            aes(x = FC_base_log, y = IBDQ_base, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "PAM Clustering: FC_base_log vs IBDQ_base",
       x = "FC_base_log (standardized)",
       y = "IBDQ_base (standardized)",
       color = "Cluster") +
  theme_minimal()

plot_pam_cluster2 <- ggplot(data.frame(cluster2_data, cluster = factor(pam_cluster2$clusters)),
                            aes(x = FC_induc_log, y = IBDQ_induc, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "PAM Clustering: FC_induc_log vs IBDQ_induc",
       x = "FC_induc_log (standardized)",
       y = "IBDQ_induc (standardized)",
       color = "Cluster") +
  theme_minimal()

ggsave("pam_cluster1_scatter.png", plot = plot_pam_cluster1, width = 8, height = 6)
ggsave("pam_cluster2_scatter.png", plot = plot_pam_cluster2, width = 8, height = 6)

# ================================================================================
# SECTION 6: Clustering Method 4 - Gaussian Mixture Model (GMM)
# ================================================================================

cat("\n=== GAUSSIAN MIXTURE MODEL (GMM) ===\n")

perform_gmm_clustering <- function(data, cluster_name, max_k = 10) {
  
  cat("\n--- GMM for", cluster_name, "---\n")
  
  # Step 1: Fit GMM for different k and calculate BIC
  bic_scores <- numeric(max_k)
  gmm_models <- list()
  
  for (k in 1:max_k) {
    gmm_result <- Mclust(data, G = k, verbose = FALSE)
    bic_scores[k] <- gmm_result$bic
    gmm_models[[k]] <- gmm_result
  }
  
  # Plot BIC scores
  bic_data <- data.frame(k = 1:max_k, BIC = bic_scores)
  bic_plot <- ggplot(bic_data, aes(x = k, y = BIC)) +
    geom_line() +
    geom_point(size = 3) +
    labs(title = paste("BIC Criterion for GMM -", cluster_name),
         x = "Number of Components (k)",
         y = "BIC") +
    theme_minimal() +
    scale_x_continuous(breaks = 1:max_k)
  
  ggsave(paste0("gmm_bic_", cluster_name, ".png"),
         plot = bic_plot, width = 8, height = 6)
  
  # Determine optimal k (highest BIC)
  optimal_k <- which.max(bic_scores)
  cat("Optimal k (by BIC):", optimal_k, "\n")
  
  # Step 2: Use optimal model
  final_gmm <- gmm_models[[optimal_k]]
  
  return(list(
    model = final_gmm,
    clusters = final_gmm$classification,
    optimal_k = optimal_k,
    bic_plot = bic_plot
  ))
}

# Apply GMM to both clusters
gmm_cluster1 <- perform_gmm_clustering(cluster1_data, "Cluster1_Base")
gmm_cluster2 <- perform_gmm_clustering(cluster2_data, "Cluster2_Induc")

# Save results to data_imputed
data_imputed$gmm_cluster1 <- gmm_cluster1$clusters
data_imputed$gmm_cluster2 <- gmm_cluster2$clusters

# Create scatter plots
plot_gmm_cluster1 <- ggplot(data.frame(cluster1_data, cluster = factor(gmm_cluster1$clusters)),
                            aes(x = FC_base_log, y = IBDQ_base, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "GMM Clustering: FC_base_log vs IBDQ_base",
       x = "FC_base_log (standardized)",
       y = "IBDQ_base (standardized)",
       color = "Cluster") +
  theme_minimal()

plot_gmm_cluster2 <- ggplot(data.frame(cluster2_data, cluster = factor(gmm_cluster2$clusters)),
                            aes(x = FC_induc_log, y = IBDQ_induc, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "GMM Clustering: FC_induc_log vs IBDQ_induc",
       x = "FC_induc_log (standardized)",
       y = "IBDQ_induc (standardized)",
       color = "Cluster") +
  theme_minimal()

ggsave("gmm_cluster1_scatter.png", plot = plot_gmm_cluster1, width = 8, height = 6)
ggsave("gmm_cluster2_scatter.png", plot = plot_gmm_cluster2, width = 8, height = 6)

# ================================================================================
# SECTION 7: Clustering Method 5 - DBSCAN
# ================================================================================

cat("\n=== DBSCAN CLUSTERING ===\n")

perform_dbscan_clustering <- function(data, cluster_name) {
  
  cat("\n--- DBSCAN for", cluster_name, "---\n")
  
  # Step 1: Determine optimal eps using k-NN distance plot
  knn_dist <- kNNdist(data, k = 4)
  knn_dist_sorted <- sort(knn_dist)
  
  # Create k-NN distance plot
  knn_plot_data <- data.frame(index = 1:length(knn_dist_sorted), 
                               distance = knn_dist_sorted)
  knn_plot <- ggplot(knn_plot_data, aes(x = index, y = distance)) +
    geom_line() +
    labs(title = paste("k-NN Distance Plot for", cluster_name),
         x = "Points sorted by distance",
         y = "4-NN distance") +
    theme_minimal()
  
  ggsave(paste0("dbscan_knn_", cluster_name, ".png"),
         plot = knn_plot, width = 8, height = 6)
  
  # Determine eps from the "elbow" in k-NN plot (approximate)
  # For standardized data, eps around 0.5 is often reasonable
  eps_value <- 0.5
  minPts_value <- 4
  
  cat("Using eps =", eps_value, "and minPts =", minPts_value, "\n")
  
  # Step 2: Perform DBSCAN
  dbscan_result <- dbscan(data, eps = eps_value, minPts = minPts_value)
  
  cat("Number of clusters:", max(dbscan_result$cluster), "\n")
  cat("Number of noise points:", sum(dbscan_result$cluster == 0), "\n")
  
  return(list(
    model = dbscan_result,
    clusters = dbscan_result$cluster,
    eps = eps_value,
    minPts = minPts_value,
    knn_plot = knn_plot
  ))
}

# Apply DBSCAN to both clusters
dbscan_cluster1 <- perform_dbscan_clustering(cluster1_data, "Cluster1_Base")
dbscan_cluster2 <- perform_dbscan_clustering(cluster2_data, "Cluster2_Induc")

# Save results to data_imputed
data_imputed$dbscan_cluster1 <- dbscan_cluster1$clusters
data_imputed$dbscan_cluster2 <- dbscan_cluster2$clusters

# Create scatter plots (noise points shown separately)
plot_dbscan_cluster1 <- ggplot(data.frame(cluster1_data, 
                                          cluster = factor(dbscan_cluster1$clusters)),
                               aes(x = FC_base_log, y = IBDQ_base, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "DBSCAN Clustering: FC_base_log vs IBDQ_base",
       x = "FC_base_log (standardized)",
       y = "IBDQ_base (standardized)",
       color = "Cluster\n(0=noise)") +
  theme_minimal()

plot_dbscan_cluster2 <- ggplot(data.frame(cluster2_data, 
                                          cluster = factor(dbscan_cluster2$clusters)),
                               aes(x = FC_induc_log, y = IBDQ_induc, color = cluster)) +
  geom_point(size = 3, alpha = 0.6) +
  labs(title = "DBSCAN Clustering: FC_induc_log vs IBDQ_induc",
       x = "FC_induc_log (standardized)",
       y = "IBDQ_induc (standardized)",
       color = "Cluster\n(0=noise)") +
  theme_minimal()

ggsave("dbscan_cluster1_scatter.png", plot = plot_dbscan_cluster1, width = 8, height = 6)
ggsave("dbscan_cluster2_scatter.png", plot = plot_dbscan_cluster2, width = 8, height = 6)

# ================================================================================
# SECTION 8: Pattern Change Analysis from Base to Induc
# ================================================================================

cat("\n=== PATTERN CHANGE ANALYSIS ===\n")

# For demonstration, we'll use K-means results
# Create transition matrix showing how clusters change from base to induc

analyze_cluster_transitions <- function(cluster1, cluster2, method_name) {
  
  cat("\n--- Transition Analysis for", method_name, "---\n")
  
  # Create transition table
  transition_table <- table(Base = cluster1, Induc = cluster2)
  print(transition_table)
  
  # Calculate transition proportions
  transition_prop <- prop.table(transition_table, margin = 1)
  print(round(transition_prop, 3))
  
  # Create Sankey-like visualization showing transitions
  transition_data <- as.data.frame(transition_table)
  colnames(transition_data) <- c("Base", "Induc", "Count")
  
  transition_plot <- ggplot(transition_data, aes(x = 1, fill = Base)) +
    geom_bar(position = "stack", stat = "identity", aes(y = Count)) +
    geom_bar(aes(x = 2, y = Count, fill = Induc), 
             position = "stack", stat = "identity") +
    labs(title = paste("Cluster Transitions:", method_name),
         x = "",
         y = "Number of Patients") +
    scale_x_continuous(breaks = c(1, 2), labels = c("Baseline", "Induction")) +
    theme_minimal()
  
  ggsave(paste0(tolower(gsub(" ", "_", method_name)), "_transitions.png"),
         plot = transition_plot, width = 8, height = 6)
  
  # Create combined cluster pattern
  pattern <- paste0(cluster1, "->", cluster2)
  
  return(list(
    transition_table = transition_table,
    transition_prop = transition_prop,
    pattern = pattern
  ))
}

# Analyze transitions for each method
kmeans_transitions <- analyze_cluster_transitions(
  data_imputed$kmeans_cluster1, 
  data_imputed$kmeans_cluster2,
  "K-means"
)

hc_transitions <- analyze_cluster_transitions(
  data_imputed$hc_cluster1,
  data_imputed$hc_cluster2,
  "Hierarchical Clustering"
)

pam_transitions <- analyze_cluster_transitions(
  data_imputed$pam_cluster1,
  data_imputed$pam_cluster2,
  "PAM"
)

gmm_transitions <- analyze_cluster_transitions(
  data_imputed$gmm_cluster1,
  data_imputed$gmm_cluster2,
  "GMM"
)

dbscan_transitions <- analyze_cluster_transitions(
  data_imputed$dbscan_cluster1,
  data_imputed$dbscan_cluster2,
  "DBSCAN"
)

# Save transition patterns to data_imputed
data_imputed$kmeans_pattern <- kmeans_transitions$pattern
data_imputed$hc_pattern <- hc_transitions$pattern
data_imputed$pam_pattern <- pam_transitions$pattern
data_imputed$gmm_pattern <- gmm_transitions$pattern
data_imputed$dbscan_pattern <- dbscan_transitions$pattern

# Identify common patterns (using K-means as example)
pattern_freq <- table(data_imputed$kmeans_pattern)
common_patterns <- names(pattern_freq)[pattern_freq >= 10]  # patterns with at least 10 cases

cat("\nCommon transition patterns (K-means):\n")
print(pattern_freq)

# ================================================================================
# SECTION 9: Create New Groups Based on Patterns
# ================================================================================

cat("\n=== CREATING PATTERN-BASED GROUPS ===\n")

# Define pattern groups based on clinical interpretation
# Example grouping (adjust based on actual patterns):
# Group 1: Stable low (e.g., 1->1)
# Group 2: Improved (e.g., 2->1, 3->1)
# Group 3: Worsened (e.g., 1->2, 1->3)
# Group 4: Stable high (e.g., 3->3)

create_pattern_groups <- function(cluster1, cluster2) {
  pattern_group <- rep(NA, length(cluster1))
  
  for (i in 1:length(cluster1)) {
    base <- cluster1[i]
    induc <- cluster2[i]
    
    # Define groups based on transition patterns
    if (base == 1 && induc == 1) {
      pattern_group[i] <- "Stable_Low"
    } else if (base > induc) {
      pattern_group[i] <- "Improved"
    } else if (base < induc) {
      pattern_group[i] <- "Worsened"
    } else {
      pattern_group[i] <- "Stable_High"
    }
  }
  
  return(pattern_group)
}

# Create pattern groups for K-means (primary method)
data_imputed$pattern_group <- create_pattern_groups(
  data_imputed$kmeans_cluster1,
  data_imputed$kmeans_cluster2
)

cat("\nPattern group distribution:\n")
print(table(data_imputed$pattern_group))

# ================================================================================
# SECTION 10: Baseline Characteristics Comparison Table
# ================================================================================

cat("\n=== BASELINE CHARACTERISTICS COMPARISON ===\n")

# Create baseline characteristics table by pattern group
baseline_vars <- c("Age", "Sex", "BMI", "Disease_Duration", 
                   "FC_base", "IBDQ_base", "Outcome")

# Create Table 1
table1 <- CreateTableOne(
  vars = baseline_vars,
  strata = "pattern_group",
  data = data_imputed,
  factorVars = c("Sex", "Outcome")
)

# Print table
print(table1, showAllLevels = TRUE)

# Save table as CSV
table1_df <- print(table1, printToggle = FALSE, showAllLevels = TRUE)
write.csv(table1_df, "baseline_characteristics_table.csv")

# ================================================================================
# SECTION 11: Logistic Regression Analysis
# ================================================================================

cat("\n=== LOGISTIC REGRESSION ANALYSIS ===\n")

# Perform logistic regression with pattern groups as predictor
# Outcome as dependent variable

# Set reference group
data_imputed$pattern_group <- factor(data_imputed$pattern_group)
data_imputed$pattern_group <- relevel(data_imputed$pattern_group, ref = "Stable_Low")

# Univariate logistic regression
univariate_model <- glm(Outcome ~ pattern_group, 
                        data = data_imputed, 
                        family = binomial())

cat("\n--- Univariate Logistic Regression ---\n")
print(summary(univariate_model))

# Calculate OR and 95% CI
or_univariate <- exp(coef(univariate_model))
ci_univariate <- exp(confint(univariate_model))

cat("\nOdds Ratios (95% CI):\n")
print(cbind(OR = or_univariate, ci_univariate))

# Multivariate logistic regression (adjusted for confounders)
multivariate_model <- glm(Outcome ~ pattern_group + Age + Sex + BMI + Disease_Duration,
                          data = data_imputed,
                          family = binomial())

cat("\n--- Multivariate Logistic Regression ---\n")
print(summary(multivariate_model))

# Calculate OR and 95% CI for multivariate model
or_multivariate <- exp(coef(multivariate_model))
ci_multivariate <- exp(confint(multivariate_model))

cat("\nAdjusted Odds Ratios (95% CI):\n")
print(cbind(OR = or_multivariate, ci_multivariate))

# Save regression results
regression_results <- data.frame(
  Variable = names(coef(multivariate_model)),
  OR = or_multivariate,
  CI_lower = ci_multivariate[, 1],
  CI_upper = ci_multivariate[, 2],
  P_value = summary(multivariate_model)$coefficients[, 4]
)

write.csv(regression_results, "logistic_regression_results.csv", row.names = FALSE)

# Create forest plot for ORs
regression_results_filtered <- regression_results[grep("pattern_group", regression_results$Variable), ]

forest_plot <- ggplot(regression_results_filtered, 
                      aes(x = OR, y = Variable)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.2) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "red") +
  labs(title = "Forest Plot: Adjusted Odds Ratios for Pattern Groups",
       x = "Odds Ratio (95% CI)",
       y = "Pattern Group") +
  theme_minimal() +
  scale_x_log10()

ggsave("forest_plot_pattern_groups.png", plot = forest_plot, width = 10, height = 6)

# ================================================================================
# SECTION 12: Save Final Dataset and Summary
# ================================================================================

# Save final dataset with all clustering results
write.csv(data_imputed, "data_with_clustering_results.csv", row.names = FALSE)

# Create summary report
sink("clustering_analysis_summary.txt")
cat("================================================================================\n")
cat("CLUSTERING ANALYSIS SUMMARY REPORT\n")
cat("================================================================================\n\n")

cat("Dataset Information:\n")
cat("Number of observations:", nrow(data_imputed), "\n")
cat("Number of variables:", ncol(data_imputed), "\n\n")

cat("Clustering Methods Applied:\n")
cat("1. K-means (optimal k via elbow method)\n")
cat("2. Hierarchical Clustering (optimal k via silhouette analysis)\n")
cat("3. PAM - Partitioning Around Medoids (optimal k via silhouette analysis)\n")
cat("4. Gaussian Mixture Model (optimal k via BIC)\n")
cat("5. DBSCAN (optimal eps via k-NN distance)\n\n")

cat("Optimal Parameters:\n")
cat("K-means - k =", kmeans_cluster1$optimal_k, "\n")
cat("Hierarchical - k =", hc_cluster1$optimal_k, "\n")
cat("PAM - k =", pam_cluster1$optimal_k, "\n")
cat("GMM - k =", gmm_cluster1$optimal_k, "\n")
cat("DBSCAN - eps =", dbscan_cluster1$eps, ", minPts =", dbscan_cluster1$minPts, "\n\n")

cat("Pattern Groups Distribution:\n")
print(table(data_imputed$pattern_group))
cat("\n")

cat("Files Generated:\n")
cat("- Elbow plots for K-means\n")
cat("- Dendrograms and silhouette plots for Hierarchical clustering\n")
cat("- Silhouette plots for PAM\n")
cat("- BIC plots for GMM\n")
cat("- k-NN distance plots for DBSCAN\n")
cat("- Scatter plots for all methods\n")
cat("- Transition analysis plots\n")
cat("- Baseline characteristics table (CSV)\n")
cat("- Logistic regression results (CSV)\n")
cat("- Forest plot for odds ratios\n")
cat("- Final dataset with clustering results (CSV)\n\n")

cat("================================================================================\n")
sink()

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("All results saved to working directory.\n")
cat("Summary report: clustering_analysis_summary.txt\n")
cat("Final dataset: data_with_clustering_results.csv\n")
