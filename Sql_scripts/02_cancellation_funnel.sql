/*
БІЗНЕС-ПИТАННЯ: Як наявність верифікації профілю орендаря впливає на відсоток успішних угод?
МЕТА: Оцінити вплив Trust & Safety на конверсію в оплату, щоб обґрунтувати необхідність обов'язкової верифікації перед першим бронюванням.
*/

SELECT 
    CASE WHEN u.is_verified = TRUE THEN 'Верифіковані' ELSE 'Неверифіковані' END AS "Статус орендаря",
    COUNT(r.rental_id) AS "Всього запитів",
    SUM(CASE WHEN r.status = 'completed' THEN 1 ELSE 0 END) AS "Успішні оренди",
    SUM(CASE WHEN r.status = 'cancelled_by_owner' THEN 1 ELSE 0 END) AS "Відхилено власником",
    ROUND(
        SUM(CASE WHEN r.status = 'completed' THEN 1.0 ELSE 0.0 END) / COUNT(r.rental_id) * 100, 
        2
    ) AS "Conversion Rate (%)"
FROM 
    rentals r
JOIN 
    users u ON r.renter_id = u.user_id
GROUP BY 
    u.is_verified
ORDER BY 
    "Conversion Rate (%)" DESC;