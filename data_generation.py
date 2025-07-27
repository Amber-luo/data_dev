# 重新导入必要模块（因执行环境重置）
import pandas as pd
import numpy as np
from faker import Faker
import random

# 初始化
fake = Faker()

# 定义行为类型和页面类型
event_types = ["login", "view", "click", "add_to_cart", "order", "logout"]
pages = ["home", "product", "cart", "checkout", "order_success", "search"]

# 构造单条用户行为事件
def generate_event(user_id):
    event_type = random.choices(
        event_types,
        weights=[0.2, 0.3, 0.25, 0.1, 0.1, 0.05],
        k=1
    )[0]
    # random.choice 返回值是一个列表，[0]是为了取到第一个元素

    if event_type == "login":
        page = "home"
    elif event_type == "order":
        page = "order_success"
    elif event_type == "add_to_cart":
        page = "cart"
    elif event_type == "click":
        page = "product"
    else:
        page = random.choice(pages)
    
    return {
        "event_time": fake.date_time_between(start_date="-1d", end_date="now"),
        "user_id": user_id,
        "event_type": event_type,
        "page_id": page
    }

# 生成1000条数据
num_users = 100
num_records = 1000
user_ids = [random.randint(1000, 1100) for _ in range(num_users)]
events = [generate_event(random.choice(user_ids)) for _ in range(num_records)]
print(events)
# 构造DataFrame
events_df = pd.DataFrame(events)
events_df.sort_values("event_time", inplace=True)
events_df.reset_index(drop=True, inplace=True)

# 保存为CSV
file_path = "./user_behavior_realistic.csv"
events_df.to_csv(file_path, index=False)


