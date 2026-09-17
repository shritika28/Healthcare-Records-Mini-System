/* ============================================================
   Healthcare Records Mini-System (Microsoft SQL Server / T-SQL)
   ============================================================
   Purpose: small demo system covering the core skills a SQL
   Developer JD typically asks for — stored procedures, triggers,
   reporting views, and basic optimization (indexing).

   Run this in SQL Server Management Studio (SSMS), Azure Data
   Studio, or a local SQL Server container.
   ============================================================ */

CREATE DATABASE HealthcareRecordsDemo;
GO
USE HealthcareRecordsDemo;
GO

-- ============================================================
-- 1. SCHEMA
-- ============================================================

CREATE TABLE Patients (
    PatientID     INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(100) NOT NULL,
    DateOfBirth   DATE NOT NULL,
    Gender        CHAR(1) CHECK (Gender IN ('M','F','O')),
    ContactNumber NVARCHAR(20)
);

CREATE TABLE Doctors (
    DoctorID      INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(100) NOT NULL,
    Specialty     NVARCHAR(50)
);

CREATE TABLE Visits (
    VisitID       INT IDENTITY(1,1) PRIMARY KEY,
    PatientID     INT NOT NULL FOREIGN KEY REFERENCES Patients(PatientID),
    DoctorID      INT NOT NULL FOREIGN KEY REFERENCES Doctors(DoctorID),
    VisitDate     DATETIME NOT NULL DEFAULT GETDATE(),
    Diagnosis     NVARCHAR(200)
);

CREATE TABLE Prescriptions (
    PrescriptionID INT IDENTITY(1,1) PRIMARY KEY,
    VisitID        INT NOT NULL FOREIGN KEY REFERENCES Visits(VisitID),
    MedicationName NVARCHAR(100) NOT NULL,
    Dosage         NVARCHAR(50),
    DateIssued     DATETIME NOT NULL DEFAULT GETDATE()
);

-- Audit table for the trigger below
CREATE TABLE PrescriptionAuditLog (
    AuditID        INT IDENTITY(1,1) PRIMARY KEY,
    PrescriptionID INT,
    ActionType     NVARCHAR(10),      -- 'INSERT' or 'UPDATE'
    ActionDate     DATETIME DEFAULT GETDATE(),
    ChangedBy      NVARCHAR(100) DEFAULT SYSTEM_USER
);
GO

-- ============================================================
-- 2. SAMPLE DATA
-- ============================================================

INSERT INTO Patients (FullName, DateOfBirth, Gender, ContactNumber) VALUES
('John Carter', '1985-04-12', 'M', '555-0101'),
('Maria Lopez', '1990-09-23', 'F', '555-0102'),
('Amit Shah',   '1978-01-05', 'M', '555-0103');

INSERT INTO Doctors (FullName, Specialty) VALUES
('Dr. Susan Reyes', 'Cardiology'),
('Dr. Kevin Ng',    'General Practice');

INSERT INTO Visits (PatientID, DoctorID, Diagnosis) VALUES
(1, 1, 'Hypertension follow-up'),
(2, 2, 'Seasonal flu'),
(3, 1, 'Routine checkup');
GO

-- ============================================================
-- 3. STORED PROCEDURE
--    Retrieves a patient's full visit + prescription history —
--    directly maps to the JD's "data loading, merging data,
--    creating reports" responsibility.
-- ============================================================

CREATE PROCEDURE usp_GetPatientHistory
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.FullName        AS PatientName,
        v.VisitDate,
        d.FullName         AS DoctorName,
        v.Diagnosis,
        pr.MedicationName,
        pr.Dosage
    FROM Patients p
    JOIN Visits v         ON p.PatientID = v.PatientID
    JOIN Doctors d        ON v.DoctorID  = d.DoctorID
    LEFT JOIN Prescriptions pr ON v.VisitID = pr.VisitID
    WHERE p.PatientID = @PatientID
    ORDER BY v.VisitDate DESC;
END;
GO

-- Example call:
-- EXEC usp_GetPatientHistory @PatientID = 1;

-- ============================================================
-- 4. TRIGGER
--    Automatically logs every new or updated prescription —
--    a common real-world healthcare-compliance requirement
--    (audit trails for medication changes).
-- ============================================================

CREATE TRIGGER trg_LogPrescriptionChanges
ON Prescriptions
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PrescriptionAuditLog (PrescriptionID, ActionType)
    SELECT
        i.PrescriptionID,
        CASE WHEN EXISTS (SELECT 1 FROM deleted d WHERE d.PrescriptionID = i.PrescriptionID)
             THEN 'UPDATE' ELSE 'INSERT' END
    FROM inserted i;
END;
GO

-- ============================================================
-- 5. REPORTING VIEW
--    Pre-built report: prescriptions issued per month, per
--    doctor — maps directly to the JD's "creating reports"
--    responsibility for stakeholders.
-- ============================================================

CREATE VIEW vw_MonthlyPrescriptionReport AS
SELECT
    d.FullName                         AS DoctorName,
    FORMAT(pr.DateIssued, 'yyyy-MM')   AS ReportMonth,
    COUNT(*)                           AS PrescriptionsIssued
FROM Prescriptions pr
JOIN Visits v   ON pr.VisitID = v.VisitID
JOIN Doctors d  ON v.DoctorID = d.DoctorID
GROUP BY d.FullName, FORMAT(pr.DateIssued, 'yyyy-MM');
GO

-- ============================================================
-- 6. OPTIMIZATION — INDEXING
--    Visits are queried by PatientID constantly (see the stored
--    procedure above). Without an index, SQL Server does a full
--    table scan on every lookup as the table grows. A
--    non-clustered index on the foreign key column speeds up
--    exactly that access pattern.
-- ============================================================

CREATE NONCLUSTERED INDEX IX_Visits_PatientID
ON Visits (PatientID)
INCLUDE (VisitDate, Diagnosis);

-- To verify the optimization in SSMS:
--   1. Enable "Include Actual Execution Plan"
--   2. Run: SELECT * FROM Visits WHERE PatientID = 1;
--   3. Compare the plan before/after the index — should shift
--      from a Table Scan to an Index Seek.

-- ============================================================
-- END OF SCRIPT
-- ============================================================
