# Web Server Log Analysis with Apache Hive

## Project Overview
This project involves analyzing web server logs using Apache Hive to gain insights into website traffic patterns. By querying log data, we can extract valuable information such as request frequency, status code distribution, popular URLs, and user agents. Additionally, we identify suspicious activity and observe traffic trends over time.

## Implementation Approach
The project follows these steps:
1. **Setup Hive Environment**: Create a Hive database and an external table for web server logs.
2. **Loading Data**: Store the CSV log data in HDFS and load it into the Hive table.
3. **Executing Queries**: Perform analytical queries to extract insights.
4. **Detecting Suspicious Activity**: Identify abnormal patterns in log data.
5. **Optimizing Query Performance**: Implement partitioning to speed up query execution.
6. **Generating Reports**: Export query results to a text file for further analysis.

## Execution Steps
### 1. Setting Up Environment
```sh
docker exec -it namenode /bin/bash
hdfs dfs -ls /
hdfs dfs -mkdir -p /data/web_logs
mkdir -p /data/web_logs
ls -l /data/web_logs
exit
```

### 2. Loading Data to HDFS
```sh
docker cp /workspaces/webserver-log-analysis-hive-bhargavi-potu/web_server_logs.csv namenode:/data/web_logs/web_server_logs.csv

docker exec -it namenode /bin/bash
ls -l /data/web_logs/
hdfs dfs -mkdir -p /data/web_logs
hdfs dfs -put /data/web_logs/web_server_logs.csv /data/web_logs/
hdfs dfs -ls /data/web_logs/
exit
```

### 3. Setting Up Hive Table
```sh
docker exec -it hive-server /bin/bash
hive
```
```sql
-- Create an external table for web logs
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
```

### 4. Executing Queries
```sql
-- Retrieve first 5 records
SELECT * FROM web_logs LIMIT 5;

-- Count total requests
SELECT COUNT(*) AS total_requests FROM web_logs;

-- Count requests per status code
SELECT status, COUNT(*) AS count FROM web_logs GROUP BY status;

-- Most visited URLs
SELECT url, COUNT(*) AS visits FROM web_logs GROUP BY url ORDER BY visits DESC LIMIT 3;

-- Count requests per user agent
SELECT user_agent, COUNT(*) AS count FROM web_logs GROUP BY user_agent ORDER BY count DESC;

-- Find IPs with more than 3 failed requests (404, 500)
SELECT ip, COUNT(*) AS failed_requests FROM web_logs WHERE status IN (404, 500) GROUP BY ip HAVING COUNT(*) > 3;

-- Requests per minute
SELECT substr(`timestamp`, 0, 16) AS minute, COUNT(*) AS requests FROM web_logs GROUP BY substr(`timestamp`, 0, 16) ORDER BY minute;
```

### 5. Running Queries from File
```sh
touch hql_queries.hql
code hql_queries.hql

docker cp hql_queries.hql hive-server:/opt/hql_queries.hql
docker exec -it hive-server ls -l /opt/hql_queries.hql
docker exec -it hive-server /bin/bash
hive -f /opt/hql_queries.hql | tee /opt/hql_output.txt

docker cp hive-server:/opt/hql_output.txt hql_output.txt
ls -l
```

## Challenges Faced
1. **Data Parsing Errors**: Some records had NULL values that needed handling in Hive queries.
2. **HDFS Permissions Issues**: Required setting correct ownership and permissions for seamless data loading.
3. **Query Performance Optimization**: Using partitioning improved execution efficiency.
4. **Log Data Variability**: Ensured all fields in log data matched expected formats.

## Sample Input
CSV file format:
```csv
ip,timestamp,url,status,user_agent
192.168.1.1,2024-02-01 10:15:00,/home,200,Mozilla/5.0
192.168.1.2,2024-02-01 10:16:00,/products,200,Chrome/90.0
192.168.1.3,2024-02-01 10:17:00,/checkout,404,Safari/13.1
192.168.1.10,2024-02-01 10:18:00,/home,500,Mozilla/5.0
192.168.1.15,2024-02-01 10:19:00,/products,404,Chrome/90.0
```

## Expected Output
```
Total Web Requests:
Total Requests: 101

Status Code Analysis:
200: 57
404: 21
500: 22

Most Visited Pages:
/products: 24
/contact: 24
/home: 20

Traffic Source Analysis:
Edge/88.0: 23
Chrome/90.0: 23
Opera/74.0: 21
Safari/13.1: 17
Mozilla/5.0: 16

Suspicious IP Addresses:
192.168.1.1: 5 failed requests
192.168.1.15: 7 failed requests
192.168.1.2: 6 failed requests
192.168.1.20: 6 failed requests
192.168.1.25: 4 failed requests
192.168.1.3: 9 failed requests

Traffic Trend Over Time:
2024-02-01 10:15: 7 requests
2024-02-01 10:16: 2 requests
2024-02-01 10:17: 3 requests
...
2024-02-01 10:59: 3 requests
```

This project effectively demonstrates web log analysis using Apache Hive, providing insights into traffic patterns, request sources, and potential security threats through comprehensive query execution.

