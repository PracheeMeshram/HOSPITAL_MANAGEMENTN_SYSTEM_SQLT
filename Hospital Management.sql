create database projects;
use projects;

select *from appointments;

select *from billing;

select *from doctors;

select *from medications;

select *from patients;



-- View for upcoming appointments

CREATE OR REPLACE VIEW UpcomingAppointments AS
SELECT
    appointments.AppointmentID,
    CONCAT(patients.First_Name, ' ', patients.Last_Name) AS PatientName,
    CONCAT(doctors.First_Name, ' ', doctors.Last_Name) AS DoctorName,
    appointments.AppointmentDate,
    appointments.Reason
FROM projects.appointments
JOIN projects.patients ON appointments.PatientID = patients.PatientID
JOIN projects.doctors ON appointments.DoctorID = doctors.DoctorID
WHERE appointments.AppointmentDate >= NOW();

SELECT * FROM UpcomingAppointments;


-- Procedure to get a patient's full medical history

DELIMITER //

CREATE PROCEDURE projects.GetPatientHistory(IN pid INT)
BEGIN
    -- Appointments of the patient
    SELECT * FROM projects.appointments 
    WHERE PatientID = pid;

    -- Medications prescribed to the patient
    SELECT * FROM projects.medications 
    WHERE PatientID = pid;

    -- Billing details for the patient
    SELECT * FROM projects.billing 
    WHERE PatientID = pid;
END //

CALL GetPatientHistory(1);

DELIMITER ;

-- Triggers

DELIMITER //

CREATE TRIGGER projects.after_appointment_insert
AFTER INSERT ON projects.appointments
FOR EACH ROW
BEGIN
    INSERT INTO projects.billing (PatientID, AppointmentID, Amount, BillingDate, Paid)
    VALUES (NEW.PatientID, NEW.AppointmentID, 1000.00, CURDATE(), FALSE);
END //

DELIMITER ;


-- Total Revenue (only paid bills):

SELECT SUM(Amount) AS TotalRevenue 
FROM billing 
WHERE Amount = TRUE;
-- OR
SELECT SUM(Amount) AS TotalRevenue  
FROM billing  
WHERE Amount = 'Paid';



-- Appointments Count by Doctor:

SELECT DoctorID, COUNT(*) AS TotalAppointments
FROM appointments
GROUP BY DoctorID;


-- Appointments Count by Doctor with name

SELECT d.DoctorID, 
       CONCAT(d.First_Name, ' ', d.Last_Name) AS DoctorName, 
       COUNT(a.AppointmentID) AS TotalAppointments
FROM projects.appointments a
JOIN projects.doctors d ON a.DoctorID = d.DoctorID
GROUP BY d.DoctorID, d.First_Name, d.Last_Name
LIMIT 0, 1000;


--  Patients with Unpaid Bills:

SELECT p.First_Name, p.Last_Name, b.Amount, b.billingDate
FROM projects.billing b
JOIN projects.patients p ON b.PatientID = p.PatientID
WHERE b.Amount >0;



