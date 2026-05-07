#!/usr/bin/env Rscript
# ============================================================================
# Advanced Alluvial Diagram Creator
# ============================================================================
# This script creates publication-quality alluvial diagrams showing
# cluster label transitions from baseline to induction
# ============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  if(require("dplyr", quietly = TRUE)) {
    library(dplyr)
  }
})

# Check for ggalluvial
has_ggalluvial <- suppressPackageStartupMessages(
  require("ggalluvial", quietly = TRUE)
)

if(!has_ggalluvial) {
  cat("\n⚠ Warning: ggalluvial package not installed\n")
  cat("For best results, install with:\n")
  cat("  install.packages('ggalluvial')\n")
  cat("Creating alternative visualization instead...\n\n")
}

# ============================================================================
# Function: Create Alluvial Diagram
# ============================================================================

create_advanced_alluvial <- function(
  data,
  base_col,
  induc_col,
  title = "Cluster Transitions",
  subtitle = NULL,
  output_file = "alluvial_diagram.png",
  width = 12,
  height = 8,
  show_percentages = TRUE
) {
  
  cat(sprintf("Creating alluvial diagram: %s\n", title))
  
  # Ensure factors
  data[[base_col]] <- as.factor(data[[base_col]])
  data[[induc_col]] <- as.factor(data[[induc_col]])
  
  # Calculate statistics
  n_total <- nrow(data)
  n_stable <- sum(data[[base_col]] == data[[induc_col]])
  n_changed <- n_total - n_stable
  
  if(is.null(subtitle)) {
    subtitle <- sprintf(
      "N = %d | Stable: %d (%.1f%%) | Changed: %d (%.1f%%)",
      n_total, n_stable, n_stable/n_total*100, 
      n_changed, n_changed/n_total*100
    )
  }
  
  # Create transition frequency table
  if(require("dplyr", quietly = TRUE)) {
    trans_freq <- data %>%
      group_by(!!sym(base_col), !!sym(induc_col)) %>%
      summarise(n = n(), .groups = 'drop') %>%
      mutate(
        percentage = n / n_total * 100,
        pattern = paste0(!!sym(base_col), "→", !!sym(induc_col))
      )
  } else {
    # Alternative without dplyr
    trans_freq <- as.data.frame(table(data[[base_col]], data[[induc_col]]))
    names(trans_freq) <- c(base_col, induc_col, "n")
    trans_freq$percentage <- trans_freq$n / n_total * 100
    trans_freq$pattern <- paste0(trans_freq[[base_col]], "→", trans_freq[[induc_col]])
    trans_freq <- trans_freq[trans_freq$n > 0, ]
  }
  
  cat("\nTransition frequencies:\n")
  print(trans_freq[order(-trans_freq$n), ])
  
  if(has_ggalluvial) {
    # Create with ggalluvial
    suppressPackageStartupMessages(library(ggalluvial))
    
    p <- ggplot(data,
                aes(axis1 = !!sym(base_col), 
                    axis2 = !!sym(induc_col))) +
      geom_alluvium(aes(fill = !!sym(base_col)), 
                    width = 1/12, alpha = 0.7, 
                    curve_type = "quintic") +
      geom_stratum(width = 1/12, fill = "white", 
                   color = "black", size = 1) +
      geom_text(stat = "stratum", 
                aes(label = after_stat(stratum)), 
                size = 6, fontface = "bold") +
      scale_x_discrete(
        limits = c(base_col, induc_col),
        labels = c("Baseline", "Induction"),
        expand = c(0.15, 0.05)
      ) +
      scale_fill_brewer(
        palette = "Set2",
        name = "Baseline\nCluster"
      ) +
      labs(
        title = title,
        subtitle = subtitle,
        y = "Number of patients"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 12, hjust = 0.5, color = "gray40"),
        axis.title.x = element_blank(),
        axis.text.x = element_text(size = 14, face = "bold"),
        axis.text.y = element_text(size = 11),
        axis.title.y = element_text(size = 13, face = "bold"),
        legend.position = "right",
        legend.title = element_text(size = 12, face = "bold"),
        legend.text = element_text(size = 11),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      )
    
    ggsave(output_file, plot = p, width = width, height = height, dpi = 300)
    
  } else {
    # Create alternative with base R
    png(output_file, width = width*100, height = height*100, res = 100)
    
    # Create transition matrix
    trans_matrix <- table(data[[base_col]], data[[induc_col]])
    
    # Set up colors
    max_val <- max(trans_matrix)
    colors <- colorRampPalette(c("white", "lightblue", "darkblue"))(max_val + 1)
    
    par(mar = c(6, 6, 6, 3))
    
    # Create heatmap
    image(1:ncol(trans_matrix), 1:nrow(trans_matrix), t(trans_matrix),
          col = colors,
          xlab = "", ylab = "",
          main = paste0(title, "\n", subtitle),
          axes = FALSE,
          cex.main = 1.3)
    
    # Add axes
    axis(1, at = 1:ncol(trans_matrix), 
         labels = paste("Cluster", colnames(trans_matrix)),
         cex.axis = 1.2, font = 2)
    axis(2, at = 1:nrow(trans_matrix), 
         labels = paste("Cluster", rownames(trans_matrix)),
         las = 1, cex.axis = 1.2, font = 2)
    
    mtext("Induction", side = 1, line = 4, cex = 1.3, font = 2)
    mtext("Baseline", side = 2, line = 4, cex = 1.3, font = 2)
    
    # Add values
    for(i in 1:nrow(trans_matrix)) {
      for(j in 1:ncol(trans_matrix)) {
        val <- trans_matrix[i, j]
        if(val > 0) {
          pct <- sprintf("%.1f%%", val/n_total*100)
          text(j, i, paste0(val, "\n(", pct, ")"), 
               cex = 1.2, font = 2,
               col = if(val > max_val/2) "white" else "black")
        }
      }
    }
    
    # Add grid
    abline(h = 0.5:(nrow(trans_matrix) + 0.5), col = "gray30", lwd = 1)
    abline(v = 0.5:(ncol(trans_matrix) + 0.5), col = "gray30", lwd = 1)
    
    dev.off()
  }
  
  cat(sprintf("✓ Saved: %s\n", output_file))
  
  # Return statistics
  return(list(
    n_total = n_total,
    n_stable = n_stable,
    n_changed = n_changed,
    pct_stable = n_stable/n_total*100,
    pct_changed = n_changed/n_total*100,
    transitions = trans_freq
  ))
}

# ============================================================================
# Function: Create Multiple Diagrams
# ============================================================================

create_all_alluvial_diagrams <- function(data, methods = NULL) {
  
  if(is.null(methods)) {
    # Auto-detect clustering method columns
    methods <- list(
      kmeans = c("kmeans_cluster_base", "kmeans_cluster_induc"),
      hclust = c("hclust_cluster_base", "hclust_cluster_induc"),
      gmm = c("gmm_cluster_base", "gmm_cluster_induc"),
      dbscan = c("dbscan_cluster_base", "dbscan_cluster_induc"),
      ap = c("ap_cluster_base", "ap_cluster_induc")
    )
  }
  
  if(!dir.exists("output")) dir.create("output")
  
  results <- list()
  
  for(method_name in names(methods)) {
    cols <- methods[[method_name]]
    
    if(all(cols %in% names(data))) {
      cat(sprintf("\n=== %s ===\n", toupper(method_name)))
      
      results[[method_name]] <- create_advanced_alluvial(
        data = data,
        base_col = cols[1],
        induc_col = cols[2],
        title = sprintf("%s Clustering Transitions", 
                       toupper(method_name)),
        output_file = sprintf("output/alluvial_%s.png", method_name)
      )
    } else {
      cat(sprintf("⚠ Skipping %s (columns not found)\n", method_name))
    }
  }
  
  return(results)
}

# ============================================================================
# Main Execution
# ============================================================================

if(!interactive()) {
  cat("\n=== Advanced Alluvial Diagram Creator ===\n\n")
  
  # Check for input data
  if(file.exists("output/data_with_clusters.csv")) {
    cat("Loading data from output/data_with_clusters.csv\n")
    data <- read.csv("output/data_with_clusters.csv")
    
  } else if(file.exists("output/example_data_with_clusters.csv")) {
    cat("Loading data from output/example_data_with_clusters.csv\n")
    data <- read.csv("output/example_data_with_clusters.csv")
    
  } else if(file.exists("output/cluster_data.csv")) {
    cat("Loading data from output/cluster_data.csv\n")
    data <- read.csv("output/cluster_data.csv")
    
  } else {
    # Create demo data
    cat("No existing data found. Creating demo data...\n")
    set.seed(123)
    n <- 100
    
    data <- data.frame(
      ID = 1:n,
      cluster_base = sample(1:3, n, replace = TRUE),
      cluster_induc = sample(1:3, n, replace = TRUE)
    )
    
    # Add some correlation
    for(i in 1:n) {
      if(runif(1) < 0.6) {
        data$cluster_induc[i] <- data$cluster_base[i]
      }
    }
  }
  
  cat(sprintf("Data loaded: %d rows, %d columns\n", nrow(data), ncol(data)))
  cat("Columns:", paste(names(data), collapse = ", "), "\n\n")
  
  # Create diagrams based on available columns
  if(all(c("cluster_base", "cluster_induc") %in% names(data))) {
    stats <- create_advanced_alluvial(
      data = data,
      base_col = "cluster_base",
      induc_col = "cluster_induc",
      title = "Cluster Transitions from Baseline to Induction",
      output_file = "output/alluvial_transitions.png"
    )
    
    cat("\n=== Summary Statistics ===\n")
    cat(sprintf("Total patients: %d\n", stats$n_total))
    cat(sprintf("Stable: %d (%.1f%%)\n", stats$n_stable, stats$pct_stable))
    cat(sprintf("Changed: %d (%.1f%%)\n", stats$n_changed, stats$pct_changed))
    
  } else {
    # Try to create for all available method pairs
    results <- create_all_alluvial_diagrams(data)
    
    if(length(results) > 0) {
      cat("\n=== Summary Across All Methods ===\n")
      for(method in names(results)) {
        cat(sprintf("\n%s:\n", toupper(method)))
        cat(sprintf("  Stable: %.1f%%\n", results[[method]]$pct_stable))
        cat(sprintf("  Changed: %.1f%%\n", results[[method]]$pct_changed))
      }
    }
  }
  
  cat("\n=== Complete ===\n")
}
