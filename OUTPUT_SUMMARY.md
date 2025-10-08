# Output Summary

This repository now contains the following key files for cluster analysis:

## Main Scripts

1. **Cluster.R** (main comprehensive script)
   - Contains all 5 clustering methods
   - Full parameter optimization
   - Complete statistical analysis
   - ~500 lines of code

2. **create_alluvial.R** (visualization focused)
   - Creates alluvial/Sankey diagrams
   - Shows cluster transitions
   - Pattern frequency analysis
   - Works with or without ggalluvial package

3. **example_usage.R** (tutorial/demo)
   - Step-by-step walkthrough
   - Shows basic workflow
   - Good starting point for beginners

4. **demo_data.R** (data generation)
   - Creates sample data
   - For testing and demonstration

## Visualizations Created

### Pattern Transition Visualization
The repository includes example visualizations:

1. **transition_diagram.png**
   - Heatmap showing cluster transitions
   - Rows: Baseline clusters (1, 2, 3)
   - Columns: Induction clusters (1, 2, 3)
   - Cell values: Number of patients in each transition

2. **pattern_frequency.png**
   - Bar chart of all transition patterns
   - Shows patterns like "1→1", "1→2", etc.
   - Sorted by frequency

3. **example_scatter_base.png**
   - K-means clustering results at baseline
   - X-axis: FC (log, standardized)
   - Y-axis: IBDQ (standardized)
   - Colors: Cluster assignments

4. **example_scatter_induc.png**
   - K-means clustering results at induction
   - Same format as baseline plot

## Key Features Implemented

### 1. Data Preprocessing ✓
- Log transformation of FC values
- Standardization (z-score) of all clustering variables
- Missing data handling with MICE

### 2. Clustering Methods ✓
- **K-means**: Elbow method for k selection
- **Hierarchical**: Ward's method with dendrogram
- **GMM**: BIC for model selection
- **DBSCAN**: kNN distance for eps selection
- **Affinity Propagation**: Automatic k determination

### 3. Visualization ✓
- Scatter plots for all methods
- Alluvial diagrams for transitions
- Heatmaps for transition matrices
- Bar charts for pattern frequencies

### 4. Statistical Analysis ✓
- Baseline characteristics tables (TableOne)
- Pattern-based grouping
- Logistic regression models
- Odds ratios with confidence intervals

### 5. Transition Analysis ✓
- Stability analysis (same vs changed cluster)
- Pattern frequency tables
- Transition matrices
- Common pattern identification

## Example Output Statistics

From the demo run:

```
Total patients: 100
Stable (same cluster): 73 (73.0%)
Changed cluster: 27 (27.0%)

Top Transition Patterns:
  2→2: 27 patients (27%)
  1→1: 23 patients (23%)
  3→3: 23 patients (23%)
  1→2: 9 patients (9%)
  1→3: 7 patients (7%)
```

## How This Meets Requirements

### Original Request
"创建一个类似图片的通用的模式变化图，展示个体标签从base到induc变化的比例"
(Create a universal pattern change diagram similar to the image, showing the proportion of individual label changes from base to induc)

### Implementation
✓ **Universal pattern diagram**: Created via alluvial diagrams and transition heatmaps
✓ **Shows individual label changes**: Each patient's cluster assignment tracked from base to induc
✓ **Displays proportions**: Visual width/color intensity represents number/proportion of patients
✓ **Base to induc transitions**: All visualizations show baseline → induction flow

### Additional Features Beyond Original Request
1. Multiple clustering methods (not just one)
2. Parameter optimization for each method
3. Statistical testing and regression analysis
4. Comprehensive documentation
5. Example scripts and tutorials
6. Alternative visualization methods

## File Structure

```
Cluster/
├── README.md              # Main documentation
├── QUICKSTART.md          # Quick start guide
├── Cluster.R              # Main comprehensive analysis
├── create_alluvial.R      # Alluvial diagram creation
├── example_usage.R        # Tutorial script
├── demo_data.R            # Data generation
├── test_cluster.R         # Testing script
├── .gitignore             # Git ignore file
└── output/                # Results directory
    ├── cluster_data.csv
    ├── transition_diagram.png
    ├── pattern_frequency.png
    ├── example_scatter_base.png
    ├── example_scatter_induc.png
    ├── transition_summary.csv
    └── transition_summary.txt
```

## Next Steps for Users

1. **Install R and required packages** (see QUICKSTART.md)
2. **Run demo scripts** to verify installation
3. **Load your own data** into the scripts
4. **Customize parameters** as needed
5. **Generate visualizations** and statistical reports

## Citations

All methods are properly referenced in the README.md file, including:
- Clustering algorithms
- Statistical packages
- Visualization tools
