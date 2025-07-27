CREATE DATABASE IF NOT EXISTS user_data_dev;
USE user_data_dev;
CREATE TABLE ods_user_behavior (
    event_time DATETIME,
    user_id INT,
    event_type VARCHAR(50),
    page_id VARCHAR(100)
);
SELECT * FROM ods_user_behavior LIMIT 10;
CREATE TABLE IF NOT EXISTS dwd_user_behavior (
    event_time DATETIME,
    user_id INT,
    event_type VARCHAR(50),
    page_id VARCHAR(100),
    event_hour INT,
    behavior_category VARCHAR(50)
);
INSERT INTO dwd_user_behavior (event_time, user_id, event_type, page_id, event_hour, behavior_category)
SELECT
    event_time,
    user_id,
    event_type,
    page_id,
    HOUR(event_time) AS event_hour,
    CASE 
        WHEN event_type IN ('click', 'view', 'browse') THEN 'browse'
        WHEN event_type IN ('order', 'pay', 'purchase') THEN 'purchase'
        WHEN event_type = 'login' THEN 'login'
        ELSE 'other'
    END AS behavior_category
FROM (
    SELECT DISTINCT * FROM ods_user_behavior
) AS tmp;
SELECT * FROM dwd_user_behavior LIMIT 10;

CREATE TABLE IF NOT EXISTS dws_user_profile (
    user_id INT PRIMARY KEY,
    first_event_time DATETIME,
    last_event_time DATETIME,
    total_event_count INT,
    click_count INT,
    order_count INT,
    login_count INT,
    active_days INT
);

INSERT INTO dws_user_profile (
    user_id, first_event_time, last_event_time,
    total_event_count, click_count, order_count,
    login_count, active_days
)
SELECT
    user_id, MIN(event_time), MAX(event_time),
    COUNT(*),
    SUM(CASE WHEN behavior_category = 'browse' THEN 1 ELSE 0 END),
    SUM(CASE WHEN behavior_category = 'purchase' THEN 1 ELSE 0 END),
    SUM(CASE WHEN behavior_category = 'login' THEN 1 ELSE 0 END),
    COUNT(DISTINCT DATE(event_time))
FROM dwd_user_behavior
GROUP BY user_id
ON DUPLICATE KEY UPDATE
    first_event_time = VALUES(first_event_time),
    last_event_time = VALUES(last_event_time),
    total_event_count = VALUES(total_event_count),
    click_count = VALUES(click_count),
    order_count = VALUES(order_count),
    login_count = VALUES(login_count),
    active_days = VALUES(active_days);


SELECT * FROM dws_user_profile LIMIT 10;


CREATE TABLE IF NOT EXISTS ads_daily_active_users (
    log_date DATE PRIMARY KEY,
    dau INT
);

INSERT INTO ads_daily_active_users
SELECT
    DATE(event_time) AS log_date,
    COUNT(DISTINCT user_id) AS dau
FROM dwd_user_behavior
GROUP BY log_date;

CREATE TABLE IF NOT EXISTS ads_user_funnel (
    log_date DATE PRIMARY KEY,
    login_users INT,
    click_users INT,
    order_users INT
);

INSERT INTO ads_user_funnel
SELECT
    DATE(event_time) AS log_date,
    COUNT(DISTINCT CASE WHEN behavior_category = 'login' THEN user_id END) AS login_users,
    COUNT(DISTINCT CASE WHEN behavior_category = 'browse' THEN user_id END) AS click_users,
    COUNT(DISTINCT CASE WHEN behavior_category = 'purchase' THEN user_id END) AS order_users
FROM dwd_user_behavior
GROUP BY log_date;

CREATE TABLE IF NOT EXISTS ads_first_order_users (
    user_id INT PRIMARY KEY,
    first_order_dt DATE
);

INSERT INTO ads_first_order_users
SELECT
    user_id,
    MIN(DATE(event_time)) AS first_order_dt
FROM dwd_user_behavior
WHERE behavior_category = 'purchase'
GROUP BY user_id;

SELECT * FROM ads_daily_active_users ORDER BY log_date LIMIT 5;
SELECT * FROM ads_user_funnel ORDER BY log_date LIMIT 5;
SELECT * FROM ads_first_order_users LIMIT 5;

