CREATE TABLE dbo.assessment_types (
    assessment_type_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    type_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(MAX),
    weight_percentage DECIMAL(5,2),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_assessment_types_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT UQ_assessment_type UNIQUE (school_id, type_name)
);

CREATE TABLE dbo.grade_scales (
    scale_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    grade NVARCHAR(5) NOT NULL,
    min_score DECIMAL(5,2) NOT NULL,
    max_score DECIMAL(5,2) NOT NULL,
    grade_point DECIMAL(3,2),
    description NVARCHAR(100),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_grade_scales_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT CHK_score_range CHECK (min_score <= max_score)
);

CREATE TABLE dbo.assessments (
    assessment_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    class_subject_id INT NOT NULL,
    assessment_type_id INT NOT NULL,
    term_id INT NOT NULL,
    title NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    max_score DECIMAL(5,2) NOT NULL,
    assessment_date DATE,
    created_by INT NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_assessments_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_assessments_class_subject FOREIGN KEY (class_subject_id) 
        REFERENCES class_subjects(class_subject_id),
    CONSTRAINT FK_assessments_type FOREIGN KEY (assessment_type_id) 
        REFERENCES assessment_types(assessment_type_id)
);

CREATE TABLE dbo.student_assessments (
    student_assessment_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    assessment_id INT NOT NULL,
    student_id INT NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    grade NVARCHAR(5),
    remarks NVARCHAR(MAX),
    assessed_by INT NOT NULL,
    assessed_date DATETIME2 DEFAULT GETUTCDATE(),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_student_assessments_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_student_assessments_assessment FOREIGN KEY (assessment_id) 
        REFERENCES assessments(assessment_id),
    CONSTRAINT FK_student_assessments_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id),
    CONSTRAINT UQ_student_assessment UNIQUE (school_id, assessment_id, student_id)
); 