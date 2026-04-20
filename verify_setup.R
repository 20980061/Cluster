# ============================================================================
# Setup Verification Script
# ============================================================================
# Run this script to verify your R environment is properly configured
# before running the full clustering analysis
# ============================================================================

cat("================================================================================\n")
cat("CLUSTERING ANALYSIS SETUP VERIFICATION\n")
cat("================================================================================\n\n")

# ============================================================================
# 1. Check R Version
# ============================================================================

cat("1. Checking R version...\n")
r_version <- R.version.string
cat("   ", r_version, "\n")

if (as.numeric(R.version$major) >= 4) {
  cat("   ✓ R version is adequate (4.0 or higher)\n\n")
} else {
  cat("   ✗ Warning: R version is older than 4.0\n")
  cat("   Consider updating R for best compatibility\n\n")
}

# ============================================================================
# 2. Check Required Packages
# ============================================================================

cat("2. Checking required packages...\n")

required_packages <- c(
  "tidyverse",
  "cluster",
  "factoextra",
  "mclust",
  "dbscan",
  "apcluster",
  "ggalluvial",
  "tableone",
  "caret",
  "pROC",
  "gridExtra",
  "dendextend",
  "NbClust"
)

missing_packages <- c()
available_packages <- c()

for (pkg in required_packages) {
  if (requireNamespace(pkg, quietly = TRUE)) {
    available_packages <- c(available_packages, pkg)
  } else {
    missing_packages <- c(missing_packages, pkg)
  }
}

cat("   Available packages:", length(available_packages), "/", length(required_packages), "\n")

if (length(available_packages) > 0) {
  cat("   ✓ Installed:", paste(available_packages, collapse = ", "), "\n")
}

if (length(missing_packages) > 0) {
  cat("   ✗ Missing:", paste(missing_packages, collapse = ", "), "\n")
  cat("\n   Installing missing packages...\n")
  
  for (pkg in missing_packages) {
    cat("   Installing", pkg, "...\n")
    tryCatch({
      install.packages(pkg, repos = "https://cloud.r-project.org/", 
                      dependencies = TRUE, quiet = TRUE)
      cat("   ✓", pkg, "installed successfully\n")
    }, error = function(e) {
      cat("   ✗ Failed to install", pkg, ":", e$message, "\n")
    })
  }
} else {
  cat("   ✓ All required packages are installed\n")
}

cat("\n")

# ============================================================================
# 3. Load Packages
# ============================================================================

cat("3. Testing package loading...\n")

load_errors <- c()

for (pkg in required_packages) {
  tryCatch({
    suppressMessages(library(pkg, character.only = TRUE, quietly = TRUE))
  }, error = function(e) {
    load_errors <- c(load_errors, pkg)
  })
}

if (length(load_errors) == 0) {
  cat("   ✓ All packages loaded successfully\n\n")
} else {
  cat("   ✗ Failed to load:", paste(load_errors, collapse = ", "), "\n\n")
}

# ============================================================================
# 4. Check Working Directory
# ============================================================================

cat("4. Checking working directory...\n")
wd <- getwd()
cat("   Current directory:", wd, "\n")

# Check write permissions
test_file <- file.path(wd, ".test_write_permission.tmp")
can_write <- tryCatch({
  write("test", test_file)
  file.remove(test_file)
  TRUE
}, error = function(e) {
  FALSE
})

if (can_write) {
  cat("   ✓ Write permission: OK\n\n")
} else {
  cat("   ✗ Cannot write to current directory\n")
  cat("   You may need to change directory or check permissions\n\n")
}

# ============================================================================
# 5. Test Basic Functionality
# ============================================================================

cat("5. Testing basic clustering functionality...\n")

# Generate minimal test data
set.seed(42)
test_data <- data.frame(
  x = rnorm(50, mean = 0, sd = 1),
  y = rnorm(50, mean = 0, sd = 1)
)

# Test K-means
tryCatch({
  km <- kmeans(test_data, centers = 2, nstart = 10)
  cat("   ✓ K-means: Working\n")
}, error = function(e) {
  cat("   ✗ K-means: Failed\n")
})

# Test hierarchical clustering
tryCatch({
  hc <- hclust(dist(test_data), method = "ward.D2")
  cat("   ✓ Hierarchical clustering: Working\n")
}, error = function(e) {
  cat("   ✗ Hierarchical clustering: Failed\n")
})

# Test GMM
tryCatch({
  suppressMessages({
    gmm <- Mclust(test_data, G = 2)
  })
  cat("   ✓ GMM (mclust): Working\n")
}, error = function(e) {
  cat("   ✗ GMM (mclust): Failed\n")
})

# Test DBSCAN
tryCatch({
  db <- dbscan(test_data, eps = 0.5, minPts = 5)
  cat("   ✓ DBSCAN: Working\n")
}, error = function(e) {
  cat("   ✗ DBSCAN: Failed\n")
})

# Test Affinity Propagation
tryCatch({
  suppressMessages({
    ap <- apcluster(negDistMat(r = 2), test_data)
  })
  cat("   ✓ Affinity Propagation: Working\n")
}, error = function(e) {
  cat("   ✗ Affinity Propagation: Failed\n")
})

cat("\n")

# ============================================================================
# 6. Test Visualization
# ============================================================================

cat("6. Testing visualization capabilities...\n")

tryCatch({
  # Test ggplot2
  p <- ggplot(test_data, aes(x = x, y = y)) + geom_point()
  cat("   ✓ ggplot2: Working\n")
  
  # Test if we can save
  temp_plot <- tempfile(fileext = ".png")
  ggsave(temp_plot, plot = p, width = 4, height = 4)
  if (file.exists(temp_plot)) {
    file.remove(temp_plot)
    cat("   ✓ Plot saving: Working\n")
  }
}, error = function(e) {
  cat("   ✗ Visualization: Failed\n")
})

cat("\n")

# ============================================================================
# 7. Memory Check
# ============================================================================

cat("7. Checking system resources...\n")

# Try to detect available memory (platform-dependent)
if (.Platform$OS.type == "windows") {
  tryCatch({
    mem_limit <- memory.limit()
    cat("   Memory limit:", mem_limit, "MB\n")
  }, error = function(e) {
    cat("   Memory information not available\n")
  })
} else {
  cat("   Memory checking not available on this platform\n")
}

# Check object size handling
tryCatch({
  large_obj <- matrix(rnorm(1000000), ncol = 100)
  obj_size <- format(object.size(large_obj), units = "MB")
  cat("   ✓ Can handle large objects (test:", obj_size, ")\n")
  rm(large_obj)
  gc(verbose = FALSE)
}, error = function(e) {
  cat("   ✗ Memory allocation issues detected\n")
})

cat("\n")

# ============================================================================
# 8. Summary
# ============================================================================

cat("================================================================================\n")
cat("VERIFICATION SUMMARY\n")
cat("================================================================================\n\n")

all_good <- length(missing_packages) == 0 && 
            length(load_errors) == 0 && 
            can_write

if (all_good) {
  cat("✓ Your R environment is ready for clustering analysis!\n\n")
  cat("Next steps:\n")
  cat("1. Prepare your data or run 'generate_example_data.R'\n")
  cat("2. Run 'clustering_analysis.R'\n")
  cat("3. Check the output files\n\n")
} else {
  cat("⚠ Some issues were detected. Please review the output above.\n\n")
  
  if (length(missing_packages) > 0) {
    cat("Missing packages:\n")
    cat("  Run: install.packages(c('", paste(missing_packages, collapse = "', '"), "'))\n\n", sep = "")
  }
  
  if (length(load_errors) > 0) {
    cat("Package loading errors:\n")
    cat("  Try reinstalling: install.packages(c('", paste(load_errors, collapse = "', '"), "'))\n\n", sep = "")
  }
  
  if (!can_write) {
    cat("Write permission issue:\n")
    cat("  Change to a directory where you have write access\n")
    cat("  Use: setwd('/path/to/your/directory')\n\n")
  }
}

cat("For troubleshooting help, see TROUBLESHOOTING.md\n")
cat("For detailed documentation, see README.md\n\n")

# ============================================================================
# 9. Session Info
# ============================================================================

cat("================================================================================\n")
cat("SESSION INFORMATION\n")
cat("================================================================================\n\n")

print(sessionInfo())

cat("\n================================================================================\n")
cat("Verification complete!\n")
cat("================================================================================\n")

# Save verification report
report_file <- "verification_report.txt"
sink(report_file)
cat("Clustering Analysis Setup Verification Report\n")
cat("Generated:", date(), "\n\n")
cat("R Version:", r_version, "\n")
cat("Working Directory:", wd, "\n\n")
cat("Installed Packages:\n")
print(available_packages)
cat("\nMissing Packages:\n")
print(missing_packages)
cat("\nSession Info:\n")
print(sessionInfo())
sink()

cat("\nVerification report saved to:", report_file, "\n")
