# 设置随机种子以保证结果可重现
set.seed(123)

# 设置样本量
n <- 450  # 可以根据需要调整样本量

# 定义变量组
biomarkers <- c("FC_base","FC_induc","FC_maint","IBDQ_TOTAL_base","IBDQ_TOTAL_induc","IBDQ_TOTAL_maint")
outcomes_induc <- c("CR_induc","CRS_induc","EI_induc","ER_induc","HI_induc","HR_induc")
outcomes_maint <- c("CR_maint","EI_maint","ER_maint","HI_maint","HR_maint")
other_biomarkers <- c(
  # baseline 变量
  "Basophils_base", "Eosinophils_base",
  "WBC_base", "HCT_base", "HB_base", "LY_base", "MO_base",
  "NEUT_base", "PLT_base", "Protein_base",
  "AST_base", "BUN_base", "CREA_base", "CRP_base", "MES_baseline",
  
  # induc 变量  
  "Basophils_induc", "Eosinophils_induc",
  "WBC_induc", "HCT_induc", "HB_induc", "LY_induc", "MO_induc",
  "NEUT_induc", "PLT_induc", "Protein_induc",
  "AST_induc", "ALT_induc", "BUN_induc", "Bilirubin_induc", "MES_induc",
  
  # maint 变量
  "Basophils_maint", "Eosinophils_maint",
  "WBC_maint", "HCT_maint", "HB_maint", "LY_maint", "MO_maint",
  "NEUT_maint", "PLT_maint", "Protein_maint",
  "AST_maint", "ALT_maint", "BUN_maint", "Bilirubin_maint", "MES_maint"
)
confounders <- c("Sex", "Age", "Smoking", "Disease_duration",
                 "Immunomodulator", "Corticosteroid", "HR_ASA")

# 创建数据框
data_test <- data.frame(row.names = 1:n)

# 生成生物标志物数据
# FC (Fecal Calprotectin) - 通常在100-5000范围内，对数正态分布
data_test$FC_base <- exp(rnorm(n, mean = log(800), sd = 1.2))
data_test$FC_induc <- data_test$FC_base * exp(rnorm(n, mean = -0.5, sd = 0.8))  # 诱导期一般会降低
data_test$FC_maint <- data_test$FC_induc * exp(rnorm(n, mean = -0.2, sd = 0.6))  # 维持期继续改善

# IBDQ总分 - 范围32-224，分数越高表示生活质量越好
data_test$IBDQ_TOTAL_base <- round(rnorm(n, mean = 120, sd = 25))
data_test$IBDQ_TOTAL_base <- pmax(32, pmin(224, data_test$IBDQ_TOTAL_base))
data_test$IBDQ_TOTAL_induc <- round(data_test$IBDQ_TOTAL_base + rnorm(n, mean = 15, sd = 20))
data_test$IBDQ_TOTAL_induc <- pmax(32, pmin(224, data_test$IBDQ_TOTAL_induc))
data_test$IBDQ_TOTAL_maint <- round(data_test$IBDQ_TOTAL_induc + rnorm(n, mean = 5, sd = 15))
data_test$IBDQ_TOTAL_maint <- pmax(32, pmin(224, data_test$IBDQ_TOTAL_maint))

# 生成结局变量（二分类变量，0/1）
# 诱导期结局
for(outcome in outcomes_induc) {
  data_test[[outcome]] <- rbinom(n, 1, 0.4)  # 40%的缓解率
}

# 维持期结局
for(outcome in outcomes_maint) {
  data_test[[outcome]] <- rbinom(n, 1, 0.6)  # 60%的维持率
}

# 生成其他生物标志物
# 血液学指标
generate_lab_values <- function(n, base_mean, base_sd, change_mean = 0, change_sd = 0.1) {
  base <- rnorm(n, base_mean, base_sd)
  induc <- base + rnorm(n, change_mean, change_sd * base_mean)
  maint <- induc + rnorm(n, change_mean * 0.5, change_sd * base_mean * 0.5)
  return(list(base = base, induc = induc, maint = maint))
}

# 嗜碱性粒细胞 (%)
basophils <- generate_lab_values(n, 0.5, 0.3, 0, 0.1)
data_test$Basophils_base <- pmax(0, basophils$base)
data_test$Basophils_induc <- pmax(0, basophils$induc)
data_test$Basophils_maint <- pmax(0, basophils$maint)

# 嗜酸性粒细胞 (%)
eosinophils <- generate_lab_values(n, 2.5, 1.0, 0, 0.2)
data_test$Eosinophils_base <- pmax(0, eosinophils$base)
data_test$Eosinophils_induc <- pmax(0, eosinophils$induc)
data_test$Eosinophils_maint <- pmax(0, eosinophils$maint)

# 白细胞计数 (×10^9/L)
wbc <- generate_lab_values(n, 8.5, 2.5, -0.5, 0.1)
data_test$WBC_base <- pmax(2, wbc$base)
data_test$WBC_induc <- pmax(2, wbc$induc)
data_test$WBC_maint <- pmax(2, wbc$maint)

# 血细胞比容 (%)
hct <- generate_lab_values(n, 40, 5, 1, 0.05)
data_test$HCT_base <- pmax(25, pmin(55, hct$base))
data_test$HCT_induc <- pmax(25, pmin(55, hct$induc))
data_test$HCT_maint <- pmax(25, pmin(55, hct$maint))

# 血红蛋白 (g/dL)
hb <- generate_lab_values(n, 12.5, 2.0, 0.5, 0.05)
data_test$HB_base <- pmax(8, pmin(18, hb$base))
data_test$HB_induc <- pmax(8, pmin(18, hb$induc))
data_test$HB_maint <- pmax(8, pmin(18, hb$maint))

# 淋巴细胞 (%)
ly <- generate_lab_values(n, 30, 8, 2, 0.1)
data_test$LY_base <- pmax(10, pmin(50, ly$base))
data_test$LY_induc <- pmax(10, pmin(50, ly$induc))
data_test$LY_maint <- pmax(10, pmin(50, ly$maint))

# 单核细胞 (%)
mo <- generate_lab_values(n, 7, 2, 0, 0.1)
data_test$MO_base <- pmax(2, pmin(15, mo$base))
data_test$MO_induc <- pmax(2, pmin(15, mo$induc))
data_test$MO_maint <- pmax(2, pmin(15, mo$maint))

# 中性粒细胞 (%)
neut <- generate_lab_values(n, 60, 10, -2, 0.1)
data_test$NEUT_base <- pmax(40, pmin(80, neut$base))
data_test$NEUT_induc <- pmax(40, pmin(80, neut$induc))
data_test$NEUT_maint <- pmax(40, pmin(80, neut$maint))

# 血小板计数 (×10^9/L)
plt <- generate_lab_values(n, 350, 100, -20, 0.05)
data_test$PLT_base <- pmax(100, plt$base)
data_test$PLT_induc <- pmax(100, plt$induc)
data_test$PLT_maint <- pmax(100, plt$maint)

# 总蛋白 (g/dL)
protein <- generate_lab_values(n, 7.2, 0.8, 0.2, 0.02)
data_test$Protein_base <- pmax(5, pmin(9, protein$base))
data_test$Protein_induc <- pmax(5, pmin(9, protein$induc))
data_test$Protein_maint <- pmax(5, pmin(9, protein$maint))

# 天冬氨酸转氨酶 (U/L)
ast <- generate_lab_values(n, 25, 8, 0, 0.1)
data_test$AST_base <- pmax(10, ast$base)
data_test$AST_induc <- pmax(10, ast$induc)
data_test$AST_maint <- pmax(10, ast$maint)

# 丙氨酸转氨酶 (U/L) - 只有induc和maint期
alt <- generate_lab_values(n, 30, 10, 0, 0.1)
data_test$ALT_induc <- pmax(10, alt$induc)
data_test$ALT_maint <- pmax(10, alt$maint)

# 尿素氮 (mg/dL)
bun <- generate_lab_values(n, 15, 5, 0, 0.05)
data_test$BUN_base <- pmax(5, bun$base)
data_test$BUN_induc <- pmax(5, bun$induc)
data_test$BUN_maint <- pmax(5, bun$maint)

# 肌酐 (mg/dL) - 只有baseline
data_test$CREA_base <- rnorm(n, 1.0, 0.3)
data_test$CREA_base <- pmax(0.5, pmin(2.0, data_test$CREA_base))

# CRP (mg/L) - 只有baseline
data_test$CRP_base <- exp(rnorm(n, log(8), 1))
data_test$CRP_base <- pmax(0.5, data_test$CRP_base)

# 胆红素 (mg/dL) - 只有induc和maint期
bilirubin <- generate_lab_values(n, 1.0, 0.4, 0, 0.05)
data_test$Bilirubin_induc <- pmax(0.2, bilirubin$induc)
data_test$Bilirubin_maint <- pmax(0.2, bilirubin$maint)

# Mayo内镜评分
data_test$MES_baseline <- sample(0:3, n, replace = TRUE, prob = c(0.1, 0.3, 0.4, 0.2))
data_test$MES_induc <- pmax(0, data_test$MES_baseline + sample(-2:1, n, replace = TRUE, prob = c(0.3, 0.4, 0.2, 0.1)))
data_test$MES_maint <- pmax(0, data_test$MES_induc + sample(-1:1, n, replace = TRUE, prob = c(0.4, 0.5, 0.1)))

# 混杂因子
data_test$Sex <- sample(c("Male", "Female"), n, replace = TRUE, prob = c(0.45, 0.55))
data_test$Age <- round(rnorm(n, 42, 15))
data_test$Age <- pmax(18, pmin(80, data_test$Age))
data_test$Smoking <- sample(c("Never", "Former", "Current"), n, replace = TRUE, prob = c(0.6, 0.25, 0.15))
data_test$Disease_duration <- round(exp(rnorm(n, log(5), 0.8)))
data_test$Disease_duration <- pmax(0.5, pmin(30, data_test$Disease_duration))
data_test$Immunomodulator <- sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.6, 0.4))
data_test$Corticosteroid <- sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.3, 0.7))
data_test$HR_ASA <- sample(c("Yes", "No"), n, replace = TRUE, prob = c(0.4, 0.6))

# 检查生成的数据
all_vars <- c(biomarkers, outcomes_induc, outcomes_maint, other_biomarkers, confounders)
existing_vars <- intersect(all_vars, names(data_test))
data_test <- data_test[existing_vars]

# 显示数据集概览
print("数据集维度:")
print(dim(data_test))

print("\n变量类型概览:")
print(str(data_test))

print("\n前几行数据:")
print(head(data_test))

print("\n数值变量的描述统计:")
numeric_vars <- sapply(data_test, is.numeric)
print(summary(data_test[numeric_vars]))

print("\n分类变量的频数:")
categorical_vars <- !numeric_vars
if(any(categorical_vars)) {
  for(var in names(data_test)[categorical_vars]) {
    cat("\n", var, ":\n")
    print(table(data_test[[var]]))
  }
}

# 保存数据（可选）
# write.csv(data_test, "ibd_simulation_data.csv", row.names = FALSE)