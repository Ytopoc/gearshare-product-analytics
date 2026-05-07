/*
БІЗНЕС-ПИТАННЯ: В яких категоріях ми маємо найбільший дефіцит пропозиції?
Тобто моя мета це визначити "Unmet demand" за категоріями.
*/

SELECT 
    category_filter AS "Категорія",
    COUNT(search_id) AS "Загальна кількість пошуків",
    SUM(CASE WHEN results_count = 0 THEN 1 ELSE 0 END) AS "Пошуків з 0 результатів",
    ROUND(
        SUM(CASE WHEN results_count = 0 THEN 1.0 ELSE 0.0 END) / COUNT(search_id) * 100, 
        2
    ) AS "Unmet demand (%)"
FROM 
    search_logs
GROUP BY 
    category_filter
HAVING 
    COUNT(search_id) > 10 -- відкидаємо категорії з аномально малою кількістю пошуків
ORDER BY 
    "Unmet demand (%)" DESC;