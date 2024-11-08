-- Enable Row Level Security
CREATE SCHEMA security;
GO

-- Create function for row-level security
CREATE FUNCTION security.fn_tenantAccessPredicate(@school_id INT)
    RETURNS TABLE
    WITH SCHEMABINDING
AS
    RETURN SELECT 1 AS fn_securitypredicate_result
    WHERE @school_id = CAST(SESSION_CONTEXT(N'school_id') AS INT);
GO

-- Create sequence for school codes
CREATE SEQUENCE seq_school_code
    START WITH 1000
    INCREMENT BY 1;
GO 