--liquibase formatted sql

-- changeset service1:debraj.manna@nexla.com:JIRA:1
-- comment: Create the service1_data table
CREATE TABLE service1_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    payload JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- changeset service1:debraj.manna@nexla.com:JIRA:2
-- comment: Add an index to the service_name column
CREATE INDEX idx_service_name ON service1_data(service_name);
-- rollback DROP INDEX idx_service_name ON service1_data;
