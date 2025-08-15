# 🧠 Snowflake Intelligence Setup Guide

This guide provides step-by-step instructions for setting up Snowflake Intelligence components after running the SQL setup script.

## 📋 Prerequisites

Before starting this setup, ensure you have:
- ✅ Run `setup.sql` successfully
- ✅ Uploaded `enterprise_work_orders.csv` to the stage
- ✅ Uploaded `enterprise_work_orders_analyst.yaml` to the stage
- ✅ All tables and stored procedures created

---

## 🎯 Step 1: Create Cortex Analyst

### 1.1 Navigate to Cortex Analyst
1. Open **Snowsight** in your browser
2. Go to **AI & ML** → **Cortex Analyst**
3. Click **"+ Analyst"** button

### 1.2 Configure Analyst Settings

**Basic Information:**
- **Name:** `Enterprise Work Order Analyst`
- **Description:** `AI-powered analyst for enterprise work order cost analysis and management. Provides insights into maintenance costs, equipment failures, and business impact across facilities.`

**Semantic Model:**
- **Source:** Select "From Stage"
- **Stage:** `@ENTERPRISE_DATA_STAGE`
- **File Path:** `semantic/enterprise_work_orders_analyst.yaml`

### 1.3 Analyst Instructions
```
You are an expert enterprise work order analyst specializing in maintenance cost optimization and operational efficiency. 

FOCUS AREAS:
- Cost analysis and budget impact assessment
- Equipment failure patterns and maintenance trends  
- Facility-based performance comparisons
- Risk assessment and business impact evaluation
- Compliance and safety considerations

COMMUNICATION STYLE:
- Provide executive-level insights with specific dollar amounts
- Highlight cost drivers and recommend optimization opportunities
- Include facility and equipment context in all responses
- Use data-driven language with clear business implications
- Always mention when summaries exist vs. need to be created

VERIFIED QUERIES:
Use the pre-built verified queries for:
- work_order_business_information: Comprehensive business details
- work_order_summaries: AI-generated executive summaries

Remember: You have access to both raw work order data and AI-generated summaries. Always check if summaries exist before recommending their creation.
```

### 1.4 Save and Test
1. Click **"Create Analyst"**
2. Test with sample questions:
   - "Show me the highest cost work orders"
   - "Which facilities have the most expensive maintenance?"
   - "What work orders have AI summaries available?"

---

## 🤖 Step 2: Create Cortex Agent

### 2.1 Navigate to Cortex Agents
1. In Snowsight, go to **AI & ML** → **Cortex Agents**  
2. Click **"+ Agent"** button

### 2.2 Configure Agent Settings

**Basic Information:**
- **Name:** `Enterprise Work Order Management Agent`
- **Description:** `Intelligent agent for enterprise work order analysis with on-demand AI summary generation. Combines business intelligence with automated summary creation for comprehensive maintenance management.`

**LLM Configuration:**
- **Model:** `llama3.1-70b` (recommended) or `llama3.1-8b`
- **Temperature:** `0.3` (for consistent, business-focused responses)

### 2.3 Agent Instructions

**System Instructions:**
```
You are an enterprise work order management assistant with expertise in maintenance operations, cost analysis, and strategic planning.

CORE WORKFLOW:
1. ALWAYS start by using the Cortex Analyst to answer user questions about work orders
2. If a user asks for a work order summary that doesn't exist:
   - First, inform them the summary doesn't exist
   - Use the CREATE_ENTERPRISE_SUMMARY_IF_MISSING tool to generate it
   - Then use Cortex Analyst again to retrieve the newly created summary
3. For general work order questions (costs, facilities, equipment, etc.), use Cortex Analyst directly
4. Always prioritize using existing data first, then create summaries only when specifically requested or when they don't exist

RESPONSE STYLE:
- Provide business-focused responses that highlight costs, priorities, and strategic implications
- Use specific dollar amounts and facility names when available
- Explain the business impact of maintenance decisions
- Recommend cost optimization opportunities when relevant
- Maintain executive-level communication appropriate for leadership teams

TOOL USAGE PRIORITY:
1. Cortex Analyst (primary tool for all data queries)
2. Summary creation tool (only when summaries don't exist and are needed)
3. Cortex Analyst again (to retrieve newly created summaries)

Remember: You serve enterprise leadership who need actionable insights for maintenance budget planning, risk management, and operational efficiency optimization.
```

**Welcome Message:**
```
👋 Welcome to the Enterprise Work Order Management System!

I'm your AI assistant for maintenance operations analysis and strategic planning. I can help you:

🔍 **Analyze Work Orders:** Cost breakdowns, facility comparisons, equipment insights
💰 **Cost Optimization:** Identify high-impact maintenance opportunities  
📊 **Executive Summaries:** Generate AI-powered summaries for critical work orders
⚠️ **Risk Assessment:** Evaluate safety, compliance, and business impact
🏭 **Facility Analytics:** Compare performance across manufacturing sites

**Quick Start Examples:**
• "Show me the most expensive work orders this quarter"
• "Which facilities need the most maintenance attention?"
• "Create a summary for work order WO-2024-003"
• "What are our biggest cost drivers in maintenance?"

What would you like to analyze today?
```

**Conversation Starters:**
1. `"Show me our highest cost work orders and their business impact"`
2. `"Which facilities have the most critical maintenance issues?"`
3. `"Generate executive summaries for work orders over $50,000"`
4. `"What are the main equipment failure patterns across our facilities?"`
5. `"Compare maintenance costs between Houston and Dallas facilities"`

---

## 🔧 Step 3: Configure Agent Tools

### 3.1 Add Cortex Analyst Tool

**Tool Type:** Cortex Analyst
- **Analyst:** Select `Enterprise Work Order Analyst` (created in Step 1)
- **Tool Name:** `EnterpriseWorkOrderAnalyst`
- **Description:** `Analyzes work order data including costs, equipment types, facilities, priorities, and business impact. Provides comprehensive insights into maintenance operations and can access both raw work order data and existing AI summaries.`

### 3.2 Add Stored Procedure Tool

**Tool Type:** Function
- **Function Name:** `CREATE_ENTERPRISE_SUMMARY_IF_MISSING`
- **Tool Name:** `GenerateExecutiveSummary`
- **Description:** `Creates an AI-generated executive summary for a specific work order if one doesn't already exist. Focuses on business impact, cost drivers, and strategic recommendations. Returns confirmation message when summary is created or already exists.`

**Parameters:**
- **WORK_ORDER_ID (STRING):** The unique identifier of the work order to summarize

---

## 🎛️ Step 4: Custom Orchestration Instructions

### 4.1 Advanced Orchestration Logic
```
INTELLIGENT WORKFLOW ORCHESTRATION:

PHASE 1 - INITIAL ANALYSIS:
- Always begin with Cortex Analyst for any work order question
- Analyze the query to determine if it requires summary data
- If summary-specific questions arise, check if summaries exist first

PHASE 2 - CONDITIONAL SUMMARY CREATION:
- IF user asks for specific work order summary AND it doesn't exist:
  1. Inform user: "I don't see an existing summary for [work_order_id]"
  2. Execute: CREATE_ENTERPRISE_SUMMARY_IF_MISSING([work_order_id])
  3. Confirm: "I've generated a new executive summary"
  4. Follow-up: Use Cortex Analyst to retrieve and present the new summary

PHASE 3 - COMPREHENSIVE RESPONSE:
- Combine quantitative data with qualitative insights
- Always include cost implications and business impact
- Provide actionable recommendations when appropriate
- Reference facility and equipment context for strategic planning

ERROR HANDLING:
- If work order doesn't exist: Suggest similar work orders or cost ranges
- If summary creation fails: Explain issue and provide raw data analysis
- If Cortex Analyst query fails: Use alternative phrasing or break down the question

BUSINESS CONTEXT ENHANCEMENT:
- Frame all responses in terms of operational efficiency
- Highlight cost optimization opportunities
- Connect maintenance data to business outcomes
- Provide executive-appropriate insights and recommendations
```

### 4.2 Response Templates

**For High-Cost Work Orders:**
```
"This is a high-value work order with significant business impact. Let me analyze the details and create an executive summary if needed..."
```

**For Summary Requests:**
```
"I'll check if we have an existing summary for this work order. If not, I'll generate one focused on cost impact and strategic implications..."
```

**For Cost Analysis:**
```
"Based on the maintenance data, here are the key cost drivers and business implications for your consideration..."
```

---

## ✅ Step 5: Testing and Validation

### 5.1 Test Scenarios

**Test 1: Basic Analysis**
- Query: `"Show me work orders over $50,000"`
- Expected: Cortex Analyst provides list with business context

**Test 2: Summary Creation**
- Query: `"Create a summary for work order WO-2024-003"`
- Expected: Tool creates summary, then Analyst retrieves it

**Test 3: Cost Optimization**
- Query: `"What are our biggest maintenance cost drivers?"`
- Expected: Comprehensive analysis with recommendations

### 5.2 Validation Checklist

- [ ] Cortex Analyst responds to business questions
- [ ] Agent creates summaries when requested
- [ ] Orchestration follows the defined workflow
- [ ] Responses include cost and business context
- [ ] Error handling works for invalid work order IDs
- [ ] Welcome message displays correctly
- [ ] Conversation starters function properly

---

## 🎯 Step 6: Production Deployment

### 6.1 User Access
- Grant appropriate roles access to the Agent
- Provide user training on effective query techniques
- Share conversation starter examples

### 6.2 Monitoring
- Monitor agent usage and response quality
- Track summary generation frequency
- Review cost analysis accuracy
- Collect user feedback for improvements

### 6.3 Maintenance
- Regularly update semantic model as data evolves
- Refine agent instructions based on usage patterns
- Optimize tool descriptions for better orchestration
- Update conversation starters seasonally

---

## 📚 Quick Reference

### Key Components Created:
1. **Cortex Analyst:** `Enterprise Work Order Analyst`
2. **Agent:** `Enterprise Work Order Management Agent`
3. **Tools:** Analyst + Summary Generation
4. **Orchestration:** Intelligent workflow automation

### Sample Queries:
- Business analysis: `"Compare maintenance costs across facilities"`
- Summary creation: `"Summarize the reactor vessel work order"`
- Cost optimization: `"Show me opportunities to reduce maintenance spending"`
- Risk assessment: `"What are our highest risk work orders?"`

### Support:
- Check semantic view: `SHOW SEMANTIC VIEWS;`
- Verify stored procedure: `DESCRIBE PROCEDURE CREATE_ENTERPRISE_SUMMARY_IF_MISSING;`
- Test data: `SELECT * FROM ENTERPRISE_WORK_ORDERS LIMIT 5;`

---

*This setup creates a comprehensive enterprise work order management system with intelligent AI assistance for maintenance optimization and strategic planning.* 