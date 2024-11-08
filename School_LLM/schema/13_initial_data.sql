-- Default Subscription Plans
INSERT INTO dbo.subscription_plans (
    plan_name, description, price, billing_cycle, 
    max_students, max_teachers, features, is_active
) VALUES 
('Starter', 'Basic school management features', 99.99, 'Monthly', 100, 10,
    JSON_MODIFY('{}', '$.features', JSON_QUERY('["basic_attendance","basic_grading"]')),
    1),
('Professional', 'Advanced features with more capacity', 199.99, 'Monthly', 500, 50,
    JSON_MODIFY('{}', '$.features', JSON_QUERY('["advanced_attendance","advanced_grading","financial_management"]')),
    1),
('Enterprise', 'Full feature set with unlimited capacity', 499.99, 'Monthly', NULL, NULL,
    JSON_MODIFY('{}', '$.features', JSON_QUERY('["all_features"]')),
    1);
GO

-- Default Assessment Types
CREATE PROCEDURE dbo.sp_create_default_assessment_types
    @school_id INT
AS
BEGIN
    INSERT INTO dbo.assessment_types (
        school_id, type_name, description, weight_percentage, is_active
    ) VALUES 
    (@school_id, 'Quiz', 'Short assessments', 10.00, 1),
    (@school_id, 'Assignment', 'Take-home work', 20.00, 1),
    (@school_id, 'Mid-Term', 'Mid-term examination', 30.00, 1),
    (@school_id, 'Final', 'Final examination', 40.00, 1);
END;
GO

-- Default Grade Scales
CREATE PROCEDURE dbo.sp_create_default_grade_scales
    @school_id INT
AS
BEGIN
    INSERT INTO dbo.grade_scales (
        school_id, grade, min_score, max_score, grade_point, description
    ) VALUES 
    (@school_id, 'A+', 95.00, 100.00, 4.00, 'Outstanding'),
    (@school_id, 'A', 90.00, 94.99, 3.75, 'Excellent'),
    (@school_id, 'B+', 85.00, 89.99, 3.50, 'Very Good'),
    (@school_id, 'B', 80.00, 84.99, 3.00, 'Good'),
    (@school_id, 'C+', 75.00, 79.99, 2.50, 'Above Average'),
    (@school_id, 'C', 70.00, 74.99, 2.00, 'Average'),
    (@school_id, 'D', 60.00, 69.99, 1.00, 'Below Average'),
    (@school_id, 'F', 0.00, 59.99, 0.00, 'Fail');
END;
GO

-- Default Fee Categories
CREATE PROCEDURE dbo.sp_create_default_fee_categories
    @school_id INT
AS
BEGIN
    INSERT INTO dbo.fee_categories (
        school_id, category_name, description, is_recurring, frequency
    ) VALUES 
    (@school_id, 'Tuition Fee', 'Regular tuition fees', 1, 'Monthly'),
    (@school_id, 'Registration Fee', 'One-time registration fee', 0, NULL),
    (@school_id, 'Laboratory Fee', 'Science lab usage fee', 1, 'Termly'),
    (@school_id, 'Library Fee', 'Library maintenance fee', 1, 'Yearly'),
    (@school_id, 'Sports Fee', 'Sports facilities and equipment', 1, 'Yearly');
END;
GO

-- School Onboarding Procedure
CREATE PROCEDURE dbo.sp_onboard_new_school
    @school_name NVARCHAR(100),
    @email NVARCHAR(100),
    @phone NVARCHAR(20),
    @address NVARCHAR(MAX),
    @plan_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @school_id INT;
    
    -- Create school
    INSERT INTO dbo.schools (
        school_name, email, phone, address,
        subscription_status, subscription_start_date
    ) VALUES (
        @school_name, @email, @phone, @address,
        'Trial', GETDATE()
    );
    
    SET @school_id = SCOPE_IDENTITY();
    
    -- Create default settings
    EXEC dbo.sp_create_default_assessment_types @school_id;
    EXEC dbo.sp_create_default_grade_scales @school_id;
    EXEC dbo.sp_create_default_fee_categories @school_id;
    
    -- Create subscription
    INSERT INTO dbo.school_subscriptions (
        school_id, plan_id, start_date, end_date, 
        status, payment_status
    ) VALUES (
        @school_id, @plan_id, GETDATE(), 
        DATEADD(MONTH, 1, GETDATE()),
        'Trial', 'Pending'
    );
    
    COMMIT TRANSACTION;
    
    SELECT @school_id AS new_school_id;
END;
GO 