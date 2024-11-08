CREATE TABLE dbo.audit_logs (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    user_id INT,
    action NVARCHAR(50) NOT NULL,
    entity_type NVARCHAR(50) NOT NULL,
    entity_id NVARCHAR(50) NOT NULL,
    old_values NVARCHAR(MAX), -- JSON
    new_values NVARCHAR(MAX), -- JSON
    ip_address NVARCHAR(45),
    user_agent NVARCHAR(255),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_audit_logs_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_audit_logs_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
);

-- Enable temporal tables for key entities
ALTER TABLE dbo.students
ADD 
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
    CONSTRAINT DF_Students_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
    CONSTRAINT DF_Students_ValidTo DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

ALTER TABLE dbo.students
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.students_history)); 