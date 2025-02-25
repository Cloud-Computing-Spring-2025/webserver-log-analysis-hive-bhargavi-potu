-- Create the external table
CREATE EXTERNAL TABLE IF NOT EXISTS web_logs (
    ip STRING,
    `timestamp` STRING,
    url STRING,
    status INT,
    user_agent STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/web_logs';

-- Load data into Hive table
LOAD DATA INPATH '/data/web_logs/web_server_logs.csv' INTO TABLE web_logs;

-- Fetch first 5 rows
SELECT * FROM web_logs LIMIT 5;

-- Count total requests
SELECT COUNT(*) AS total_requests FROM web_logs;

-- Count requests by status code
SELECT status, COUNT(*) AS count FROM web_logs GROUP BY status;

-- Most visited URLs
SELECT url, COUNT(*) AS visits FROM web_logs GROUP BY url ORDER BY visits DESC LIMIT 3;

-- Count requests per user agent
SELECT user_agent, COUNT(*) AS count FROM web_logs GROUP BY user_agent ORDER BY count DESC;

-- Find IPs with more than 3 failed requests (404, 500)
SELECT ip, COUNT(*) AS failed_requests FROM web_logs 
WHERE status IN (404, 500) GROUP BY ip HAVING COUNT(*) > 3;

-- Requests per minute
SELECT substr(`timestamp`, 0, 16) AS minute, COUNT(*) AS requests 
FROM web_logs GROUP BY substr(`timestamp`, 0, 16) ORDER BY minute;
