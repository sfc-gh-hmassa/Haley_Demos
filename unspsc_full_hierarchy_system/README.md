# 🧠 **Production UNSPSC Classification System** - **REFLECTION EDITION**

## **🌟 Revolutionary Intelligent Reflection System**

This system now features **INTELLIGENT REFLECTION** that ensures optimal classification accuracy:

- ✅ **Always returns 8-digit codes** (commodity or class + 00 padding)
- ✅ **Intelligent commodity reflection** - decides whether commodity match is good enough
- ✅ **Never returns below class level** - minimum 6-digit class codes
- ✅ **Smart fallback logic** - class level when commodity isn't specific enough
- ✅ **Production-ready accuracy** - no overly generic classifications

### **🧠 Reflection Logic:**

The system **always attempts commodity classification**, then reflects:

```
🎯 High Confidence Commodity → Use 8-digit commodity code
🔄 Low Confidence Commodity → Fall back to 8-digit class code  
🔄 Generic Commodity Match → Fall back to class level for accuracy
❌ Classification Failed → Use class level with 00 padding
```

### **🏆 Key Innovation: Smart 8-Digit Codes**

UNSPSC codes are always returned as 8 digits:
```
COMMODITY LEVEL: 40151509 (Reciprocating pumps)
CLASS LEVEL:     40151500 (401515 "Pumps" + 00 padding)

Both are valid 8-digit UNSPSC codes!
```

## **🚀 What This System Does**

### Complete Enhanced Workflow
1. **🧠 Intelligent LLM Extraction** - Extracts brands, serial numbers, models using Snowflake Cortex
   - Generic pattern-based extraction (no hardcoded brand lists)
   - Enhanced technical record handling
   - Sparse data optimization for technician logs
2. **🌐 Smart Web Search** - Searches DuckDuckGo with intelligent search terms
3. **📋 Enhanced Technical Summary** - Combines all information with technical context
4. **🎯 Hierarchical Classification with Reflection** - AI-powered classification:
   - Segment (2-digit) → Family (4-digit) → Class (6-digit) → Commodity (8-digit)
   - **Self-correction** when hierarchical mismatches detected
   - **Reflection analysis** to validate classification paths
5. **✅ Advanced Validation** - Multi-level validation with intelligent fallbacks

### 🧠 Revolutionary Reflection Capabilities
- **🔍 Hierarchical Mismatch Detection** - Automatically detects when classifications don't align
- **🔄 Self-Correction** - Re-classifies using alternative segment paths when conflicts arise
- **🎯 Confidence Analysis** - Evaluates classification confidence and triggers corrections
- **📊 Multiple Path Validation** - Tests different classification approaches
- **⚡ Real-Time Improvement** - Learns from classification conflicts during processing

### Key Features
- ✅ **No Hardcoded Lists** - Generic, scalable extraction for any product type
- ✅ **Technical Record Optimized** - Handles sparse maintenance logs and technician records
- ✅ **AI Self-Correction** - Reflects on and corrects classification mismatches
- ✅ **Real Infrastructure** - Uses your Snowflake connection and UNSPSC data
- ✅ **Real Web Search** - DuckDuckGo integration for product intelligence
- ✅ **LLM-Powered** - Snowflake Cortex llama3-70b for extraction and classification
- ✅ **Production Ready** - Error handling, logging, and robust architecture
- ✅ **Comprehensive Testing** - Organized test suite with validation scripts

## 🏗️ Enhanced System Architecture

```
📝 Product Description / Technical Record
    ↓
🧠 Enhanced LLM Extraction (Generic + Technical Patterns)
    ├── Standard Product Extraction
    ├── Technical Record Enhancement
    └── Service Code Recognition
    ↓
🌐 Smart Web Search Intelligence
    ├── Intelligent Search Terms
    ├── Technical Equipment Focus
    └── Product Category Detection
    ↓
📋 Enhanced Technical Summary
    ├── Context Recognition (Maintenance/Service)
    └── Technical Record Optimization
    ↓
🎯 Hierarchical Classification with Reflection
    ├── Initial Classification Attempt
    ├── 🧠 Reflection & Validation Layer
    │   ├── Hierarchical Mismatch Detection
    │   ├── Confidence Analysis
    │   └── Alternative Path Suggestion
    ├── 🔄 Self-Correction (if needed)
    │   ├── Re-segment Classification
    │   ├── Corrected Family Selection
    │   └── Validation of New Path
    └── Final Classification & Confidence
    ↓
🏆 Validated UNSPSC Code + Reflection Report
```

## 📁 Organized Project Structure

```
production_unspsc_system/
├── 📁 tests/                         # 🧪 Complete testing suite
│   ├── test_haleyconnect_setup.py   # Connection validation
│   ├── debug_classification.py      # Step-by-step debugging
│   ├── debug_database.py           # Database query testing
│   ├── test_generic_extractor.py    # Generic extraction testing
│   ├── test_reflection_system.py    # Reflection capabilities testing
│   ├── test_single_product.py      # Single product testing
│   └── demo_classification_test.py  # Complete system demo
├── 📁 config/                       # Snowflake connection management
│   ├── __init__.py
│   └── snowflake_config.py         # haleyconnect integration
├── 📁 models/                       # LLM wrappers
│   ├── __init__.py
│   └── snowflake_llm.py            # Snowflake Cortex LLM
├── 📁 extractors/                   # Enhanced product intelligence
│   ├── __init__.py
│   ├── llm_extractor.py            # Generic LLM extraction (no hardcoded lists)
│   └── web_searcher.py             # Smart DuckDuckGo search
├── 📁 agents/                       # AI classification agents
│   ├── __init__.py
│   ├── product_summarizer.py       # Enhanced technical summary creation
│   ├── segment_classifier.py       # UNSPSC segment classification
│   ├── family_classifier.py        # UNSPSC family classification
│   ├── class_classifier.py         # UNSPSC class classification
│   └── commodity_classifier.py     # UNSPSC commodity classification
├── 📁 database/                     # UNSPSC database interface
│   ├── __init__.py
│   └── unspsc_database.py          # Your Snowflake UNSPSC data access
├── 📁 chain/                        # Advanced orchestration
│   ├── __init__.py
│   ├── classification_chain.py     # Standard workflow orchestrator
│   └── classification_chain_with_reflection.py  # 🧠 Enhanced reflection system
├── interactive_demo.py             # 🎯 Interactive demo (modify YOUR_PRODUCTS section)
├── notebook_template.py            # 📓 Jupyter notebook template
├── requirements.txt                 # Python dependencies
└── README.md                       # This documentation
```

## 🔧 Configuration

The system automatically uses your **haleyconnect** Snowflake connection:
- Reads from `~/.snowflake/connections.toml`
- Uses JWT authentication with your private key
- Connects to your UNSPSC database: `DEMODB.UNSPSC_CODE_PROJECT.UNSPSC_CODES_UNDP`

## 💻 Usage Examples

### Enhanced Classification with Reflection
```python
from chain.classification_chain_with_reflection import UNSPSCClassificationChainWithReflection

# Initialize enhanced classifier with reflection
classifier = UNSPSCClassificationChainWithReflection()

# Classify complex technical record
result = classifier.classify_product_with_reflection("""
06H-100101-1 Performed scheduled preventative maintenance on hydraulic pump #3, 
which included checking fluid levels, inspecting hoses for leaks and wear, 
and cleaning the intake strainer. All components were found to be within 
operational parameters, with no signs of leaks or abnormal wear detected.
""")

# Check if reflection was applied
if result.get("reflection_applied"):
    print(f"🧠 Self-correction applied: {result['reflection_reasoning']}")
    print(f"📝 Original: Segment {result.get('original_segment')}")
    print(f"🎯 Corrected: Segment {result['segment_code']}")

print(f"🏷️ Final UNSPSC: {result['final_unspsc_code']}")
print(f"📊 Confidence: {result['confidence']}")
```

### Standard Classification
```python
from chain.classification_chain import UNSPSCClassificationChain

classifier = UNSPSCClassificationChain()

result = classifier.classify_product("""
Siemens S7-1200 CPU 1214C DC/DC/DC programmable logic controller
""")

# Access classification details
if result.success:
    print(f"Final UNSPSC Code: {result.final_unspsc_code}")
    print(f"Classification Level: {result.classification_level}")
```

### Interactive Demo
```bash
# Easy-to-use interactive demo - just modify the YOUR_PRODUCTS section
python interactive_demo.py

# The demo includes these customizable examples:
YOUR_PRODUCTS = {
    "Your Product #1": "REPLACE THIS WITH YOUR PRODUCT DESCRIPTION",
    "Your Product #2": "REPLACE THIS WITH YOUR TECHNICAL RECORD",
    "Your Product #3": "REPLACE THIS WITH ANY PRODUCT TYPE"
}
```

### Jupyter Notebook
```python
# Copy code from notebook_template.py into Jupyter cells
# Each "# CELL X:" comment represents a new notebook cell
# Modify the product descriptions and run interactively
```

### Testing Single Products
```python
# Test any product description
python tests/test_single_product.py

# Or customize for your specific product:
from tests.test_single_product import test_single_product

test_single_product("Your product description here")
```

## 🎯 Real-World Examples

### Technical Maintenance Record
**Input:**
```
06H-100101-1 Performed scheduled preventative maintenance on hydraulic pump #3
```

**Enhanced System Output:**
```
🎯 ENHANCED CLASSIFICATION WITH REFLECTION
✅ Technical Record Processing Applied
🔍 Enhanced Extraction:
   Service Code: 06H-100101-1
   Equipment ID: Unit-3
   Context: Technical maintenance record
🧠 Reflection Analysis: ✅ No correction needed
🏆 Final Classification: 2315 - Industrial process machinery
📊 Confidence: High
```

### Generic Product Classification
**Input:**
```
Caterpillar C9.3B ACERT diesel engine 275HP industrial
```

**Generic System Output:**
```
🧠 Intelligent Extraction (No Hardcoded Lists):
   Brand: Caterpillar
   Model: C9.3B
   Search Terms: [Caterpillar C9.3B, ACERT diesel engine, 275HP industrial engine]
🎯 Classification: 2310 - Engines and turbines
```

## 🧪 Comprehensive Testing Suite

### Available Tests
```bash
# Connection & Setup Testing
python tests/test_haleyconnect_setup.py    # Validate Snowflake connection

# System Debugging  
python tests/debug_classification.py       # Step-by-step classification debug
python tests/debug_database.py            # Database query validation

# Feature Testing
python tests/test_generic_extractor.py     # Test generic extraction on diverse products
python tests/test_reflection_system.py     # Test reflection and self-correction
python tests/test_single_product.py       # Test your specific product

# Complete Demonstration
python tests/demo_classification_test.py   # Full system demo with multiple products
```

### Test Results Preview
```
🧪 Generic Extractor Tests:
   ✅ Siemens PLC → Generated: "programmable logic controller", "PLC"
   ✅ 3M Adhesive → Generated: "structural adhesive", "3M adhesive" 
   ✅ Honeywell Sensor → Generated: "3-axis digital compass", "magnetometer sensor"

🧠 Reflection System Tests:
   ✅ Hierarchical mismatch detection working
   ✅ Self-correction capabilities functional
   ✅ Technical record enhancement active
```

## 🔍 Advanced System Validation

### Multi-Layer Validation
1. **Extraction Validation** - Ensures meaningful product data extraction
2. **Search Validation** - Verifies intelligent search term generation
3. **Classification Validation** - Single response requirement at each level
4. **Hierarchical Validation** - Ensures proper UNSPSC hierarchy adherence
5. **Reflection Validation** - Detects and corrects classification conflicts
6. **Database Validation** - Confirms all codes exist in Snowflake UNSPSC data

### Intelligent Error Handling
- **Generic Extraction** - No dependency on hardcoded brand/product lists
- **Technical Record Processing** - Optimized for sparse maintenance logs
- **Reflection Recovery** - Self-corrects classification mismatches
- **Graceful Fallbacks** - Returns highest achieved classification level
- **Connection Resilience** - Clear error messages for infrastructure issues

## 🌟 Revolutionary Capabilities

### For Any Product Type
- **No Hardcoded Lists** - Works on any product, any industry
- **Intelligent Pattern Recognition** - Learns from product description context
- **Scalable Architecture** - Ready for thousands of diverse products

### For Technical Records
- **Maintenance Log Processing** - Optimized for technician logs
- **Service Code Recognition** - Identifies technical identifiers
- **Equipment Context Understanding** - Handles sparse technical data
- **Industrial Equipment Focus** - Enhanced for manufacturing environments

### AI-Powered Intelligence
- **Self-Reflection** - Analyzes its own classification decisions
- **Automatic Correction** - Fixes hierarchical mismatches without human intervention
- **Confidence Assessment** - Evaluates and improves classification quality
- **Learning Architecture** - Improves accuracy through reflection analysis

## 🎉 Production Ready!

This system is **enterprise-ready** and uses your **real Snowflake infrastructure**:
- ✅ Your haleyconnect connection and credentials
- ✅ Your UNSPSC database (DEMODB.UNSPSC_CODE_PROJECT.UNSPSC_CODES_UNDP)
- ✅ Snowflake Cortex LLM (llama3-70b)
- ✅ Real web search integration
- ✅ Advanced reflection and self-correction
- ✅ Comprehensive validation and error handling
- ✅ Organized testing suite for validation
- ✅ Technical record optimization
- ✅ Generic, scalable architecture

**Start classifying any product or technical record now!**

## **🎯 Quick Start - Reflection Edition**

### **1. Basic Classification with Intelligent Reflection**
```python
from chain.classification_chain import UNSPSCClassificationChain

classifier = UNSPSCClassificationChain()
result = classifier.classify_product("Parker Hannifin hydraulic pump P2075")

# 🧠 REFLECTION RESULTS:
print(f"Level: {result.classification_level}")          # "commodity" or "class"
print(f"8-digit code: {result.complete_unspsc_code}")   # Always 8 digits!
print(f"Confidence: {result.confidence}")               # Shows reflection reasoning

# Examples of reflection decisions:
# High confidence → 40151509 (commodity)
# Low confidence  → 40151500 (class 401515 + 00)
```

### **2. Understanding Reflection Decisions**
```python
if result.classification_level == "commodity":
    print("✅ Reflection chose: Specific commodity match")
    print(f"Full commodity: {result.commodity_code} - {result.commodity_description}")
else:
    print("🔄 Reflection chose: Class level (commodity not specific enough)")
    print(f"Class + padding: {result.class_code} + 00 = {result.complete_unspsc_code}")
```

### **3. Always 8-Digit Production-Ready Codes**
```python
# The system ALWAYS returns 8-digit codes:
assert len(result.complete_unspsc_code) == 8  # ✅ Always true!

# Whether commodity level:     40151509
# Or class level with padding: 40151500 (401515 + 00)
```

### **4. Direct Hierarchy Lookup from Commodity Code**
```python
from database.unspsc_database import UNSPSCDatabase

db = UNSPSCDatabase()
hierarchy = db.get_commodity_with_hierarchy("40151801")

print(f"Complete hierarchy for commodity 40151801:")
print(f"Segment: {hierarchy['segment']['code']} - {hierarchy['segment']['description']}")
print(f"Family: {hierarchy['family']['code']} - {hierarchy['family']['description']}")  
print(f"Class: {hierarchy['class']['code']} - {hierarchy['class']['description']}")
print(f"Commodity: {hierarchy['commodity']['code']} - {hierarchy['commodity']['description']}")
```

### **5. Enhanced Classification with Reflection**
```python
from chain.classification_chain_with_reflection import UNSPSCClassificationChainWithReflection

enhanced_classifier = UNSPSCClassificationChainWithReflection()
result = enhanced_classifier.classify_product_with_reflection(
    "06H-100101-1 Performed maintenance on hydraulic pump #3..."
)

# Gets complete hierarchy with AI self-correction
print(result.get_full_hierarchy_display())
```

### **6. Search Commodities by Description**
```python
from database.unspsc_database import UNSPSCDatabase

db = UNSPSCDatabase()
matches = db.search_commodities_by_text(["hydraulic", "pump"], limit=10)

for match in matches:
    print(f"Found: {match['commodity']['code']} - {match['commodity']['description']}")
    print(f"  Full hierarchy: {match['complete_hierarchy']['segment_code']} → {match['complete_hierarchy']['family_code']} → {match['complete_hierarchy']['class_code']} → {match['complete_hierarchy']['commodity_code']}")
```

## **🚀 Interactive Demos**

### **1. 📔 Jupyter Notebook Demo (Recommended)**
```bash
jupyter notebook UNSPSC_Classification_Demo.ipynb
```
**✨ NEW: Enhanced with detailed process view!**
- 🔍 **Web search results** - queries, titles, snippets, sources
- 🎯 **Segment classification** - detailed reasoning and confidence
- 📊 **Complete hierarchy progression** - segment → family → class → commodity
- 🧠 **Reflection decisions** - commodity vs class level with full reasoning  
- ✅ **Final 8-digit codes** - always production ready
- 🎮 **Interactive section** - modify products to test your own examples

### **2. 🎯 Enhanced Command Line Demo**
```bash
python interactive_demo.py
```
**✨ NEW: Shows complete process including web search and segment details!**
- Enhanced display with web search results when performed
- Segment classification details with confidence
- Complete hierarchy display with reflection reasoning

### **3. 🔬 Individual Component Tests** 
```bash
python tests/test_haleyconnect_setup.py      # Test connection
python tests/debug_classification.py         # Debug pipeline  
python tests/test_reflection_system.py       # Test AI reflection
python tests/demo_classification_test.py     # Complete demo
``` 