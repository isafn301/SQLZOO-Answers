/* Guest House Medium Questions, from:
http://sqlzoo.net/wiki/Guest_House_Assessment_Medium */

/* QUESTION 6
Ruth Cadbury. Show the total amount payable by guest Ruth Cadbury
 for her room bookings. You should JOIN to the rate table using 
 room_type_requested and occupants. */

SELECT
	g.first_name,
    	g.last_name,
    	SUM(a.nights*a.amount) as total_amount
FROM
	(SELECT
		b.guest_id,
		b.room_type_requested,
        	b.occupants,
        	b.nights,
        	r.amount
	FROM
		booking b
		INNER JOIN
			rate r
			ON
				b.room_type_requested = r.room_type 
				AND b.occupants = r.occupancy
	) AS a
    
	INNER JOIN
		guest g
		ON g.id = a.guest_id

WHERE 
	g.first_name = 'Ruth'
	AND g.last_name = 'Cadbury'
    
GROUP BY g.first_name, g.last_name;

/* QUESTION 7
Including Extras. Calculate the total bill for booking 5128 including extras. */

SELECT
	booking_id,	
    	SUM(amount) as total_amount
FROM(
	(SELECT
		b.booking_id,
		b.nights*r.amount as amount
	FROM
		booking b
		INNER JOIN
			rate r
			ON b.room_type_requested = r.room_type 
			AND b.occupants = r.occupancy)

	UNION ALL

	(SELECT
		booking_id,
        	SUM(amount)
	FROM 
		extra
	GROUP BY booking_id)
    ) a
WHERE 
	booking_id = 5128
GROUP BY booking_id;

/* QUESTION 8
Edinburgh Residents. For every guest who has the word “Edinburgh” in their
address show the total number of nights booked. Be sure to include 0 for
those guests who have never had a booking. Show last name, first name, 
address and number of nights. Order by last name then first name. */

SELECT 
	g.first_name,
    	g.last_name,
    	g.address, 
	CASE
		WHEN SUM(b.nights) IS NULL THEN 0
		ELSE SUM(b.nights)
	END AS nights
FROM
	guest g
	LEFT JOIN
		booking b
		ON b.guest_id = g.id
WHERE
	address LIKE '%Edinburgh%'
GROUP BY g.first_name, g.last_name, g.address
ORDER BY address;

/* QUESTION 9
Show the number of people arriving. For each day of the week beginning 2016-11-25
show the number of people who are arriving that day. */

SELECT 
	booking_date, 
    	DATE_FORMAT(booking_date, '%W') AS weekday,
    	COUNT(booking_id) AS arrivals
FROM
	booking
WHERE 
	DATEDIFF(booking_date, '2016-11-25') <7 
	AND DATEDIFF(booking_date, '2016-11-25') >=0 
GROUP BY booking_date, weekday
ORDER BY booking_date;

/* QUESTION 10
How many guests? Show the number of guests in the hotel on the night of 2016-11-21.
Include all those who checked in that day or before but not those who have check out
on that day or before.*/

SELECT 
	SUM(occupants)
FROM
	booking
WHERE
	booking_date <= '2016-11-21'
    	AND (booking_date + INTERVAL nights DAY)>'2016-11-21';
