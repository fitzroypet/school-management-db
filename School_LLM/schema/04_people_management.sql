CREATE TABLE dbo.teachers (
    teacher_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    user_id INT NOT NULL,
    staff_id NVARCHAR(20),
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender NVARCHAR(10),
    department_id INT,
    phone_number NVARCHAR(20),
    emergency_contact NVARCHAR(100),
    address NVARCHAR(MAX),
    qualification NVARCHAR(MAX),
    joining_date DATE NOT NULL,
    employment_status NVARCHAR(20) DEFAULT 'Active',
    contract_type NVARCHAR(20),
    teaching_subjects NVARCHAR(MAX), -- JSON array
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_teachers_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_teachers_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id),
    CONSTRAINT FK_teachers_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT UQ_teacher_staff_id UNIQUE (school_id, staff_id)
);

CREATE TABLE dbo.parents (
    parent_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    user_id INT NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    phone_number NVARCHAR(20),
    alternate_phone NVARCHAR(20),
    occupation NVARCHAR(100),
    address NVARCHAR(MAX),
    relationship_type NVARCHAR(30),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_parents_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_parents_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
);

CREATE TABLE dbo.students (
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    user_id INT NOT NULL,
    admission_number NVARCHAR(20) NOT NULL,
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender NVARCHAR(10),
    current_class_id INT,
    parent_id INT,
    blood_group NVARCHAR(5),
    address NVARCHAR(MAX),
    medical_conditions NVARCHAR(MAX),
    emergency_contact NVARCHAR(100),
    enrollment_date DATE NOT NULL,
    status NVARCHAR(20) DEFAULT 'Active',
    previous_school NVARCHAR(200),
    additional_info NVARCHAR(MAX), -- JSON for flexible fields
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_students_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_students_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id),
    CONSTRAINT FK_students_class FOREIGN KEY (current_class_id) 
        REFERENCES classes(class_id),
    CONSTRAINT FK_students_parent FOREIGN KEY (parent_id) 
        REFERENCES parents(parent_id),
    CONSTRAINT UQ_admission_number UNIQUE (school_id, admission_number)
); 