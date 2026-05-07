# Clustering Methods Comparison / 聚类方法比较

## Summary Table / 对比表格

| Method<br>方法 | Parameter Selection<br>参数选择 | Strengths<br>优点 | Limitations<br>局限性 | Best For<br>最适用于 |
|---------------|-------------------------------|-------------------|---------------------|---------------------|
| **K-means** | Elbow method (WSS)<br>肘部法则(WSS) | Fast, simple, scalable<br>快速、简单、可扩展 | Assumes spherical clusters, sensitive to outliers<br>假设球形聚类，对异常值敏感 | Large datasets with spherical clusters<br>具有球形聚类的大数据集 |
| **Hierarchical** | Silhouette analysis<br>轮廓系数分析 | No need to specify k initially, produces dendrogram<br>无需预先指定k值，生成树状图 | Computationally expensive, sensitive to noise<br>计算开销大，对噪声敏感 | Exploratory analysis, visualizing relationships<br>探索性分析、可视化关系 |
| **PAM** | Silhouette analysis<br>轮廓系数分析 | Robust to outliers, uses actual data points as centers<br>对异常值稳健，使用实际数据点作为中心 | Slower than K-means, not scalable to very large datasets<br>比K-means慢，不适用于超大数据集 | Small to medium datasets with outliers<br>有异常值的中小型数据集 |
| **GMM** | BIC criterion<br>BIC准则 | Probabilistic approach, handles elliptical clusters<br>概率方法，可处理椭圆形聚类 | Assumes Gaussian distribution, can overfit<br>假设高斯分布，可能过拟合 | Data with probabilistic nature, overlapping clusters<br>具有概率性质的数据，重叠聚类 |
| **DBSCAN** | k-NN distance plot<br>k-NN距离图 | Finds arbitrary shapes, identifies noise points<br>发现任意形状，识别噪声点 | Struggles with varying densities, requires careful parameter tuning<br>难以处理不同密度，需要仔细调参 | Spatial data, datasets with noise and arbitrary shapes<br>空间数据，有噪声和任意形状的数据集 |

---

## Detailed Comparison / 详细比较

### 1. K-means Clustering

**Algorithm / 算法**: 
- Iteratively assigns points to nearest centroid and updates centroids
- 迭代地将点分配到最近的质心并更新质心

**When to Use / 何时使用**:
- ✓ Large datasets (n > 1000) / 大数据集
- ✓ Expected spherical/circular clusters / 预期球形/圆形聚类
- ✓ Need fast computation / 需要快速计算
- ✗ Many outliers present / 存在许多异常值
- ✗ Clusters of very different sizes / 聚类大小差异很大

**Parameter Selection / 参数选择**:
- **Elbow Method**: Plot WSS vs k, find "elbow" point
- **肘部法则**: 绘制WSS vs k，找到"肘部"点
- Typical k range: 2-10
- 典型k范围：2-10

**Interpretation Tips / 解读提示**:
- Sharp elbow indicates clear optimal k / 明显的肘部表示清晰的最优k
- Gradual decline suggests no clear cluster structure / 逐渐下降表示无明确聚类结构

---

### 2. Hierarchical Clustering / 层次聚类

**Algorithm / 算法**: 
- Bottom-up approach: starts with each point as cluster, merges similar ones
- 自下而上方法：从每个点作为聚类开始，合并相似的聚类

**When to Use / 何时使用**:
- ✓ Want to see hierarchical relationships / 想查看层次关系
- ✓ Unknown number of clusters / 未知聚类数
- ✓ Small to medium datasets (n < 1000) / 中小型数据集
- ✗ Very large datasets / 非常大的数据集
- ✗ Need fast computation / 需要快速计算

**Parameter Selection / 参数选择**:
- **Dendrogram**: Visual inspection of tree structure
- **树状图**: 树结构的视觉检查
- **Silhouette Analysis**: Measures cluster quality
- **轮廓分析**: 衡量聚类质量

**Interpretation Tips / 解读提示**:
- Height in dendrogram = dissimilarity / 树状图中的高度 = 差异性
- Cut at different heights to get different k / 在不同高度切割以获得不同的k
- Higher silhouette score (closer to 1) = better clustering / 更高的轮廓分数（接近1）= 更好的聚类

---

### 3. PAM (Partitioning Around Medoids)

**Algorithm / 算法**: 
- Similar to K-means but uses actual data points (medoids) as centers
- 类似K-means但使用实际数据点（medoids）作为中心

**When to Use / 何时使用**:
- ✓ Presence of outliers / 存在异常值
- ✓ Need interpretable cluster centers / 需要可解释的聚类中心
- ✓ Non-Euclidean distance metrics / 非欧几里得距离度量
- ✗ Very large datasets (n > 5000) / 非常大的数据集
- ✗ Need fastest possible algorithm / 需要最快的算法

**Parameter Selection / 参数选择**:
- **Silhouette Analysis**: Same as hierarchical clustering
- **轮廓分析**: 与层次聚类相同
- Choose k with highest average silhouette width
- 选择平均轮廓宽度最高的k

**Interpretation Tips / 解读提示**:
- Medoids are actual data points, easier to interpret / Medoids是实际数据点，更易解释
- Silhouette width > 0.5: reasonable structure / 轮廓宽度 > 0.5：合理结构
- Silhouette width < 0.25: weak structure / 轮廓宽度 < 0.25：弱结构

---

### 4. Gaussian Mixture Model (GMM) / 高斯混合模型

**Algorithm / 算法**: 
- Assumes data comes from mixture of Gaussian distributions
- 假设数据来自高斯分布的混合

**When to Use / 何时使用**:
- ✓ Clusters have different shapes/sizes / 聚类有不同形状/大小
- ✓ Need probabilistic cluster assignments / 需要概率性聚类分配
- ✓ Overlapping clusters / 重叠聚类
- ✗ Data clearly non-Gaussian / 数据明显非高斯分布
- ✗ Very small sample size / 样本量非常小

**Parameter Selection / 参数选择**:
- **BIC (Bayesian Information Criterion)**: Balances fit and complexity
- **BIC（贝叶斯信息准则）**: 平衡拟合度和复杂性
- Higher BIC = better model / 更高的BIC = 更好的模型
- Also consider AIC as alternative / 也可考虑AIC作为替代

**Interpretation Tips / 解读提示**:
- Each point has probability of belonging to each cluster / 每个点属于每个聚类都有概率
- Can handle elliptical clusters / 可以处理椭圆形聚类
- Soft clustering vs hard clustering / 软聚类 vs 硬聚类

---

### 5. DBSCAN (Density-Based Spatial Clustering)

**Algorithm / 算法**: 
- Groups points that are closely packed, marks outliers as noise
- 将紧密聚集的点分组，将异常值标记为噪声

**When to Use / 何时使用**:
- ✓ Arbitrary cluster shapes / 任意聚类形状
- ✓ Need to identify outliers/noise / 需要识别异常值/噪声
- ✓ Spatial/geographic data / 空间/地理数据
- ✗ Clusters of varying densities / 密度变化的聚类
- ✗ High-dimensional data / 高维数据

**Parameter Selection / 参数选择**:
- **eps (epsilon)**: Maximum distance between two points in same cluster
- **eps (epsilon)**: 同一聚类中两点之间的最大距离
- **minPts**: Minimum points to form dense region
- **minPts**: 形成密集区域的最小点数
- Use k-NN distance plot to find "knee" for eps
- 使用k-NN距离图找到eps的"拐点"

**Interpretation Tips / 解读提示**:
- Cluster 0 = noise points / 聚类0 = 噪声点
- Can find non-convex clusters / 可以找到非凸聚类
- eps too small: many small clusters / eps太小：许多小聚类
- eps too large: all points in one cluster / eps太大：所有点在一个聚类中

---

## Choosing the Right Method / 选择正确的方法

### Decision Tree / 决策树

```
Do you have outliers/noise in your data?
数据中是否有异常值/噪声？
│
├─ Yes → Consider PAM or DBSCAN
│        考虑PAM或DBSCAN
│
└─ No → Do you know the number of clusters?
        是否知道聚类数？
        │
        ├─ Yes → Use K-means (fast) or PAM (robust)
        │        使用K-means（快速）或PAM（稳健）
        │
        └─ No → Do you need hierarchical relationships?
                是否需要层次关系？
                │
                ├─ Yes → Use Hierarchical Clustering
                │        使用层次聚类
                │
                └─ No → Are clusters likely non-spherical?
                        聚类可能是非球形的吗？
                        │
                        ├─ Yes → Use GMM or DBSCAN
                        │        使用GMM或DBSCAN
                        │
                        └─ No → Use K-means or PAM
                                使用K-means或PAM
```

---

## Recommendations for This Analysis / 本分析的建议

Given that we have:
鉴于我们有：

- 2 continuous variables (FC_log and IBDQ) / 2个连续变量
- Medical data (may have outliers) / 医学数据（可能有异常值）
- Need to track changes over time / 需要追踪随时间的变化
- Want interpretable results / 需要可解释的结果

### Primary Methods / 主要方法:
1. **K-means**: Quick baseline, good for initial exploration
   K-means：快速基线，适合初步探索

2. **PAM**: More robust to outliers in medical data
   PAM：对医学数据中的异常值更稳健

3. **Hierarchical**: Helps understand cluster relationships
   层次聚类：帮助理解聚类关系

### Secondary Methods / 辅助方法:
4. **GMM**: Check if clusters have different shapes
   GMM：检查聚类是否有不同形状

5. **DBSCAN**: Identify potential outliers/noise
   DBSCAN：识别潜在异常值/噪声

---

## Consensus Clustering / 共识聚类

**Best Practice / 最佳实践**: 
Compare results across methods. If multiple methods agree on cluster structure, this increases confidence in results.
比较各方法的结果。如果多种方法对聚类结构达成一致，这会增加对结果的信心。

**Look for / 寻找**:
- Consistent number of clusters across methods / 各方法间一致的聚类数
- Similar cluster assignments (check correlation) / 相似的聚类分配（检查相关性）
- Stable patterns across different parameter choices / 不同参数选择下稳定的模式

---

## Validation / 验证

### Internal Validation / 内部验证:
- Silhouette coefficient / 轮廓系数
- Within-cluster sum of squares / 簇内平方和
- Between-cluster separation / 簇间分离度

### External Validation / 外部验证:
- Clinical meaningfulness / 临床意义
- Association with outcomes / 与结局的关联
- Stability across subsamples / 子样本间的稳定性

---

## Further Reading / 延伸阅读

### English Resources:
- "Introduction to Statistical Learning" - Chapter 10 (Clustering)
- Scikit-learn documentation on clustering
- "Elements of Statistical Learning" - Chapter 14

### Chinese Resources / 中文资源:
- 《统计学习方法》- 李航
- 《机器学习》- 周志华（西瓜书）
- R语言实战（第二版）- 聚类分析章节
