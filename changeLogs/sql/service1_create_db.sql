--liquibase formatted sql

-- changeset debraj.manna@nexla.com:JIRA_ID1-1
-- comment: Create the service1_data table
CREATE TABLE service1_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    service_name VARCHAR(100) NOT NULL,
    payload JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- changeset debraj.manna@nexla.com:JIRA_ID2-1
-- comment: Add an index to the service_name column
CREATE INDEX idx_service_name ON service1_data(service_name);
-- rollback DROP INDEX idx_service_name ON service1_data;
