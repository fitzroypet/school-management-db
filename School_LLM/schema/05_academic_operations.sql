CREATE TABLE dbo.subjects (
    subject_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    subject_code NVARCHAR(20) NOT NULL,
    subject_name NVARCHAR(100) NOT NULL,
    department_id INT,
    credits INT,
    description NVARCHAR(MAX),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_subjects_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_subjects_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT UQ_subject_code UNIQUE (school_id, subject_code)
);

CREATE TABLE dbo.class_subjects (
    class_subject_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    is_mandatory BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_class_subjects_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_class_subjects_class FOREIGN KEY (class_id) 
        REFERENCES classes(class_id),
    CONSTRAINT FK_class_subjects_subject FOREIGN KEY (subject_id) 
        REFERENCES subjects(subject_id),
    CONSTRAINT FK_class_subjects_teacher FOREIGN KEY (teacher_id) 
        REFERENCES teachers(teacher_id),
    CONSTRAINT UQ_class_subject UNIQUE (school_id, class_id, subject_id, academic_year_id)
);

CREATE TABLE dbo.attendance (
    attendance_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    date DATE NOT NULL,
    status NVARCHAR(20) NOT NULL,
    reason NVARCHAR(MAX),
    marked_by INT NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_attendance_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_attendance_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id),
    CONSTRAINT FK_attendance_class FOREIGN KEY (class_id) 
        REFERENCES classes(class_id),
    CONSTRAINT FK_attendance_marked_by FOREIGN KEY (marked_by) 
        REFERENCES users(user_id),
    CONSTRAINT UQ_daily_attendance UNIQUE (school_id, student_id, date)
);

-- Create partitioned view for attendance
CREATE PARTITION FUNCTION PF_Attendance (DATE)
AS RANGE RIGHT FOR VALUES 
('2024-01-01', '2025-01-01', '2026-01-01');

CREATE PARTITION SCHEME PS_Attendance
AS PARTITION PF_Attendance 
ALL TO ([PRIMARY]); 