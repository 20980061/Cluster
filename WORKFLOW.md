# Workflow Overview / 工作流程概览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         CLUSTERING ANALYSIS WORKFLOW                     │
│                            聚类分析工作流程                              │
└─────────────────────────────────────────────────────────────────────────┘

STEP 1: SETUP / 设置
═══════════════════════════════════════════════════════════════════════════
    
    📦 setup_packages.R
    │
    ├─→ Install tidyverse
    ├─→ Install cluster
    ├─→ Install factoextra
    ├─→ Install mclust
    ├─→ Install dbscan
    ├─→ Install ggplot2
    ├─→ Install gridExtra
    └─→ Install tableone
    
    Output: ✓ All packages installed
    输出：✓ 所有包已安装


STEP 2: DATA PREPARATION / 数据准备
═══════════════════════════════════════════════════════════════════════════
    
    📊 Your Data (CSV/Excel/etc.)
    │
    ├─→ Required: FC_base, FC_induc, IBDQ_base, IBDQ_induc
    └─→ Optional: Age, Sex, BMI, Disease_Duration, Outcome
    
    ⚠️  validate_data.R
    │
    ├─→ Check required columns ✓
    ├─→ Check data types ✓
    ├─→ Check missing values ⚠
    ├─→ Check positive FC values ✓
    ├─→ Check outliers ⚠
    ├─→ Check sample size ✓
    ├─→ Check variance ✓
    └─→ Check optional variables ✓
    
    Output: Validation report
    输出：验证报告


STEP 3: CLUSTERING ANALYSIS / 聚类分析
═══════════════════════════════════════════════════════════════════════════
    
    🔬 clustering_analysis.R
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.1 DATA PREPROCESSING / 数据预处理                          │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Log transform FC values (FC_base_log, FC_induc_log)
    │   对数转换FC值
    │
    ├─→ Standardize variables (z-score)
    │   标准化变量
    │
    └─→ Create two datasets:
        创建两个数据集：
        • Cluster 1: FC_base_log + IBDQ_base
        • Cluster 2: FC_induc_log + IBDQ_induc
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.2 METHOD 1: K-MEANS / K均值聚类                            │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Calculate WSS for k=1 to 10
    │   计算k=1到10的WSS
    │
    ├─→ Create elbow plot
    │   创建肘部图
    │
    ├─→ Select optimal k (typically k=3)
    │   选择最优k值（通常k=3）
    │
    ├─→ Perform clustering
    │   执行聚类
    │
    └─→ Output: 
        • kmeans_elbow_*.png
        • kmeans_cluster*_scatter.png
        • kmeans_cluster1, kmeans_cluster2 (in data)
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.3 METHOD 2: HIERARCHICAL / 层次聚类                        │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Compute distance matrix
    │   计算距离矩阵
    │
    ├─→ Perform hierarchical clustering (Ward's method)
    │   执行层次聚类（Ward方法）
    │
    ├─→ Create dendrogram
    │   创建树状图
    │
    ├─→ Calculate silhouette scores
    │   计算轮廓分数
    │
    ├─→ Select optimal k
    │   选择最优k值
    │
    └─→ Output:
        • hierarchical_dendrogram_*.png
        • hierarchical_silhouette_*.png
        • hierarchical_cluster*_scatter.png
        • hc_cluster1, hc_cluster2 (in data)
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.4 METHOD 3: PAM / PAM聚类                                  │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Calculate silhouette scores for k=2 to 10
    │   计算k=2到10的轮廓分数
    │
    ├─→ Create silhouette plot
    │   创建轮廓图
    │
    ├─→ Select optimal k (highest silhouette)
    │   选择最优k值（最高轮廓分数）
    │
    ├─→ Perform PAM clustering
    │   执行PAM聚类
    │
    └─→ Output:
        • pam_silhouette_*.png
        • pam_cluster*_scatter.png
        • pam_cluster1, pam_cluster2 (in data)
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.5 METHOD 4: GMM / 高斯混合模型                             │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Fit GMM for k=1 to 10
    │   拟合k=1到10的GMM
    │
    ├─→ Calculate BIC scores
    │   计算BIC分数
    │
    ├─→ Create BIC plot
    │   创建BIC图
    │
    ├─→ Select optimal k (highest BIC)
    │   选择最优k值（最高BIC）
    │
    └─→ Output:
        • gmm_bic_*.png
        • gmm_cluster*_scatter.png
        • gmm_cluster1, gmm_cluster2 (in data)
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.6 METHOD 5: DBSCAN / DBSCAN聚类                            │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Calculate k-NN distances
    │   计算k-NN距离
    │
    ├─→ Create k-NN distance plot
    │   创建k-NN距离图
    │
    ├─→ Determine optimal eps (from elbow in plot)
    │   确定最优eps值（从图中的拐点）
    │
    ├─→ Set minPts = 4
    │   设置minPts = 4
    │
    ├─→ Perform DBSCAN clustering
    │   执行DBSCAN聚类
    │
    └─→ Output:
        • dbscan_knn_*.png
        • dbscan_cluster*_scatter.png
        • dbscan_cluster1, dbscan_cluster2 (in data)
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.7 PATTERN ANALYSIS / 模式分析                              │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Analyze transitions from base to induc
    │   分析从基线到诱导期的转换
    │   (e.g., 1→1, 1→2, 2→1, etc.)
    │
    ├─→ Create transition tables
    │   创建转换表
    │
    ├─→ Create transition plots
    │   创建转换图
    │
    ├─→ Group patterns:
    │   分组模式：
    │   • Stable_Low (1→1)
    │   • Improved (2→1, 3→1)
    │   • Worsened (1→2, 1→3)
    │   • Stable_High (3→3)
    │
    └─→ Output:
        • *_transitions.png (for each method)
        • pattern_group (in data)
    
    
    ┌─────────────────────────────────────────────────────────────┐
    │ 3.8 STATISTICAL ANALYSIS / 统计分析                          │
    └─────────────────────────────────────────────────────────────┘
    │
    ├─→ Baseline Characteristics Table
    │   基线特征表
    │   │
    │   ├─→ Compare by pattern_group
    │   │   按模式组比较
    │   │
    │   ├─→ Include: Age, Sex, BMI, etc.
    │   │   包括：年龄、性别、BMI等
    │   │
    │   └─→ Output: baseline_characteristics_table.csv
    │
    └─→ Logistic Regression
        Logistic回归
        │
        ├─→ Univariate: Outcome ~ pattern_group
        │   单因素：结局 ~ 模式组
        │
        ├─→ Multivariate: Outcome ~ pattern_group + covariates
        │   多因素：结局 ~ 模式组 + 协变量
        │
        ├─→ Calculate OR and 95% CI
        │   计算OR和95%CI
        │
        ├─→ Create forest plot
        │   创建森林图
        │
        └─→ Output:
            • logistic_regression_results.csv
            • forest_plot_pattern_groups.png


STEP 4: RESULTS / 结果
═══════════════════════════════════════════════════════════════════════════
    
    📊 Generated Files (约30个文件):
    
    Visualizations / 可视化 (~20 plots):
    ├─→ Parameter selection plots (10)
    ├─→ Clustering scatter plots (10)
    ├─→ Transition plots (5)
    ├─→ Forest plot (1)
    └─→ (Dendrograms included in parameter plots)
    
    Data Files / 数据文件 (3):
    ├─→ baseline_characteristics_table.csv
    ├─→ logistic_regression_results.csv
    └─→ data_with_clustering_results.csv
    
    Reports / 报告 (1):
    └─→ clustering_analysis_summary.txt


STEP 5: INTERPRETATION / 解释
═══════════════════════════════════════════════════════════════════════════
    
    📖 Read: OUTPUT_GUIDE.md
    阅读：OUTPUT_GUIDE.md
    │
    ├─→ How to interpret parameter selection plots
    │   如何解释参数选择图
    │
    ├─→ How to read clustering scatter plots
    │   如何阅读聚类散点图
    │
    ├─→ Understanding transition patterns
    │   理解转换模式
    │
    ├─→ Interpreting statistical results
    │   解释统计结果
    │
    └─→ Quality checks
        质量检查


═══════════════════════════════════════════════════════════════════════════
                               END OF WORKFLOW
                                工作流程结束
═══════════════════════════════════════════════════════════════════════════

TOTAL TIME: Approximately 5-15 minutes
总耗时：约5-15分钟

DEPENDENCIES: R >= 4.0, 8 R packages
依赖项：R >= 4.0，8个R包

OUTPUT SIZE: ~30 files, ~10-50 MB
输出大小：约30个文件，约10-50 MB

═══════════════════════════════════════════════════════════════════════════
```
