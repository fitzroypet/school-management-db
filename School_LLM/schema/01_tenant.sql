CREATE TABLE dbo.schools (
    school_id INT IDENTITY(1,1) PRIMARY KEY,
    school_code AS 'SCH' + CAST(NEXT VALUE FOR seq_school_code AS VARCHAR(20)) PERSISTED UNIQUE,
    school_name NVARCHAR(100) NOT NULL,
    subscription_status NVARCHAR(20) NOT NULL 
        CONSTRAINT CK_subscription_status 
        CHECK (subscription_status IN ('Active', 'Inactive', 'Trial', 'Expired')),
    subscription_start_date DATE,
    subscription_end_date DATE,
    address NVARCHAR(MAX),
    phone NVARCHAR(20),
    email NVARCHAR(100) NOT NULL,
    website NVARCHAR(255),
    logo_url NVARCHAR(255),
    timezone NVARCHAR(50) DEFAULT 'UTC',
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT UQ_school_email UNIQUE (email)
);

-- Add RLS policy
CREATE SECURITY POLICY school_security_policy
    ADD FILTER PREDICATE security.fn_tenantAccessPredicate(school_id)
    ON dbo.schools;
GO

CREATE TABLE dbo.subscription_plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10,2) NOT NULL,
    billing_cycle NVARCHAR(20) NOT NULL
        CONSTRAINT CK_billing_cycle 
        CHECK (billing_cycle IN ('Monthly', 'Yearly')),
    max_students INT,
    max_teachers INT,
    features NVARCHAR(MAX), -- JSON
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2
);

CREATE TABLE dbo.school_subscriptions (
    subscription_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status NVARCHAR(20) NOT NULL,
    payment_status NVARCHAR(20) NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_school_subscriptions_school 
        FOREIGN KEY (school_id) REFERENCES schools(school_id),
    CONSTRAINT FK_school_subscriptions_plan 
        FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id)
); 