-- Clustered indexes are already created with Primary Keys
-- Creating essential non-clustered indexes for performance

-- Users and Authentication
CREATE NONCLUSTERED INDEX IX_users_email_school
ON dbo.users (school_id, email)
INCLUDE (username, is_active);

CREATE NONCLUSTERED INDEX IX_users_username_school
ON dbo.users (school_id, username)
INCLUDE (email, is_active);

-- Students
CREATE NONCLUSTERED INDEX IX_students_admission_school
ON dbo.students (school_id, admission_number)
INCLUDE (first_name, last_name, current_class_id);

CREATE NONCLUSTERED INDEX IX_students_class
ON dbo.students (school_id, current_class_id)
INCLUDE (first_name, last_name, admission_number);

-- Attendance
CREATE NONCLUSTERED INDEX IX_attendance_date
ON dbo.attendance (school_id, date, class_id)
INCLUDE (student_id, status);

-- Financial
CREATE NONCLUSTERED INDEX IX_student_fees_status
ON dbo.student_fees (school_id, status, due_date)
INCLUDE (student_id, amount_due, amount_paid);

CREATE NONCLUSTERED INDEX IX_payments_date
ON dbo.payments (school_id, payment_date, status)
INCLUDE (student_fee_id, amount);

-- Notifications
CREATE NONCLUSTERED INDEX IX_notifications_status
ON dbo.notifications (school_id, status, scheduled_at)
INCLUDE (title, notification_type);

-- Audit Logs
CREATE NONCLUSTERED INDEX IX_audit_logs_entity
ON dbo.audit_logs (school_id, entity_type, entity_id, created_at);

-- Create filtered indexes for common queries
CREATE NONCLUSTERED INDEX IX_active_students
ON dbo.students (school_id, current_class_id)
INCLUDE (first_name, last_name, admission_number)
WHERE status = 'Active';

CREATE NONCLUSTERED INDEX IX_pending_payments
ON dbo.student_fees (school_id, due_date)
INCLUDE (student_id, amount_due)
WHERE status = 'Pending'; 