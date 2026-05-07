import pandas as pd
import random
from faker import Faker
from datetime import datetime, timedelta

fake = Faker()
Faker.seed(42)
random.seed(42)

# Кількості записів 
NUM_USERS = 200
NUM_ITEMS = 150
NUM_SEARCHES = 800
NUM_RENTALS = 400

# Генерація юзерів
users_data = []
for user_id in range(1, NUM_USERS + 1):
    created_at = fake.date_time_between(start_date='-2y', end_date='-1y')
    country = random.choices(
        ['Ukraine', 'Poland', 'Germany', 'USA'], 
        weights=[0.6, 0.2, 0.1, 0.1]
    )[0]
    is_verified = random.choices([True, False], weights=[0.7, 0.3])[0]
    
    users_data.append([user_id, created_at, country, is_verified])

df_users = pd.DataFrame(users_data, columns=['user_id', 'created_at', 'country', 'is_verified'])

# Генерація айтемів
categories = {
    'Drones': ['DJI Mavic 3', 'DJI Mini 3 Pro', 'DJI Air 2S', 'Autel Evo Lite'],
    'Cameras': ['Sony A7 IV', 'Canon EOS R5', 'Blackmagic Pocket 6K', 'Fujifilm X-T4'],
    'Lenses': ['Canon RF 24-70mm', 'Sony FE 50mm f/1.2', 'Sigma 35mm Art'],
    'Lighting': ['Godox SL-60W', 'Aputure 120d II', 'Nanlite Forza 60']
}

items_data = []
for item_id in range(1, NUM_ITEMS + 1):
    owner_id = random.randint(1, NUM_USERS)
    owner_created_at = df_users.iloc[owner_id - 1]['created_at']
    created_at = fake.date_time_between(start_date=owner_created_at, end_date='now')
    
    category = random.choice(list(categories.keys()))
    model_name = random.choice(categories[category])
    daily_price = round(random.uniform(15.0, 120.0), 2)
    status = random.choices(['active', 'inactive'], weights=[0.85, 0.15])[0]
    
    items_data.append([item_id, owner_id, category, model_name, daily_price, created_at, status])

df_items = pd.DataFrame(items_data, columns=['item_id', 'owner_id', 'category', 'model_name', 'daily_price', 'created_at', 'status'])

# Генерація пошуків
searches_data = []
for search_id in range(1, NUM_SEARCHES + 1):
    user_id = random.randint(1, NUM_USERS)
    search_timestamp = fake.date_time_between(start_date='-1y', end_date='now')
    category_filter = random.choice(list(categories.keys()))
    search_query = random.choice(categories[category_filter]).split()[0] # берем первое слово модели
    
    # Штучний дефіцит (іноді видає 0)
    results_count = random.choices([0, 1, 2, 5, 10], weights=[0.2, 0.3, 0.3, 0.15, 0.05])[0]
    
    searches_data.append([search_id, user_id, search_timestamp, search_query, category_filter, results_count])

df_searches = pd.DataFrame(searches_data, columns=['search_id', 'user_id', 'search_timestamp', 'search_query', 'category_filter', 'results_count'])

# Генерація оренд
rentals_data = []
for rental_id in range(1, NUM_RENTALS + 1):
    item = df_items.sample(1).iloc[0]
    item_id = item['item_id']
    
    renter_id = random.randint(1, NUM_USERS)
    while renter_id == item['owner_id']: # Сам у себе не може орендувати(
        renter_id = random.randint(1, NUM_USERS)
        
    start_date = fake.date_time_between(start_date='-1y', end_date='now').date()
    days_rented = random.randint(1, 14)
    end_date = start_date + timedelta(days=days_rented)
    total_price = round(item['daily_price'] * days_rented, 2)
    
    # Якщо орендатор не верифікований то шанс відміни вище
    is_renter_verified = df_users.iloc[renter_id - 1]['is_verified']
    if not is_renter_verified:
        status = random.choices(['completed', 'cancelled_by_owner', 'cancelled_by_renter'], weights=[0.4, 0.5, 0.1])[0]
    else:
        status = random.choices(['completed', 'cancelled_by_owner', 'cancelled_by_renter'], weights=[0.85, 0.05, 0.1])[0]
        
    rentals_data.append([rental_id, item_id, renter_id, start_date, end_date, total_price, status])

df_rentals = pd.DataFrame(rentals_data, columns=['rental_id', 'item_id', 'renter_id', 'start_date', 'end_date', 'total_price', 'status'])

# Збереження у цсв
df_users.to_csv('data/users.csv', index=False)
df_items.to_csv('data/items.csv', index=False)
df_searches.to_csv('data/search_logs.csv', index=False)
df_rentals.to_csv('data/rentals.csv', index=False)

print('Finish!')