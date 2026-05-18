import pandas as pd
import numpy as np
from datetime import datetime, timedelta

# Settings
num_users = 5000
start_date = datetime(2025, 1, 1)

# 1. USER GENERATION
users = pd.DataFrame({
    'user_id': range(1000, 1000 + num_users),
    'reg_date': [start_date + timedelta(days=np.random.randint(0, 120)) for _ in range(num_users)],
    'country': np.random.choice(['Ukraine', 'Poland', 'Germany', 'UK', 'USA'], num_users),
    'device': np.random.choice(['iOS', 'Android'], num_users, p=[0.4, 0.6]),
    'channel': np.random.choice(['Facebook Ads', 'Google Search', 'TikTok', 'Organic'], num_users)
})

# 2. PURCHASE GENERATION
purchases = []
for user_id in users['user_id']:
    if np.random.rand() < 0.15:  # 15% conversion
        num_purchases = np.random.randint(1, 5)
        for _ in range(num_purchases):
            purchases.append({
                'purchase_id': len(purchases) + 1,
                'user_id': user_id,
                'amount': round(np.random.uniform(5, 50), 2),
                'timestamp': users.loc[users['user_id'] == user_id, 'reg_date'].iloc[0] + timedelta(days=np.random.randint(0, 30))
            })
purchases_df = pd.DataFrame(purchases)

# 3. EVENT GENERATION (for Retention)
events = []
for _, user in users.iterrows():
    retention_days = [0, 1, 3, 7, 14, 28]
    for day in retention_days:
        if np.random.rand() > (day / 40): # Simulation of outflow
            events.append({
                'user_id': user['user_id'],
                'event_name': 'app_open',
                'timestamp': user['reg_date'] + timedelta(days=day)
            })
events_df = pd.DataFrame(events)

# Preservation
users.to_csv('users_data.csv', index=False)
purchases_df.to_csv('purchases_data.csv', index=False)
events_df.to_csv('events_data.csv', index=False)

print("The data has been successfully generated!")