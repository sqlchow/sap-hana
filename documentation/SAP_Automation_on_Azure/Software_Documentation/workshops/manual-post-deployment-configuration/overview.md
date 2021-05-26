### <img src="../../../assets/images/UnicornSAPBlack256x256.png" width="64px"> SAP Deployment Automation Framework <!-- omit in toc -->
<br/><br/>

# Deployment Workshop <!-- omit in toc -->

<br/>

## Table of contents <!-- omit in toc -->

- [Steps](#steps)
- [Overview](#overview)

<br/><br/>

## Steps
1. [Bootstrap - Deployer](01-bootstrap-deployer.md)
2. [Bootstrap - SPN](02-spn.md)
3. [Bootstrap - SAP Library](03-bootstrap-library.md)
4. [Bootstrap - Reinitialize](04-reinitialize.md)
5. [Deploy SAP Workload VNET](05-workload-vnet.md)
6. [Deploy SDU](06-sdu.md)

<br/>

---

<br/>

## Overview
![Overview](assets/BlockOverview.png)

Playbooks
- Base OS configuration
- SAP specific OS Configuration
- SAP Bill of Materials (BOM) processing - Software Download
- DB Install
- SAP Software Install
  - SCS Install
  - DB Load
  - Primary Application Server Install
Future Steps will include:
- Application Server Install
- Web Dispatcher Install
- SAPRouter
- Pacemaker DB / SCS


<br/><br/><br/><br/>


# Next: [Bootstrapping the Deployer](01-bootstrap-deployer.md) <!-- omit in toc -->
