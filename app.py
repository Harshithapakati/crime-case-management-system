from flask import Flask, render_template, redirect, url_for, session, request, flash
from flask_mysqldb import MySQL
import MySQLdb
import bcrypt

app = Flask(__name__)
app.secret_key = "supersecretkey"
app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'Harshitha13@'
app.config['MYSQL_DB'] = 'miniproject_db'

mysql = MySQL(app)

@app.route('/')
def index():
    if 'user_id' in session:
        return redirect(url_for('dashboard'))
    return render_template('login.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT Investigator_ID, Password_Hash, Role FROM Investigator WHERE Email=%s", (email,))
        user = cursor.fetchone()
        cursor.close()
        if user and bcrypt.checkpw(password.encode(), user[1].encode()):
            session['user_id'] = user[0]
            session['role'] = user[2]
            return redirect(url_for('dashboard'))
        flash('Invalid credentials')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/dashboard', methods=['GET', 'POST'])
def dashboard():
    if 'role' not in session:
        return redirect(url_for('unauthorised'))
    cases = None
    details = None
    error = None
    if request.method == 'POST':
        case_id = request.form.get('case_id_search', '').strip()
        suspect_name = request.form.get('suspect_name', '').strip()
        cursor = mysql.connection.cursor()
        if case_id:
            try:
                cursor.execute(
                    """
                    SELECT 
                        ct.Case_ID, ct.Case_Title, ct.Case_Description, ct.Case_Date, ct.Status, ct.Priority_Level, ct.Case_Duration,
                        GROUP_CONCAT(DISTINCT CONCAT(s.First_Name, ' ', IFNULL(s.Middle_Name,''), ' ', s.Last_Name) SEPARATOR '; ') AS SuspectNames,
                        GROUP_CONCAT(DISTINCT s.Contact_No SEPARATOR '; ') AS SuspectContact,
                        GROUP_CONCAT(DISTINCT s.Address SEPARATOR '; ') AS SuspectAddress,
                        GROUP_CONCAT(DISTINCT CONCAT(v.First_Name, ' ', IFNULL(v.Middle_Name,''), ' ', v.Last_Name) SEPARATOR '; ') AS VictimNames,
                        GROUP_CONCAT(DISTINCT v.Contact_No SEPARATOR '; ') AS VictimContact,
                        GROUP_CONCAT(DISTINCT v.Address SEPARATOR '; ') AS VictimAddress,
                        cr.Court_Name, cr.Location, cr.Judge_Name,
                        MAX(fr.Report_Date) AS ForensicReportDate,
                        GROUP_CONCAT(DISTINCT fr.Findings SEPARATOR ' || ') AS ForensicFindings,
                        GROUP_CONCAT(DISTINCT fr.Status SEPARATOR '; ') AS ForensicReportStatus,
                        MAX(crpt.Report_Date) AS CourtReportDate,
                        GROUP_CONCAT(DISTINCT crpt.Report_Text SEPARATOR ' || ') AS CourtReportText
                    FROM CaseTable ct
                    LEFT JOIN Case_Suspect cs ON ct.Case_ID = cs.Case_ID
                    LEFT JOIN Suspect s ON cs.Suspect_ID = s.Suspect_ID
                    LEFT JOIN Case_Victim cv ON ct.Case_ID = cv.Case_ID
                    LEFT JOIN Victim v ON cv.Victim_ID = v.Victim_ID
                    LEFT JOIN Court cr ON ct.Court_ID = cr.Court_ID
                    LEFT JOIN Forensic_Report fr ON ct.Case_ID = fr.Case_ID
                    LEFT JOIN Court_Report crpt ON ct.Case_ID = crpt.Case_ID
                    WHERE ct.Case_ID = %s
                    GROUP BY ct.Case_ID
                    """,
                    (int(case_id),)
                )
                result_set = cursor.fetchall()
                if result_set:
                    field_names = [i[0] for i in cursor.description]
                    details = [dict(zip(field_names, row)) for row in result_set]
                    for d in details:
                        d['SuspectFirstName'] = d.get('SuspectNames') or ''
                        d['SuspectLastName'] = ''
                        d['SuspectContact'] = d.get('SuspectContact') or ''
                        d['SuspectAddress'] = d.get('SuspectAddress') or ''
                        d['VictimFirstName'] = d.get('VictimNames') or ''
                        d['VictimLastName'] = ''
                        d['VictimContact'] = d.get('VictimContact') or ''
                        d['VictimAddress'] = d.get('VictimAddress') or ''
                else:
                    error = "No such case registered."
            except Exception as e:
                error = f"Invalid Case ID or error: {str(e)}"
            finally:
                cursor.close()
        elif suspect_name:
            name_parts = suspect_name.strip().split()
            first_name = name_parts[0]
            last_name = name_parts[-1] if len(name_parts) > 1 else ""
            cursor.execute(
                "SELECT c.Case_ID, c.Case_Title, c.Status, c.Case_Date FROM CaseTable c "
                "JOIN Case_Suspect cs ON c.Case_ID = cs.Case_ID "
                "JOIN Suspect s ON cs.Suspect_ID = s.Suspect_ID "
                "WHERE s.First_Name = %s AND s.Last_Name = %s",
                (first_name, last_name))
            cases = cursor.fetchall()
            if not cases:
                error = "No such suspect registered."
            cursor.close()
    return render_template('dashboard.html', details=details, cases=cases, error=error)

@app.route('/add_case', methods=['GET', 'POST'])
def add_case():
    if 'role' not in session or session['role'] not in ['admin', 'officer']:
        return redirect(url_for('unauthorised'))
    msg = error = ""
    cursor = mysql.connection.cursor()

    cursor.execute('SELECT Investigator_ID, First_Name, Middle_Name, Last_Name FROM Investigator')
    investigators = cursor.fetchall()
    cursor.execute('SELECT Victim_ID, First_Name, Middle_Name, Last_Name FROM Victim')
    victims = cursor.fetchall()
    cursor.execute('SELECT Suspect_ID, First_Name, Middle_Name, Last_Name FROM Suspect')
    suspects = cursor.fetchall()
    cursor.execute('SELECT Court_ID, Court_Name FROM Court')
    courts = cursor.fetchall()

    if request.method == 'POST':
        try:
            title = request.form['title'].strip()
            desc = request.form.get('desc', '').strip()
            date = request.form['date']
            status = request.form['status']
            priority = request.form['priority']
            duration = int(request.form.get('duration') or 0)
            court_name = request.form.get('court_name', '').strip()
            court_loc = request.form.get('court_loc', '').strip()
            court_judge = request.form.get('court_judge', '').strip()

            cursor.execute("SELECT Court_ID FROM Court WHERE Court_Name=%s AND Location=%s", (court_name, court_loc))
            court = cursor.fetchone()
            if court:
                court_id = court[0]
            else:
                cursor.execute("INSERT INTO Court (Court_Name, Location, Judge_Name, Password_Hash) VALUES (%s, %s, %s, '')",
                               (court_name, court_loc, court_judge))
                mysql.connection.commit()
                court_id = cursor.lastrowid

            victim_ids = []
            if request.form.getlist('victim_fn[]'):
                v_fns = request.form.getlist('victim_fn[]')
                v_mns = request.form.getlist('victim_mn[]')
                v_lns = request.form.getlist('victim_ln[]')
                v_addrs = request.form.getlist('victim_addr[]')
                v_emails = request.form.getlist('victim_email[]')
                v_contacts = request.form.getlist('victim_contact[]')
                for i in range(len(v_fns)):
                    fn = v_fns[i].strip()
                    mn = v_mns[i].strip() if i < len(v_mns) else None
                    ln = v_lns[i].strip() if i < len(v_lns) else ''
                    addr = v_addrs[i].strip() if i < len(v_addrs) else ''
                    email = v_emails[i].strip() if i < len(v_emails) else ''
                    contact = v_contacts[i].strip() if i < len(v_contacts) else ''
                    cursor.execute("SELECT Victim_ID FROM Victim WHERE First_Name=%s AND Last_Name=%s AND Email=%s", (fn, ln, email))
                    victim = cursor.fetchone()
                    if victim:
                        victim_ids.append(victim[0])
                    else:
                        cursor.execute("INSERT INTO Victim (First_Name, Middle_Name, Last_Name, Address, Email, Contact_No) VALUES (%s, %s, %s, %s, %s, %s)",
                                       (fn, mn or None, ln, addr, email, contact))
                        mysql.connection.commit()
                        victim_ids.append(cursor.lastrowid)
            else:
                for vid in request.form.getlist('victims'):
                    victim_ids.append(int(vid))

            suspect_ids = []
            if request.form.getlist('suspect_fn[]'):
                s_fns = request.form.getlist('suspect_fn[]')
                s_mns = request.form.getlist('suspect_mn[]')
                s_lns = request.form.getlist('suspect_ln[]')
                s_addrs = request.form.getlist('suspect_addr[]')
                s_contacts = request.form.getlist('suspect_contact[]')
                s_hist = request.form.getlist('suspect_history[]')
                for i in range(len(s_fns)):
                    fn = s_fns[i].strip()
                    mn = s_mns[i].strip() if i < len(s_mns) else None
                    ln = s_lns[i].strip() if i < len(s_lns) else ''
                    addr = s_addrs[i].strip() if i < len(s_addrs) else ''
                    contact = s_contacts[i].strip() if i < len(s_contacts) else None
                    history = s_hist[i].strip() if i < len(s_hist) else None
                    cursor.execute("SELECT Suspect_ID FROM Suspect WHERE First_Name=%s AND Last_Name=%s AND Address=%s",
                                   (fn, ln, addr))
                    suspect = cursor.fetchone()
                    if suspect:
                        suspect_ids.append(suspect[0])
                    else:
                        cursor.execute("INSERT INTO Suspect (First_Name, Middle_Name, Last_Name, Criminal_History, Address, Contact_No) VALUES (%s, %s, %s, %s, %s, %s)",
                                       (fn, mn or None, ln, history or None, addr, contact))
                        mysql.connection.commit()
                        suspect_ids.append(cursor.lastrowid)
            else:
                for sid in request.form.getlist('suspects'):
                    suspect_ids.append(int(sid))

            investigator_ids = []
            if request.form.getlist('investigators'):
                investigator_ids = [int(x) for x in request.form.getlist('investigators')]
            else:
                inv = request.form.get('investigator')
                if inv:
                    investigator_ids = [int(inv)]

            cursor.execute('''INSERT INTO CaseTable (Case_Title, Case_Description, Case_Date, Status, Priority_Level, Case_Duration, Court_ID)
                              VALUES (%s, %s, %s, %s, %s, %s, %s)''',
                           (title, desc, date, status, priority, duration, court_id))
            mysql.connection.commit()
            case_id = cursor.lastrowid

            for inv_id in investigator_ids:
                cursor.execute('INSERT IGNORE INTO Case_Investigator (Case_ID, Investigator_ID) VALUES (%s, %s)', (case_id, int(inv_id)))
            for vid in victim_ids:
                cursor.execute('INSERT IGNORE INTO Case_Victim (Case_ID, Victim_ID) VALUES (%s, %s)', (case_id, int(vid)))
            for sid in suspect_ids:
                cursor.execute('INSERT IGNORE INTO Case_Suspect (Case_ID, Suspect_ID) VALUES (%s, %s)', (case_id, int(sid)))

            mysql.connection.commit()
            msg = "Case added successfully!"
        except Exception as e:
            mysql.connection.rollback()
            error = f"Error adding case: {e}"

    cursor.close()

    return render_template('add_case.html', msg=msg, error=error, investigators=investigators)


@app.route('/select_case_update.html')
def select_case_update():
    if 'role' not in session:
        return redirect(url_for('unauthorised'))
    cursor = mysql.connection.cursor()
    cursor.execute('SELECT Case_ID, Case_Title FROM CaseTable ORDER BY Case_ID DESC')
    cases = cursor.fetchall()
    cursor.close()
    return render_template('select_case_update.html', cases=cases)


@app.route('/update_case/<int:case_id>', methods=['GET', 'POST'])
def update_case(case_id):
    if 'role' not in session or session['role'] not in ['admin', 'officer']:
        return redirect(url_for('unauthorised'))
    msg = error = ""
    cursor = mysql.connection.cursor()
    if request.method == 'POST':
        try:
            title = request.form.get('title', '').strip()
            status = request.form.get('status', '').strip()
            priority = request.form.get('priority', '').strip()
            duration = int(request.form.get('duration') or 0)
            cursor.execute('UPDATE CaseTable SET Case_Title=%s, Status=%s, Priority_Level=%s, Case_Duration=%s WHERE Case_ID=%s', (title, status, priority, duration, case_id))
            mysql.connection.commit()
            msg = 'Case updated successfully.'
        except Exception as e:
            mysql.connection.rollback()
            error = f'Error updating case: {e}'
        else:
            # Handle forensic report and court report updates/inserts
            try:
                # Forensic
                fr_id = request.form.get('forensic_report_id')
                fr_date = request.form.get('forensic_date') or None
                fr_findings = request.form.get('forensic_findings','').strip() or None
                fr_status = request.form.get('forensic_status','').strip() or None
                if fr_id:
                    cursor.execute('UPDATE Forensic_Report SET Report_Date=%s, Findings=%s, Status=%s WHERE Report_ID=%s', (fr_date, fr_findings, fr_status, int(fr_id)))
                else:
                    # insert only if any forensic content provided
                    if fr_findings or fr_date or fr_status:
                        cursor.execute('INSERT INTO Forensic_Report (Report_Date, Findings, Status, Case_ID) VALUES (%s, %s, %s, %s)', (fr_date, fr_findings, fr_status, case_id))

                # Court report
                cr_id = request.form.get('court_report_id')
                cr_date = request.form.get('court_date') or None
                cr_text = request.form.get('court_text','').strip() or None
                if cr_id:
                    cursor.execute('UPDATE Court_Report SET Report_Date=%s, Report_Text=%s WHERE Report_ID=%s', (cr_date, cr_text, int(cr_id)))
                else:
                    if cr_text or cr_date:
                        cursor.execute('INSERT INTO Court_Report (Case_ID, Report_Date, Report_Text) VALUES (%s, %s, %s)', (case_id, cr_date, cr_text))

                mysql.connection.commit()
            except Exception as e:
                mysql.connection.rollback()
                # append to error but don't override previous
                error = (error + ' ') + f'Error updating reports: {e}' if error else f'Error updating reports: {e}'
    # Fetch current values for the form
    cursor.execute('SELECT Case_ID, Case_Title, Case_Description, Case_Date, Status, Priority_Level, Case_Duration FROM CaseTable WHERE Case_ID=%s', (case_id,))
    case = cursor.fetchone()
    # Fetch latest forensic and court reports (if any)
    cursor.execute('SELECT Report_ID, Report_Date, Findings, Status FROM Forensic_Report WHERE Case_ID=%s ORDER BY Report_Date DESC LIMIT 1', (case_id,))
    forensic = cursor.fetchone()
    cursor.execute('SELECT Report_ID, Report_Date, Report_Text FROM Court_Report WHERE Case_ID=%s ORDER BY Report_Date DESC LIMIT 1', (case_id,))
    court = cursor.fetchone()
    cursor.close()
    if not case:
        return redirect(url_for('select_case_update'))
    return render_template('update_case.html', case=case, msg=msg, error=error, forensic=forensic, court=court)
 
@app.route('/add_investigator', methods=['GET', 'POST'])
def add_investigator():
    if 'role' not in session or session['role'] != 'admin':
        return redirect(url_for('unauthorised'))
    msg = ""
    if request.method == 'POST':
        fname = request.form['first_name']
        mname = request.form['middle_name']
        lname = request.form['last_name']
        email = request.form['email']
        password = request.form['password']
        rank = request.form['rank']
        contact_numbers = request.form.getlist('contact_numbers[]')  # list of contact numbers submitted

        hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        cursor = mysql.connection.cursor()
        try:
            # Insert Investigator without contact number field
            cursor.execute("""
                INSERT INTO Investigator (First_Name, Middle_Name, Last_Name, Ranks, Email, Password_Hash, Role) 
                VALUES (%s, %s, %s, %s, %s, %s, 'officer')""",
                (fname, mname, lname, rank, email, hashed))
            mysql.connection.commit()
            inv_id = cursor.lastrowid

            # Insert multiple contact numbers into Investigator_Contact table
            for num in contact_numbers:
                num = num.strip()
                if num:
                    cursor.execute("INSERT INTO Investigator_Contact (Investigator_ID, Contact_No) VALUES (%s, %s)", (inv_id, num))
            mysql.connection.commit()
        except Exception as e:
            mysql.connection.rollback()
            cursor.close()
            return render_template('add_investigator.html', msg=f"Error adding investigator: {e}")
        cursor.close()
        msg = "Investigator added!"
    return render_template('add_investigator.html', msg=msg)

@app.route('/change_password', methods=['GET', 'POST'])
def change_password():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    msg = ""
    if request.method == 'POST':
        current = request.form['current_password']
        new = request.form['new_password']
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT Password_Hash FROM Investigator WHERE Investigator_ID = %s", (session['user_id'],))
        user = cursor.fetchone()
        if user and bcrypt.checkpw(current.encode(), user[0].encode()):
            new_hashed = bcrypt.hashpw(new.encode(), bcrypt.gensalt()).decode()
            cursor.execute("UPDATE Investigator SET Password_Hash = %s WHERE Investigator_ID = %s", (new_hashed, session['user_id']))
            mysql.connection.commit()
            msg = "Password updated."
        else:
            msg = "Current password incorrect."
        cursor.close()
    return render_template('change_password.html', msg=msg)

@app.route('/unauthorised')
def unauthorised():
    return render_template('unauthorised.html')

if __name__ == "__main__":
    app.run(debug=True)
