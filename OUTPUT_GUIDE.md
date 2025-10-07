# Expected Output Guide / 预期输出指南

## Overview / 概述

After running `clustering_analysis.R`, you will get approximately 25-30 output files organized as follows:

运行 `clustering_analysis.R` 后，您将获得约25-30个输出文件，组织如下：

---

## 1. Parameter Selection Plots / 参数选择图

### K-means
- `kmeans_elbow_Cluster1_Base.png` - Shows WSS vs k to determine optimal k
- `kmeans_elbow_Cluster2_Induc.png`

**How to interpret / 如何解读**: Look for the "elbow" point where the curve starts to flatten
寻找曲线开始变平的"肘部"点

### Hierarchical Clustering / 层次聚类
- `hierarchical_dendrogram_Cluster1_Base.png` - Tree diagram showing hierarchical relationships
- `hierarchical_dendrogram_Cluster2_Induc.png`
- `hierarchical_silhouette_Cluster1_Base.png` - Silhouette scores for different k values
- `hierarchical_silhouette_Cluster2_Induc.png`

**How to interpret / 如何解读**: 
- Dendrogram: Height indicates dissimilarity between clusters / 高度表示聚类间的差异性
- Silhouette: Higher average silhouette width indicates better clustering / 更高的平均轮廓宽度表示更好的聚类

### PAM
- `pam_silhouette_Cluster1_Base.png`
- `pam_silhouette_Cluster2_Induc.png`

**How to interpret / 如何解读**: Select k with highest average silhouette width
选择平均轮廓宽度最高的k值

### GMM (Gaussian Mixture Model)
- `gmm_bic_Cluster1_Base.png` - BIC values for different number of components
- `gmm_bic_Cluster2_Induc.png`

**How to interpret / 如何解读**: Higher BIC indicates better model fit
更高的BIC值表示更好的模型拟合

### DBSCAN
- `dbscan_knn_Cluster1_Base.png` - k-NN distance plot to determine eps
- `dbscan_knn_Cluster2_Induc.png`

**How to interpret / 如何解读**: Look for the "knee" in the curve to set eps value
寻找曲线中的"拐点"以设置eps值

---

## 2. Clustering Result Plots / 聚类结果图

Each method produces 2 scatter plots (baseline and induction):
每种方法产生2个散点图（基线和诱导期）：

### K-means
- `kmeans_cluster1_scatter.png` - Shows FC_base_log vs IBDQ_base with cluster colors
- `kmeans_cluster2_scatter.png` - Shows FC_induc_log vs IBDQ_induc with cluster colors

### Hierarchical Clustering
- `hierarchical_cluster1_scatter.png`
- `hierarchical_cluster2_scatter.png`

### PAM
- `pam_cluster1_scatter.png`
- `pam_cluster2_scatter.png`

### GMM
- `gmm_cluster1_scatter.png`
- `gmm_cluster2_scatter.png`

### DBSCAN
- `dbscan_cluster1_scatter.png` - Cluster 0 represents noise points
- `dbscan_cluster2_scatter.png`

**How to interpret / 如何解读**: 
- Different colors represent different clusters / 不同颜色代表不同聚类
- Look for clear separation between clusters / 寻找聚类间的清晰分离
- Tight clusters indicate high within-cluster similarity / 紧密的聚类表示聚类内高相似性

---

## 3. Transition Analysis Plots / 转换分析图

Shows how patients move between clusters from baseline to induction:
显示患者如何从基线移动到诱导期的聚类：

- `k-means_transitions.png`
- `hierarchical_clustering_transitions.png`
- `pam_transitions.png`
- `gmm_transitions.png`
- `dbscan_transitions.png`

**How to interpret / 如何解读**: 
- Stacked bars show distribution at baseline and induction / 堆叠条显示基线和诱导期的分布
- Identifies common transition patterns / 识别常见的转换模式

---

## 4. Statistical Analysis Outputs / 统计分析输出

### Forest Plot / 森林图
- `forest_plot_pattern_groups.png` - Shows odds ratios for different pattern groups

**How to interpret / 如何解读**: 
- Points represent OR estimates / 点代表OR估计值
- Lines represent 95% confidence intervals / 线代表95%置信区间
- Crossing the vertical line at OR=1 indicates no significant association / 跨过OR=1的垂直线表示无显著关联

### Tables / 表格
- `baseline_characteristics_table.csv` - Comparison of baseline features by pattern group
  基线特征按模式组比较
  
- `logistic_regression_results.csv` - Regression results with OR and 95% CI
  回归结果与OR和95%CI

**Columns in logistic regression table / 回归表中的列**:
- Variable: Variable name / 变量名
- OR: Odds ratio / 比值比
- CI_lower: Lower 95% CI / 95%CI下限
- CI_upper: Upper 95% CI / 95%CI上限
- P_value: P-value / P值

### Complete Dataset / 完整数据集
- `data_with_clustering_results.csv` - Original data plus all clustering results
  原始数据加上所有聚类结果

**Additional columns / 附加列**:
- `FC_base_log`, `FC_induc_log` - Log-transformed FC values / 对数转换的FC值
- `kmeans_cluster1`, `kmeans_cluster2` - K-means cluster assignments / K-means聚类分配
- `hc_cluster1`, `hc_cluster2` - Hierarchical cluster assignments / 层次聚类分配
- `pam_cluster1`, `pam_cluster2` - PAM cluster assignments / PAM聚类分配
- `gmm_cluster1`, `gmm_cluster2` - GMM cluster assignments / GMM聚类分配
- `dbscan_cluster1`, `dbscan_cluster2` - DBSCAN cluster assignments / DBSCAN聚类分配
- `kmeans_pattern` - Transition pattern (e.g., "1->2") / 转换模式（如"1->2"）
- `pattern_group` - Grouped patterns (Stable_Low, Improved, etc.) / 分组模式

---

## 5. Summary Report / 摘要报告

- `clustering_analysis_summary.txt` - Text summary of the entire analysis
  整个分析的文本摘要

**Contents / 内容**:
- Dataset information / 数据集信息
- Clustering methods applied / 应用的聚类方法
- Optimal parameters for each method / 每种方法的最优参数
- Pattern group distribution / 模式组分布
- List of generated files / 生成的文件列表

---

## Example Interpretation Workflow / 示例解读工作流程

### Step 1: Check Parameter Selection / 步骤1：检查参数选择

1. Open elbow plot for K-means / 打开K-means的肘部图
2. Identify the "elbow" point (typically k=2-4) / 识别"肘部"点（通常k=2-4）
3. Verify this matches the k value in the summary / 验证这与摘要中的k值匹配

### Step 2: Review Clustering Results / 步骤2：审查聚类结果

1. Open scatter plots / 打开散点图
2. Check if clusters are well-separated / 检查聚类是否分离良好
3. Compare results across different methods / 比较不同方法的结果
4. Identify the most interpretable clustering / 识别最可解释的聚类

### Step 3: Analyze Transitions / 步骤3：分析转换

1. Open transition plots / 打开转换图
2. Identify common patterns (e.g., most patients in 1->1) / 识别常见模式
3. Check pattern group distribution in summary / 检查摘要中的模式组分布

### Step 4: Interpret Statistical Results / 步骤4：解释统计结果

1. Open baseline characteristics table / 打开基线特征表
2. Look for significant differences between pattern groups / 寻找模式组间的显著差异
3. Review logistic regression results / 审查logistic回归结果
4. Check forest plot for visual representation of ORs / 检查森林图以可视化OR

---

## Common Issues and Solutions / 常见问题和解决方案

### Issue 1: Too many or too few clusters
问题1：聚类太多或太少

**Solution / 解决方案**: Adjust `max_k` parameter in the script
调整脚本中的`max_k`参数

### Issue 2: DBSCAN finds only noise points
问题2：DBSCAN只找到噪声点

**Solution / 解决方案**: Decrease eps value or minPts value
减小eps值或minPts值

### Issue 3: Clusters not well separated
问题3：聚类分离不明显

**Solution / 解决方案**: 
- Consider using different clustering methods / 考虑使用不同的聚类方法
- Check if data preprocessing is appropriate / 检查数据预处理是否适当
- Variables might not have clear cluster structure / 变量可能没有明确的聚类结构

---

## Quality Checks / 质量检查

Before interpreting results, verify:
在解释结果前，验证：

✓ All plots generated successfully / 所有图形成功生成
✓ Cluster numbers are reasonable (typically 2-5) / 聚类数合理（通常2-5）
✓ No warnings or errors in summary report / 摘要报告中无警告或错误
✓ Cluster assignments saved in final dataset / 聚类分配已保存到最终数据集
✓ Statistical analyses completed / 统计分析已完成
