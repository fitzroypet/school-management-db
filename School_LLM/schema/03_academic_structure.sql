CREATE TABLE dbo.academic_years (
    academic_year_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    year_name NVARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    created_by INT,
    updated_at DATETIME2,
    updated_by INT,
    CONSTRAINT FK_academic_years_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_academic_years_created_by FOREIGN KEY (created_by) 
        REFERENCES users(user_id),
    CONSTRAINT FK_academic_years_updated_by FOREIGN KEY (updated_by) 
        REFERENCES users(user_id),
    CONSTRAINT UQ_year_per_school UNIQUE (school_id, year_name)
);

CREATE TABLE dbo.terms (
    term_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    term_name NVARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    created_by INT,
    updated_at DATETIME2,
    updated_by INT,
    CONSTRAINT FK_terms_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_terms_academic_year FOREIGN KEY (academic_year_id) 
        REFERENCES academic_years(academic_year_id),
    CONSTRAINT UQ_term_per_year UNIQUE (school_id, academic_year_id, term_name)
);

CREATE TABLE dbo.departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    department_name NVARCHAR(100) NOT NULL,
    department_head_id INT,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    created_by INT,
    updated_at DATETIME2,
    updated_by INT,
    CONSTRAINT FK_departments_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT UQ_department_per_school UNIQUE (school_id, department_name)
);

CREATE TABLE dbo.classes (
    class_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    class_name NVARCHAR(50) NOT NULL,
    academic_year_id INT NOT NULL,
    department_id INT,
    form_teacher_id INT,
    capacity INT,
    class_code NVARCHAR(20),
    description NVARCHAR(MAX),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    created_by INT,
    updated_at DATETIME2,
    updated_by INT,
    CONSTRAINT FK_classes_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_classes_academic_year FOREIGN KEY (academic_year_id) 
        REFERENCES academic_years(academic_year_id),
    CONSTRAINT FK_classes_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT UQ_class_per_school_year UNIQUE (school_id, academic_year_id, class_name)
); 