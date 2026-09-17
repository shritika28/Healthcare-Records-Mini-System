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

## What to actually understand before an interview

If this comes up in conversation, be ready to explain, in your own words:

- **Why a stored procedure instead of writing the same query in application
  code each time** (reusability, centralized logic, reduced network
  round-trips, easier permissions management).
- **Why a trigger fires on both INSERT and UPDATE, and how the `inserted`/
  `deleted` pseudo-tables work** (SQL Server automatically populates these
  during DML operations — `deleted` has the old row on an UPDATE, `inserted`
  has the new one).
- **Why the index targets `PatientID` specifically** (it's the column most
  frequently filtered on, based on the stored procedure's WHERE clause —
  indexing decisions should follow actual query patterns, not be applied
  blindly to every column).
- **The tradeoff of indexing** (faster reads, but slightly slower writes
  since the index must also be updated on every INSERT/UPDATE/DELETE).

## Honest scope note

This is a learning/demo project built quickly to have something concrete
in Microsoft SQL Server (T-SQL) specifically, since prior projects used
SQLite and MySQL. It does not include Oracle PL/SQL — if a role requires
both Oracle and MS-SQL, be upfront that your hands-on experience so far is
MS-SQL/T-SQL, with SQL fundamentals (joins, subqueries, schema design)
transferring from SQLite/MySQL work on other projects.
