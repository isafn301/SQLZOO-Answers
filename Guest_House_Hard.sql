/* Guest House Hard Questions, from:
http://sqlzoo.net/wiki/Guest_House_Assessment_Hard */

/* QUESTION 11
Coincidence. Have two guests with the same surname ever stayed in the hotel
on the evening? Show the last name and both first names. Do not include duplicates. */

SELECT DISTINCT 
	a.last_name,
    a.first_name, 
    b.first_name
FROM
	(SELECT *
		FROM 
			booking
			INNER JOIN
				guest 
			ON guest.id = booking.guest_id
	) a, 
	(SELECT *
		FROM 
			booking
		INNER JOIN
			guest 
		ON guest.id = booking.guest_id
	) b
    
WHERE 
	a.last_name = b.last_name
	AND a.first_name > b.first_name
	AND a.booking_date <= b.booking_date
	AND (a.booking_date + INTERVAL a.nights DAY)>b.booking_date
ORDER BY a.last_name;

/* QUESTION 12
Check out per floor. The first digit of the room number indicates the floor 
– e.g. room 201 is on the 2nd floor. For each day of the week beginning 
2016-11-14 show how many guests are checking out that day by floor number. 
Columns should be day (Monday, Tuesday ...), floor 1, floor 2, floor 3. */

SELECT 
	(booking_date + INTERVAL nights DAY) as check_out,
	DATE_FORMAT((booking_date + INTERVAL nights DAY), '%W') as weekday, 
	SUM(CASE WHEN room_no LIKE '1%' THEN 1 ELSE 0 END) AS 1st_floor,
	SUM(CASE WHEN room_no LIKE '2%' THEN 1 ELSE 0 END) AS 2nd_floor,
	SUM(CASE WHEN room_no LIKE '3%' THEN 1 ELSE 0 END) AS 3rd_floor
FROM 
	booking
WHERE 
	(booking_date + INTERVAL nights DAY) BETWEEN '2016-11-14'
    AND ('2016-11-14' + INTERVAL 6 DAY)
GROUP BY check_out, weekday
ORDER BY check_out;

/* QUESTION 13
Who is in 207? Who is in room 207 during the week beginning 21st Nov. 
Be sure to list those days when the room is empty. Show the date and the last name.
You may find the table calendar useful for this query. */

SELECT 
	c.i AS date,
    CASE WHEN g.last_name IS NULL THEN 'EMPTY' ELSE g.last_name END AS last_name
FROM 
	calendar c
	LEFT JOIN
		booking b
		ON b.booking_date <= c.i
        AND (b.booking_date + INTERVAL b.nights DAY)>c.i
        AND b.room_no =207
	LEFT JOIN 
		guest g
		ON g.id = b.guest_id

WHERE 
	c.i BETWEEN '2016-11-21' AND '2016-11-21' + INTERVAL 6 DAY
ORDER BY date;

/* QUESTION 14
Double room for seven nights required. A customer wants a double room for 7 
consecutive nights as some time between 2016-11-03 and 2016-12-19. 
Show the date and room number for the first such availabilities. */

SET @row_number1 := 0;
SELECT 
	MIN(xx.i-INTERVAL xx.nights_empty -1  DAY) AS date,
    xx.room_no
	FROM (
		SELECT 
			x.i,
            x.room_no,
            x.booking_date,
            x.prev_room,
			@row_number1 := CASE
				WHEN x.booking_date IS NULL AND x.prev_room = x.room_no 
					THEN @row_number1 +1
				WHEN x.booking_date IS NULL AND x.prev_room <> x.room_no
					THEN 1
				ELSE 0
			END AS nights_empty
            #Calculate the number of days in a row a room is empty
            #We compare with the previous room_no to make sure we are counting for the same room
            
		FROM(
			SELECT
				a.i,
				a.room_no,
                b.booking_date,
				LAG(a.room_no) OVER (ORDER BY a.room_no, a.i) AS prev_room
                #Save the previous room number

			FROM (
				SELECT
					c.i,
                    r.id as room_no
				FROM
					calendar c
					CROSS JOIN room r 
				WHERE
					r.room_type = 'double'
					AND c.i BETWEEN '2016-11-03' AND '2016-12-19' 
			) AS a #We obtain a table of room number and dates
				LEFT JOIN booking b #We join this table 'a' with the bookings
					ON b.booking_date <= a.i
					AND (b.booking_date + INTERVAL b.nights DAY)>a.i
					AND a.room_no = b.room_no

			ORDER BY room_no, i
		) AS x
	) AS xx
WHERE 
	xx.nights_empty = 7
GROUP BY xx.room_no
ORDER BY date;

/* QUESTION 15
Gross income by week. Money is collected from guests when they leave. 
For each Thursday in November show the total amount of money collected from
the previous Friday to that day, inclusive. */

SELECT 
	t.next_thurs, 
    SUM(t.total_amount) AS week_amount
    
FROM (
	SELECT 
		b.booking_id, 
		b.booking_date, 
		b.booking_date + INTERVAL b.nights DAY AS checkout_date,
		b.occupants, 
		b.room_type_requested, 
		b.nights, 
		r.amount AS room_rate,
		e.extra_amount,
		CASE
			WHEN e.extra_amount IS NULL THEN r.amount*b.nights
			ELSE (r.amount*b.nights + e.extra_amount)
		END AS total_amount,
		#Look for the next Thursday (hence the 5)
        CASE 
			#For Sun (1) to Thurs (5)
            WHEN (5 - DAYOFWEEK(b.booking_date + INTERVAL b.nights DAY)) >= 0 
				THEN (b.booking_date + INTERVAL b.nights DAY) + INTERVAL (5 - DAYOFWEEK(b.booking_date + INTERVAL b.nights DAY)) DAY
			#For Fri (6) and Sat (7)
            ELSE (b.booking_date + INTERVAL b.nights DAY) + INTERVAL (12 - DAYOFWEEK(b.booking_date + INTERVAL b.nights DAY)) DAY
		END AS next_thurs
	FROM
		booking b
		INNER JOIN
			rate r
			ON 	b.room_type_requested = r.room_type 
			AND b.occupants = r.occupancy
		LEFT JOIN
			(SELECT 
				booking_id,
				SUM(amount) as extra_amount
			FROM 
				extra
			GROUP BY booking_id
			) AS e
			ON b.booking_id = e.booking_id
	) AS t
WHERE 
	DATE_FORMAT(next_thurs,'%m') = 11
GROUP BY t.next_thurs
ORDER BY t.next_thurs;