create DATABASE miniproject_db;
USE miniproject_db;

1. INVESTIGATOR
CREATE TABLE Investigator (
    Investigator_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Middle_Name VARCHAR(50),
    Last_Name VARCHAR(50) NOT NULL,
    Ranks VARCHAR(50),
    Email VARCHAR(100) NOT NULL UNIQUE,
    Contact_No VARCHAR(15) NOT NULL,
    Password_Hash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) DEFAULT 'officer'
);

-- 2. VICTIM
CREATE TABLE Victim (
    Victim_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Middle_Name VARCHAR(50),
    Last_Name VARCHAR(50) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Contact_No VARCHAR(15) NOT NULL
);

-- 3. SUSPECT
CREATE TABLE Suspect (
    Suspect_ID INT AUTO_INCREMENT PRIMARY KEY,
    First_Name VARCHAR(50) NOT NULL,
    Middle_Name VARCHAR(50),
    Last_Name VARCHAR(50) NOT NULL,
    Criminal_History TEXT,
    Address VARCHAR(255) NOT NULL,
    Contact_No VARCHAR(15),
    Related_Suspect_ID INT,
    FOREIGN KEY (Related_Suspect_ID) REFERENCES Suspect(Suspect_ID)
);

-- 4. COURT
CREATE TABLE Court (
    Court_ID INT AUTO_INCREMENT PRIMARY KEY,
    Court_Name VARCHAR(100) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Judge_Name VARCHAR(100) NOT NULL,
    Password_Hash VARCHAR(255) NOT NULL,
    CONSTRAINT unique_court_location UNIQUE (Court_Name, Location)
);

-- 5. CASE
CREATE TABLE CaseTable (
    Case_ID INT AUTO_INCREMENT PRIMARY KEY,
    Case_Title VARCHAR(255) NOT NULL,
    Case_Description TEXT,
    Case_Date DATE NOT NULL,
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Open', 'Closed', 'Pending', 'Under Investigation')),
    Priority_Level VARCHAR(20) CHECK (Priority_Level IN ('Low', 'Medium', 'High', 'Critical')),
    Case_Duration INT,
    Investigator_ID INT NOT NULL,
    Victim_ID INT NOT NULL,
    Suspect_ID INT NOT NULL,
    Court_ID INT NOT NULL,
    FOREIGN KEY (Investigator_ID) REFERENCES Investigator(Investigator_ID),
    FOREIGN KEY (Victim_ID) REFERENCES Victim(Victim_ID),
    FOREIGN KEY (Suspect_ID) REFERENCES Suspect(Suspect_ID),
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID),
    CONSTRAINT unique_case UNIQUE (Case_Title, Case_Date)
);

-- 6. EVIDENCE
CREATE TABLE Evidence (
    Evidence_ID INT AUTO_INCREMENT PRIMARY KEY,
    Evidence_Type VARCHAR(100) NOT NULL,
    Description TEXT,
    Location VARCHAR(255) NOT NULL,
    Case_ID INT NOT NULL,
    FOREIGN KEY (Case_ID) REFERENCES CaseTable(Case_ID)
);

-- 7. FORENSIC REPORT
CREATE TABLE Forensic_Report (
    Report_ID INT AUTO_INCREMENT PRIMARY KEY,
    Report_Date DATE NOT NULL,
    Findings TEXT,
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Pending', 'Completed')),
    Case_ID INT NOT NULL,
    FOREIGN KEY (Case_ID) REFERENCES CaseTable(Case_ID)
);

-- 8. REPORT (LINK INVESTIGATOR TO EVIDENCE)
CREATE TABLE Report (
    Report_ID INT AUTO_INCREMENT PRIMARY KEY,
    Evidence_ID INT NOT NULL,
    Investigator_ID INT NOT NULL,
    FOREIGN KEY (Evidence_ID) REFERENCES Evidence(Evidence_ID),
    FOREIGN KEY (Investigator_ID) REFERENCES Investigator(Investigator_ID),
    CONSTRAINT unique_evidence_investigator UNIQUE (Evidence_ID, Investigator_ID)
);

-- 9. COURT REPORT (Optional, added for completeness)
CREATE TABLE Court_Report (
    Report_ID INT AUTO_INCREMENT PRIMARY KEY,
    Case_ID INT NOT NULL,
    Report_Date DATE NOT NULL,
    Report_Text TEXT,
    FOREIGN KEY (Case_ID) REFERENCES CaseTable(Case_ID)
);

-- Recommended indexes for foreign key columns
CREATE INDEX idx_case_investigator ON CaseTable(Investigator_ID);
CREATE INDEX idx_case_victim ON CaseTable(Victim_ID);
CREATE INDEX idx_case_suspect ON CaseTable(Suspect_ID);
CREATE INDEX idx_case_court ON CaseTable(Court_ID);
CREATE INDEX idx_evidence_case ON Evidence(Case_ID);
CREATE INDEX idx_report_evidence ON Report(Evidence_ID);
CREATE INDEX idx_report_investigator ON Report(Investigator_ID);

INSERT INTO Investigator (First_Name, Middle_Name, Last_Name, Ranks, Email, Contact_No, Password_Hash, Role) VALUES
('Amit', 'R.', 'Sharma', 'Inspector', 'amit.sharma@bangalorepolice.in', '9845012345', 'hash1', 'admin'),
('Neha', NULL, 'Patil', 'Sub-Inspector', 'neha.patil@bangalorepolice.in', '9886012345', 'hash2', 'admin'),
('Rajesh', 'K.', 'Kulkarni', 'Inspector', 'rajesh.kulkarni@bangalorepolice.in', '9876712345', 'hash3', 'officer'),
('Divya', NULL, 'Reddy', 'Sub-Inspector', 'divya.reddy@bangalorepolice.in', '9845016789', 'hash4', 'officer'),
('Suresh', NULL, 'Naik', 'Investigator', 'suresh.naik@bangalorepolice.in', '9876509876', 'hash5', 'officer'),
('Preeti', 'S.', 'Kumar', 'Inspector', 'preeti.kumar@bangalorepolice.in', '9886076543', 'hash6', 'officer'),
('Vikram', NULL, 'Joshi', 'Sub-Inspector', 'vikram.joshi@bangalorepolice.in', '9845067890', 'hash7', 'officer'),
('Harsh', NULL, 'Gupta', 'Inspector', 'harsh.gupta@bangalorepolice.in', '9834112222', 'hash8', 'officer'),
('Anita', 'M.', 'Verma', 'Investigator', 'anita.verma@bangalorepolice.in', '9821334455', 'hash9', 'officer'),
('Sunil', NULL, 'Goel', 'Sub-Inspector', 'sunil.goel@bangalorepolice.in', '9811152233', 'hash10', 'officer');

INSERT INTO Victim (First_Name, Middle_Name, Last_Name, Address, Email, Contact_No) VALUES
('Kiran', NULL, 'Shetty', 'MG Road, Bangalore', 'kiran.shetty@gmail.com', '9900001111'),
('Sneha', NULL, 'Iyer', 'Jayanagar, Bangalore', 'sneha.iyer@gmail.com', '9900002222'),
('Deepak', NULL, 'Patel', 'Koramangala, Bangalore', 'deepak.patel@gmail.com', '9900003333'),
('Priya', NULL, 'Sharma', 'Indiranagar, Bangalore', 'priya.sharma@gmail.com', '9900004444'),
('Manoj', NULL, 'Rao', 'Whitefield, Bangalore', 'manoj.rao@gmail.com', '9900005555'),
('Anita', NULL, 'Das', 'HSR Layout, Bangalore', 'anita.das@gmail.com', '9900006666'),
('Rahul', NULL, 'Shetty', 'Electronic City, Bangalore', 'rahul.shetty@gmail.com', '9900007777'),
('Vikas', NULL, 'Shah', 'BTM Layout, Bangalore', 'vikas.shah@gmail.com', '9900008888'),
('Isha', NULL, 'Jain', 'Richmond Town, Bangalore', 'isha.jain@gmail.com', '9900009999'),
('Sumit', NULL, 'Yadav', 'Frazer Town, Bangalore', 'sumit.yadav@gmail.com', '9900001122');

INSERT INTO Suspect (First_Name, Middle_Name, Last_Name, Criminal_History, Address, Contact_No, Related_Suspect_ID) VALUES
('Anil', NULL, 'Kumar', 'Cyber fraud', 'Bannerghatta Road, Bangalore', '9810001111', NULL),
('Karthik', NULL, 'Naidu', 'Hacking activities', 'Jayanagar, Bangalore', '9810002222', 1),
('Mohan', NULL, 'Singh', 'Phishing scams', 'Rajajinagar, Bangalore', '9810003333', NULL),
('Ramesh', NULL, 'Patel', 'Identity theft', 'Malleshwaram, Bangalore', '9810004444', 3),
('Sanjay', NULL, 'Gupta', 'Malware distribution', 'HSR Layout, Bangalore', '9810005555', NULL),
('Vijay', NULL, 'Sharma', 'Ransomware attack', 'BTM Layout, Bangalore', '9810006666', 5),
('Arjun', NULL, 'Reddy', 'Data breach', 'Kumaraswamy Layout, Bangalore', '9810007777', NULL),
('Kiran', NULL, 'Verma', 'Online scam', 'Majestic, Bangalore', '9810008888', NULL),
('Harish', NULL, 'Joshi', 'Unauthorized access', 'Indiranagar, Bangalore', '9810009999', NULL),
('Ravi', NULL, 'Saxena', 'ATM skimming', 'Koramangala, Bangalore', '9810001122', 2);

INSERT INTO Court (Court_Name, Location, Judge_Name, Password_Hash) VALUES
('Bangalore City Court', 'Bangalore', 'Justice Anil Kumar', 'courthash1'),
('Karnataka High Court', 'Bangalore', 'Justice Radhika Menon', 'courthash2'),
('Cyber Crimes Court', 'Bangalore', 'Justice Prakash Rao', 'courthash3'),
('District Court Electronic City', 'Bangalore', 'Justice Suresh Pai', 'courthash4'),
('Mobile Court Koramangala', 'Bangalore', 'Justice Meera Iyer', 'courthash5'),
('Fast Track Court HSR', 'Bangalore', 'Justice Vinay Kumar', 'courthash6'),
('Judicial Court Whitefield', 'Bangalore', 'Justice Lakshmi Devi', 'courthash7'),
('Session Court Jayanagar', 'Bangalore', 'Justice Tanvi Desai', 'courthash8'),
('Special Court Frazer Town', 'Bangalore', 'Justice Pranav Jain', 'courthash9'),
('Criminal Court Yeshwantpur', 'Bangalore', 'Justice Aman Ghosh', 'courthash10');

INSERT INTO CaseTable (Case_Title, Case_Description, Case_Date, Status, Priority_Level, Case_Duration, Investigator_ID, Victim_ID, Suspect_ID, Court_ID) VALUES
('Phishing Scam', 'Victim targeted by phishing emails.', '2025-03-15', 'Open', 'High', 30, 1, 1, 1, 1),
('Online Payment Fraud', 'Fraudulent online payments.', '2025-04-01', 'Pending', 'Medium', 40, 2, 2, 2, 2),
('Data Breach', 'Unauthorized server data access.', '2025-04-10', 'Open', 'High', 50, 3, 3, 3, 3),
('Identity Theft', 'ID docs used illegally.', '2025-05-05', 'Under Investigation', 'High', 35, 4, 4, 4, 4),
('Malware Attack', 'Malicious software via email.', '2025-05-15', 'Open', 'Medium', 45, 5, 5, 5, 5),
('Credit Card Theft', 'Credit card fraud.', '2025-05-25', 'Closed', 'High', 25, 6, 6, 6, 6),
('Ransomware Infiltration', 'Ransomware demand.', '2025-06-01', 'Open', 'Critical', 20, 7, 7, 7, 7),
('ATM Skimming', 'Skimming device on ATM.', '2025-06-10', 'Pending', 'Medium', 18, 8, 8, 10, 8),
('Sim Card Swap', 'Mobile fraud via SIM swap.', '2025-06-15', 'Open', 'Low', 22, 9, 9, 9, 9),
('Spyware Attack', 'Spyware detected in system.', '2025-06-22', 'Closed', 'Medium', 30, 10, 10, 8, 10);

INSERT INTO Evidence (Evidence_Type, Description, Location, Case_ID) VALUES
('Phishing Emails', 'Headers from phishing emails', 'Cyber Forensics Lab', 1),
('Transaction Logs', 'Suspicious bank records', 'Bank Branch Koramangala', 2),
('Access Logs', 'Unauthorized server access', 'Corporation HQ', 3),
('Fake ID Docs', 'Forged ID cards', 'Police Evidence Room', 4),
('Malware Samples', 'Ransomware binary', 'Forensics Lab', 5),
('Credit Card Statements', 'Fraudulent charges', 'Bank Records', 6),
('Ransom Note', 'Digital ransom message', 'Cyber Cell', 7),
('ATM Video Footage', 'Suspect at ATM', 'ATM, Brigade Rd.', 8),
('SIM Card', 'Fraudulent SIM', 'Telecom Office', 9),
('Spyware Caused Files', 'System file change logs', 'Corporate IT', 10);

INSERT INTO Forensic_Report (Report_Date, Findings, Status, Case_ID) VALUES
('2025-03-20', 'Emails traced to suspect.', 'Completed', 1),
('2025-04-05', 'Fraud trail established.', 'Completed', 2),
('2025-04-15', 'Data breach confirmed.', 'Pending', 3),
('2025-05-10', 'Fake IDs linked.', 'Completed', 4),
('2025-05-20', 'Malware is known variant.', 'Pending', 5),
('2025-05-30', 'Credit card fraud proven.', 'Completed', 6),
('2025-06-05', 'Ransomware source checking.', 'Pending', 7),
('2025-06-12', 'ATM video clear, suspect seen.', 'Completed', 8),
('2025-06-17', 'SIM fraud links to telecom.', 'Pending', 9),
('2025-06-25', 'Spyware source located.', 'Completed', 10);

INSERT INTO Report (Evidence_ID, Investigator_ID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

INSERT INTO Court_Report (Case_ID, Report_Date, Report_Text) VALUES
(1, '2025-03-25', 'Case admitted. Next hearing in May.'),
(2, '2025-04-10', 'Court issued a notice to bank.'),
(3, '2025-04-20', 'Hearing adjourned for evidence.'),
(4, '2025-05-20', 'Prosecution presented fake ID cards.'),
(5, '2025-05-22', 'Evidence recorded.'),
(6, '2025-06-01', 'Trial to begin next month.'),
(7, '2025-06-07', 'Hearing deferred until investigation complete.'),
(8, '2025-06-15', 'Video evidence accepted by court.'),
(9, '2025-06-20', 'Telecom department summoned.'),
(10, '2025-07-01', 'Case closed with verdict for prosecution.');

DELIMITER //

CREATE FUNCTION CaseAge(case_id_in INT) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE age_days INT;
  SELECT DATEDIFF(CURDATE(), Case_Date) INTO age_days FROM CaseTable WHERE Case_ID = case_id_in;
  RETURN age_days;
END;
//

DELIMITER ;


DELIMITER //

CREATE PROCEDURE AddCase(
  IN p_CaseTitle VARCHAR(255),
  IN p_CaseDescription TEXT,
  IN p_CaseDate DATE,
  IN p_Status VARCHAR(20),
  IN p_PriorityLevel VARCHAR(20),
  IN p_CaseDuration INT,
  IN p_InvestigatorID INT,
  IN p_VictimID INT,
  IN p_SuspectID INT,
  IN p_CourtID INT
)
BEGIN
  INSERT INTO CaseTable 
    (Case_Title, Case_Description, Case_Date, Status, Priority_Level, Case_Duration, Investigator_ID, Victim_ID, Suspect_ID, Court_ID)
  VALUES (p_CaseTitle, p_CaseDescription, p_CaseDate, p_Status, p_PriorityLevel, p_CaseDuration, p_InvestigatorID, p_VictimID, p_SuspectID, p_CourtID);
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetCasesByInvestigatorEmail(IN email_in VARCHAR(100))
BEGIN
  SELECT c.Case_ID, c.Case_Title, c.Status, v.First_Name AS VictimFirstName, v.Last_Name AS VictimLastName
  FROM CaseTable c
  JOIN Investigator i ON c.Investigator_ID = i.Investigator_ID
  JOIN Victim v ON c.Victim_ID = v.Victim_ID
  WHERE i.Email = email_in;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetFullCaseDetails(IN case_id_in INT)
BEGIN
  SELECT 
    ct.Case_ID, ct.Case_Title, ct.Case_Description, ct.Case_Date, ct.Status, ct.Priority_Level, ct.Case_Duration,
    s.First_Name AS SuspectFirstName, s.Last_Name AS SuspectLastName, s.Criminal_History, s.Address AS SuspectAddress, s.Contact_No AS SuspectContact,
    v.First_Name AS VictimFirstName, v.Last_Name AS VictimLastName, v.Address AS VictimAddress, v.Contact_No AS VictimContact,
    cr.Court_Name, cr.Location, cr.Judge_Name,
    fr.Report_Date AS ForensicReportDate, fr.Findings AS ForensicFindings, fr.Status AS ForensicReportStatus,
    crpt.Report_Date AS CourtReportDate, crpt.Report_Text AS CourtReportText
  FROM CaseTable ct
  LEFT JOIN Suspect s ON ct.Suspect_ID = s.Suspect_ID
  LEFT JOIN Victim v ON ct.Victim_ID = v.Victim_ID
  LEFT JOIN Court cr ON ct.Court_ID = cr.Court_ID
  LEFT JOIN Forensic_Report fr ON ct.Case_ID = fr.Case_ID
  LEFT JOIN Court_Report crpt ON ct.Case_ID = crpt.Case_ID
  WHERE ct.Case_ID = case_id_in;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE AddEvidence(
  IN p_EvidenceType VARCHAR(100),
  IN p_Description TEXT,
  IN p_Location VARCHAR(255),
  IN p_CaseID INT
)
BEGIN
  INSERT INTO Evidence (Evidence_Type, Description, Location, Case_ID)
  VALUES (p_EvidenceType, p_Description, p_Location, p_CaseID);
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE AssignEvidenceToInvestigator(
  IN p_EvidenceID INT,
  IN p_InvestigatorID INT
)
BEGIN
  INSERT INTO Report (Evidence_ID, Investigator_ID)
  VALUES (p_EvidenceID, p_InvestigatorID);
END;
//

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_update_case_status_after_report
AFTER UPDATE ON Forensic_Report
FOR EACH ROW
BEGIN
  IF NEW.Status = 'Completed' THEN
    UPDATE CaseTable SET Status = 'Under Investigation' WHERE Case_ID = NEW.Case_ID;
  END IF;
END;
//

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetCasesBySuspectName(
  IN first_name_in VARCHAR(50),
  IN middle_name_in VARCHAR(50),
  IN last_name_in VARCHAR(50)
)
BEGIN
  SELECT 
    c.Case_ID, c.Case_Title, c.Status, c.Case_Date, s.First_Name, s.Middle_Name, s.Last_Name
  FROM CaseTable c
  JOIN Suspect s ON c.Suspect_ID = s.Suspect_ID
  WHERE
    s.First_Name = first_name_in
    AND (s.Middle_Name = middle_name_in OR (s.Middle_Name IS NULL AND middle_name_in IS NULL))
    AND s.Last_Name = last_name_in;
END;
//

DELIMITER ;

UPDATE Investigator
SET Password_Hash = '$2b$12$jXo2xOj2.p4.21dtAFYlEuvqi.38O3a4X4Ih5uS1R0KY1gRX08c9S', Role = 'admin'
WHERE Email = 'amit.sharma@bangalorepolice.in';

UPDATE Investigator
SET Password_Hash = '$2b$12$LwP3eDstyXOevmoqTULnq.YNtlVnFCqVRCtKauylcXE1AxXNrPIje', Role = 'admin'
WHERE Email = 'neha.patil@bangalorepolice.in';

-- Remove indexes if they exist
DROP INDEX idx_case_investigator ON CaseTable;
DROP INDEX idx_case_victim ON CaseTable;
DROP INDEX idx_case_suspect ON CaseTable;

-- Drop foreign keys
ALTER TABLE CaseTable DROP FOREIGN KEY CaseTable_ibfk_1;
ALTER TABLE CaseTable DROP FOREIGN KEY CaseTable_ibfk_2;
ALTER TABLE CaseTable DROP FOREIGN KEY CaseTable_ibfk_3;

-- Drop columns from CaseTable
ALTER TABLE CaseTable DROP COLUMN Investigator_ID;
ALTER TABLE CaseTable DROP COLUMN Victim_ID;
ALTER TABLE CaseTable DROP COLUMN Suspect_ID;

-- Investigator–Case join table
CREATE TABLE Case_Investigator (
    Case_ID INT NOT NULL,
    Investigator_ID INT NOT NULL,
    PRIMARY KEY (Case_ID, Investigator_ID),
    FOREIGN KEY (Case_ID) REFERENCES CaseTable(Case_ID),
    FOREIGN KEY (Investigator_ID) REFERENCES Investigator(Investigator_ID)
);

-- Victim–Case join table
CREATE TABLE Case_Victim (
    Case_ID INT NOT NULL,
    Victim_ID INT NOT NULL,
    PRIMARY KEY (Case_ID, Victim_ID),
    FOREIGN KEY (Case_ID) REFERENCES CaseTable(Case_ID),
    FOREIGN KEY (Victim_ID) REFERENCES Victim(Victim_ID)
);

-- Suspect–Case join table
CREATE TABLE Case_Suspect (
    Case_ID INT NOT NULL,
    Suspect_ID INT NOT NULL,
    PRIMARY KEY (Case_ID, Suspect_ID),
    FOREIGN KEY (Case_ID) REFERENCES CaseTable(Case_ID),
    FOREIGN KEY (Suspect_ID) REFERENCES Suspect(Suspect_ID)
);
-- Link investigators to cases
INSERT INTO Case_Investigator (Case_ID, Investigator_ID) VALUES (1, 1), (1, 2);
INSERT INTO Case_Investigator (Case_ID, Investigator_ID) VALUES (2, 3);

-- Link victims to cases
INSERT INTO Case_Victim (Case_ID, Victim_ID) VALUES (1, 5), (1, 6);
INSERT INTO Case_Victim (Case_ID, Victim_ID) VALUES (2, 7);

-- Link suspects to cases
INSERT INTO Case_Suspect (Case_ID, Suspect_ID) VALUES (1, 2), (1, 3);
INSERT INTO Case_Suspect (Case_ID, Suspect_ID) VALUES (2, 4);

-- All investigators for a case
SELECT i.* FROM Investigator i 
JOIN Case_Investigator ci ON i.Investigator_ID = ci.Investigator_ID
WHERE ci.Case_ID = 1;

-- All victims for a case
SELECT v.* FROM Victim v 
JOIN Case_Victim cv ON v.Victim_ID = cv.Victim_ID
WHERE cv.Case_ID = 1;

-- All suspects for a case
SELECT s.* FROM Suspect s 
JOIN Case_Suspect cs ON s.Suspect_ID = cs.Suspect_ID
WHERE cs.Case_ID = 1;
ALTER TABLE Investigator DROP COLUMN Contact_No;
CREATE TABLE Investigator_Contact (
    Contact_ID INT AUTO_INCREMENT PRIMARY KEY,
    Investigator_ID INT NOT NULL,
    Contact_No VARCHAR(15) NOT NULL,
    FOREIGN KEY (Investigator_ID) REFERENCES Investigator(Investigator_ID)
);
SELECT 
    i.Investigator_ID,
    i.First_Name,
    i.Middle_Name,
    i.Last_Name,
    GROUP_CONCAT(ic.Contact_No SEPARATOR ', ') AS ContactNumbers
FROM Investigator i
LEFT JOIN Investigator_Contact ic ON i.Investigator_ID = ic.Investigator_ID
GROUP BY i.Investigator_ID, i.First_Name, i.Middle_Name, i.Last_Name;

