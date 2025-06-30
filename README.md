user_behavior_data_warehouse/
├── data/                  # 存放原始行为日志（已生成）
│   └── user_behavior_logs.csv
├── etl/
│   ├── load_ods.py        # 加载并清洗原始数据
│   ├── transform_dwd.py   # 标准化字段（行为枚举化）
│   ├── aggregate_dws.py   # 聚合成用户行为宽表
│   └── metrics_ads.py     # 计算 DAU、留存率、转化率
├── output/                # 最终指标报表输出
└── README.md              # 项目说明文档
