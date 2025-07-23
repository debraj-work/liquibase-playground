--liquibase formatted sql

-- changeset service2:debraj.manna@nexla.com:JIRA:1
-- comment: Create the service2_status table
CREATE TABLE service2_status (
    id INT PRIMARY KEY AUTO_INCREMENT,
    status_code VARCHAR(50) NOT NULL,
    details TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
