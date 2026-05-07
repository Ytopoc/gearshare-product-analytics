/*
БІЗНЕС-ПИТАННЯ: Який відсоток часу обладнання знаходиться в оренді?
МЕТА: Виявити низьколіквідні категорії товарів, власники яких знаходяться в зоні ризику відтоку.
*/

WITH item_lifespan AS (
    -- Рахуємо, скільки днів кожен активний товар знаходиться на платформі
    SELECT 
        item_id,
        category,
        CURRENT_DATE - DATE(created_at) AS days_on_platform
    FROM 
        items
    WHERE 
        status = 'active'
),
rental_days AS (
    -- Рахуємо загальну кількість днів, які товар провів в успішній оренді
    SELECT 
        item_id,
        SUM(end_date - start_date) AS total_rented_days
    FROM 
        rentals
    WHERE 
        status = 'completed'
    GROUP BY 
        item_id
)

SELECT 
    il.category AS "Категорія",
    COUNT(il.item_id) AS "Кількість товарів",
    ROUND(AVG(il.days_on_platform), 0) AS "Середній вік товару (днів)",
    ROUND(AVG(COALESCE(rd.total_rented_days, 0)), 0) AS "Середньо днів в оренді",
    ROUND(
        AVG(COALESCE(rd.total_rented_days, 0)::DECIMAL / il.days_on_platform) * 100, 
        2
    ) AS "Utilization Rate (%)"
FROM 
    item_lifespan il
LEFT JOIN 
    rental_days rd ON il.item_id = rd.item_id
WHERE 
    il.days_on_platform > 0 -- Товари які зареєстровані сьогодні
GROUP BY 
    il.category
ORDER BY 
    "Utilization Rate (%)" DESC;