# Path-Traversal-in-Oracle-GlassFish-Server-Open-Source-Edition
Published: 08/27/2015 Version: 1.0  Vendor: Oracle Corporation (Project sponsored by Oracle) Product: GlassFish Server Open Source Edition Version affected:  4.1 and prior versions
Oracle GlassFish Server 4.1 - Directory Traversal
CVE:2017-1000028


# Vulnerable GlassFish 4.1 for Path Traversal Practice (CVE-2017-1000028)

This repository provides a **Dockerized vulnerable setup** of **Oracle GlassFish Server Open Source Edition 4.1** to safely practice the **directory traversal vulnerability** (CVE-2017-1000028) described in Trustwave SpiderLabs advisory TWSL2015-016.

**Purpose**: Educational / CTF-style learning only. Demonstrates an **authenticated** path traversal flaw in the GlassFish admin console (port 4848) that allows reading arbitrary files on the server.

**Important Warnings**
- **Do NOT expose this container to the internet** — especially port 4848.
- Use only in isolated lab environments (local machine, VM, etc.).
- This is intentionally vulnerable software — never use in production.
- For learning cybersecurity, penetration testing, or CTF challenges.

## Vulnerability Details

- **CVE**: CVE-2017-1000028
- **Affected Versions**: GlassFish Open Source Edition 4.1 and prior
- **Affected Component**: Administration Console (port 4848)
- **Type**: Authenticated Directory Traversal
- **Bypass Technique**: Uses `%c0%ae%c0%ae%c0%af` (encoded `../`) to bypass filters
- **Requirements**: Valid session (JSESSIONID cookie from admin login)
- **Impact**: Read arbitrary files (e.g., `/etc/shadow`, config files, or in this setup: `/flag.txt`)

Reference: [Trustwave Advisory TWSL2015-016](https://www.trustwave.com/Resources/Security-Advisories/Advisories/TWSL2015-016/?fid=6904)




### Build the Docker image
## docker build -t vulnerable-glassfish:4.1 .

### Run the container
## docker run -d -p 4848:4848 -p 8080:8080 -p 8181:8181 --name glassfish-ctf vulnerable-glassfish:4.1

### Access the Admin ConsoleOpen your browser and go to:
https://localhost:4848
