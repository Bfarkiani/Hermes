# IP Use Case

This folder contains the configuration files and implementation for the IP Use Case. Before running the setup, ensure that all IP addresses and server configurations are appropriately updated based on your environment.

---

## Setup Instructions

### 1. Update IP Addresses
- **DB Folder**
  - In the `update1` and `update2` files, set the relevant IP addresses for the database servers.

### 2. Configure the Updater
- **`main.go`**
  - This file acts as the updater for configurations. You must set the address of your CouchDB instance before compiling and running this file.

### 3. Configure Proxies
- **Client and Ingress Proxies**
  - In the `client`, `client2`, `ingress1`, and `ingress2` folders, update the configuration files to include the correct IP address of the controller.

---

## Running the Use Case
1. Update all IP addresses and server configurations as described above.
2. Start the proxies in `client`, `client2`, `ingress1`, and `ingress2` folders.
3. Build and run the `main.go` file to start upadting configurations.

---

## Notes

For further questions or troubleshooting, refer to the main [Hermes documentation](../README.md).
