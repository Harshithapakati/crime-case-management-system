📌 Crime Case Management System

A full-stack Crime Case Management System built using Flask (Python) and a MySQL database.
The project helps law-enforcement agencies manage investigators, victims, suspects, cases, evidence, and forensic/court reports in a secure, structured way.

This system includes a complete SQL database (DDL, DML, Functions, Procedures, Triggers), a clean Flask backend, HTML templates for UI, and CSS styling.

🚀 Features

Secure login system with role-based access

Add and manage criminal cases

Assign investigators, update cases, track victims & suspects

Forensic and court report management

Evidence tracking linked to cases

Automatic case status update (via trigger)

SQL procedures & functions for reusable operations

Join, nested, and aggregate queries

Clean and responsive UI built using Flask templates

🗂️ Project Structure
project/
│
├── app.py                  # Main Flask application logic
├── password.py             # Password hashing and authentication utilities
├── database.sql            # Full SQL schema: tables, joins, triggers, procedures
├── requirements.txt        # Python dependencies
│
├── static/
│   └── css/
│       └── style.css       # Frontend styling
│
├── templates/              # HTML templates for UI
│   ├── base.html
│   ├── index.html
│   ├── login.html
│   ├── dashboard.html
│   ├── add_case.html
│   ├── add_investigator.html
│   ├── update_case.html
│   ├── select_case_update.html
│   ├── unauthorised.html
│   ├── change_password.html
│
└── README.md

💾 Database Components
DDL

Tables for Investigator, Victim, Suspect, Court, Case, Evidence, Forensic Report, Court Report

Join tables: Case_Investigator, Case_Victim, Case_Suspect

Auto-incremented primary keys, foreign keys, unique constraints, and indexing

DML

UPDATE and SELECT queries

JOIN queries

Aggregate operations using GROUP_CONCAT

Procedures & Functions

AddCase()

AddEvidence()

AssignEvidenceToInvestigator()

GetFullCaseDetails()

GetCasesByInvestigatorEmail()

CaseAge() (Custom SQL function)

Trigger

Automatically changes case status when a forensic report is marked Completed

⚙️ Installation & Setup
1️⃣ Install Dependencies
pip install -r requirements.txt

2️⃣ Set Up MySQL Database
CREATE DATABASE miniproject_db;
USE miniproject_db;


Run database.sql to create all tables, data, functions, procedures, and triggers.

3️⃣ Run Flask App
python app.py


Open in browser:
👉 http://localhost:5000

👥 Contributors
Hithaishhitgowda

Developed as part of an academic mini-project on crime case automation.
