# Docker & Liquibase MySQL Demo
This repository provides a simple, self-contained example of how to use Liquibase to manage a MySQL database schema, with both services running in Docker containers. It's designed as a hands-on playground for developers to understand and experiment with database migrations in a containerized environment.

The setup uses separate changelogs for two hypothetical microservices (service1 and service2) that share a single database, which is a common real-world scenario.

## Prerequisites
Before you begin, ensure you have the following installed on your local machine:

- Docker Desktop: To run the containers. Download Docker Desktop

You will also need a MySQL command-line client if you wish to connect to the database from your host machine. The easiest way to install it on macOS is with Homebrew:

```
brew install mysql-client
```

## Directory Structure
The project is organized to separate changelogs by service, promoting a modular approach to database schema management.

```
.
├── changeLogs/
│   ├── service1_mysql_root_changelog.xml  # Master changelog for service1
│   ├── service2_mysql_root_changelog.xml  # Master changelog for service2
│   └── sql/
│       ├── service1_create_db.sql         # SQL changesets for service1
│       └── service2_create_db.sql         # SQL changesets for service2
├── docker-compose.yaml                    # Defines the MySQL service
└── runner.sh                              # Helper script to run migrations
```

## Getting Started
Follow these steps to get the database running and apply the schema migrations.

Step 1: Start the MySQL Database
Navigate to the root directory of this project in your terminal and start the MySQL container using Docker Compose.

```
docker-compose up -d
```

This command starts a MySQL 8.0 server in a detached container. The database will be available on your host machine at port 3307 to avoid conflicts with any local MySQL installations.

Step 2: Make the Runner Script Executable
You only need to do this once. Grant execute permissions to the `runner.sh` script.

```
chmod +x runner.sh
```

Step 3: Run the Database Migrations
Use the `runner.sh` script to apply the database changes for each service.

To run migrations for `service1`:

```
./runner.sh service1
```

To run migrations for `service2`:

```
./runner.sh service2
```

The script will spin up a temporary Liquibase container, connect it to the running MySQL container's network, and apply the changes defined in the appropriate changelog files.

## How It Works
- `docker-compose.yaml`: This file defines and configures the mysql_db service. It sets up the database name, user, and passwords. Crucially, it maps port 3307 on your host machine to port 3306 inside the container.
- `runner.sh`: This is a convenience script that simplifies running Liquibase. It dynamically determines the Docker network name and mounts your local changeLogs directory into the Liquibase container. It requires a service name (service1 or service2) as an argument to run the correct changelog.
- Liquibase Changelogs: The changelogs directory contains the database migration files. Each service has its own XML file that acts as a master changelog for that service, which in turn includes one or more .sql files containing the actual schema changes.

## Final Database Schema

After running the migrations for both service1 and service2, the mydatabase database will contain the following tables:

- `service1_data`: Created by service1's migration. Contains data specific to service 1.
- `service2_status`: Created by service2's migration. Contains status information for service 2.
- `DATABASECHANGELOG`: Liquibase's tracking table. It records every changeset that has been successfully executed, including the author, ID, and a checksum of the change.
- `DATABASECHANGELOGLOCK`: Liquibase's concurrency control table. It places a lock on the database to prevent multiple Liquibase instances from running at the same time.

## Advanced Usage
Connecting to the Database from Your Host
You can connect to the MySQL database running inside the Docker container from your host machine using any standard SQL client or the command line.

### Connection Details:

- Host: 127.0.0.1
- Port: 3307
- User: user or root
- Password: password or rootpassword
- Database: mydatabase

Example command-line connection (as `user`):

```
mysql -h 127.0.0.1 -P 3307 -u user -p mydatabase
```

### Adding New Migrations
To add a new database change (e.g., adding a new table or column for `service1`):

1. Open the `changeLogs/sql/service1_create_db.sql` file.
2. Add a new `--changeset` block to the end of the file.
3. Crucially, ensure the `id` of the new changeset is unique within that file.
4. Run `./runner.sh service1` again. Liquibase will see the new changeset and apply it, skipping the ones it has already executed.

### Specifying a Log Level
The runner.sh script accepts an optional second argument for the Liquibase log level (debug, info, warning, severe). This is useful for troubleshooting.

# Run service1 migrations with detailed debug logging
```
./runner.sh service1 debug
```

## Troubleshooting
### "Access Denied" Errors
If you get an "Access Denied" error when connecting from your host, it's likely you are connecting to a different, non-Docker MySQL server running on your machine. Ensure you are using port 3307 in your connection command.

### "Duplicate Identifiers" Error
If Liquibase fails with a ValidationFailedException: duplicate identifiers error, it means you are trying to run a changeset that has already been recorded in the DATABASECHANGELOG table. This is a safety feature. Do not modify existing changesets. Instead, add a new changeset with a unique ID to make your changes.
