import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import date
# 设置中文字体为 SimHei（黑体）
plt.rcParams['font.sans-serif'] = ['SimHei']
# 正常显示负号
plt.rcParams['axes.unicode_minus'] = False
# 建立连接
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='960917',
    database='user_data_dev'
)

query = "SELECT * FROM ads_user_funnel ORDER BY log_date"
df = pd.read_sql(query, conn)
conn.close()

print(df)

import matplotlib.pyplot as plt

# 选择某一天的数据绘制
selected_date= date(2025, 7, 5)
row = df[df["log_date"] ==selected_date].iloc[0]
print("0705:",row)
# print(df["log_date"].dtype)
# print(df["log_date"].head())
# print("打印log_date",repr(df["log_date"].tolist()))
funnel = {
    '登录': row['login_users'],
    '浏览': row['click_users'],
    '下单': row['order_users']
}

# 绘图
plt.figure(figsize=(8, 5))
plt.barh(list(funnel.keys())[::-1], list(funnel.values())[::-1], color='skyblue')
plt.title(f'用户行为漏斗图:{selected_date}')
plt.xlabel('用户数')
for i, v in enumerate(list(funnel.values())[::-1]):
    plt.text(v + 1, i, str(v), va='center')
plt.tight_layout()
plt.show()