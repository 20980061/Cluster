#!/usr/bin/env Rscript

# Simple test to verify R works and create a basic visualization
cat("Creating demonstration visualization...\n")

# Create test data
set.seed(123)
n <- 100

# Simulate cluster transitions
data <- data.frame(
  ID = 1:n,
  cluster_base = sample(1:3, n, replace = TRUE, prob = c(0.4, 0.35, 0.25)),
  cluster_induc = sample(1:3, n, replace = TRUE, prob = c(0.3, 0.4, 0.3))
)

# Add some correlation between base and induc
for(i in 1:n) {
  if(runif(1) < 0.6) {  # 60% stay in same cluster
    data$cluster_induc[i] <- data$cluster_base[i]
  }
}

# Create output directory
if(!dir.exists("output")) {
  dir.create("output")
}

# Create transition summary
transition_table <- table(
  Base = data$cluster_base,
  Induction = data$cluster_induc
)

cat("\nCluster Transition Table:\n")
print(transition_table)

# Create transition summary data frame
transition_df <- as.data.frame.table(transition_table)
names(transition_df) <- c("Base", "Induction", "Count")
transition_df <- transition_df[transition_df$Count > 0, ]

cat("\nTransition Patterns:\n")
print(transition_df)

# Save data
write.csv(data, "output/cluster_data.csv", row.names = FALSE)
write.csv(transition_df, "output/transition_summary.csv", row.names = FALSE)

cat("\n✓ Data created successfully!\n")
cat("Files saved:\n")
cat("  - output/cluster_data.csv\n")
cat("  - output/transition_summary.csv\n")
cat("\nUse these files to create visualizations with ggalluvial package.\n")
