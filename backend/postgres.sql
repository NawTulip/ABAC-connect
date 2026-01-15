-- 1. Creating Tables

-- 1.1. Admin Table
CREATE TABLE admin (
    admin_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255)
);

-- 1.2. Student Table
CREATE TABLE student (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    password VARCHAR(255),
    profile_info TEXT
);

-- 1.3. Van Table
CREATE TABLE van (
    van_id SERIAL PRIMARY KEY,
    van_number VARCHAR(50),
    capacity INT,
    license_plate VARCHAR(50),
    status VARCHAR(20)
);

-- 1.4. Driver Table
CREATE TABLE driver (
    driver_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    contract VARCHAR(50),
    assigned_van_id INT REFERENCES van(van_id) ON DELETE SET NULL
);

-- 1.5. Route Table
CREATE TABLE route (
    route_id SERIAL PRIMARY KEY,
    start_location VARCHAR(100),
    end_location VARCHAR(100),
    stops TEXT,
    admin_id INT REFERENCES admin(admin_id) ON DELETE SET NULL
);

-- 1.6. Booking Table
CREATE TABLE booking (
    booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES student(user_id) ON DELETE CASCADE,
    route_id INT REFERENCES route(route_id) ON DELETE CASCADE,
    van_id INT REFERENCES van(van_id) ON DELETE SET NULL,
    driver_id INT REFERENCES driver(driver_id) ON DELETE SET NULL,
    booking_date DATE,
    pickup_location VARCHAR(100),
    dropoff_location VARCHAR(100),
    status VARCHAR(20)
);

-- 1.7. Payment Table
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES booking(booking_id) ON DELETE CASCADE,
    amount DECIMAL(10, 2),
    method VARCHAR(50),
    status VARCHAR(20)
);

-- 1.8. Feedback Table (Fixed)
CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    route_from VARCHAR(255) NOT NULL,
    route_to VARCHAR(255) NOT NULL,
    trip_details TEXT
);

-- 2. Sample Data Insertions
-- Final Project: ABAC Connect SQL Scripts
TRUNCATE TABLE feedback, payment, booking, driver, van_route, van, route, student, admin RESTART IDENTITY CASCADE;


-- Insert Admin Data
INSERT INTO admin (name, email, password) VALUES
('John Admin', 'admin@example.com', 'adminpassword'),
('Jane Admin', 'jane@example.com', 'jane123'),
('Mike Admin', 'mike@example.com', 'mikepass'),
('Sara Admin', 'sara@example.com', 'sarapass'),
('Tom Admin', 'tom@example.com', 'tompass');

-- Insert Student Data
INSERT INTO student (name, email, phone_number, password) VALUES
('Alice Student', 'alice@student.com', '1234567890', 'alice123'),
('Bob Student', 'bob@student.com', '0987654321', 'bob123'),
('Charlie Student', 'charlie@student.com', '1112223333', 'charlie123'),
('Daisy Student', 'daisy@student.com', '4445556666', 'daisy123'),
('Ethan Student', 'ethan@student.com', '7778889999', 'ethan123');

-- Insert Route Data
INSERT INTO route (start_location, end_location, stops, admin_id) VALUES
('Abacus', 'Hua Mak', 'Stop1, Stop2, Stop3', 1),
('Hua Mak', 'Bang Na', 'StopA, StopB, StopC', 2),
('Mega', 'Siam', 'Stop1, Stop2, Stop3', 3),
('Icon Siam', 'Hua Mak', 'StopA, StopB', 4),
('Central', 'Ladprao', 'StopX, StopY', 5);

-- Insert Van Data
INSERT INTO van (van_number, capacity, license_plate, status) VALUES
('Van 101', 12, 'AB-1234', 'Available'),
('Van 102', 10, 'CD-5678', 'Available'),
('Van 103', 15, 'EF-9012', 'Available'),
('Van 104', 8, 'GH-3456', 'Available'),
('Van 105', 14, 'IJ-7890', 'Available');

-- Insert Van-Route Assignments
INSERT INTO van_route (van_id, route_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3),
(5, 4);

-- Insert Driver Data
INSERT INTO driver (name, contract, assigned_van_id) VALUES
('David Driver', 'Full-Time', 1),
('Eve Driver', 'Part-Time', 2),
('Frank Driver', 'Full-Time', 3),
('Grace Driver', 'Part-Time', 4),
('Henry Driver', 'Full-Time', 5);

-- Insert Booking Data
INSERT INTO booking (user_id, route_id, van_id, driver_id, booking_date, pickup_location, dropoff_location, status) VALUES
(1, 1, 1, 1, '2025-02-20', 'Abacus', 'Hua Mak', 'Confirmed'),
(2, 2, 2, 2, '2025-02-21', 'Hua Mak', 'Bang Na', 'Pending'),
(3, 3, 3, 3, '2025-02-22', 'Mega', 'Siam', 'Confirmed'),
(4, 4, 4, 4, '2025-02-23', 'Icon Siam', 'Hua Mak', 'Pending'),
(5, 5, 5, 5, '2025-02-24', 'Central', 'Ladprao', 'Confirmed');

-- Insert Payment Data
INSERT INTO payment (booking_id, amount, method, status) VALUES
(1, 300.00, 'Credit Card', 'Paid'),
(2, 200.00, 'PromptPay', 'Pending'),
(3, 250.00, 'Credit Card', 'Paid'),
(4, 180.00, 'Cash', 'Pending'),
(5, 220.00, 'PromptPay', 'Paid');


TRUNCATE TABLE payment RESTART IDENTITY;



-- Insert Feedback Data
INSERT INTO feedback (booking_id, user_name, route_from, route_to, trip_details) VALUES
(1, 'Alice Student', 'Abacus', 'Hua Mak', 'Smooth ride and very punctual.'),
(2, 'Bob Student', 'Hua Mak', 'Bang Na', 'Comfortable seats, but slightly late.'),
(3, 'Charlie Student', 'Mega', 'Siam', 'Excellent service and friendly driver.'),
(4, 'Daisy Student', 'Icon Siam', 'Hua Mak', 'Good ride, but the air conditioning was weak.'),
(5, 'Ethan Student', 'Central', 'Ladprao', 'Overall a nice experience, but a bit bumpy.');




-- 3. SQL Queries with Joins

-- 3.1. Cross Join (Cartesian Product)
SELECT s.name AS student_name, v.van_number AS van_name
FROM student s
CROSS JOIN van v;

-- 3.2. Inner Join (Theta Join)
SELECT b.booking_id, s.name AS student_name, v.van_number, r.start_location, r.end_location
FROM booking b
INNER JOIN student s ON b.user_id = s.user_id
INNER JOIN van v ON b.van_id = v.van_id
INNER JOIN route r ON b.route_id = r.route_id
WHERE b.status = 'Confirmed';

-- 3.3. Natural Join
SELECT *
FROM booking
NATURAL JOIN student;

-- 3.4. Left Outer Join
SELECT s.name AS student_name, b.booking_id, b.status
FROM student s
LEFT OUTER JOIN booking b ON s.user_id = b.user_id;

-- 3.5. Right Outer Join
SELECT v.van_number, b.booking_id, b.status
FROM van v
RIGHT OUTER JOIN booking b ON v.van_id = b.van_id;

-- 3.6. Full Outer Join
SELECT r.start_location, b.booking_id, b.status
FROM route r
FULL OUTER JOIN booking b ON r.route_id = b.route_id;

-- 4. SQL Queries with Aggregation and Arithmetic Operations

-- 4.1. Count the Total Number of Bookings per Student
SELECT s.name, COUNT(b.booking_id) AS total_bookings
FROM student s
LEFT JOIN booking b ON s.user_id = b.user_id
GROUP BY s.name;

-- 4.2. Sum of Payments Made for a Specific Route
SELECT r.start_location, r.end_location, SUM(p.amount) AS total_paid
FROM route r
JOIN booking b ON r.route_id = b.route_id
JOIN payment p ON b.booking_id = p.booking_id
GROUP BY r.start_location, r.end_location;

-- 4.3. Average Booking Amount per Van
SELECT v.van_number, AVG(p.amount) AS avg_payment
FROM van v
JOIN booking b ON v.van_id = b.van_id
JOIN payment p ON b.booking_id = p.booking_id
GROUP BY v.van_number;

-- 4.4. Minimum and Maximum Booking Date for Each Van
SELECT v.van_number, MIN(b.booking_date) AS first_booking, MAX(b.booking_date) AS last_booking
FROM van v
JOIN booking b ON v.van_id = b.van_id
GROUP BY v.van_number;

-- 4.5. Arithmetic Operation to Calculate the Profit (e.g., Total Payment - Cost)
SELECT r.start_location, r.end_location, SUM(p.amount) - (COUNT(b.booking_id) * 50) AS profit
FROM route r
JOIN booking b ON r.route_id = b.route_id
JOIN payment p ON b.booking_id = p.booking_id
GROUP BY r.start_location, r.end_location;

-- 5. WHERE Clause Conditions

-- 5.1. Filter by Specific Status
SELECT * FROM booking
WHERE status = 'Confirmed';

-- 5.3. Using LIKE for Pattern Matching
SELECT * FROM van
WHERE van_number LIKE 'VAN%';

-- 5.4. Using IN for Multiple Conditions
SELECT * FROM payment
WHERE status IN ('Paid', 'Pending');

-- 5.5. Using EXISTS for Subqueries
SELECT * FROM route
WHERE EXISTS (
    SELECT 1 FROM booking b WHERE b.route_id = route.route_id
);

-- 5.6. Subquery to Find Students Who Have Booked Vans
SELECT name FROM student
WHERE user_id IN (
    SELECT user_id FROM booking WHERE status = 'Confirmed'
);

SELECT email, password FROM student

SELECT name, password FROM student

SELECT name, password FROM admin

SELECT * FROM admin 
WHERE name = 'admin_user' 
AND password_hash = crypt('securepassword', password_hash);


SELECT b.booking_id AS order_id, 
       s.name AS student_name, 
       r.start_location AS route_from, 
       r.end_location AS route_to, 
       CONCAT('Van: ', v.van_number, ', Date: ', b.booking_date) AS trip_details
FROM booking b
JOIN student s ON b.user_id = s.user_id
JOIN route r ON b.route_id = r.route_id
JOIN van v ON b.van_id = v.van_id
WHERE b.booking_id = 1;


DROP TABLE IF EXISTS feedback;

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES bookings(booking_id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    route_from VARCHAR(255) NOT NULL,
    route_to VARCHAR(255) NOT NULL,
    trip_details TEXT
);

ALTER TABLE booking ADD COLUMN seat_number INT;

CREATE TABLE van_route (
    van_id INT REFERENCES van(van_id) ON DELETE CASCADE,
    route_id INT REFERENCES route(route_id) ON DELETE CASCADE,
    PRIMARY KEY (van_id, route_id)
);


SELECT r.route_id, 
       r.start_location, 
       r.end_location, 
       b.trip_date, 
       v.van_number, 
       v.capacity - (CASE WHEN SUM(b.seats_booked) IS NULL THEN 0 ELSE SUM(b.seats_booked) END) AS available_seats
FROM route r
JOIN van_route vr ON r.route_id = vr.route_id  
JOIN van v ON vr.van_id = v.van_id
LEFT JOIN booking b ON r.route_id = b.route_id 
                    AND b.trip_date = '2025-03-22'  -- Filter by selected date
WHERE r.start_location = 'Abacus'
AND r.end_location = 'Hua Mak'
GROUP BY r.route_id, b.trip_date, v.van_number, v.capacity
HAVING (v.capacity - (CASE WHEN SUM(b.seats_booked) IS NULL THEN 0 ELSE SUM(b.seats_booked) END)) >= 6;


SELECT * FROM booking WHERE trip_date = '2025-02-20';




SELECT * FROM van_route;
INSERT INTO route (start_location, end_location, stops, admin_id)
VALUES ('Abacus', 'Hua Mak', 'Stop1, Stop2', 1);


SELECT * FROM route WHERE start_location = 'Abacus' AND end_location = 'Hua Mak';

ALTER TABLE booking ADD COLUMN trip_date DATE;
ALTER TABLE booking ADD COLUMN seats_booked INT DEFAULT 0;

SELECT payment_id, booking_id, amount, method, status
FROM payment
WHERE method IN ('Credit Card', 'PromptPay')
AND status = 'Pending';

CREATE TABLE passenger_details (
    passenger_id SERIAL PRIMARY KEY,
    booking_id INT REFERENCES booking(booking_id) ON DELETE CASCADE,
    passenger_name VARCHAR(100),
    gender VARCHAR(10),
    phone VARCHAR(20),
    special_request TEXT,
    departure_time TIME,
    number_of_seats INT,
    subtotal DECIMAL(10,2)
);
INSERT INTO passenger_details (booking_id, passenger_name, gender, phone, special_request, departure_time, number_of_seats, subtotal)
VALUES 
(1, 'John Doe', 'Male', '099909090', 'I have two luggages', '08:00:00', 6, 1200),
(2, 'Alice Smith', 'Female', '0888888888', 'Needs wheelchair assistance', '09:30:00', 2, 400),
(3, 'Bob Johnson', 'Male', '0777777777', 'Prefers front seat', '11:15:00', 1, 200),
(4, 'Emma Brown', 'Female', '0666666666', 'Traveling with a pet', '14:45:00', 3, 600),
(5, 'Charlie Wilson', 'Male', '0555555555', 'No special requests', '16:00:00', 4, 800);

SELECT * FROM passenger_details;

SELECT * FROM feedback;

SELECT * FROM admin 

















