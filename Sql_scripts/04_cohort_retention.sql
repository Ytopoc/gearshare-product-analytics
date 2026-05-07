/*
БІЗНЕС-ПИТАННЯ: Який відсоток орендарів повертається на платформу для повторної оренди в наступні місяці (Retention Rate)?
МЕТА: Побудувати матрицю утримання за місячними когортами, щоб оцінити LTV (Lifetime Value) та лояльність клієнтів.
*/

WITH user_cohorts AS (
    -- Знаходимо місяць першої успішної оренди для кожного користувача
    SELECT 
        renter_id,
        DATE_TRUNC('month', MIN(start_date)) AS cohort_month
    FROM 
        rentals
    WHERE 
        status = 'completed'
    GROUP BY 
        renter_id
),
rental_months AS (
    -- Визначаємо місяць для кожної успішної оренди загалом
    SELECT 
        renter_id,
        DATE_TRUNC('month', start_date) AS rental_month
    FROM 
        rentals
    WHERE 
        status = 'completed'
),
cohort_data AS (
    --Рахуємо Month Index (0 - той самий місяць, 1 - наступний тощо)
    SELECT 
        uc.cohort_month,
        rm.rental_month,
        uc.renter_id,
        (EXTRACT(YEAR FROM rm.rental_month) - EXTRACT(YEAR FROM uc.cohort_month)) * 12 + 
        (EXTRACT(MONTH FROM rm.rental_month) - EXTRACT(MONTH FROM uc.cohort_month)) AS month_index
    FROM 
        user_cohorts uc
    JOIN 
        rental_months rm ON uc.renter_id = rm.renter_id
)

--Будуємо фінальну Retention матрицю
SELECT 
    TO_CHAR(cohort_month, 'YYYY-MM') AS "Когорта (Місяць)",
    COUNT(DISTINCT CASE WHEN month_index = 0 THEN renter_id END) AS "M0 (Нові орендарі)",
    COUNT(DISTINCT CASE WHEN month_index = 1 THEN renter_id END) AS "M1",
    COUNT(DISTINCT CASE WHEN month_index = 2 THEN renter_id END) AS "M2",
    COUNT(DISTINCT CASE WHEN month_index = 3 THEN renter_id END) AS "M3",
    -- Рахуємо відсоток утримання для 1-го місяця
    ROUND(
        COUNT(DISTINCT CASE WHEN month_index = 1 THEN renter_id END)::DECIMAL / 
        NULLIF(COUNT(DISTINCT CASE WHEN month_index = 0 THEN renter_id END), 0) * 100, 
    2) AS "M1 Retention (%)"
FROM 
    cohort_data
GROUP BY 
    cohort_month
ORDER BY 
    cohort_month;