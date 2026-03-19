# Examples Around Bringing Your Own Models to Container Services 

## CHRONOSBOLT_BYO_MODEL
Deploys Amazon's Chronos-Bolt time series forecasting model to Snowflake using the **Bring Your Own (BYO) artifact approach** - downloads the full model and packages it for deployment.

### **Phase 1: Environment Setup**
1. **Install Dependencies** - Install chronos-forecasting, torch, transformers with compatible versions
2. **Test Local Model** - Verify Chronos-Bolt works locally before deployment
3. **Setup Snowflake Session** - Connect to Snowflake with proper authentication

### **Phase 2: Infrastructure Setup**
4. **Create External Access** - Setup `ALLOW_ALL_INTEGRATION` for Hugging Face access
5. **Create Image Repository** - Setup container registry for model images
6. **Create Compute Pool** - Setup `CPU_X64_M` compute resources for containers

### **Phase 3: Model Preparation**
7. **Download Model** - Use `snapshot_download()` to get `amazon/chronos-bolt-base`
8. **Package as Artifact** - Create model artifacts for Snowflake deployment
9. **Define Custom Model** - Implement `ChronosBoltModel` class with predict method

### **Phase 4: Model Registration**
10. **Register in ML Registry** - Use `log_model()` with hybrid pip/conda dependencies
11. **Version Management** - Create versioned model (e.g., V5) in registry
12. **Test Python API** - Verify model works via Python interface

### **Phase 5: Container Service Deployment**
13. **Service Creation** - Deploy model as container service for SQL access
14. **Build Monitoring** - Track container build status (BUILDING → RUNNING)
15. **Service Diagnostics** - Use phantom service detection if creation fails

### **Phase 6: Inference & Testing**
16. **Python Inference** - Test forecasting via Python API
17. **SQL Inference** - Test forecasting via SQL service calls
18. **Results Validation** - Compare outputs between Python and SQL paths
