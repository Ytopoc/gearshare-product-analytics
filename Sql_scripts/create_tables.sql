-- Таблиця юзерів
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,              -- ID юзера (ключик)
    created_at TIMESTAMP DEFAULT NOW(),       -- Дата реєстрації
    country VARCHAR(50),                      -- Країна (для аналізу географії)
    is_verified BOOLEAN DEFAULT FALSE         -- Чи пройшов перевірку документів (важливо для P2P)
);

-- Таблиця обладнання
CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,               -- ID товару (ключик)
    owner_id INTEGER REFERENCES users(user_id), -- ID власника (зв'язок з таблицею users)
    category VARCHAR(50),                     -- Категорія: 'Drones', 'Cameras', 'Lenses', 'Lighting'
    model_name VARCHAR(255),                  -- Назва моделі
    daily_price DECIMAL(10, 2),               -- Ціна оренди за добу
    created_at TIMESTAMP DEFAULT NOW(),       -- Коли товар з'явився на платформі
    status VARCHAR(20) DEFAULT 'active'       -- Статус: 'active', 'inactive' (якщо власник приховав товар)
);

-- (Search Logs)
CREATE TABLE search_logs (
    search_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id), -- Хто шукав
    search_timestamp TIMESTAMP DEFAULT NOW(),   -- Коли
    search_query VARCHAR(255),                 -- Текст запиту
    category_filter VARCHAR(50),               -- Який фільтр категорій був обраний
    results_count INTEGER                      -- Скільки результатів видала база
);

-- Таблиця оренд
CREATE TABLE rentals (
    rental_id SERIAL PRIMARY KEY,
    item_id INTEGER REFERENCES items(item_id),  -- Що орендують
    renter_id INTEGER REFERENCES users(user_id), -- Хто орендує
    start_date DATE,                            -- Дата початку оренди
    end_date DATE,                              -- Дата закінчення
    total_price DECIMAL(10, 2),                 -- Загальна сума (обчислюється: дні * daily_price)
    status VARCHAR(50)                          -- Статус: 'completed', 'cancelled_by_owner', 'cancelled_by_renter', 'in_progress'
);