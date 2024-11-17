# Configuration Manager

This folder contains the Configuration Manager (part of the overlay controller) for the Hermes overlay network. The Configuration Manager is responsible for pushing configurations to the overlay proxies. It reads configurations and secrets from the CouchDB database.

---

## Setup Instructions

### 1. Update Database Address
- Open the `run.sh` file.
- Set the database address (`DB_ADDRESS`) to the correct CouchDB instance in your environment.

### 2. Run the Configuration Manager
- After updating the `run.sh` file, execute it using the following command:
  ```bash
  ./run.sh
