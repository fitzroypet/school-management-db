CREATE TABLE dbo.roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    role_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(MAX),
    permissions NVARCHAR(MAX), -- JSON array of permissions
    is_system_role BIT DEFAULT 0,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_roles_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT UQ_role_per_school UNIQUE (school_id, role_name)
);

CREATE TABLE dbo.users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    username NVARCHAR(50) NOT NULL,
    email NVARCHAR(100) NOT NULL,
    password_hash NVARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    is_active BIT DEFAULT 1,
    email_verified BIT DEFAULT 0,
    last_login DATETIME2,
    failed_login_attempts INT DEFAULT 0,
    password_reset_token NVARCHAR(255),
    token_expiry DATETIME2,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_users_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_users_role FOREIGN KEY (role_id) 
        REFERENCES roles(role_id),
    CONSTRAINT UQ_email_per_school UNIQUE (school_id, email),
    CONSTRAINT UQ_username_per_school UNIQUE (school_id, username)
);

CREATE TABLE dbo.user_sessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    token NVARCHAR(255) NOT NULL,
    ip_address NVARCHAR(45),
    user_agent NVARCHAR(255),
    expires_at DATETIME2 NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_sessions_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
); 