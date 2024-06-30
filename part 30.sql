use tips;
create table booking
(booking_id varchar(10),
booking_date date,
user_id varchar(10),
line_of_business varchar(512));
insert into booking values
('b1','2022-03-23','u1','flight'),('b2','2022-03-27','u2','flight'),
('b3','2022-03-28','u1','hotel'),('b4','2022-03-31','u4','flight'),
('b5','2022-04-02','u1','hotel'),('b6','2022-04-02','u2','flight'),
('b7','2022-04-06','u5','flight'),('b8','2022-04-06','u6','hotel'),
('b9','2022-04-06','u2','flight'),('b10','2022-04-10','u1','flight'),
('b11','2022-04-12','u4','flight'),('b12','2022-04-16','u1','flight'),
('b13','2022-04-19','u2','flight'),('b14','2022-04-20','u5','hotel'),
('b15','2022-04-22','u6','flight'),('b16','2022-04-26','u4','hotel'),
('b17','2022-04-28','u2','hotel'),('b18','2022-04-30','u1','hotel'),
('b19','2022-05-04','u1','hotel'),('b20','2022-05-06','u1','flight');
create table user
(user_id varchar(10),
segment varchar(10));
insert into user values
('u1','s1'),('u2','s1'),('u3','s1'),
('u4','s2'),('u5','s2'),('u6','s3'),
('u7','s3'),('u8','s3'),('u9','s3'),('u10','s3');

-- query 1
SELECT u.segment, COUNT(DISTINCT u.user_id) AS no_of_users,
COUNT(DISTINCT CASE WHEN b.line_of_business='flight' AND 
		b.booking_date BETWEEN '2022-04-01' AND '2022-04-30' 
        THEN b.user_id END) AS user_who_booked_flight_in_apr2022
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id
GROUP BY u.segment;

-- query 2
-- method 1
SELECT * FROM (
	SELECT *,
	RANK() OVER(PARTITION BY user_id ORDER BY booking_date) AS rn
	FROM booking) rank_users
WHERE rn=1 AND line_of_business='hotel';

-- method 2
SELECT DISTINCT user_id FROM (
	SELECT *,
	FIRST_VALUE(line_of_business) OVER(PARTITION BY user_id ORDER BY booking_date) AS first_booking
	FROM booking) book_users
WHERE first_booking='hotel';

-- query 3
SELECT user_id, MIN(booking_date) AS first_booking, 
	MAX(booking_date) AS last_booking,
	DATEDIFF(MAX(booking_date), MIN(booking_date)) AS no_of_days
FROM booking
GROUP BY user_id;

-- query 4
-- by segment
SELECT segment,
SUM(CASE WHEN line_of_business='flight' THEN 1 ELSE 0 END) AS flight_booking,
SUM(CASE WHEN line_of_business='hotel' THEN 1 ELSE 0 END) AS hotel_booking
FROM booking b
INNER JOIN user u ON b.user_id=u.user_id
GROUP BY segment;

-- by user_id
SELECT user_id,
SUM(CASE WHEN line_of_business='flight' THEN 1 ELSE 0 END) AS flight_booking,
SUM(CASE WHEN line_of_business='hotel' THEN 1 ELSE 0 END) AS hotel_booking
FROM booking b
-- INNER JOIN user u ON b.user_id=u.user_id
GROUP BY user_id;











