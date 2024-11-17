# Hermes: A General-Purpose Proxy-Enabled Networking Architecture

This repository contains the prototype implementation of Hermes use cases presented in the paper [draft](https://arxiv.org/abs/XXXXXXXX). The repository will be updated periodically to include additional use cases.

---

## Abstract
Hermes is a networking architecture designed to delegate networking responsibilities from applications and services to overlay proxies. By employing a range of proxying and tunneling techniques, utilizing HTTP as its core component, and integrating assisting components, Hermes facilitates service delivery, enhances communication, and improves the end-user experience. This design supports backward compatibility, reliable delivery in unstable conditions, and end-to-end solutions for modern networking challenges.

---

## Design Principles
The Hermes architecture is built upon four core principles:

1. **Delegation of Responsibilities**  
   Networking responsibilities are offloaded from applications or services to a dynamically reconfigurable proxy network. This abstraction simplifies application design, allowing service and application developers to focus on communicating with their local proxies while the overlay manages networking complexities.

2. **Overlay Tunneling**  
   Hermes supports UDP, TCP, and HTTP proxies to ensure seamless compatibility with the existing internet infrastructure.

3. **HTTP-Based Semantic Processing**  
   The architecture leverages HTTP's extensibility, allowing semantic processing and routing at any node within the overlay.

4. **Assisting Components**  
   Proxies are complemented by assisting components that add advanced capabilities, such as policy enforcement, caching, and traffic manipulation.

---

## Features
Hermes provides the following key features:

- **Simplified Applications**  
  Service and application developers can rely on the overlay to manage networking complexities, enabling them to focus on communication with their local proxies.

- **Dedicated Address Spaces**  
  Hermes allows customizable dedicated address spaces, bypassing traditional name resolution at end-hosts through DNS.

- **End-to-End Traffic Control**  
  Hermes facilitates policy- and privacy-aware end-to-end control over IP traffic.

- **Legacy Compatibility**  
  Enables compatibility with legacy services and protocols while easing the development of new features.

- **Reliable Communication**  
  Employs dynamically reconfigurable proxies capable of managing challenging network conditions.

- **Support for Experimental Architectures**  
  Provides a reliable underlying network for testing new protocols or architectures, such as Named Data Networking (NDN).

---

## Repository Contents
This repository includes:

1. **Use Case Implementations**  
   Prototypes of use cases presented in the paper, including:
   - A dynamic overlay update that enforces end-to-end policies for IP traffic.
   - UDP video streaming over noisy networks.
   - Secure end-to-end communication in degraded environments.
   - Experimental networking architecture support.
   - A simple HTTP policy-based routing example and related Nginx implementation.
   - A simple MySQL database use case that uses the client's IP address for authorization.
   - Additional use cases will be added in future updates.


2. **Control Plane**  
   Compiled configuration manager (located in the `Controller` folder).

3. **Android Client** 
   The Android client uses the Envoy library to create an HTTP proxy that can be configured dynamically through the control plane.
---

## Testing Use Cases
To test each use case:

1. Check the IP addresses in the configuration files located within each use case folder.
2. Update the IP addresses if necessary to match your environment.
3. Run the run.sh script.

---

For more details, refer to the full paper linked above.
