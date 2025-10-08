# ============================================================================
# Clustering Analysis Script with Pattern Transition Visualization
# ============================================================================
# This script performs clustering analysis using multiple methods and 
# visualizes cluster label transitions from baseline to induction
# ============================================================================

# Install and load required packages
required_packages <- c(
  "tidyverse",      # Data manipulation
  "cluster",        # Clustering algorithms
  "factoextra",     # Clustering visualization
  "mclust",         # GMM clustering
  "dbscan",         # DBSCAN clustering
  "apcluster",      # Affinity Propagation
  "ggalluvial",     # Alluvial diagrams
  "gridExtra",      # Arrange multiple plots
  "mice",           # Data imputation
  "tableone"        # Baseline tables
)

# Install missing packages
for(pkg in required_packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# ============================================================================
# SECTION 1: Data Loading and Preprocessing
# ============================================================================

# Create sample data for demonstration
# Replace this with your actual data loading:
# setwd("your/working/directory")
# load("RCT3.RData")
# data_test <- data_UNIFI

set.seed(123)
n <- 100

# Generate sample data
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

# Handle missing values using MICE imputation
if(sum(is.na(data_test)) > 0) {
  imp <- mice(data_test, m = 1, method = "pmm", seed = 123, printFlag = FALSE)
  data_imputed <- complete(imp, 1)
} else {
  data_imputed <- data_test
}

# Log transformation of FC values
data_imputed$FC_base_log <- log(data_imputed$FC_base)
data_imputed$FC_induc_log <- log(data_imputed$FC_induc)

# Standardization function
standardize <- function(x) {
  return((x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE))
}

# Standardize clustering variables
data_imputed$FC_base_log_std <- standardize(data_imputed$FC_base_log)
data_imputed$FC_induc_log_std <- standardize(data_imputed$FC_induc_log)
data_imputed$IBDQ_base_std <- standardize(data_imputed$IBDQ_base)
data_imputed$IBDQ_induc_std <- standardize(data_imputed$IBDQ_induc)

# Prepare clustering datasets
cluster_data_base <- data_imputed[, c("FC_base_log_std", "IBDQ_base_std")]
cluster_data_induc <- data_imputed[, c("FC_induc_log_std", "IBDQ_induc_std")]

# Create output directory
if(!dir.exists("output")) {
  dir.create("output")
}

# ============================================================================
# SECTION 2: K-means Clustering
# ============================================================================

cat("\n=== K-means Clustering ===\n")

# Function to perform elbow method
kmeans_elbow <- function(data, max_k = 10) {
  wss <- sapply(1:max_k, function(k) {
    kmeans(data, centers = k, nstart = 25)$tot.withinss
  })
  return(wss)
}

# Elbow method for base
wss_base <- kmeans_elbow(cluster_data_base, max_k = 10)
png("output/kmeans_elbow_base.png", width = 800, height = 600)
plot(1:10, wss_base, type = "b", pch = 19, 
     xlab = "Number of clusters K", ylab = "Total within-cluster sum of squares",
     main = "Elbow Method - Base")
dev.off()

# Elbow method for induc
wss_induc <- kmeans_elbow(cluster_data_induc, max_k = 10)
png("output/kmeans_elbow_induc.png", width = 800, height = 600)
plot(1:10, wss_induc, type = "b", pch = 19,
     xlab = "Number of clusters K", ylab = "Total within-cluster sum of squares",
     main = "Elbow Method - Induc")
dev.off()

# Choose optimal k (typically 3-4 based on elbow)
optimal_k <- 3

# Perform K-means clustering
set.seed(123)
kmeans_base <- kmeans(cluster_data_base, centers = optimal_k, nstart = 25)
kmeans_induc <- kmeans(cluster_data_induc, centers = optimal_k, nstart = 25)

# Save results
data_imputed$kmeans_cluster_base <- kmeans_base$cluster
data_imputed$kmeans_cluster_induc <- kmeans_induc$cluster

# Scatter plot visualization
png("output/kmeans_scatter_base.png", width = 800, height = 600)
fviz_cluster(kmeans_base, data = cluster_data_base,
             geom = "point", ellipse.type = "convex",
             main = "K-means Clustering - Base",
             xlab = "FC_base_log (standardized)",
             ylab = "IBDQ_base (standardized)")
dev.off()

png("output/kmeans_scatter_induc.png", width = 800, height = 600)
fviz_cluster(kmeans_induc, data = cluster_data_induc,
             geom = "point", ellipse.type = "convex",
             main = "K-means Clustering - Induc",
             xlab = "FC_induc_log (standardized)",
             ylab = "IBDQ_induc (standardized)")
dev.off()

# ============================================================================
# SECTION 3: Hierarchical Clustering
# ============================================================================

cat("\n=== Hierarchical Clustering ===\n")

# Compute distance matrices
dist_base <- dist(cluster_data_base, method = "euclidean")
dist_induc <- dist(cluster_data_induc, method = "euclidean")

# Hierarchical clustering
hclust_base <- hclust(dist_base, method = "ward.D2")
hclust_induc <- hclust(dist_induc, method = "ward.D2")

# Dendrogram
png("output/hclust_dendrogram_base.png", width = 1000, height = 600)
plot(hclust_base, main = "Hierarchical Clustering Dendrogram - Base",
     xlab = "", sub = "", cex = 0.7)
rect.hclust(hclust_base, k = optimal_k, border = 2:4)
dev.off()

png("output/hclust_dendrogram_induc.png", width = 1000, height = 600)
plot(hclust_induc, main = "Hierarchical Clustering Dendrogram - Induc",
     xlab = "", sub = "", cex = 0.7)
rect.hclust(hclust_induc, k = optimal_k, border = 2:4)
dev.off()

# Cut tree to get clusters
hclust_clusters_base <- cutree(hclust_base, k = optimal_k)
hclust_clusters_induc <- cutree(hclust_induc, k = optimal_k)

# Save results
data_imputed$hclust_cluster_base <- hclust_clusters_base
data_imputed$hclust_cluster_induc <- hclust_clusters_induc

# Scatter plot visualization
png("output/hclust_scatter_base.png", width = 800, height = 600)
fviz_cluster(list(data = cluster_data_base, cluster = hclust_clusters_base),
             geom = "point", ellipse.type = "convex",
             main = "Hierarchical Clustering - Base")
dev.off()

png("output/hclust_scatter_induc.png", width = 800, height = 600)
fviz_cluster(list(data = cluster_data_induc, cluster = hclust_clusters_induc),
             geom = "point", ellipse.type = "convex",
             main = "Hierarchical Clustering - Induc")
dev.off()

# ============================================================================
# SECTION 4: Gaussian Mixture Model (GMM) Clustering
# ============================================================================

cat("\n=== GMM Clustering ===\n")

# BIC for model selection
gmm_base <- Mclust(cluster_data_base, G = 1:10)
gmm_induc <- Mclust(cluster_data_induc, G = 1:10)

# BIC plot
png("output/gmm_bic_base.png", width = 800, height = 600)
plot(gmm_base, what = "BIC", main = "BIC - Base")
dev.off()

png("output/gmm_bic_induc.png", width = 800, height = 600)
plot(gmm_induc, what = "BIC", main = "BIC - Induc")
dev.off()

# Save results
data_imputed$gmm_cluster_base <- gmm_base$classification
data_imputed$gmm_cluster_induc <- gmm_induc$classification

# Scatter plot visualization
png("output/gmm_scatter_base.png", width = 800, height = 600)
plot(gmm_base, what = "classification", main = "GMM Clustering - Base")
dev.off()

png("output/gmm_scatter_induc.png", width = 800, height = 600)
plot(gmm_induc, what = "classification", main = "GMM Clustering - Induc")
dev.off()

# ============================================================================
# SECTION 5: DBSCAN Clustering
# ============================================================================

cat("\n=== DBSCAN Clustering ===\n")

# kNN distance plot for eps selection
knn_base <- kNNdist(cluster_data_base, k = 4)
knn_induc <- kNNdist(cluster_data_induc, k = 4)

png("output/dbscan_knn_base.png", width = 800, height = 600)
plot(sort(knn_base), type = "l", main = "k-NN Distance Plot - Base",
     xlab = "Points sorted by distance", ylab = "4-NN distance")
abline(h = 0.5, col = "red", lty = 2)
dev.off()

png("output/dbscan_knn_induc.png", width = 800, height = 600)
plot(sort(knn_induc), type = "l", main = "k-NN Distance Plot - Induc",
     xlab = "Points sorted by distance", ylab = "4-NN distance")
abline(h = 0.5, col = "red", lty = 2)
dev.off()

# DBSCAN clustering
dbscan_base <- dbscan(cluster_data_base, eps = 0.5, minPts = 5)
dbscan_induc <- dbscan(cluster_data_induc, eps = 0.5, minPts = 5)

# Save results
data_imputed$dbscan_cluster_base <- dbscan_base$cluster
data_imputed$dbscan_cluster_induc <- dbscan_induc$cluster

# Scatter plot visualization
png("output/dbscan_scatter_base.png", width = 800, height = 600)
fviz_cluster(list(data = cluster_data_base, cluster = dbscan_base$cluster),
             geom = "point", ellipse.type = "convex",
             main = "DBSCAN Clustering - Base")
dev.off()

png("output/dbscan_scatter_induc.png", width = 800, height = 600)
fviz_cluster(list(data = cluster_data_induc, cluster = dbscan_induc$cluster),
             geom = "point", ellipse.type = "convex",
             main = "DBSCAN Clustering - Induc")
dev.off()

# ============================================================================
# SECTION 6: Affinity Propagation Clustering
# ============================================================================

cat("\n=== Affinity Propagation Clustering ===\n")

# Affinity Propagation clustering
ap_base <- apcluster(negDistMat(r=2), cluster_data_base)
ap_induc <- apcluster(negDistMat(r=2), cluster_data_induc)

# Save results
data_imputed$ap_cluster_base <- ap_base@idx
data_imputed$ap_cluster_induc <- ap_induc@idx

# Scatter plot visualization
png("output/ap_scatter_base.png", width = 800, height = 600)
plot(ap_base, cluster_data_base, main = "Affinity Propagation - Base")
dev.off()

png("output/ap_scatter_induc.png", width = 800, height = 600)
plot(ap_induc, cluster_data_induc, main = "Affinity Propagation - Induc")
dev.off()

# ============================================================================
# SECTION 7: Create Alluvial Diagrams for Pattern Transitions
# ============================================================================

cat("\n=== Creating Pattern Transition Visualizations ===\n")

# Function to create alluvial diagram
create_alluvial_plot <- function(data, base_col, induc_col, title, filename) {
  # Prepare data for alluvial plot
  transition_data <- data %>%
    select(all_of(c(base_col, induc_col))) %>%
    rename(base = 1, induc = 2) %>%
    mutate(base = as.factor(base),
           induc = as.factor(induc)) %>%
    count(base, induc)
  
  # Create alluvial plot
  p <- ggplot(data %>% 
                mutate(base = as.factor(!!sym(base_col)),
                       induc = as.factor(!!sym(induc_col))),
              aes(axis1 = base, axis2 = induc)) +
    geom_alluvium(aes(fill = base), width = 1/12, alpha = 0.7) +
    geom_stratum(width = 1/12, fill = "white", color = "black") +
    geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 4) +
    scale_x_discrete(limits = c("base", "induc"),
                     labels = c("Baseline", "Induction"),
                     expand = c(0.15, 0.05)) +
    labs(title = title,
         subtitle = "Cluster transitions from baseline to induction",
         y = "Number of patients",
         fill = "Baseline Cluster") +
    theme_minimal() +
    theme(legend.position = "bottom",
          plot.title = element_text(size = 14, face = "bold"),
          axis.text.x = element_text(size = 12, face = "bold"))
  
  ggsave(filename, plot = p, width = 10, height = 8, dpi = 300)
  
  # Print transition summary
  cat("\n", title, "\n")
  cat("Transition patterns:\n")
  print(transition_data)
  
  return(p)
}

# Create alluvial diagrams for each clustering method
create_alluvial_plot(data_imputed, "kmeans_cluster_base", "kmeans_cluster_induc",
                     "K-means Clustering Transitions",
                     "output/alluvial_kmeans.png")

create_alluvial_plot(data_imputed, "hclust_cluster_base", "hclust_cluster_induc",
                     "Hierarchical Clustering Transitions",
                     "output/alluvial_hclust.png")

create_alluvial_plot(data_imputed, "gmm_cluster_base", "gmm_cluster_induc",
                     "GMM Clustering Transitions",
                     "output/alluvial_gmm.png")

create_alluvial_plot(data_imputed, "dbscan_cluster_base", "dbscan_cluster_induc",
                     "DBSCAN Clustering Transitions",
                     "output/alluvial_dbscan.png")

create_alluvial_plot(data_imputed, "ap_cluster_base", "ap_cluster_induc",
                     "Affinity Propagation Clustering Transitions",
                     "output/alluvial_ap.png")

# ============================================================================
# SECTION 8: Pattern-based Grouping and Analysis
# ============================================================================

cat("\n=== Pattern-based Grouping Analysis ===\n")

# Create pattern groups based on K-means (as example)
data_imputed <- data_imputed %>%
  mutate(
    kmeans_pattern = paste0(kmeans_cluster_base, "->", kmeans_cluster_induc),
    kmeans_stable = ifelse(kmeans_cluster_base == kmeans_cluster_induc, "Stable", "Changed")
  )

# Summary of patterns
pattern_summary <- data_imputed %>%
  group_by(kmeans_pattern) %>%
  summarise(
    n = n(),
    percentage = n() / nrow(data_imputed) * 100
  ) %>%
  arrange(desc(n))

cat("\nPattern combinations (K-means):\n")
print(pattern_summary)

# Create baseline characteristics table by pattern group
# Only include numeric and factor variables
baseline_vars <- c("Age", "Sex", "FC_base", "IBDQ_base")

# Create TableOne
tab1 <- CreateTableOne(vars = baseline_vars,
                       strata = "kmeans_pattern",
                       data = data_imputed,
                       test = TRUE)

cat("\nBaseline characteristics by cluster transition pattern:\n")
print(tab1, showAllLevels = TRUE)

# Save table
capture.output(print(tab1, showAllLevels = TRUE), 
               file = "output/baseline_table_kmeans.txt")

# ============================================================================
# SECTION 9: Logistic Regression Analysis
# ============================================================================

cat("\n=== Logistic Regression Analysis ===\n")

# Logistic regression for response outcome
if("Response" %in% names(data_imputed)) {
  # Model 1: Pattern as predictor
  model1 <- glm(Response ~ kmeans_pattern, 
                data = data_imputed, 
                family = binomial())
  
  cat("\nModel 1: Pattern as predictor\n")
  print(summary(model1))
  
  # Model 2: Pattern + baseline characteristics
  model2 <- glm(Response ~ kmeans_pattern + Age + Sex + FC_base + IBDQ_base,
                data = data_imputed,
                family = binomial())
  
  cat("\nModel 2: Pattern + baseline characteristics\n")
  print(summary(model2))
  
  # Save model summaries
  capture.output(summary(model1), file = "output/logistic_model1.txt")
  capture.output(summary(model2), file = "output/logistic_model2.txt")
  
  # Calculate odds ratios
  or1 <- exp(cbind(OR = coef(model1), confint(model1)))
  or2 <- exp(cbind(OR = coef(model2), confint(model2)))
  
  cat("\nOdds Ratios - Model 1:\n")
  print(or1)
  
  cat("\nOdds Ratios - Model 2:\n")
  print(or2)
  
  # Save odds ratios
  write.csv(or1, "output/odds_ratios_model1.csv")
  write.csv(or2, "output/odds_ratios_model2.csv")
}

# ============================================================================
# SECTION 10: Summary and Export
# ============================================================================

cat("\n=== Analysis Complete ===\n")
cat("Results saved to 'output' directory\n")
cat("- Elbow plots for K-means\n")
cat("- Dendrograms for hierarchical clustering\n")
cat("- BIC plots for GMM\n")
cat("- kNN distance plots for DBSCAN\n")
cat("- Scatter plots for all clustering methods\n")
cat("- Alluvial diagrams showing cluster transitions\n")
cat("- Baseline characteristics tables\n")
cat("- Logistic regression results\n")

# Save final dataset
write.csv(data_imputed, "output/data_with_clusters.csv", row.names = FALSE)
cat("\nFinal dataset saved: output/data_with_clusters.csv\n")

# Print session info
cat("\n=== Session Info ===\n")
sessionInfo()
