rm(list =ls())
gc()

set.seed(123)
n <- 100

# 生成类别
class <- sample(1:5, n, replace = TRUE)

# FC和IBDQ相关变量，按类别分层
FC_base <- rnorm(n, mean = class * 100, sd = 15)
FC_induc <- rnorm(n, mean = class * 100, sd = 15)
IBDQ_TOTAL_base <- rnorm(n, mean = 240 - class * 30, sd = 10)
IBDQ_TOTAL_induc <- rnorm(n, mean = 240 - class * 30, sd = 10)

IBDQ_BS_base <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_BS_induc <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_SS_base <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_SS_induc <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_EF_base <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_EF_induc <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_SF_base <- rnorm(n, mean = 60 - class * 5, sd = 5)
IBDQ_SF_induc <- rnorm(n, mean = 60 - class * 5, sd = 5)

# outcomes变量为0或1（可按class规律生成，也可随机）
outcomes_induc <- c("CR_induc", "CRS_induc", "EI_induc", "ER_induc", "HI_induc", "HR_induc")
outcomes_maint <- c("CR_maint", "EI_maint", "ER_maint", "HI_maint", "HR_maint")
for (var in outcomes_induc) assign(var, as.numeric(class > sample(1:5, n, replace = TRUE)))
for (var in outcomes_maint) assign(var, as.numeric(class > sample(1:5, n, replace = TRUE)))

# 其他变量同前
other_biomarkers <- c(
  "Basophils_base", "Eosinophils_base", "WBC_base", "HCT_base", "HB_base", "LY_base", "MO_base",
  "NEUT_base", "PLT_base", "Protein_base", "AST_base", "BUN_base", "CREA_base", "CRP_base", "MES_baseline",
  "Basophils_induc", "Eosinophils_induc", "WBC_induc", "HCT_induc", "HB_induc", "LY_induc", "MO_induc",
  "NEUT_induc", "PLT_induc", "Protein_induc", "AST_induc", "ALT_induc", "BUN_induc", "Bilirubin_induc", "MES_induc"
)
for (var in other_biomarkers) assign(var, rnorm(n, mean = 10, sd = 3))

Sex <- sample(c("M", "F"), n, replace = TRUE)
Age <- round(runif(n, 18, 80))
Smoking <- sample(c(0, 1), n, replace = TRUE)
Disease_duration <- round(runif(n, 0, 20), 1)
Immunomodulator <- sample(c(0, 1), n, replace = TRUE)
Corticosteroid <- sample(c(0, 1), n, replace = TRUE)
HR_ASA <- sample(c(0, 1), n, replace = TRUE)

data_test <- data.frame(
  FC_base, FC_induc, IBDQ_TOTAL_base, IBDQ_TOTAL_induc,
  IBDQ_BS_base, IBDQ_BS_induc, IBDQ_SS_base, IBDQ_SS_induc,
  IBDQ_EF_base, IBDQ_EF_induc, IBDQ_SF_base, IBDQ_SF_induc,
  CR_induc, CRS_induc, EI_induc, ER_induc, HI_induc, HR_induc,
  CR_maint, EI_maint, ER_maint, HI_maint, HR_maint,
  Basophils_base, Eosinophils_base, WBC_base, HCT_base, HB_base, LY_base, MO_base,
  NEUT_base, PLT_base, Protein_base, AST_base, BUN_base, CREA_base, CRP_base, MES_baseline,
  Basophils_induc, Eosinophils_induc, WBC_induc, HCT_induc, HB_induc, LY_induc, MO_induc,
  NEUT_induc, PLT_induc, Protein_induc, AST_induc, ALT_induc, BUN_induc, Bilirubin_induc, MES_induc,
  Sex, Age, Smoking, Disease_duration, Immunomodulator, Corticosteroid, HR_ASA,
  class = as.factor(class)
)

head(data_test)

options(repos = c(CRAN = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))
setwd("/workspaces/Cluster")


#====================1.数据准备====================
# 读取数据
# setwd("V:/huangpw/FC")
# load("V:/huangpw/RCT3.RData")
# data_test <- data_UNIFI
set.seed(123)

# 安装和加载必要包
required_packages <- c(
  "dplyr", "mice", "VIM",
  "ggplot2", "nnet", "reshape2", "psych", "tidyr", "car",
  "broom", "knitr", "purrr", "lcmm", "devtools", "LCTMtools","tidyLPA","tidySEM",
  "tableone",
  "RColorBrewer","gridExtra",
  "MASS","mclust", #GMM
  "factoextra"
)
#及时删除更新不必要的包

for(pkg in required_packages) {
  if(!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# 定义变量
biomarkers <- c("FC_base","FC_induc","IBDQ_TOTAL_base","IBDQ_TOTAL_induc",
                "IBDQ_BS_base","IBDQ_BS_induc","IBDQ_SS_base","IBDQ_SS_induc",
                "IBDQ_EF_base","IBDQ_EF_induc","IBDQ_SF_base","IBDQ_SF_induc")
outcomes_induc <- c("CR_induc","CRS_induc","EI_induc","ER_induc","HI_induc","HR_induc")
outcomes_maint <- c("CR_maint","EI_maint","ER_maint","HI_maint","HR_maint")
other_biomarkers <- c(
  "Basophils_base", "Eosinophils_base",
  "WBC_base", "HCT_base", "HB_base", "LY_base", "MO_base",
  "NEUT_base", "PLT_base", "Protein_base",
  "AST_base", "BUN_base", "CREA_base", "CRP_base", "MES_baseline",
  "Basophils_induc", "Eosinophils_induc",
  "WBC_induc", "HCT_induc", "HB_induc", "LY_induc", "MO_induc",
  "NEUT_induc", "PLT_induc", "Protein_induc",
  "AST_induc", "ALT_induc", "BUN_induc", "Bilirubin_induc", "MES_induc")
confounders <- c("Sex", "Age", "Smoking", "Disease_duration",
                 "Immunomodulator", "Corticosteroid", "HR_ASA")

all_vars <- c(biomarkers, outcomes_induc, outcomes_maint, other_biomarkers, confounders)

# 数据清理
existing_vars <- intersect(all_vars, names(data_test))
data_test <- data_test[existing_vars]

# 去除异常值
remove_outliers_5sd <- function(x){
  if(!is.numeric(x))return(x)
  mean_x <- mean(x,na.rm=TRUE)
  sd_x <- sd(x,na.rm=TRUE)
  x[abs(x-mean_x)>5*sd_x] <- NA
  return(x)
}

biomarker_vars <- c(biomarkers, other_biomarkers)
data_test[biomarker_vars] <- lapply(data_test[biomarker_vars], remove_outliers_5sd)

# 数据插补
outcome_vars <- c(outcomes_induc, outcomes_maint)
data_imputed <- data_test

non_outcome_vars <- setdiff(names(data_test), outcome_vars)
mice_result <- mice(data_test[non_outcome_vars],m=5,method = 'pmm',printFlag = FALSE,seed=123)
data_imputed[non_outcome_vars] <- complete(mice_result)

#标准化

# # log变换
data_imputed$FC_base_log <- scale((data_imputed$FC_base))
data_imputed$FC_induc_log <- scale(log1p(data_imputed$FC_induc))

# IBDQ总分标准化
data_imputed$IBDQ_base_std <- scale(data_imputed$IBDQ_TOTAL_base)[,1]
data_imputed$IBDQ_induc_std <- scale(data_imputed$IBDQ_TOTAL_induc)[,1]

# IBDQ各子维度标准化
data_imputed$IBDQ_BS_base_std <- scale(data_imputed$IBDQ_BS_base)[,1]
data_imputed$IBDQ_BS_induc_std <- scale(data_imputed$IBDQ_BS_induc)[,1]
data_imputed$IBDQ_SS_base_std <- scale(data_imputed$IBDQ_SS_base)[,1]
data_imputed$IBDQ_SS_induc_std <- scale(data_imputed$IBDQ_SS_induc)[,1]
data_imputed$IBDQ_EF_base_std <- scale(data_imputed$IBDQ_EF_base)[,1]
data_imputed$IBDQ_EF_induc_std <- scale(data_imputed$IBDQ_EF_induc)[,1]
data_imputed$IBDQ_SF_base_std <- scale(data_imputed$IBDQ_SF_base)[,1]
data_imputed$IBDQ_SF_induc_std <- scale(data_imputed$IBDQ_SF_induc)[,1]


# 聚类变量组合
#clust_base <- data_imputed[, c("FC_base_log", "IBDQ_TOTAL_base")]
clust_base <- data_imputed[, c("FC_base_log", "IBDQ_BS_base_std","IBDQ_SS_base_std",
                               "IBDQ_EF_base_std","IBDQ_SF_base_std")]

#clust_induc <- data_imputed[, c("FC_induc_log", "IBDQ_TOTAL_induc")]
clust_induc <- data_imputed[, c("FC_induc_log","IBDQ_BS_induc_std","IBDQ_SS_induc_std",
                                "IBDQ_EF_induc_std","IBDQ_SF_induc_std")]


#了解数据的分布
plot(data_imputed$FC_base_log, data_imputed$IBDQ_TOTAL_base, 
     main = "FC与IBDQ的散点图", 
     xlab = "FC", 
     ylab = "IBDQ", 
     pch = 19,cex=0.5)

## ==================== GMM聚类 ====================
#===============base
# 选择需要进行聚类的变量
gmm_base <- clust_base

# 创建并拟合混合高斯模型
gmm_model_base <- Mclust(gmm_base)

# 查看模型概况
summary(gmm_model_base)


# #可选，查看各种模型的BIC值（mclust中BIC因为符号问题，越大越好）
# plot.Mclust(gmm_model_base, what = "BIC",
#             ylim = range(gmm_model_base$BIC[,-(1:2)], na.rm = TRUE),
#             legendArgs = list(x = "bottomleft", cex =0.7))
# #可选，手动选择G组数，VVE模型
# mod2 <- Mclust(X, G = 3, modelNames = "VVE", x=BIC)


# 在散点图上加上聚类结果
plot(gmm_base, col = gmm_model_base$classification, 
     main = "FC与IBDQ_base", 
     pch = 19,cex=0.5)

#保存聚类标签
data_imputed$GMM_cluster_base <- gmm_model_base$classification

#可选，聚类结果在二维空间展示
# drmod <- MclustDR(gmm_model_base, lambda = 1)
# plot(drmod)

#===============induc
# 选择需要进行聚类的变量
gmm_induc <- clust_induc

# 创建并拟合混合高斯模型
gmm_model_induc <- Mclust(gmm_induc)

# 查看模型概况
summary(gmm_model_induc)


# #可选，查看各种模型的BIC值（mclust中BIC因为符号问题，越大越好）
# plot.Mclust(gmm_model_induc, what = "BIC", 
#             ylim = range(gmm_model$BIC[,-(1:2)], na.rm = TRUE), 
#             legendArgs = list(x = "bottomleft", cex =0.7))
# #可选，手动选择G组数，VVE模型
# mod2 <- Mclust(X, G = 3, modelNames = "VVE", x=BIC)


# 在散点图上加上聚类结果
plot(gmm_induc, col = gmm_model_induc$classification, 
     main = "FC与IBDQ_induc", 
     pch = 19,cex=0.5)

#保存聚类标签
data_imputed$GMM_cluster_induc <- gmm_model_induc$classification

# 将聚类标签转为因子，便于分组展示
data_imputed$GMM_cluster_base <- factor(data_imputed$GMM_cluster_base)
data_imputed$GMM_cluster_induc <- factor(data_imputed$GMM_cluster_induc)

# ==================================================================
# 通用聚类汇总分析函数
# ==================================================================

# 定义当前使用的聚类方法（可切换到其他聚类方法）
cluster_base <- "GMM_cluster_base"   # 基线期聚类变量
cluster_induc <- "GMM_cluster_induc" # 诱导期聚类变量
method_name <- "GMM"                 # 聚类方法名称

# ============= 基线期聚类汇总分析 =============
cluster_summary_base <- data_imputed %>%
  dplyr::select(all_of(cluster_base), FC_base_log, IBDQ_BS_base_std, IBDQ_SS_base_std, 
                IBDQ_EF_base_std, IBDQ_SF_base_std) %>%
  tidyr::pivot_longer(cols = -all_of(cluster_base), names_to = "Variable", values_to = "Value") %>%
  dplyr::group_by(across(all_of(cluster_base)), Variable) %>%
  dplyr::summarise(
    Mean = mean(Value, na.rm = TRUE),
    SD = sd(Value, na.rm = TRUE),
    n = sum(!is.na(Value)),
    SE = SD / sqrt(n),
    CI_lower = Mean - qt(0.975, df = n - 1) * SE,
    CI_upper = Mean + qt(0.975, df = n - 1) * SE,
    .groups = "drop"
  )

# 导出基线期汇总
write.csv(cluster_summary_base, 
          file = paste0(method_name, "_base_cluster_summary.csv"), 
          row.names = FALSE)

# 基线期可视化
plt_cluster_summary_base <- ggplot(cluster_summary_base, 
                                   aes(x = Mean, y = Variable)) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.1, size = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", alpha = 0.5) +
  facet_grid(as.formula(paste0(". ~ ", cluster_base)), scales = "free_x") +
  labs(title = paste0("基线期聚类特征 (", method_name, ")"), 
       x = "Mean Value (with 95% CI)", y = "Variable") +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.background = element_rect(fill = "lightblue", color = "black"),
    strip.text = element_text(face = "bold", size = 10),
    axis.text.y = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 0.5)
  )

ggsave(paste0(method_name, "_base_cluster_summary.png"), 
       plt_cluster_summary_base, width = 8, height = 4, dpi = 300)

# ============= 诱导期聚类汇总分析 =============
cluster_summary_induc <- data_imputed %>%
  dplyr::select(all_of(cluster_induc), FC_induc_log, IBDQ_BS_induc_std, IBDQ_SS_induc_std, 
                IBDQ_EF_induc_std, IBDQ_SF_induc_std) %>%
  tidyr::pivot_longer(cols = -all_of(cluster_induc), names_to = "Variable", values_to = "Value") %>%
  dplyr::group_by(across(all_of(cluster_induc)), Variable) %>%
  dplyr::summarise(
    Mean = mean(Value, na.rm = TRUE),
    SD = sd(Value, na.rm = TRUE),
    n = sum(!is.na(Value)),
    SE = SD / sqrt(n),
    CI_lower = Mean - qt(0.975, df = n - 1) * SE,
    CI_upper = Mean + qt(0.975, df = n - 1) * SE,
    .groups = "drop"
  )

# 导出诱导期汇总
write.csv(cluster_summary_induc, 
          file = paste0(method_name, "_induc_cluster_summary.csv"), 
          row.names = FALSE)

# 诱导期可视化
plt_cluster_summary_induc <- ggplot(cluster_summary_induc, 
                                    aes(x = Mean, y = Variable)) +
  geom_errorbarh(aes(xmin = CI_lower, xmax = CI_upper), height = 0.1, size = 0.8) +
  geom_point(size = 2) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", alpha = 0.5) +
  facet_grid(as.formula(paste0(". ~ ", cluster_induc)), scales = "free_x") +
  labs(title = paste0("诱导期聚类特征 (", method_name, ")"), 
       x = "Mean Value (with 95% CI)", y = "Variable") +
  theme_minimal() +
  theme(
    legend.position = "none",
    strip.background = element_rect(fill = "lightgreen", color = "black"),
    strip.text = element_text(face = "bold", size = 10),
    axis.text.y = element_text(face = "bold"),
    panel.border = element_rect(color = "black", fill = NA, size = 0.5)
  )

ggsave(paste0(method_name, "_induc_cluster_summary.png"), 
       plt_cluster_summary_induc, width = 8, height = 4, dpi = 300)


### ==================== 基线特征比较表（通用） ====================

# 定义需要比较的变量
vars_to_compare <- c(other_biomarkers, confounders)

# 基线期特征比较表
baseline_table_base <- CreateTableOne(vars = vars_to_compare,
                                      strata = cluster_base,
                                      data = data_imputed,
                                      test = TRUE)

cat("\n=== 基线期特征比较表 ===\n")
print(baseline_table_base, showAllLevels = TRUE)

baseline_table_matrix_base <- print(baseline_table_base, 
                                    showAllLevels = TRUE,
                                    printToggle = FALSE)

write.csv(baseline_table_matrix_base, 
          paste0("Baseline_Characteristics_", method_name, "_base.csv"))

# 诱导期特征比较表
baseline_table_induc <- CreateTableOne(vars = vars_to_compare,
                                       strata = cluster_induc,
                                       data = data_imputed,
                                       test = TRUE)

cat("\n=== 诱导期特征比较表 ===\n")
print(baseline_table_induc, showAllLevels = TRUE)

baseline_table_matrix_induc <- print(baseline_table_induc, 
                                     showAllLevels = TRUE,
                                     printToggle = FALSE)

write.csv(baseline_table_matrix_induc, 
          paste0("Baseline_Characteristics_", method_name, "_induc.csv"))

### ==================== Logistic回归 ====================
# 回归分析函数
perform_logistic_regression <- function(data, group_var, outcome_vars, confounders, analysis_name) {
  results <- data.frame()
  available_confounders <- intersect(confounders, names(data))
  
  for (outcome in outcome_vars) {
    if(outcome %in% names(data)) {
      formula_str <- paste0(outcome, "~", group_var)
      if(length(available_confounders) > 0) {
        formula_str <- paste0(formula_str, "+", paste(available_confounders, collapse = "+"))
      }
      
      model <- glm(as.formula(formula_str), data = data, family = binomial())
      model_summary <- broom::tidy(model, conf.int = TRUE, exponentiate = TRUE)
      group_coefs <- model_summary[grep(group_var, model_summary$term), ]
      
      if(nrow(group_coefs) > 0) {
        group_coefs$outcome <- outcome
        group_coefs$analysis <- analysis_name
        results <- dplyr::bind_rows(results, group_coefs)
      }
    }
  }
  return(results)
}

# ==================== 聚类回归分析（通用） ====================

# 基线期聚类结果的回归分析
cluster_base_result <- perform_logistic_regression(
  data_imputed, cluster_base, outcomes_induc, confounders, 
  paste0(method_name, "_base")
)

# 诱导期聚类结果的回归分析
cluster_induc_result <- perform_logistic_regression(
  data_imputed, cluster_induc, outcomes_induc, confounders, 
  paste0(method_name, "_induc")
)

# 合并聚类结果
all_results_cluster <- dplyr::bind_rows(cluster_base_result, cluster_induc_result)

# 格式化结果表格
format_results_table <- function(results, method_name) {
  results$OR_CI <- paste0(round(results$estimate, 2), "(", 
                          round(results$conf.low, 2), ",", 
                          round(results$conf.high, 2), ")")
  results$p_value <- ifelse(results$p.value < 0.001, "<0.001", round(results$p.value, 3))
  results$Significance <- ifelse(results$p.value < 0.05, "*", 
                                 ifelse(results$p.value < 0.01, "**", ""))
  
  formatted <- results[, c("analysis", "outcome", "term", "OR_CI", "p_value", "Significance")]
  formatted <- formatted[order(formatted$analysis, formatted$outcome, formatted$term), ]
  return(formatted)
}

# 格式化聚类结果表格
final_results_cluster <- format_results_table(all_results_cluster, 
                                              paste0(method_name, "_Clustering"))

cat(paste0("\n=== ", method_name, "聚类Logistic回归结果 ===\n"))
print(final_results_cluster)

# 保存聚类结果
output_file <- paste0("Logistic_Regression_Results_", method_name, "_Clustering.csv")
write.csv(final_results_cluster, 
          output_file, 
          row.names = FALSE)

cat(paste0("\n已保存", method_name, "聚类logistic回归结果:"))
cat(paste0("\n- ", output_file))

#============模式变化桑基图============
# 安装并加载ggalluvial
if(!require(ggalluvial)) install.packages("ggalluvial")
library(ggalluvial)
library(ggplot2)

df$cluster_base <- as.factor(cluster_base)
df$cluster_induc <- as.factor(cluster_induc)

ggplot(df, aes(axis1 = cluster_base, axis2 = cluster_induc)) +
  geom_alluvium(aes(fill = cluster_base), width = 1/12) +
  geom_stratum(width = 1/12, fill = "white", color = "black") +
  geom_text(stat = "stratum", aes(label = after_stat(stratum)), size = 5) +
  scale_x_discrete(limits = c("cluster_base", "cluster_induc"),
                   labels = c("Clusters at baseline", "Clusters at induction")) +
  labs(title = "Clusters from baseline to end of induction",
       y = "Number of patients") +
  theme_minimal()
ggsave("Sankey_Clusters.png", width = 8, height = 5, dpi = 300)