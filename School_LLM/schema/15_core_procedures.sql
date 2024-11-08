-- Student Registration
CREATE PROCEDURE dbo.sp_register_student
    @school_id INT,
    @first_name NVARCHAR(50),
    @last_name NVARCHAR(50),
    @date_of_birth DATE,
    @class_id INT,
    @parent_id INT,
    @email NVARCHAR(100) = NULL,
    @phone NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @user_id INT;
    DECLARE @student_id INT;
    DECLARE @admission_number NVARCHAR(20);
    
    -- Generate admission number
    SET @admission_number = 'ST' + CAST(@school_id AS NVARCHAR(10)) + 
        CAST(YEAR(GETDATE()) AS NVARCHAR(4)) +
        RIGHT('0000' + CAST(NEXT VALUE FOR dbo.seq_admission_number AS NVARCHAR(4)), 4);
    
    -- Create user account if email provided
    IF @email IS NOT NULL
    BEGIN
        INSERT INTO dbo.users (school_id, email, username, role_id)
        VALUES (@school_id, @email, @admission_number, 
            (SELECT role_id FROM dbo.roles WHERE role_name = 'Student' AND school_id = @school_id));
        
        SET @user_id = SCOPE_IDENTITY();
    END

    -- Create student record
    INSERT INTO dbo.students (
        school_id, user_id, admission_number, first_name, last_name,
        date_of_birth, current_class_id, parent_id, enrollment_date
    ) VALUES (
        @school_id, @user_id, @admission_number, @first_name, @last_name,
        @date_of_birth, @class_id, @parent_id, GETDATE()
    );
    
    SET @student_id = SCOPE_IDENTITY();
    
    -- Generate initial fee records
    INSERT INTO dbo.student_fees (
        school_id, student_id, structure_id, amount_due, due_date
    )
    SELECT 
        @school_id,
        @student_id,
        fs.structure_id,
        fs.amount,
        fs.due_date
    FROM dbo.fee_structures fs
    WHERE fs.class_id = @class_id
    AND fs.academic_year_id = (
        SELECT academic_year_id 
        FROM dbo.academic_years 
        WHERE school_id = @school_id AND is_current = 1
    );
    
    COMMIT TRANSACTION;
    
    SELECT @student_id AS student_id, @admission_number AS admission_number;
END;
GO

-- Record Assessment Results
CREATE PROCEDURE dbo.sp_record_assessment_results
    @school_id INT,
    @assessment_id INT,
    @results dbo.AssessmentResultType READONLY,
    @assessed_by INT
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO dbo.student_assessments (
        school_id, assessment_id, student_id, score,
        grade, assessed_by, assessed_date
    )
    SELECT 
        @school_id,
        @assessment_id,
        r.student_id,
        r.score,
        gs.grade,
        @assessed_by,
        GETDATE()
    FROM @results r
    CROSS APPLY (
        SELECT TOP 1 grade 
        FROM dbo.grade_scales gs
        WHERE gs.school_id = @school_id
        AND r.score BETWEEN gs.min_score AND gs.max_score
    ) gs;
END;
GO

-- Process Fee Payment
CREATE PROCEDURE dbo.sp_process_fee_payment
    @school_id INT,
    @student_fee_id INT,
    @amount DECIMAL(10,2),
    @payment_method NVARCHAR(50),
    @transaction_reference NVARCHAR(100),
    @processed_by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @current_paid DECIMAL(10,2);
    DECLARE @amount_due DECIMAL(10,2);
    
    SELECT @current_paid = amount_paid, @amount_due = amount_due
    FROM dbo.student_fees
    WHERE student_fee_id = @student_fee_id
    AND school_id = @school_id;
    
    -- Record payment
    INSERT INTO dbo.payments (
        school_id, student_fee_id, amount, payment_date,
        payment_method, transaction_reference, status, processed_by
    ) VALUES (
        @school_id, @student_fee_id, @amount, GETDATE(),
        @payment_method, @transaction_reference, 'Completed', @processed_by
    );
    
    -- Update student fee record
    UPDATE dbo.student_fees
    SET 
        amount_paid = amount_paid + @amount,
        status = CASE 
            WHEN (amount_paid + @amount) >= amount_due THEN 'Paid'
            ELSE 'Partial'
        END,
        updated_at = GETDATE()
    WHERE student_fee_id = @student_fee_id
    AND school_id = @school_id;
    
    COMMIT TRANSACTION;
END;
GO 