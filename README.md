# Healthcare Records Mini-System (T-SQL / Microsoft SQL Server)

A compact demo system built to practice core SQL Developer skills: stored
procedures, triggers, reporting views, and query optimization — using a
healthcare-records domain.

## What it does

- **Schema**: Patients, Doctors, Visits, Prescriptions, and an audit log table.
- **Stored Procedure** (`usp_GetPatientHistory`): merges patient, visit,
  doctor, and prescription data into one report-ready result set — the kind
  of "data loading, merging data, creating reports" task a data engineering
  team handles daily.
- **Trigger** (`trg_LogPrescriptionChanges`): automatically logs every new
  or updated prescription into an audit table. Healthcare systems need this
  kind of change tracking for compliance.
- **View** (`vw_MonthlyPrescriptionReport`): a pre-built report — prescriptions
  issued per doctor per month — the sort of recurring stakeholder report
  this role would produce.
- **Index** (`IX_Visits_PatientID`): a non-clustered index on the most
  frequently filtered column (PatientID), demonstrating a basic database
  optimization technique.

## How to run it

1. Install SQL Server Express (free) or use a hosted option like Azure SQL
   Database, or run SQL Server in Docker.
2. Open the `.sql` file in SQL Server Management Studio (SSMS) or Azure
   Data Studio.
3. Run the script top to bottom — it creates the database, tables, sample
   data, procedure, trigger, view, and index in order.
4. Test the stored procedure: `EXEC usp_GetPatientHistory @PatientID = 1;`
5. Test the trigger: insert or update a row in `Prescriptions`, then check
   `PrescriptionAuditLog` — a new row should appear automatically.
6. Test the optimization: turn on "Include Actual Execution Plan" in SSMS,
   run a query filtering `Visits` by `PatientID`, and observe the plan use
   an Index Seek instead of a Table Scan.
