CREATE TABLE dbo.fee_categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    category_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    is_recurring BIT DEFAULT 0,
    frequency NVARCHAR(20), -- Monthly, Termly, Yearly
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_fee_categories_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT UQ_fee_category UNIQUE (school_id, category_name)
);

CREATE TABLE dbo.fee_structures (
    structure_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    category_id INT NOT NULL,
    class_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    due_date DATE,
    late_fee DECIMAL(10,2),
    discount_percentage DECIMAL(5,2),
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_fee_structures_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_fee_structures_category FOREIGN KEY (category_id) 
        REFERENCES fee_categories(category_id),
    CONSTRAINT FK_fee_structures_class FOREIGN KEY (class_id) 
        REFERENCES classes(class_id)
);

CREATE TABLE dbo.student_fees (
    student_fee_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    student_id INT NOT NULL,
    structure_id INT NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    amount_paid DECIMAL(10,2) DEFAULT 0,
    due_date DATE NOT NULL,
    status NVARCHAR(20) DEFAULT 'Pending',
    late_fee_applied DECIMAL(10,2) DEFAULT 0,
    discount_applied DECIMAL(10,2) DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_student_fees_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_student_fees_student FOREIGN KEY (student_id) 
        REFERENCES students(student_id),
    CONSTRAINT FK_student_fees_structure FOREIGN KEY (structure_id) 
        REFERENCES fee_structures(structure_id)
);

CREATE TABLE dbo.payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    student_fee_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    payment_method NVARCHAR(50) NOT NULL,
    transaction_reference NVARCHAR(100),
    status NVARCHAR(20) DEFAULT 'Pending',
    payment_gateway_response NVARCHAR(MAX), -- JSON
    processed_by INT,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_payments_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_payments_student_fee FOREIGN KEY (student_fee_id) 
        REFERENCES student_fees(student_fee_id)
); 