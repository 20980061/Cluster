# Quick Start Guide / 快速开始指南

## English

### Step 1: Install R Packages
```r
source("setup_packages.R")
```

### Step 2: Prepare Your Data
Edit `clustering_analysis.R` (lines 32-48) to load your data:
```r
data_raw <- read.csv("your_data_file.csv")
```

Or use the sample data format in `sample_data.csv`

### Step 3: Run Analysis
```r
source("clustering_analysis.R")
```

### What You'll Get
- **Clustering Results**: 5 methods (K-means, Hierarchical, PAM, GMM, DBSCAN)
- **Visualizations**: Elbow plots, dendrograms, scatter plots, transition plots
- **Statistical Analysis**: Baseline comparison table, logistic regression
- **Complete Dataset**: All results saved in `data_with_clustering_results.csv`

---

## 中文

### 第一步：安装R包
```r
source("setup_packages.R")
```

### 第二步：准备数据
修改 `clustering_analysis.R` (第32-48行) 以加载您的数据：
```r
data_raw <- read.csv("your_data_file.csv")
```

或参考 `sample_data.csv` 的数据格式

### 第三步：运行分析
```r
source("clustering_analysis.R")
```

### 您将获得
- **聚类结果**: 5种方法（K-means、层次聚类、PAM、GMM、DBSCAN）
- **可视化图形**: 肘部图、树状图、散点图、转换图
- **统计分析**: 基线比较表、Logistic回归
- **完整数据集**: 所有结果保存在 `data_with_clustering_results.csv`

---

## Files / 文件说明

| File | Description / 描述 |
|------|-------------------|
| `clustering_analysis.R` | Main analysis script / 主分析脚本 |
| `setup_packages.R` | Package installation / 包安装脚本 |
| `sample_data.csv` | Sample data template / 示例数据模板 |
| `README.md` | Detailed documentation (English) / 详细文档（英文） |
| `使用指南.md` | User guide (Chinese) / 使用指南（中文） |

---

## Data Requirements / 数据要求

### Required columns / 必需列:
- `FC_base` - Baseline fecal calprotectin / 基线粪便钙卫蛋白
- `FC_induc` - Induction fecal calprotectin / 诱导期粪便钙卫蛋白
- `IBDQ_base` - Baseline IBDQ score / 基线IBDQ评分
- `IBDQ_induc` - Induction IBDQ score / 诱导期IBDQ评分

### Optional columns / 可选列 (for regression / 用于回归):
- `Age`, `Sex`, `BMI`, `Disease_Duration`, `Outcome`
