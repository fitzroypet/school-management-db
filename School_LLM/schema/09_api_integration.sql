CREATE TABLE dbo.api_keys (
    api_key_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    key_name NVARCHAR(100) NOT NULL,
    api_key NVARCHAR(255) NOT NULL,
    hashed_secret NVARCHAR(255) NOT NULL,
    is_active BIT DEFAULT 1,
    expires_at DATETIME2,
    permissions NVARCHAR(MAX), -- JSON array of permitted operations
    created_by INT NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    last_used_at DATETIME2,
    CONSTRAINT FK_api_keys_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT UQ_api_key UNIQUE (api_key)
);

CREATE TABLE dbo.integration_logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    api_key_id INT,
    endpoint NVARCHAR(200),
    method NVARCHAR(10),
    request_headers NVARCHAR(MAX), -- JSON
    request_body NVARCHAR(MAX), -- JSON
    response_code INT,
    response_body NVARCHAR(MAX), -- JSON
    ip_address NVARCHAR(45),
    execution_time INT, -- milliseconds
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_integration_logs_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_integration_logs_api_key FOREIGN KEY (api_key_id) 
        REFERENCES api_keys(api_key_id)
);

CREATE TABLE dbo.webhooks (
    webhook_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    endpoint_url NVARCHAR(255) NOT NULL,
    secret_key NVARCHAR(255),
    event_types NVARCHAR(MAX), -- JSON array of subscribed events
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_webhooks_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id)
); 