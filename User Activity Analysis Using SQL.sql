use user_activity

--  Creating Users Table 
CREATE TABLE users (
    USER_ID INT PRIMARY KEY,
    USER_NAME VARCHAR(20) NOT NULL,
    USER_STATUS VARCHAR(20) NOT NULL
);
-- Creating Logins Table
CREATE TABLE logins (
    USER_ID INT,
    LOGIN_TIMESTAMP DATETIME NOT NULL,
    SESSION_ID INT PRIMARY KEY,
    SESSION_SCORE INT,
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID)
);

-- Inserting Users Informtion into Users Table
INSERT INTO USERS VALUES (1, 'Alice', 'Active');
INSERT INTO USERS VALUES (2, 'Bob', 'Inactive');
INSERT INTO USERS VALUES (3, 'Charlie', 'Active');
INSERT INTO USERS  VALUES (4, 'David', 'Active');
INSERT INTO USERS  VALUES (5, 'Eve', 'Inactive');
INSERT INTO USERS  VALUES (6, 'Frank', 'Active');
INSERT INTO USERS  VALUES (7, 'Grace', 'Inactive');
INSERT INTO USERS  VALUES (8, 'Heidi', 'Active');
INSERT INTO USERS VALUES (9, 'Ivan', 'Inactive');
INSERT INTO USERS VALUES (10, 'Judy', 'Active');

-- Inserting Logins Informtion into Logins Table
INSERT INTO LOGINS  VALUES (1, '2023-07-15 09:30:00', 1001, 85);
INSERT INTO LOGINS VALUES (2, '2023-07-22 10:00:00', 1002, 90);
INSERT INTO LOGINS VALUES (3, '2023-08-10 11:15:00', 1003, 75);
INSERT INTO LOGINS VALUES (4, '2023-08-20 14:00:00', 1004, 88);
INSERT INTO LOGINS  VALUES (5, '2023-09-05 16:45:00', 1005, 82);

INSERT INTO LOGINS  VALUES (6, '2023-10-12 08:30:00', 1006, 77);
INSERT INTO LOGINS  VALUES (7, '2023-11-18 09:00:00', 1007, 81);
INSERT INTO LOGINS VALUES (8, '2023-12-01 10:30:00', 1008, 84);
INSERT INTO LOGINS  VALUES (9, '2023-12-15 13:15:00', 1009, 79);


INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1011, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2024-01-25 09:30:00', 1012, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-02-05 11:00:00', 1013, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2024-03-01 14:30:00', 1014, 91);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-03-15 16:00:00', 1015, 83);

INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2024-04-12 08:00:00', 1016, 80);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (7, '2024-05-18 09:15:00', 1017, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (8, '2024-05-28 10:45:00', 1018, 87);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (9, '2024-06-15 13:30:00', 1019, 76);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-25 15:00:00', 1010, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-26 15:45:00', 1020, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-27 15:00:00', 1021, 92);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (10, '2024-06-28 15:45:00', 1022, 93);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (1, '2024-01-10 07:45:00', 1101, 86);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (3, '2024-01-25 09:30:00', 1102, 89);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (5, '2024-01-15 11:00:00', 1103, 78);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (2, '2023-11-10 07:45:00', 1201, 82);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (4, '2023-11-25 09:30:00', 1202, 84);
INSERT INTO LOGINS (USER_ID, LOGIN_TIMESTAMP, SESSION_ID, SESSION_SCORE) VALUES (6, '2023-11-15 11:00:00', 1203, 80);
=========================================================================================================================
Business Questions:

1. Which users did not log in during the past 5 months?
Current Date : 02-08-2024
Past 5 Month : 02-03-2024
Mthd 1:
select distinct user_id from logins
where user_id not in
(select user_id from logins
group by user_id
having max(date(login_timestamp)) > date_sub(curdate(), interval 5 month))

Mthd 2:
select user_id,max(login_timestamp) as last_login
from logins
group by user_id
having max(login_timestamp) < date_sub(curdate(), interval 5 month)


2.How many users and sessions were there in each quarter, ordered from newest to oldest?
select quarter(login_timestamp) as quarter_no,
date_format(min(login_timestamp), '%Y-%m-01') as first_date_of_quarter,
min(date(login_timestamp)) as first_date,
count(*) as session_count,count(distinct user_id) as user_count 
from logins
group by quarter(login_timestamp)




3. Which users logged in during January 2024 but did not log in during November 2023?
select distinct user_id from logins
where date(login_timestamp) between '2024-01-01' and '2024-01-31'
except
select distinct user_id from logins
where date(login_timestamp) between '2023-11-01' and '2023-11-30'


4. What is the percentage change in sessions from the last quarter?
with previous_session as
(
select quarter(login_timestamp) as quarter_num, 
count(*) as session_count ,
lag(count(*)) over (order by quarter(login_timestamp)) as previous_session_count
from logins
group by quarter(login_timestamp)
)
select *,round(((session_count- previous_session_count)/(session_count)*100),2) as percentage_change from previous_session



5. Which user had the highest session score each day?
select * from
(select user_id,session_score,date(login_timestamp),
row_number() over (partition by date(login_timestamp) order by session_score desc) as row_num
from logins)T
where row_num=1

6.Which users have had a session every single day since their first login?
select user_id, min(date(login_timestamp)) as first_login,count(distinct date(login_timestamp)) as no_of_logins_made,
datediff(curdate(),min(date(login_timestamp))) as no_of_logins_required
from logins
group by user_id
having count(distinct date(login_timestamp)) = datediff(curdate(),min(date(login_timestamp)))

7. On what dates were there no logins at all?

with recursive cte as
(
select min(date(login_timestamp)) as first_date, max(date(login_timestamp)) as last_date 
from logins
union all
select date_add(first_date, interval 1 day), last_date  from cte
where  first_date <  last_date
)
select * from cte
where first_date not in (select distinct date(login_timestamp) from logins)



==================================================================================================================




