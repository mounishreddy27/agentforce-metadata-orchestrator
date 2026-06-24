# Agentforce Setup Metadata Orchestrator

[![Salesforce](https://img.shields.io/badge/Salesforce-Agentforce-00A1E0?style=for-the-badge&logo=salesforce)](#)
[![API Version](https://img.shields.io/badge/API_Version-v62.0-brightgreen?style=for-the-badge)](#)

An enterprise-grade, Agentforce implementation that bypasses native platform limitations to automate the creation of Setup Metadata (specifically Email-to-Case routing addresses).

## 🗳️ Support the Idea Exchange Request
While this repository provides a functional workaround, this functionality should be native to the platform. Salesforce Support has officially recommended opening a feature request to allow Agentforce to execute CRUD actions on Setup Metadata.

**Please upvote the official Idea here:** 
[Enable Agentforce CRUD Actions for Setup Metadata](https://ideas.salesforce.com/s/idea/a0BHp000019OpwDMAS/enable-agentforce-crud-actions-for-setup-metadata)

## 🚀 The Challenge
Standard Agentforce actions are strictly scoped to the Salesforce **runtime data layer**. They cannot read or write to the Setup/Metadata layer.

## 💡 The Solution
This repository provides a complete "escape hatch" architecture:
1. **Data Transformation Pipeline:** Uses a Flex Prompt Template grounded with a strict JSON schema to turn conversational user input into strictly typed metadata configurations. 
2. **OAuth Bridge:** Utilizes an External Client App (ECA) and a direct Apex REST callout to fetch a valid Access Token, completely bypassing the restricted Agent session.
3. **SOAP Body Injection:** Manually injects the fetched token into the `<SessionHeader>` of the SOAP XML request (Named Credentials cannot do this for SOAP endpoints).
4. **Patched MetadataService:** Includes a manually patched version of the famous Certinia `MetadataService.cls`, upgraded to API v62.0 to support modern Case Settings tags.
5. **Strict Grounding:** The AgentScript is tightly grounded to restrict off-topic prompts, terminating the flow after 3 invalid attempts.

## 📦 Repository Contents
To deploy this POC, the following Salesforce metadata components are included in this source:
* **Apex Classes:** The Custom Invocable action, the OAuth Token Fetcher, and the patched v62 `MetadataService.cls`.
* **Prompt Templates:** The Flex Prompt used to generate the JSON payload.
* **Agent Configuration:** The Copilot/Agentforce metadata definitions and topic routing logic.

## 🛠️ Installation & Setup Prerequisites

To secure the authentication flow, this repository relies on an External Client App (ECA) and Custom Metadata Types to prevent hardcoded credentials.

**1. Create the External Client App & Agent API**
Please follow the official Salesforce documentation to configure your ECA and set up the Agent API for headless invocation:
* [Create a Local External Client App](https://help.salesforce.com/s/articleView?id=xcloud.create_a_local_external_client_app.htm&type=5)
* [Agent API Getting Started Guide](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-get-started.html)

**2. Configure Custom Metadata**
This repository includes a Custom Metadata Type named `Agentforce_Auth_Setting__mdt`. After deploying the repository to your org, you must create a record to store your credentials:
* Go to Setup -> Custom Metadata Types -> Manage **Agentforce Auth Settings**.
* Create a new record named exactly `Default_Config`.
* Populate the `Endpoint_URL__c`, `Client_Id__c`, and `Client_Secret__c` with the values generated from your ECA.

**3. Whitelist the Endpoint**
Add your org's OAuth token endpoint (e.g., `https://your-domain.my.salesforce.com/services/oauth2/token`) to **Remote Site Settings** so the Apex class can perform the self-referential callout.
