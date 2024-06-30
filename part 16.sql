use tips;

create table tickets
(ticket_id INT,
create_date DATE,
resolved_date DATE);

INSERT INTO tickets VALUES
(1, '2022-08-01', '2022-08-03'),
(2, '2022-08-01', '2022-08-12'),
(3, '2022-08-01', '2022-08-16');

create table holiday
(holiday_date DATE,
reason VARCHAR(50));

INSERT INTO holiday VALUES
('2022-08-11', "RAKHI"),
('2022-08-15', "INDEPENDENCE DAY");

-- days between two dates
SELECT *, DATEDIFF(resolved_date, create_date) as actual_days
FROM tickets;

-- week difference
SELECT *,
(WEEKOFYEAR(resolved_date) ) - (WEEKOFYEAR(create_date) ) as week_diff
FROM tickets;

-- find working days including public holidays
SELECT *,
DATEDIFF(resolved_date, create_date) - 
2*((WEEKOFYEAR(resolved_date)) - (WEEKOFYEAR(create_date))) AS working_days
FROM tickets;

-- find public holiday
SELECT * FROM tickets
LEFT JOIN holiday ON holiday_date BETWEEN create_date AND resolved_date;
SELECT ticket_id, create_date, resolved_date, COUNT(holiday_date) AS no_ofholidays 
FROM tickets
LEFT JOIN holiday ON holiday_date BETWEEN create_date AND resolved_date
GROUP BY ticket_id, create_date, resolved_date ;

-- find business days excluding public holiday n weekends
SELECT *,DATEDIFF(resolved_date, create_date) as actual_days,
(WEEKOFYEAR(resolved_date) ) - (WEEKOFYEAR(create_date) ) as week_diff,
DATEDIFF(resolved_date, create_date) - 
(2*((WEEKOFYEAR(resolved_date)) - (WEEKOFYEAR(create_date))) ) - no_ofholidays AS business_days
FROM
(SELECT ticket_id, create_date, resolved_date, COUNT(holiday_date) AS no_ofholidays 
FROM tickets
LEFT JOIN holiday ON holiday_date BETWEEN create_date AND resolved_date
GROUP BY ticket_id, create_date, resolved_date
) A

-- what if public holiday is on weekend





