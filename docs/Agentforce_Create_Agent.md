# Salesforce Agentforce: Agent Creation & Architecture Guide

## 1. Prerequisites & Org Enablement
Before an Agent can be created or configured, the underlying Salesforce org must be provisioned to support Agentforce.

**Enable Einstein**
1. Open the Setup Menu and click **Setup**.
2. In the Setup Quick Find, search for *Generative AI*, and select **Einstein Setup**.
3. Click the **Turn on Einstein** toggle.

**Enable Agentforce**
1. Open the Setup Menu and click **Setup**.
2. In the quick find, search for *Agents* and click **Agentforce Agents**.
3. Turn on the **Agentforce** toggle.

## 2. Core Architecture Overview
Understanding the hierarchy is critical for designing scalable agents. An Agentforce implementation is not a single massive prompt; it is a structured system of boundaries and capabilities.

* **The Agent (The Persona):** The top-level entity. It defines the overarching role, tone, and global instructions (e.g., "You are a helpful customer service representative").
* **Subagents (Formerly "Topics"):** These represent the specific "Jobs to Be Done." Subagents establish strict boundaries for the LLM. If a user asks a question, the Agent routes it to the most relevant Subagent.
* **Actions (The Tools):** The executable capabilities (Flows, Apex, Prompt Template actions) assigned to a Subagent. 
  > ⚠️ **Crucial Concept:** The Agent can *only* execute an action if that action is explicitly assigned to the currently active Subagent.

## 3. Step-by-Step Agent Creation Process

### Step 1: Initialize the Agent & Select a Template
1. Navigate to the **Agentforce Builder** from the App Launcher.
2. Click **New Agent**.
3. **Template Selection:** You will be prompted to define what you want the agent to do. Select a starting template based on your use case (e.g., select the *Agentforce Service Agent* template).
4. Define the **Agent Name** and **Developer Name** (e.g., `trail_agent`).
5. **Define the Agent's User Record** *(Specific to Service Agents)*: You must assign a dedicated Salesforce User record to the agent. Because customer-facing agents are often deployed to external sites where the end-user doesn't have a Salesforce login, any DML operations (creating, updating, or deleting records) performed by the agent will be executed and attributed to this designated Agent User. This acts as the agent's security profile, strictly dictating its Object, Record, and Field-Level Security access.
6. Define the **Description**, which outlines the agent's primary directive.

### Step 2: Transitioning to Script Mode (Developer Workflow)
While the default view provides a visual canvas, developers can utilize Script Mode for granular control over the agent's definition and logic.
1. In the top right corner of the Agentforce Builder, locate the view toggle (defaults to **Canvas**).
2. Click the dropdown and select **Script**.
> **Note:** In Script mode, you can explicitly define prompt instructions, assign subagents, and map variables via code.

### Step 3: Configure Subagents (Defining Boundaries)
Subagents represent the specific jobs the agent can perform.
1. Within the Builder's left-hand Explorer panel, expand the **Subagents** section.
2. Select an existing subagent or create a new one.
3. Define clear **Instructions** outlining the specific rules for that job.

### Step 4: Assign Actions to Reasoning
Within the active, reasoning-capable Subagent, explicitly assign the executable tools (Flows, Apex, Prompt Template actions).
* **Action Descriptions:** The LLM relies entirely on the metadata descriptions of these actions to understand when to invoke them. Ensure all assigned actions have highly descriptive summaries of their required inputs and expected outputs.

---
### 📚 Official Resources
* [Agentforce Agent Script Guide](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html)
* [Set Up and Create Agentforce Agents](https://help.salesforce.com/s/articleView?id=ai.agent_setup_create.htm&type=5)
* [Configure Agentforce Agents](https://help.salesforce.com/s/articleView?id=ai.agent_parent_configure.htm&type=5)