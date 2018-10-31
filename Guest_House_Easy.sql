/* Guest House Easy Questions, from:
http://sqlzoo.net/wiki/Guest_House_Assessment_Easy */

/* QUESTION 1
Guest 1183. Give the booking_date and the number of nights for guest 1183. */
SELECT 
	guest_id,
    booking_date,
    nights
FROM 
	booking
WHERE 
	guest_id = 1183;

/* QUESTION 2
List the arrival time and the first and last names for all guests due to arrive
 on 2016-11-05, order the output by time of arrival. */
SELECT 
	b.booking_date,
    b.arrival_time,
    g.first_name,
    g.last_name
FROM
	booking b
	INNER JOIN 
		guest g 
		ON b.guest_id = g.id
WHERE 
	b.booking_date = '2016-11-05'
ORDER BY b.arrival_time ASC;

/* QUESTION 3
Look up daily rates. Give the daily rate that should be paid for bookings
with ids 5152, 5165, 5154 and 5295. Include booking id, room type, 
number of occupants and the amount. */
SELECT 
	b.booking_id,
    b.room_type_requested,
    b.occupants,
    r.amount
FROM
	booking b
	INNER JOIN
		rate r
		ON 
			b.room_type_requested = r.room_type 
			AND b.occupants = r.occupancy
WHERE 
	b.booking_id = 5152 
    OR b.booking_id = 5165
    OR b.booking_id = 5154
    OR b.booking_id = 5295;

/* QUESTION 4
Who’s in 101? Find who is staying in room 101 on 2016-12-03,
include first name, last name and address. */
SELECT
	g.first_name,
    g.last_name,
    g.address
FROM
	guest g
	INNER JOIN
		booking b
		ON g.id = b.guest_id
WHERE
	(b.room_no = 101 
    AND b.booking_date = '2016-12-03');
    
/* QUESTION 5
How many bookings, how many nights? For guests 1185 and 1270 show the number of
bookings made and the total number nights. Your output should include the guest id
and the total number of bookings and the total number of nights. */
SELECT 
	guest_id,
    COUNT(booking_id) AS num_bookings,
    SUM(nights) AS total_nights
FROM 
	booking
WHERE 
	guest_id =1185
    OR guest_id = 1270
GROUP BY guest_id;
