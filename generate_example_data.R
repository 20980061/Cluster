# ============================================================================
# Example Data Generation Script
# ============================================================================
# This script generates example patient data for testing the clustering analysis
# 
# Run this script to create sample data that mimics a clinical trial dataset
# with biomarkers at baseline and induction timepoints
# ============================================================================

# Set random seed for reproducibility
set.seed(42)

# Number of patients
n_patients <- 250

# ============================================================================
# Generate Baseline Characteristics
# ============================================================================

# Age: normally distributed, mean 40, SD 12
age <- rnorm(n_patients, mean = 40, sd = 12)
age <- pmax(18, pmin(80, age))  # Constrain to 18-80 years

# Sex: binary
sex <- sample(c("Male", "Female"), n_patients, replace = TRUE, prob = c(0.45, 0.55))

# Disease duration: log-normal distribution
disease_duration <- rlnorm(n_patients, meanlog = 1, sdlog = 0.8)
disease_duration <- round(disease_duration, 1)

# Disease severity at baseline (used to generate correlated outcomes)
severity_baseline <- rnorm(n_patients, mean = 0, sd = 1)

# ============================================================================
# Generate Fecal Calprotectin (FC) Values
# ============================================================================

# FC baseline: log-normal distribution, correlated with disease severity
# Higher FC indicates more inflammation
FC_base_log_true <- 5 + 0.5 * severity_baseline + rnorm(n_patients, 0, 0.5)
FC_base <- exp(FC_base_log_true)

# FC induction: improvement from baseline (negative correlation)
# Simulate treatment effect
treatment_effect <- rnorm(n_patients, mean = -1, sd = 0.8)
FC_induc_log_true <- FC_base_log_true + treatment_effect + rnorm(n_patients, 0, 0.4)
FC_induc <- exp(FC_induc_log_true)

# ============================================================================
# Generate IBDQ Scores
# ============================================================================

# IBDQ baseline: normally distributed, inversely correlated with severity
# Higher IBDQ indicates better quality of life (range: 32-224)
IBDQ_base <- 140 - 15 * severity_baseline + rnorm(n_patients, 0, 20)
IBDQ_base <- pmax(32, pmin(224, IBDQ_base))  # Constrain to valid range

# IBDQ induction: improvement correlated with FC improvement
FC_improvement <- FC_base_log_true - FC_induc_log_true
IBDQ_induc <- IBDQ_base + 10 * FC_improvement + rnorm(n_patients, 0, 15)
IBDQ_induc <- pmax(32, pmin(224, IBDQ_induc))  # Constrain to valid range

# ============================================================================
# Generate Treatment Response Outcome
# ============================================================================

# Response probability based on FC and IBDQ improvement
FC_reduction <- (FC_base - FC_induc) / FC_base
IBDQ_increase <- IBDQ_induc - IBDQ_base

# Logistic model for response
logit_response <- -2 + 
                  3 * FC_reduction + 
                  0.03 * IBDQ_increase + 
                  rnorm(n_patients, 0, 0.5)

prob_response <- 1 / (1 + exp(-logit_response))
response <- rbinom(n_patients, 1, prob_response)

# ============================================================================
# Additional Clinical Variables
# ============================================================================

# Previous treatments
previous_treatments <- sample(0:3, n_patients, replace = TRUE, prob = c(0.3, 0.4, 0.2, 0.1))

# Smoking status
smoking <- sample(c("Never", "Former", "Current"), n_patients, 
                  replace = TRUE, prob = c(0.6, 0.25, 0.15))

# BMI
bmi <- rnorm(n_patients, mean = 24, sd = 4)
bmi <- pmax(16, pmin(40, bmi))

# CRP at baseline (C-reactive protein)
CRP_base <- rlnorm(n_patients, meanlog = 1.5, sdlog = 1)

# CRP at induction
CRP_induc <- CRP_base * exp(treatment_effect * 0.3 + rnorm(n_patients, 0, 0.3))

# ============================================================================
# Introduce Some Missing Values (realistic scenario)
# ============================================================================

# 5% missing for some variables
missing_indices_FC_induc <- sample(1:n_patients, size = round(0.05 * n_patients))
missing_indices_IBDQ_induc <- sample(1:n_patients, size = round(0.05 * n_patients))
missing_indices_CRP <- sample(1:n_patients, size = round(0.08 * n_patients))

FC_induc[missing_indices_FC_induc] <- NA
IBDQ_induc[missing_indices_IBDQ_induc] <- NA
CRP_induc[missing_indices_CRP] <- NA

# ============================================================================
# Create Final Dataset
# ============================================================================

patient_data <- data.frame(
  # Patient identifier
  patient_id = 1:n_patients,
  
  # Demographics
  age = round(age, 1),
  sex = sex,
  bmi = round(bmi, 1),
  smoking = smoking,
  
  # Disease characteristics
  disease_duration = disease_duration,
  previous_treatments = previous_treatments,
  
  # Baseline biomarkers
  FC_base = round(FC_base, 1),
  IBDQ_base = round(IBDQ_base, 0),
  CRP_base = round(CRP_base, 2),
  
  # Induction biomarkers
  FC_induc = round(FC_induc, 1),
  IBDQ_induc = round(IBDQ_induc, 0),
  CRP_induc = round(CRP_induc, 2),
  
  # Outcome
  response = response
)

# ============================================================================
# Data Summary
# ============================================================================

cat("===============================================\n")
cat("Example Patient Data Generated Successfully!\n")
cat("===============================================\n\n")

cat("Dataset dimensions:", nrow(patient_data), "patients x", ncol(patient_data), "variables\n\n")

cat("Variable summary:\n")
print(summary(patient_data))

cat("\n\nMissing values:\n")
missing_summary <- sapply(patient_data, function(x) sum(is.na(x)))
print(missing_summary[missing_summary > 0])

cat("\n\nResponse distribution:\n")
print(table(Response = patient_data$response))
cat("Response rate:", round(mean(patient_data$response) * 100, 1), "%\n")

# ============================================================================
# Save Data
# ============================================================================

# Save as CSV
write.csv(patient_data, "example_patient_data.csv", row.names = FALSE)
cat("\n\nData saved as: example_patient_data.csv\n")

# Save as RData
save(patient_data, file = "example_patient_data.RData")
cat("Data saved as: example_patient_data.RData\n")

# ============================================================================
# Create Data Dictionary
# ============================================================================

data_dictionary <- data.frame(
  Variable = names(patient_data),
  Description = c(
    "Unique patient identifier",
    "Age in years",
    "Sex (Male/Female)",
    "Body Mass Index",
    "Smoking status (Never/Former/Current)",
    "Disease duration in years",
    "Number of previous treatments",
    "Fecal calprotectin at baseline (μg/g)",
    "IBDQ score at baseline (32-224)",
    "C-reactive protein at baseline (mg/L)",
    "Fecal calprotectin at induction (μg/g)",
    "IBDQ score at induction (32-224)",
    "C-reactive protein at induction (mg/L)",
    "Treatment response (0=No, 1=Yes)"
  ),
  Type = sapply(patient_data, class),
  Missing = sapply(patient_data, function(x) sum(is.na(x)))
)

write.csv(data_dictionary, "data_dictionary.csv", row.names = FALSE)
cat("Data dictionary saved as: data_dictionary.csv\n")

cat("\n===============================================\n")
cat("You can now use this data with the clustering analysis script!\n")
cat("===============================================\n")

# ============================================================================
# Quick Visualization
# ============================================================================

# Check if ggplot2 is available
if(require(ggplot2, quietly = TRUE)) {
  
  cat("\nGenerating quick visualizations...\n")
  
  # FC at baseline vs induction
  p1 <- ggplot(patient_data, aes(x = FC_base, y = FC_induc, color = as.factor(response))) +
    geom_point(alpha = 0.6) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    labs(
      title = "Fecal Calprotectin: Baseline vs Induction",
      x = "FC Baseline (μg/g)",
      y = "FC Induction (μg/g)",
      color = "Response"
    ) +
    theme_bw()
  
  ggsave("example_data_FC_comparison.png", p1, width = 8, height = 6, dpi = 300)
  
  # IBDQ at baseline vs induction
  p2 <- ggplot(patient_data, aes(x = IBDQ_base, y = IBDQ_induc, color = as.factor(response))) +
    geom_point(alpha = 0.6) +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
    labs(
      title = "IBDQ Score: Baseline vs Induction",
      x = "IBDQ Baseline",
      y = "IBDQ Induction",
      color = "Response"
    ) +
    theme_bw()
  
  ggsave("example_data_IBDQ_comparison.png", p2, width = 8, height = 6, dpi = 300)
  
  cat("Visualizations saved!\n")
}

cat("\n===============================================\n")
cat("Data generation complete!\n")
cat("Next step: Run 'clustering_analysis.R' with this data\n")
cat("===============================================\n")
