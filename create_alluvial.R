#!/usr/bin/env Rscript
# ============================================================================
# Alluvial Diagram Example using ggplot2 and ggalluvial
# ============================================================================
# This script demonstrates how to create alluvial diagrams showing
# cluster transition patterns from baseline to induction
# ============================================================================

cat("Creating Alluvial Diagram Example...\n\n")

# Load required library
if(!require("ggplot2", quietly = TRUE)) {
  cat("ERROR: ggplot2 is required. Install with: install.packages('ggplot2')\n")
  quit(status = 1)
}

# Try to load ggalluvial, provide alternative if not available
has_ggalluvial <- require("ggalluvial", quietly = TRUE)

if(!has_ggalluvial) {
  cat("NOTE: ggalluvial package not found.\n")
  cat("For best results, install with: install.packages('ggalluvial')\n")
  cat("Creating alternative visualization...\n\n")
}

# Create or load demo data
if(file.exists("output/cluster_data.csv")) {
  data <- read.csv("output/cluster_data.csv")
  cat("Loaded existing cluster data\n")
} else {
  # Create demo data
  set.seed(123)
  n <- 100
  data <- data.frame(
    ID = 1:n,
    cluster_base = sample(1:3, n, replace = TRUE, prob = c(0.4, 0.35, 0.25)),
    cluster_induc = sample(1:3, n, replace = TRUE, prob = c(0.3, 0.4, 0.3))
  )
  # Add correlation
  for(i in 1:n) {
    if(runif(1) < 0.6) {
      data$cluster_induc[i] <- data$cluster_base[i]
    }
  }
  if(!dir.exists("output")) dir.create("output")
  write.csv(data, "output/cluster_data.csv", row.names = FALSE)
  cat("Created new demo cluster data\n")
}

# Create transition summary
data$base_factor <- as.factor(data$cluster_base)
data$induc_factor <- as.factor(data$cluster_induc)

transition_summary <- as.data.frame(table(
  Base = data$base_factor,
  Induc = data$induc_factor
))
names(transition_summary) <- c("Base", "Induc", "Freq")
transition_summary <- transition_summary[transition_summary$Freq > 0, ]

cat("\nTransition Summary:\n")
print(transition_summary)

# Calculate percentages
transition_summary$Percentage <- round(
  transition_summary$Freq / sum(transition_summary$Freq) * 100, 1
)

cat("\nTop Transition Patterns:\n")
top_patterns <- transition_summary[order(-transition_summary$Freq), ][1:min(5, nrow(transition_summary)), ]
print(top_patterns)

# Create visualization
if(has_ggalluvial) {
  cat("\n✓ Creating alluvial diagram with ggalluvial...\n")
  
  library(ggalluvial)
  
  # Create alluvial plot
  p <- ggplot(data,
              aes(axis1 = base_factor, axis2 = induc_factor)) +
    geom_alluvium(aes(fill = base_factor), width = 1/12, alpha = 0.7) +
    geom_stratum(width = 1/12, fill = "white", color = "black") +
    geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 5) +
    scale_x_discrete(limits = c("base_factor", "induc_factor"),
                     labels = c("Baseline Clusters", "Induction Clusters"),
                     expand = c(0.15, 0.05)) +
    scale_fill_brewer(palette = "Set2", name = "Baseline\nCluster") +
    labs(title = "Cluster Transitions from Baseline to Induction",
         subtitle = paste0("N = ", nrow(data), " patients"),
         y = "Number of patients") +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
      axis.text.x = element_text(size = 12, face = "bold"),
      axis.text.y = element_text(size = 10),
      legend.position = "right"
    )
  
  # Save plot
  ggsave("output/alluvial_diagram.png", plot = p, width = 10, height = 7, dpi = 300)
  cat("✓ Saved: output/alluvial_diagram.png\n")
  
} else {
  cat("\n✓ Creating alternative transition plot...\n")
  
  # Create a simple transition diagram using base R graphics
  png("output/transition_diagram.png", width = 1000, height = 700, res = 100)
  
  par(mar = c(5, 5, 4, 2) + 0.1)
  
  # Create a matrix for transitions
  trans_matrix <- table(data$cluster_base, data$cluster_induc)
  
  # Create a heatmap-style visualization
  image(1:ncol(trans_matrix), 1:nrow(trans_matrix), t(trans_matrix),
        col = colorRampPalette(c("white", "lightblue", "darkblue"))(20),
        xlab = "Induction Cluster", ylab = "Baseline Cluster",
        main = "Cluster Transitions from Baseline to Induction\n(Darker = More Patients)",
        axes = FALSE)
  
  axis(1, at = 1:ncol(trans_matrix), labels = colnames(trans_matrix))
  axis(2, at = 1:nrow(trans_matrix), labels = rownames(trans_matrix), las = 1)
  
  # Add text with counts
  for(i in 1:nrow(trans_matrix)) {
    for(j in 1:ncol(trans_matrix)) {
      if(trans_matrix[i, j] > 0) {
        text(j, i, trans_matrix[i, j], cex = 1.5, font = 2)
      }
    }
  }
  
  # Add grid
  abline(h = 0.5:(nrow(trans_matrix) + 0.5), col = "gray80", lwd = 0.5)
  abline(v = 0.5:(ncol(trans_matrix) + 0.5), col = "gray80", lwd = 0.5)
  
  dev.off()
  
  cat("✓ Saved: output/transition_diagram.png\n")
  cat("\nNOTE: For best visualization, install ggalluvial package:\n")
  cat("  install.packages('ggalluvial')\n")
}

# Create a bar plot showing pattern frequencies
png("output/pattern_frequency.png", width = 1000, height = 600, res = 100)

par(mar = c(8, 5, 4, 2) + 0.1)

transition_summary$Pattern <- paste0(transition_summary$Base, " → ", transition_summary$Induc)
barplot(transition_summary$Freq,
        names.arg = transition_summary$Pattern,
        las = 2,
        col = rainbow(nrow(transition_summary), alpha = 0.7),
        main = "Frequency of Cluster Transition Patterns",
        ylab = "Number of Patients",
        xlab = "")
mtext("Transition Pattern (Baseline → Induction)", side = 1, line = 6)
grid(nx = NA, ny = NULL, col = "gray80", lty = 1)

dev.off()

cat("✓ Saved: output/pattern_frequency.png\n")

# Save summary statistics
cat("\n=== Transition Statistics ===\n")
cat(sprintf("Total patients: %d\n", nrow(data)))
cat(sprintf("Stable (same cluster): %d (%.1f%%)\n",
            sum(data$cluster_base == data$cluster_induc),
            sum(data$cluster_base == data$cluster_induc) / nrow(data) * 100))
cat(sprintf("Changed cluster: %d (%.1f%%)\n",
            sum(data$cluster_base != data$cluster_induc),
            sum(data$cluster_base != data$cluster_induc) / nrow(data) * 100))

# Save all summaries to file
sink("output/transition_summary.txt")
cat("=== CLUSTER TRANSITION ANALYSIS ===\n\n")
cat(sprintf("Analysis Date: %s\n\n", Sys.Date()))

cat("Overall Statistics:\n")
cat(sprintf("  Total patients: %d\n", nrow(data)))
cat(sprintf("  Stable patients: %d (%.1f%%)\n",
            sum(data$cluster_base == data$cluster_induc),
            sum(data$cluster_base == data$cluster_induc) / nrow(data) * 100))
cat(sprintf("  Changed clusters: %d (%.1f%%)\n\n",
            sum(data$cluster_base != data$cluster_induc),
            sum(data$cluster_base != data$cluster_induc) / nrow(data) * 100))

cat("Transition Patterns:\n")
print(transition_summary[order(-transition_summary$Freq), ])

cat("\n\nTransition Matrix:\n")
print(table(Base = data$cluster_base, Induction = data$cluster_induc))

sink()

cat("\n✓ Saved: output/transition_summary.txt\n")

cat("\n=== Analysis Complete ===\n")
cat("Output files created in 'output/' directory:\n")
cat("  - cluster_data.csv: Raw cluster assignments\n")
cat("  - transition_summary.txt: Statistical summary\n")
cat("  - pattern_frequency.png: Bar plot of patterns\n")
if(has_ggalluvial) {
  cat("  - alluvial_diagram.png: Alluvial flow diagram\n")
} else {
  cat("  - transition_diagram.png: Transition heatmap\n")
}
cat("\n")
