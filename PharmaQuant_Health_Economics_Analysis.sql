/*PharmaQuant Health Economics Project SQL Script


-- Count total number of patients in the dataset
SELECT COUNT(*) AS total_patients FROM diabetes;


-- Count how many patients have diabetes (Outcome = 1) and calculate prevalence
SELECT 
    SUM(Outcome) AS total_diabetics,
    ROUND((SUM(Outcome)/COUNT(*)) * 100, 2) AS diabetes_prevalence_percentage
FROM diabetes;


-- Check for zero or null values in important clinical columns
SELECT
    SUM(CASE WHEN Glucose = 0 OR Glucose IS NULL THEN 1 ELSE 0 END) AS Glucose_zero_or_null,
    SUM(CASE WHEN BloodPressure = 0 OR BloodPressure IS NULL THEN 1 ELSE 0 END) AS BloodPressure_zero_or_null,
    SUM(CASE WHEN SkinThickness = 0 OR SkinThickness IS NULL THEN 1 ELSE 0 END) AS SkinThickness_zero_or_null,
    SUM(CASE WHEN Insulin = 0 OR Insulin IS NULL THEN 1 ELSE 0 END) AS Insulin_zero_or_null,
    SUM(CASE WHEN BMI = 0 OR BMI IS NULL THEN 1 ELSE 0 END) AS BMI_zero_or_null
FROM diabetes;


-- Distribution count of diabetic vs non-diabetic patients
SELECT Outcome, COUNT(*) AS count_patients
FROM diabetes
GROUP BY Outcome;


-- Aggregate averages of clinical metrics by diabetes outcome
SELECT
    Outcome,
    COUNT(*) AS patient_count,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(BMI), 2) AS avg_bmi,
    ROUND(AVG(Glucose), 2) AS avg_glucose,
    ROUND(AVG(BloodPressure), 2) AS avg_blood_pressure
FROM diabetes
GROUP BY Outcome;


-- Calculate variability in clinical measures by outcome
SELECT
    Outcome,
    ROUND(STDDEV_POP(Age), 2) AS stddev_age,
    ROUND(STDDEV_POP(BMI), 2) AS stddev_bmi,
    ROUND(STDDEV_POP(Glucose), 2) AS stddev_glucose,
    ROUND(STDDEV_POP(BloodPressure), 2) AS stddev_blood_pressure
FROM diabetes
GROUP BY Outcome;


-- How many patients fall into each Outcome group?
SELECT 
    Outcome, 
    COUNT(*) AS count_patients 
FROM diabetes 
GROUP BY Outcome;


-- Categorize patients by BMI groups and count by diabetes outcome
SELECT
    CASE
        WHEN BMI < 18.5 THEN 'Underweight'
        WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal Weight'
        WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight'
        
        
-- Calculate average Age and Glucose by BMI groups and diabetes outcome
SELECT
    CASE
        WHEN BMI < 18.5 THEN 'Underweight'
        WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal Weight'
        WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    Outcome,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(Glucose), 2) AS avg_glucose
FROM diabetes
GROUP BY bmi_category, Outcome
ORDER BY bmi_category, Outcome;


-- List top 10 diabetic patients with highest Glucose and BMI
SELECT
    patient_id,
    Age,
    BMI,
    Glucose,
    BloodPressure,
    Outcome
FROM diabetes
WHERE Outcome = 1
ORDER BY Glucose DESC, BMI DESC
LIMIT 10;


-- Define thresholds for "high risk"
SELECT COUNT(*) AS high_risk_count
FROM diabetes
WHERE Outcome = 1
AND BMI >= 30     -- Obese threshold
AND Glucose >= 140;  -- High glucose threshold indicating uncontrolled diabetes


-- Count high-risk patients segmented by age groups
SELECT
    CASE 
        WHEN Age < 30 THEN '<30'
        WHEN Age BETWEEN 30 AND 50 THEN '30-50'
        WHEN Age > 50 THEN '>50'
    END AS age_group,
    COUNT(*) AS patient_count
FROM diabetes
WHERE Outcome = 1
AND BMI >= 30
AND Glucose >= 140
GROUP BY age_group
ORDER BY age_group;


-- Approximate correlation using covariance divided by standard deviations
SELECT 
    ROUND(
        (AVG(Glucose*BMI) - AVG(Glucose)*AVG(BMI)) / 
        (STDDEV_POP(Glucose) * STDDEV_POP(BMI)), 4
    ) AS glucose_bmi_correlation
FROM diabetes;


-- Categorize BloodPressure, then find average Glucose in each group
SELECT
    CASE 
        WHEN BloodPressure < 60 THEN 'Low'
        WHEN BloodPressure BETWEEN 60 AND 80 THEN 'Normal'
        WHEN BloodPressure BETWEEN 81 AND 100 THEN 'Pre-High'
        ELSE 'High'
    END AS bp_category,
    ROUND(AVG(Glucose), 2) AS avg_glucose,
    COUNT(*) AS patient_count
FROM diabetes
GROUP BY bp_category
ORDER BY bp_category;


-- Group by BMI category and compute average Insulin
SELECT
    CASE
        WHEN BMI < 18.5 THEN 'Underweight'
        WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal Weight'
        WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    ROUND(AVG(Insulin), 2) AS avg_insulin,
    COUNT(*) AS patient_count
FROM diabetes
GROUP BY bmi_category
ORDER BY bmi_category;


-- Create a view summarizing key clinical averages by diabetes status
CREATE OR REPLACE VIEW diabetes_clinical_summary AS
SELECT
    Outcome,
    COUNT(*) AS patient_count,
    ROUND(AVG(Age), 2) AS avg_age,
    ROUND(AVG(BMI), 2) AS avg_bmi,
    ROUND(AVG(Glucose), 2) AS avg_glucose,
    ROUND(AVG(BloodPressure), 2) AS avg_blood_pressure,
    ROUND(AVG(SkinThickness), 2) AS avg_skin_thickness,
    ROUND(AVG(Insulin), 2) AS avg_insulin
FROM diabetes
GROUP BY Outcome;


-- Final summary query from the view
SELECT * FROM diabetes_clinical_summary;


Purpose:
- Explore clinical and utilization risk differences between diabetic and non-diabetic patients.
- Produce stratified summaries for risk profiling and business targeting.
- Identify high-risk cohorts with combined elevated BMI and glucose.
- Provide foundational data for pharmacoeconomic modeling and decision support.

Limitations:
- Dataset is cross-sectional; longitudinal validation required.
- Missing or zero clinical values require careful preprocessing before advanced modeling.
- External utilization and cost data not included in this dataset.

Usage:
- Run queries sequentially.
- Export results as CSV for business reporting.
- Views streamline repeated reporting tasks.
*/
