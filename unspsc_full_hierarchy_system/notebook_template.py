"""
🏭 Jupyter Notebook Template for UNSPSC Classification

Copy this code into Jupyter notebook cells to create your own interactive demo.
Each comment block "# CELL X:" represents a new notebook cell.
"""

# CELL 1: Setup and Imports (Code Cell)
import sys
import time
from pathlib import Path

# Ensure we can import from the current directory
sys.path.insert(0, str(Path('.').resolve()))

# Import both classification systems
from chain.classification_chain import UNSPSCClassificationChain
from chain.classification_chain_with_reflection import UNSPSCClassificationChainWithReflection
from config import test_connection

print("✅ Imports successful!")
print("🏭 Production UNSPSC Classification System Ready")

# CELL 2: Test Connection (Code Cell)
print("🔗 Testing haleyconnect Snowflake connection...")
success = test_connection("haleyconnect")

if success:
    print("✅ SUCCESS! Your connection is working!")
    print("🎯 Ready to classify products!")
else:
    print("❌ Connection failed. Please check your haleyconnect setup.")

# CELL 3: Initialize Systems (Code Cell)
print("🚀 Initializing Classification Systems...")
standard_classifier = UNSPSCClassificationChain()
enhanced_classifier = UNSPSCClassificationChainWithReflection()
print("✅ Both systems ready!")

# CELL 4: Markdown Cell
"""
## 🎯 Your Product Testing

Replace the product descriptions below with your own products and run the cells!
"""

# CELL 5: Test Your Product #1 (Code Cell)
# 🎯 REPLACE THIS WITH YOUR PRODUCT:
your_product = "Parker Hannifin P2075-31CC-VAC-02-111-0000 Hydraulic Pump"

print(f"🔍 Classifying: {your_product}")
print("=" * 60)

start_time = time.time()
result = standard_classifier.classify_product(your_product)
processing_time = time.time() - start_time

if hasattr(result, 'success') and result.success:
    print("✅ CLASSIFICATION SUCCESSFUL!")
    print(f"🏷️ Final UNSPSC Code: {getattr(result, 'final_unspsc_code', 'N/A')}")
    print(f"📊 Level: {getattr(result, 'classification_level', 'N/A').title()}")
    print(f"🎯 Confidence: {getattr(result, 'confidence', 'N/A')}")
    print(f"⏱️ Processing Time: {processing_time:.2f} seconds")
else:
    print("❌ Classification failed")

# CELL 6: Test Enhanced System with Your Product (Code Cell)
# 🎯 REPLACE THIS WITH YOUR TECHNICAL RECORD OR MAINTENANCE LOG:
your_technical_record = """06H-100101-1 Performed scheduled preventative maintenance 
on hydraulic pump #3, checking fluid levels and cleaning intake strainer."""

print(f"🔍 Enhanced Classification: {your_technical_record}")
print("=" * 60)

start_time = time.time()
result = enhanced_classifier.classify_product_with_reflection(your_technical_record)
processing_time = time.time() - start_time

if result.get("success"):
    print("✅ ENHANCED CLASSIFICATION SUCCESSFUL!")
    print(f"🏷️ Final UNSPSC Code: {result.get('final_unspsc_code', 'N/A')}")
    print(f"📊 Level: {result.get('classification_level', 'N/A').title()}")
    print(f"🎯 Confidence: {result.get('confidence', 'N/A')}")
    print(f"⏱️ Processing Time: {processing_time:.2f} seconds")
    
    # Show reflection information
    if result.get("reflection_applied"):
        print("\n🧠 AI REFLECTION APPLIED:")
        print(f"   ✅ Self-correction performed")
        print(f"   🔄 Reasoning: {result.get('reflection_reasoning', 'N/A')}")
    else:
        print("\n🧠 NO REFLECTION NEEDED")
else:
    print("❌ Enhanced classification failed")

# CELL 7: Compare Both Systems (Code Cell)
# 🎯 REPLACE THIS WITH ANY PRODUCT TO COMPARE BOTH SYSTEMS:
comparison_product = "Siemens S7-1200 CPU 1214C programmable logic controller"

print(f"🔄 Comparing both systems on: {comparison_product}")
print("=" * 60)

# Standard system
print("1️⃣ STANDARD SYSTEM:")
start_time = time.time()
standard_result = standard_classifier.classify_product(comparison_product)
standard_time = time.time() - start_time

if hasattr(standard_result, 'success') and standard_result.success:
    print(f"   ✅ Code: {getattr(standard_result, 'final_unspsc_code', 'N/A')}")
    print(f"   ⏱️ Time: {standard_time:.2f}s")
else:
    print("   ❌ Standard system failed")

# Enhanced system
print("\n2️⃣ ENHANCED SYSTEM:")
start_time = time.time()
enhanced_result = enhanced_classifier.classify_product_with_reflection(comparison_product)
enhanced_time = time.time() - start_time

if enhanced_result.get("success"):
    print(f"   ✅ Code: {enhanced_result.get('final_unspsc_code', 'N/A')}")
    print(f"   ⏱️ Time: {enhanced_time:.2f}s")
    if enhanced_result.get("reflection_applied"):
        print(f"   🧠 Reflection: Applied")
    else:
        print("   🧠 Reflection: Not needed")
else:
    print("   ❌ Enhanced system failed")

# CELL 8: Markdown Cell
"""
## 🎉 Summary

You've successfully tested the Production UNSPSC Classification System!

### 🌟 Features Demonstrated:
- ✅ Standard Classification
- ✅ AI-Powered Reflection  
- ✅ Generic Extraction
- ✅ Technical Record Processing
- ✅ Real Snowflake Integration

### 🚀 Production Usage:
```python
from chain.classification_chain_with_reflection import UNSPSCClassificationChainWithReflection

classifier = UNSPSCClassificationChainWithReflection()
result = classifier.classify_product_with_reflection("your product")
```

**The system is ready for production!** 🎯
"""

print("🎉 Notebook template complete!")
print("📝 Copy the code blocks above into separate Jupyter notebook cells")
print("🔧 Modify the product descriptions to test your own products")
print("🚀 Run the cells to see the classification system in action!") 