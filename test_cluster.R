# Quick test script to verify basic functionality
cat("Testing R environment and basic visualization...\n")

# Test package installation
test_packages <- c("ggplot2", "ggalluvial")

for(pkg in test_packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat("Installing", pkg, "...\n")
    install.packages(pkg, repos = "https://cloud.r-project.org/", dependencies = TRUE, quiet = FALSE, lib = Sys.getenv("R_LIBS_USER"))
    library(pkg, character.only = TRUE, lib.loc = Sys.getenv("R_LIBS_USER"))
  }
  cat("✓", pkg, "loaded successfully\n")
}

# Create simple test data
set.seed(123)
n <- 50
test_data <- data.frame(
  base = sample(1:3, n, replace = TRUE),
  induc = sample(1:3, n, replace = TRUE)
)

# Create simple alluvial plot
cat("\nCreating test alluvial diagram...\n")

library(ggplot2)
library(ggalluvial)

p <- ggplot(test_data, 
            aes(axis1 = as.factor(base), axis2 = as.factor(induc))) +
  geom_alluvium(aes(fill = as.factor(base)), width = 1/12, alpha = 0.7) +
  geom_stratum(width = 1/12, fill = "white", color = "black") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 4) +
  scale_x_discrete(limits = c("base", "induc"),
                   labels = c("Baseline", "Induction")) +
  labs(title = "Test Cluster Transitions",
       y = "Count",
       fill = "Baseline") +
  theme_minimal()

# Save plot
if(!dir.exists("output")) dir.create("output")
ggsave("output/test_alluvial.png", plot = p, width = 8, height = 6)

cat("✓ Test alluvial diagram created: output/test_alluvial.png\n")
cat("\nTest completed successfully!\n")
