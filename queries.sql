Business Questions:

1. Which users did not log in during the past 5 months?

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
select *,round(((session_count- previous_session_count)/(session_count)*100),2) as percentage_change 
from previous_session



5. Which user had the highest session score each day?
select date,user_name,highest_session_score from
(select u.user_id,user_name,session_score as highest_session_score,date(login_timestamp) as date,
row_number() over (partition by date(login_timestamp) order by session_score desc) as row_num
from users u inner join logins l on u.user_id = l. user_id)T
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



