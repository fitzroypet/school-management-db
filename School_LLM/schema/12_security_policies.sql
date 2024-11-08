-- Create schema for security functions
CREATE SCHEMA security;
GO

-- Create function for row-level security
CREATE FUNCTION security.fn_school_access_predicate(@school_id INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_access_predicate
    WHERE @school_id = CAST(SESSION_CONTEXT(N'current_school_id') AS INT)
    OR IS_MEMBER('db_owner') = 1;
GO

-- Apply RLS to main tables
CREATE SECURITY POLICY school_data_security_policy
ADD FILTER PREDICATE security.fn_school_access_predicate(school_id) ON dbo.students,
ADD BLOCK PREDICATE security.fn_school_access_predicate(school_id) ON dbo.students,
ADD FILTER PREDICATE security.fn_school_access_predicate(school_id) ON dbo.teachers,
ADD BLOCK PREDICATE security.fn_school_access_predicate(school_id) ON dbo.teachers,
ADD FILTER PREDICATE security.fn_school_access_predicate(school_id) ON dbo.classes,
ADD BLOCK PREDICATE security.fn_school_access_predicate(school_id) ON dbo.classes
WITH (STATE = ON);
GO

-- Create roles for different access levels
CREATE ROLE school_admin;
CREATE ROLE school_teacher;
CREATE ROLE school_parent;
CREATE ROLE school_student;

-- Grant permissions to roles
GRANT SELECT, INSERT, UPDATE ON dbo.students TO school_admin;
GRANT SELECT ON dbo.students TO school_teacher;
GRANT SELECT ON dbo.students TO school_parent;
GRANT SELECT ON dbo.students TO school_student;

-- Create stored procedure for setting school context

GO
CREATE PROCEDURE dbo.sp_set_school_context
    @school_id INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC sp_set_session_context @key = N'current_school_id', @value = @school_id;
END;
GO 