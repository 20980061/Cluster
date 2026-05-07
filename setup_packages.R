# ================================================================================
# Package Installation Script for Clustering Analysis
# ================================================================================
# This script installs all required packages for the clustering analysis
# Run this script before running clustering_analysis.R
# ================================================================================

# Install required packages
required_packages <- c(
  "tidyverse",   # Data manipulation and visualization
  "cluster",     # Clustering algorithms (PAM, Silhouette)
  "factoextra",  # Clustering visualization
  "mclust",      # Gaussian Mixture Models
  "dbscan",      # DBSCAN algorithm
  "ggplot2",     # Plotting (included in tidyverse but listed for clarity)
  "gridExtra",   # Arranging multiple plots
  "tableone"     # Creating baseline characteristics tables
)

# Check which packages are already installed
installed_packages <- installed.packages()[, "Package"]
packages_to_install <- setdiff(required_packages, installed_packages)

if (length(packages_to_install) > 0) {
  cat("Installing the following packages:\n")
  cat(paste(packages_to_install, collapse = ", "), "\n\n")
  
  # Install packages
  install.packages(packages_to_install, 
                   repos = "https://cloud.r-project.org/",
                   dependencies = TRUE,
                   Ncpus = 4)
  
  cat("\n=== Package Installation Complete ===\n")
} else {
  cat("All required packages are already installed.\n")
}

# Verify installation
cat("\nVerifying package installation...\n")
for (pkg in required_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("✓ %s installed successfully\n", pkg))
  } else {
    cat(sprintf("✗ %s installation failed\n", pkg))
  }
}

cat("\n=== Setup Complete ===\n")
cat("You can now run clustering_analysis.R\n")
