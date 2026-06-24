# Salesforce Agentforce: Agent Deployment Guide

## Core Deployment Philosophy
Agent deployment is not one-size-fits-all. The pathway you choose depends entirely on the template selected during creation. Agentforce enforces a strict boundary between internal (employee-facing) and external (customer-facing) deployments to ensure data security and appropriate context mapping.

* **Employee Agents:** Adopt the security context (Profile/Permission Set) of the logged-in Salesforce user.
* **Service Agents:** Utilize the dedicated "Agent User Record" assigned during creation to strictly govern what data external customers can access.

## 1. Service Agents (Customer-Facing)
Service Agents interact with external users (customers, partners) and are deployed across digital engagement and support channels:
* Enhanced Chat
* Other Enhanced Messaging Channels
* Email

## 2. Employee Agents (Internal)
Employee Agents are designed to assist internal staff members within their standard flow of work, operating under the user's existing Salesforce security profile:
* Salesforce Lightning Experience (LEX) & Salesforce Mobile
* Slack
* Enhanced Web Chat

---
### 📚 Official Resources
* [AI Agent Deployment with Agentforce Overview](https://help.salesforce.com/s/articleView?id=ai.agent_parent_deploy.htm&type=5)
* Grant Access and Use Agentforce Agents Effectively