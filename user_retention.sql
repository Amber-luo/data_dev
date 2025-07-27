WITH first_day_users AS (
    SELECT 
        user_id, 
        MIN(DATE(event_time)) AS create_date
    FROM dwd_user_behavior
    GROUP BY user_id
),
retention_check AS (
    SELECT 
        f.create_date,
        DATEDIFF(DATE(d.event_time), f.create_date) AS retention_day,
        d.user_id
    FROM first_day_users f
    JOIN dwd_user_behavior d
        ON f.user_id = d.user_id
    WHERE DATEDIFF(DATE(d.event_time), f.create_date) IN (1, 3, 7)
)
SELECT
    create_date,
    retention_day,
    COUNT(DISTINCT user_id) AS retained_users
FROM retention_check
GROUP BY create_date, retention_day;

CREATE TABLE ads_user_retention (
    create_date DATE,               -- 用户的首次行为日期
    retention_day INT,             -- 第几日的留存（1、3、7）
    retained_users INT             -- 留存用户数量
);

INSERT INTO ads_user_retention (create_date, retention_day, retained_users)
SELECT
    create_date,
    retention_day,
    COUNT(DISTINCT user_id) AS retained_users
FROM (
    SELECT 
        f.create_date,
        DATEDIFF(DATE(d.event_time), f.create_date) AS retention_day,
        d.user_id
    FROM (
        SELECT 
            user_id, 
            MIN(DATE(event_time)) AS create_date
        FROM dwd_user_behavior
        GROUP BY user_id
    ) f
    JOIN dwd_user_behavior d
        ON f.user_id = d.user_id
    WHERE DATEDIFF(DATE(d.event_time), f.create_date) IN (1, 3, 7)
) AS retention_check
GROUP BY create_date, retention_day;

-- select * from ads_user_retention;
select * from ads_user_funnel
