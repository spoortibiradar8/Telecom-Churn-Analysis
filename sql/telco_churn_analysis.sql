USE telcocustomerchurn;

DROP VIEW IF EXISTS v_customers;

CREATE VIEW v_customers AS
SELECT t.*,
  CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS churned,
  CASE WHEN tenure <= 6  THEN '0-6'
       WHEN tenure <= 12 THEN '7-12'
       WHEN tenure <= 24 THEN '13-24'
       WHEN tenure <= 48 THEN '25-48'
       ELSE '49-72' END AS tenure_band,
  CASE WHEN PaymentMethod LIKE '%automatic%' THEN 1 ELSE 0 END AS autopay,
  (CASE WHEN OnlineSecurity   = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN OnlineBackup     = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN DeviceProtection = 'Yes' THEN 1 ELSE 0 END
   + CASE WHEN TechSupport      = 'Yes' THEN 1 ELSE 0 END) AS addon_count,
  CASE WHEN Contract = 'Month-to-month'
        AND InternetService = 'Fiber optic'
        AND TechSupport = 'No' THEN 1 ELSE 0 END AS high_risk
FROM telco_customers t;


SELECT high_risk,
  COUNT(*) AS customers,
  ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_pct,
  ROUND(100.0 * SUM(churned) / (SELECT SUM(churned) FROM v_customers), 1) AS share_of_all_churners,
  ROUND(SUM(CASE WHEN churned = 1 THEN MonthlyCharges END), 0) AS churned_monthly_revenue
FROM v_customers
GROUP BY high_risk;