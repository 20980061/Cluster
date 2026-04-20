# Technical Documentation

## Methodology Overview

This document provides technical details about the clustering analysis implementation.

## Data Preprocessing

### 1. Log Transformation

Fecal Calprotectin (FC) values are log-transformed to:
- Reduce skewness in the distribution
- Stabilize variance
- Make the data more normally distributed

```r
FC_base_log = log(FC_base + 0.1)
FC_induc_log = log(FC_induc + 0.1)
```

A small constant (0.1) is added to handle zero values.

### 2. Standardization

All clustering variables are standardized (z-score normalization):

```r
z = (x - mean(x)) / sd(x)
```

This ensures:
- Variables are on the same scale
- No variable dominates due to scale differences
- Each variable contributes equally to distance calculations

### 3. Missing Value Imputation

Missing values are imputed using mean imputation:
- Simple and fast
- Preserves variable means
- Conservative approach

Alternative methods can be implemented (median, k-NN, MICE).

## Clustering Methods

### 1. K-means Clustering

**Algorithm**: Partitioning method that minimizes within-cluster variance

**Steps**:
1. Initialize k cluster centers
2. Assign each point to nearest center
3. Update centers as mean of assigned points
4. Repeat until convergence

**Parameter Selection**:
- **Elbow Method**: Plot total within-cluster sum of squares (WSS) vs. k
  - Look for "elbow" where WSS decrease slows
  - Formula: `WSS = Σ Σ ||x - μ_i||²` where μ_i is cluster i center
  
- **Silhouette Analysis**: Measure cluster separation quality
  - Silhouette score: `s(i) = (b(i) - a(i)) / max(a(i), b(i))`
  - a(i): mean distance to points in same cluster
  - b(i): mean distance to points in nearest cluster
  - Range: [-1, 1], higher is better

**Advantages**:
- Fast and scalable
- Simple to understand
- Works well with spherical clusters

**Limitations**:
- Requires pre-specifying k
- Sensitive to outliers
- Assumes spherical clusters

### 2. Hierarchical Clustering

**Algorithm**: Creates tree of clusters (dendrogram)

**Steps**:
1. Start with each point as a cluster
2. Merge closest clusters
3. Repeat until one cluster remains
4. Cut tree at desired height/number of clusters

**Linkage Method**: Ward's method (ward.D2)
- Minimizes total within-cluster variance
- Tends to create compact, evenly-sized clusters
- Formula: Merge clusters that minimize increase in WSS

**Parameter Selection**:
- **Dendrogram**: Visual inspection of tree structure
  - Look for natural breaks in the tree
  - Height represents dissimilarity
  
- **Silhouette Analysis**: Same as K-means
  - Test different cut heights
  - Select k with maximum average silhouette

**Advantages**:
- No need to specify k upfront
- Provides hierarchical structure
- Deterministic (no random initialization)

**Limitations**:
- Computationally expensive for large datasets (O(n²))
- Cannot undo merges
- Sensitive to noise and outliers

### 3. Gaussian Mixture Model (GMM)

**Algorithm**: Probabilistic model assuming data from mixture of Gaussians

**Model**:
```
P(x) = Σ π_k * N(x | μ_k, Σ_k)
```
- π_k: mixing proportion for component k
- μ_k: mean of component k
- Σ_k: covariance matrix of component k

**Estimation**: Expectation-Maximization (EM) algorithm
1. **E-step**: Calculate probability each point belongs to each component
2. **M-step**: Update parameters to maximize likelihood
3. Repeat until convergence

**Parameter Selection**:
- **Bayesian Information Criterion (BIC)**:
  ```
  BIC = -2 * log(L) + p * log(n)
  ```
  - L: likelihood
  - p: number of parameters
  - n: number of observations
  - Higher BIC is better (note: some use negative BIC where lower is better)

- **Model Selection**: Tests different covariance structures
  - EII: Spherical, equal volume
  - VII: Spherical, unequal volume
  - EEI: Diagonal, equal volume and shape
  - VVI: Diagonal, varying volume and shape
  - EEE: Ellipsoidal, equal volume, shape, and orientation
  - VVV: Ellipsoidal, varying volume, shape, and orientation

**Advantages**:
- Soft clustering (probabilistic assignments)
- Can model elliptical clusters
- Principled statistical framework
- Automatic model selection via BIC

**Limitations**:
- Assumes Gaussian distributions
- Can get stuck in local optima
- Requires sufficient data

### 4. DBSCAN (Density-Based Spatial Clustering of Applications with Noise)

**Algorithm**: Groups points based on density

**Definitions**:
- **Core point**: Has at least minPts points within radius eps
- **Border point**: Not core but within eps of a core point
- **Noise point**: Neither core nor border

**Steps**:
1. Identify core points
2. Connect core points within eps distance
3. Assign border points to clusters
4. Mark remaining points as noise

**Parameters**:
- **eps (ε)**: Maximum distance between points in same cluster
- **minPts**: Minimum points to form dense region

**Parameter Selection**:
- **k-NN Distance Plot**:
  1. For each point, compute distance to k-th nearest neighbor
  2. Sort distances in ascending order
  3. Plot sorted distances
  4. Look for "knee" in curve
  5. eps = distance at knee
  6. Typically use k = minPts

**Advantages**:
- Can find arbitrarily shaped clusters
- Robust to outliers
- Doesn't require pre-specifying number of clusters
- Identifies noise points

**Limitations**:
- Struggles with varying density
- Sensitive to eps and minPts
- Not suitable for high-dimensional data

### 5. Affinity Propagation

**Algorithm**: Message-passing between data points

**Concepts**:
- **Exemplars**: Representative points for clusters
- **Similarity**: Negative squared Euclidean distance
- **Messages**: 
  - Responsibility r(i,k): How suited k is to be exemplar for i
  - Availability a(i,k): How appropriate for i to choose k as exemplar

**Steps**:
1. Initialize similarities
2. Iterate:
   - Update responsibilities: `r(i,k) = s(i,k) - max{a(i,k') + s(i,k')}`
   - Update availabilities: `a(i,k) = min(0, r(k,k) + Σ max(0, r(i',k)))`
3. Converge to exemplars
4. Assign points to exemplars

**Parameter Selection**:
- **Preference**: Self-similarity (diagonal of similarity matrix)
  - Higher preference → more clusters
  - Default: median of similarities
  - Automatic determination

**Advantages**:
- Automatically determines number of clusters
- No initialization required
- Can handle non-spherical clusters
- Considers all points as potential exemplars

**Limitations**:
- Computationally expensive (O(n²))
- Memory intensive
- Can be slow to converge
- Sensitive to preference parameter

## Pattern Analysis

### Transition Patterns

For each clustering method, we analyze how patients transition from baseline to induction:

1. **Transition Matrix**: Cross-tabulation of baseline vs. induction clusters
2. **Transition Proportions**: Row-wise percentages
3. **Common Patterns**: Most frequent transitions

### Pattern Groups

Patients are categorized into pattern groups:

- **Stable_Low**: Remain in low cluster at both timepoints
- **Stable_High**: Remain in high cluster at both timepoints
- **Improved**: Move to better cluster (lower FC/higher IBDQ)
- **Worsened**: Move to worse cluster (higher FC/lower IBDQ)
- **Other**: Other transitions

## Statistical Analysis

### Baseline Characteristics Table

Created using the `tableone` package:

**For continuous variables**:
- Normal distribution: Mean ± SD, tested with ANOVA
- Non-normal: Median [IQR], tested with Kruskal-Wallis

**For categorical variables**:
- n (%), tested with Chi-square or Fisher's exact test

**Missing values**: Reported in separate column

### Logistic Regression

**Model**: Binary logistic regression

```
logit(P(Y=1)) = β₀ + β₁*PatternGroup + ε
```

**Output**:
- Coefficients and standard errors
- p-values (Wald test)
- Odds ratios with 95% confidence intervals

**Interpretation**:
- OR > 1: Pattern group associated with higher response probability
- OR < 1: Pattern group associated with lower response probability
- 95% CI excludes 1: Statistically significant association

## Visualization

### Scatter Plots

- **X-axis**: FC_log (standardized)
- **Y-axis**: IBDQ (standardized)
- **Color**: Cluster assignment
- **Purpose**: Visual assessment of cluster separation

### Sankey Diagrams

Uses `ggalluvial` package to show:
- Flow from baseline (left) to induction (right)
- Width proportional to number of patients
- Color indicates baseline cluster

### Parameter Selection Plots

Visual aids for determining optimal parameters:
- Elbow plots for K-means
- Silhouette plots for K-means and Hierarchical
- BIC plots for GMM
- k-NN distance plots for DBSCAN

## Quality Metrics

### Internal Validation

**Silhouette Coefficient**:
- Measures cluster cohesion and separation
- Range: [-1, 1]
- Interpretation:
  - > 0.7: Strong structure
  - 0.5-0.7: Reasonable structure
  - 0.25-0.5: Weak structure
  - < 0.25: No substantial structure

**Within-Cluster Sum of Squares (WSS)**:
- Measures cluster compactness
- Lower is better
- Used in elbow method

**BIC (for GMM)**:
- Balances model fit and complexity
- Higher is better (in this implementation)
- Penalizes overfitting

### External Validation

**Association with Outcomes**:
- Logistic regression p-values
- Odds ratios for treatment response
- Clinical relevance of pattern groups

## Computational Complexity

| Method | Time Complexity | Space Complexity |
|--------|----------------|------------------|
| K-means | O(n·k·i·d) | O(n·d) |
| Hierarchical | O(n²·log n) | O(n²) |
| GMM | O(n·k·i·d²) | O(n·d) |
| DBSCAN | O(n·log n) | O(n) |
| Affinity Prop. | O(n²·i) | O(n²) |

Where:
- n: number of samples
- k: number of clusters
- i: number of iterations
- d: number of dimensions

## Assumptions and Limitations

### K-means
- **Assumes**: Spherical clusters, similar sizes
- **Limitations**: Sensitive to initialization, outliers

### Hierarchical
- **Assumes**: Hierarchical structure exists
- **Limitations**: Cannot correct early merges, expensive

### GMM
- **Assumes**: Gaussian distributions
- **Limitations**: Can overfit, local optima

### DBSCAN
- **Assumes**: Clusters have similar density
- **Limitations**: Struggles with varying density, high dimensions

### Affinity Propagation
- **Assumes**: Points can be exemplars
- **Limitations**: Expensive, sensitive to preferences

## Recommendations

1. **Run all methods**: Different methods may reveal different aspects
2. **Compare results**: Look for consensus across methods
3. **Visual inspection**: Always examine scatter plots
4. **Clinical validation**: Ensure clusters are clinically meaningful
5. **Sensitivity analysis**: Test different parameter values
6. **External validation**: Validate in independent cohort if possible

## References

1. MacQueen, J. (1967). "Some methods for classification and analysis of multivariate observations"
2. Ward, J. H. (1963). "Hierarchical grouping to optimize an objective function"
3. Fraley, C. & Raftery, A. E. (2002). "Model-based clustering, discriminant analysis, and density estimation"
4. Ester, M. et al. (1996). "A density-based algorithm for discovering clusters"
5. Frey, B. J. & Dueck, D. (2007). "Clustering by passing messages between data points"
