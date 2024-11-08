CREATE TABLE dbo.notification_templates (
    template_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    template_name NVARCHAR(100) NOT NULL,
    subject NVARCHAR(200),
    body NVARCHAR(MAX),
    template_type NVARCHAR(50), -- Email, SMS, In-App
    variables NVARCHAR(MAX), -- JSON array of available variables
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2,
    CONSTRAINT FK_notification_templates_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id)
);

CREATE TABLE dbo.notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    template_id INT,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(MAX) NOT NULL,
    notification_type NVARCHAR(50),
    sender_id INT NOT NULL,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    scheduled_at DATETIME2,
    sent_at DATETIME2,
    status NVARCHAR(20) DEFAULT 'Pending',
    CONSTRAINT FK_notifications_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_notifications_template FOREIGN KEY (template_id) 
        REFERENCES notification_templates(template_id)
);

CREATE TABLE dbo.notification_recipients (
    recipient_id INT IDENTITY(1,1) PRIMARY KEY,
    notification_id INT NOT NULL,
    user_id INT NOT NULL,
    is_read BIT DEFAULT 0,
    read_at DATETIME2,
    delivery_status NVARCHAR(20) DEFAULT 'Pending',
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_notification_recipients_notification FOREIGN KEY (notification_id) 
        REFERENCES notifications(notification_id),
    CONSTRAINT FK_notification_recipients_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id)
);

CREATE TABLE dbo.messages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    school_id INT NOT NULL,
    sender_id INT NOT NULL,
    subject NVARCHAR(200),
    message_body NVARCHAR(MAX),
    parent_message_id INT,
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    CONSTRAINT FK_messages_school FOREIGN KEY (school_id) 
        REFERENCES schools(school_id),
    CONSTRAINT FK_messages_sender FOREIGN KEY (sender_id) 
        REFERENCES users(user_id),
    CONSTRAINT FK_messages_parent FOREIGN KEY (parent_message_id) 
        REFERENCES messages(message_id)
); 