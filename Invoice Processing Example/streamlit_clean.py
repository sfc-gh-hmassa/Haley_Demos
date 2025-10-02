import streamlit as st
import snowflake.snowpark as sp
from snowflake.snowpark.context import get_active_session
import tempfile
import os
from datetime import datetime
import base64
import pandas as pd
import json


session = get_active_session()


def upload_pdf_to_stage(session, pdf_file, stage_name):
    """Upload PDF to Snowflake stage"""
    
    try:
        # Create a clean filename
        clean_filename = pdf_file.name.replace(' ', '_').replace('(', '').replace(')', '').replace('[', '').replace(']', '')
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        final_filename = f"{timestamp}_{clean_filename}"
        
        # Save uploaded file to local temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as temp_file:
            pdf_file.seek(0)
            file_content = pdf_file.read()
            temp_file.write(file_content)
            temp_file_path = temp_file.name
        
        try:
            # Upload to stage
            stage_path = f"@{stage_name}/{final_filename}"
            upload_result = session.file.put(
                temp_file_path,
                stage_path,
                auto_compress=False,
                overwrite=True
            )
            
            # Refresh stage
            refresh_sql = f"ALTER STAGE {stage_name} REFRESH"
            session.sql(refresh_sql).collect()
            
            # Find uploaded file
            list_sql = f"LIST @{stage_name}"
            list_result = session.sql(list_sql).to_pandas()
            
            if list_result.empty:
                return None, None, None
            
            # Find our uploaded file
            uploaded_file = None
            target_prefix = final_filename.split('.')[0]
            
            if 'last_modified' in list_result.columns:
                list_result = list_result.sort_values('last_modified', ascending=False)
            
            for _, row in list_result.iterrows():
                filename = row.get('name', '') or row.get('file_name', '') or str(row.iloc[0])
                if target_prefix in filename:
                    uploaded_file = filename
                    break
            
            if uploaded_file:
                # Remove stage prefix for AI_EXTRACT
                ai_extract_filename = uploaded_file
                if uploaded_file.startswith(f"{stage_name.lower()}/"):
                    ai_extract_filename = uploaded_file[len(f"{stage_name.lower()}/"):]
                
                return final_filename, ai_extract_filename, file_content
            else:
                return None, None, None
                
        finally:
            # Clean up temp file
            if os.path.exists(temp_file_path):
                os.unlink(temp_file_path)
                
    except Exception as e:
        st.error(f"❌ Upload failed: {str(e)}")
        return None, None, None

def extract_data_with_ai(session, stage_name, ai_extract_filename):
    """Extract data using AI_EXTRACT"""
    
    try:
        extract_sql = f"""
        SELECT 
            AI_EXTRACT(
                file => TO_FILE('@{stage_name}', '{ai_extract_filename}'),
                responseFormat => [
                    'description: Product description for each line item',
                    'quantity: Quantity for each line item', 
                    'unit_price: Unit price for each line item',
                    'total_price: Total price for each line item'
                ]
            ) as extracted_data
        """
        
        result = session.sql(extract_sql).collect()
        
        if result and len(result) > 0 and result[0]['EXTRACTED_DATA']:
            return result[0]['EXTRACTED_DATA']
        else:
            return None
            
    except Exception as e:
        st.error(f"❌ AI_EXTRACT failed: {str(e)}")
        return None

def display_pdf(pdf_content):
    """Display PDF in Streamlit using iframe"""
    
    try:
        if not pdf_content:
            st.error("❌ PDF content is empty")
            return
        
        # Convert PDF to base64
        pdf_base64 = base64.b64encode(pdf_content).decode('utf-8')
        
        # Display PDF using iframe
        pdf_display = f'''
        <div style="width: 100%; height: 600px; border: 1px solid #ddd; border-radius: 5px; overflow: hidden;">
            <iframe src="data:application/pdf;base64,{pdf_base64}" 
                    width="100%" 
                    height="100%" 
                    type="application/pdf"
                    style="border: none;">
            </iframe>
        </div>
        '''
        st.markdown(pdf_display, unsafe_allow_html=True)
        
        # Also provide download option
        st.download_button(
            label="📥 Download PDF",
            data=pdf_content,
            file_name="uploaded_document.pdf",
            mime="application/pdf"
        )
        
    except Exception as e:
        st.error(f"❌ Error displaying PDF: {str(e)}")
        st.download_button(
            label="📥 Download PDF",
            data=pdf_content,
            file_name="uploaded_document.pdf",
            mime="application/pdf"
        )

def display_extracted_data(extracted_data):
    """Display extracted data in JSON format"""
    if extracted_data:
        st.json(extracted_data)
    else:
        st.info("No data extracted")

def get_available_customers(session):
    """Get list of available customer IDs from the invoice data"""
    try:
        query = """
        SELECT DISTINCT customer_id 
        FROM DEMODB.INVOICE_ANALYSIS.INVOICE_LINE_ITEMS 
        WHERE customer_id IS NOT NULL 
        ORDER BY customer_id
        """
        result = session.sql(query).collect()
        return [row['CUSTOMER_ID'] for row in result]
    except Exception as e:
        st.error(f"Error getting customer list: {str(e)}")
        return []

def get_presigned_url(session, file_path, stage_name):
    """Get a presigned URL for downloading a file from the stage"""
    try:
        # Get presigned URL with correct syntax: GET_PRESIGNED_URL(stage, file_path)
        url_query = f"SELECT GET_PRESIGNED_URL('@{stage_name}', '{file_path}') as presigned_url"
        result = session.sql(url_query).collect()
        
        if result and len(result) > 0:
            return result[0]['PRESIGNED_URL']
        else:
            st.error(f"Could not get presigned URL for: @{stage_name}/{file_path}")
            return None
    except Exception as e:
        st.error(f"Error getting presigned URL for {file_path}: {str(e)}")
        return None

def find_similar_products(session, description, filters=None):
    """Find similar products using Cortex Search Service with optional filters"""
    try:
        # Use the existing Cortex Search Service with available indexed columns
        # Build the JSON query string properly
        query_json = {
            "query": description,
            "columns": ["line_item_amount", "customer_id", "product_name_description", "invoice_number", "product_id", "rate", "quantity", "file_path", "order_date"],
            "limit": 10
        }
        
        # Add filters if provided
        if filters:
            filter_conditions = []
            
            # Customer ID filter
            if filters.get('customer_ids'):
                customer_filter = {"@in": {"customer_id": filters['customer_ids']}}
                filter_conditions.append(customer_filter)
            
            # Date range filter
            if filters.get('start_date') and filters.get('end_date'):
                date_filter = {
                    "@and": [
                        {"@gte": {"order_date": filters['start_date']}},
                        {"@lte": {"order_date": filters['end_date']}}
                    ]
                }
                filter_conditions.append(date_filter)
            
            # Combine filters
            if filter_conditions:
                if len(filter_conditions) == 1:
                    query_json["filter"] = filter_conditions[0]
                else:
                    query_json["filter"] = {"@and": filter_conditions}
        
        # Clean the description to avoid SQL parsing issues
        # Replace common special characters with ASCII equivalents
        clean_description = description.replace('ä', 'a').replace('ö', 'o').replace('ü', 'u')
        clean_description = clean_description.replace('Ä', 'A').replace('Ö', 'O').replace('Ü', 'U')
        clean_description = clean_description.replace('é', 'e').replace('è', 'e').replace('ê', 'e')
        clean_description = clean_description.replace('á', 'a').replace('à', 'a').replace('â', 'a')
        clean_description = clean_description.replace('í', 'i').replace('ì', 'i').replace('î', 'i')
        clean_description = clean_description.replace('ó', 'o').replace('ò', 'o').replace('ô', 'o')
        clean_description = clean_description.replace('ú', 'u').replace('ù', 'u').replace('û', 'u')
        clean_description = clean_description.replace('ñ', 'n').replace('ç', 'c')
        
        # Keep apostrophes and basic punctuation, but remove other problematic characters
        clean_description = ''.join(c for c in clean_description if c.isalnum() or c in " '-.,&()")
        
        # Ensure it's not empty
        if not clean_description.strip():
            clean_description = "product"
        
        # Update query with cleaned description
        query_json["query"] = clean_description
        
        json_query = json.dumps(query_json)
        
        # Use parameterized query to avoid SQL injection and parsing issues
        search_sql = """
        SELECT PARSE_JSON(
            SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                'Invoice_Product_Search',
                ?
            )
        )['results'] as results
        """
        
        result = session.sql(search_sql, params=[json_query]).collect()
        
        # Process the results from the search service
        if result and len(result) > 0:
            # Try different possible key names for results
            results_data = None
            if 'results' in result[0]:
                results_data = result[0]['results']
            elif 'RESULTS' in result[0]:
                results_data = result[0]['RESULTS']
            elif 'data' in result[0]:
                results_data = result[0]['data']
            else:
                # If no standard key, try to use the first value that looks like results
                for key, value in result[0].items():
                    if isinstance(value, (list, str)) and key.lower() in ['results', 'data', 'items']:
                        results_data = value
                        break
            
            if results_data is None:
                st.warning("No results data found in response")
                return []
            
            processed_results = []
            
            # Check if results_data is a string that needs to be parsed
            if isinstance(results_data, str):
                try:
                    results_data = json.loads(results_data)
                except:
                    st.error(f"Could not parse results_data as JSON: {results_data}")
                    return []
            
            # Check if results_data is a list
            if isinstance(results_data, list):
                for item in results_data:
                    # Handle both string and dict cases
                    if isinstance(item, str):
                        # If it's a string, try to parse it as JSON
                        try:
                            item = json.loads(item)
                        except:
                            st.warning(f"Could not parse item as JSON: {item}")
                            continue
                    
                    # Check if item is a dict before trying to get values
                    if isinstance(item, dict):
                        # Extract similarity score from @scores field
                        score = 0
                        if '@scores' in item and isinstance(item['@scores'], dict):
                            # Use cosine_similarity as the main score
                            score = item['@scores'].get('cosine_similarity', 0)
                        
                        # Try to get rate, quantity, and file_path if available
                        rate = 0
                        if 'rate' in item and item.get('rate'):
                            rate = float(item.get('rate', 0))
                        
                        quantity = 0
                        if 'quantity' in item and item.get('quantity'):
                            quantity = float(item.get('quantity', 0))
                        
                        file_path = item.get('file_path', '')
                        
                        processed_results.append({
                            'PRODUCT_NAME_DESCRIPTION': item.get('product_name_description', ''),
                            'CUSTOMER_ID': item.get('customer_id', ''),
                            'INVOICE_NUMBER': item.get('invoice_number', ''),
                            'PRODUCT_ID': item.get('product_id', ''),
                            'LINE_ITEM_AMOUNT': float(item.get('line_item_amount', 0)) if item.get('line_item_amount') else 0,
                            'RATE': rate,
                            'QUANTITY': quantity,
                            'FILE_PATH': file_path,
                            'SCORE': score
                        })
                    else:
                        st.warning(f"Item is not a dict: {type(item)} - {item}")
            else:
                st.warning(f"Results data is not a list: {type(results_data)}")
            
            return processed_results
        else:
            st.warning("No results returned from search service")
            return []
        
    except Exception as e:
        st.error(f"❌ Cortex Search failed: {str(e)}")
        return []

def analyze_negotiation_potential(quote_item, similar_products):
    """Analyze whether we should negotiate based on historical data"""
    if not similar_products or len(similar_products) == 0:
        return {
            'recommendation': 'No historical data',
            'confidence': 'Low',
            'reason': 'No similar products found in historical invoices'
        }
    
    # Calculate average historical unit price (rate) and quantity
    historical_rates = [item['RATE'] for item in similar_products if item['RATE'] and item['RATE'] > 0]
    historical_quantities = [item['QUANTITY'] for item in similar_products if item['QUANTITY'] and item['QUANTITY'] > 0]
    historical_totals = [item['LINE_ITEM_AMOUNT'] for item in similar_products if item['LINE_ITEM_AMOUNT']]
    
    if not historical_rates:
        return {
            'recommendation': 'No unit price data',
            'confidence': 'Low', 
            'reason': 'No unit price information in historical data'
        }
    
    avg_historical_rate = sum(historical_rates) / len(historical_rates)
    avg_historical_quantity = sum(historical_quantities) / len(historical_quantities) if historical_quantities else 0
    avg_historical_total = sum(historical_totals) / len(historical_totals) if historical_totals else 0
    
    quote_rate = quote_item.get('unit_price', 0)
    quote_quantity = quote_item.get('quantity', 0)
    quote_total = quote_item.get('total_price', 0)
    
    # Calculate unit price difference percentage
    if avg_historical_rate > 0:
        rate_diff_pct = ((quote_rate - avg_historical_rate) / avg_historical_rate) * 100
    else:
        rate_diff_pct = 0
    
    # Analyze quantity-based pricing opportunities
    quantity_analysis = ""
    if avg_historical_quantity > 0 and quote_quantity > 0:
        if quote_quantity < avg_historical_quantity:
            quantity_analysis = f" (Consider bulk discount - historical avg quantity: {avg_historical_quantity:.0f})"
        elif quote_quantity > avg_historical_quantity:
            quantity_analysis = f" (Good quantity - higher than historical avg: {avg_historical_quantity:.0f})"
    
    # Determine recommendation based on unit price comparison
    if rate_diff_pct > 20:
        recommendation = 'NEGOTIATE'
        confidence = 'High'
        reason = f'Unit price is {rate_diff_pct:.1f}% higher than historical average (${avg_historical_rate:.2f}){quantity_analysis}'
    elif rate_diff_pct > 10:
        recommendation = 'CONSIDER NEGOTIATING'
        confidence = 'Medium'
        reason = f'Unit price is {rate_diff_pct:.1f}% higher than historical average (${avg_historical_rate:.2f}){quantity_analysis}'
    elif rate_diff_pct < -10:
        recommendation = 'GOOD PRICE'
        confidence = 'High'
        reason = f'Unit price is {abs(rate_diff_pct):.1f}% lower than historical average (${avg_historical_rate:.2f}){quantity_analysis}'
    else:
        recommendation = 'ACCEPTABLE'
        confidence = 'Medium'
        reason = f'Unit price is within 10% of historical average (${avg_historical_rate:.2f}){quantity_analysis}'
    
    return {
        'recommendation': recommendation,
        'confidence': confidence,
        'reason': reason,
        'rate_difference_pct': rate_diff_pct,
        'avg_historical_rate': avg_historical_rate,
        'avg_historical_quantity': avg_historical_quantity,
        'avg_historical_total': avg_historical_total
    }

def main():
    # Custom CSS for beautiful styling
    st.markdown("""
    <style>
    .main-header {
        text-align: center;
        padding: 2rem 0;
        background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
        color: white;
        border-radius: 10px;
        margin-bottom: 2rem;
    }
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 10px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        border-left: 4px solid #667eea;
    }
    .recommendation-negotiate {
        background: linear-gradient(90deg, #ff6b6b, #ee5a52);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        text-align: center;
        font-weight: bold;
    }
    .recommendation-good {
        background: linear-gradient(90deg, #51cf66, #40c057);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        text-align: center;
        font-weight: bold;
    }
    .recommendation-consider {
        background: linear-gradient(90deg, #ffd43b, #fab005);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        text-align: center;
        font-weight: bold;
    }
    .recommendation-acceptable {
        background: linear-gradient(90deg, #74c0fc, #339af0);
        color: white;
        padding: 1rem;
        border-radius: 10px;
        text-align: center;
        font-weight: bold;
    }
    </style>
    """, unsafe_allow_html=True)
    
    # Beautiful header
    st.markdown("""
    <div class="main-header">
        <h1>🤝 Smart Negotiation Assistant</h1>
        <p>Upload your purchase order and get instant negotiation insights powered by AI</p>
    </div>
    """, unsafe_allow_html=True)
    
    # Initialize session state
    if 'upload_successful' not in st.session_state:
        st.session_state['upload_successful'] = False
    if 'pdf_content' not in st.session_state:
        st.session_state['pdf_content'] = None
    if 'extracted_data' not in st.session_state:
        st.session_state['extracted_data'] = None
    if 'final_filename' not in st.session_state:
        st.session_state['final_filename'] = None
    if 'ai_extract_filename' not in st.session_state:
        st.session_state['ai_extract_filename'] = None
    
    # Using active Snowflake session (already defined at top of file)
    
    stage_name = "PDF_STAGE"
    
    # Simplified filters section
    with st.expander("🔍 Advanced Filters (Optional)", expanded=False):
        st.markdown("Refine your analysis by filtering historical data:")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.markdown("**📅 Date Range**")
            use_date_filter = st.checkbox("Filter by date range")
            start_date = None
            end_date = None
            
            if use_date_filter:
                start_date = st.date_input("From", value=pd.to_datetime("2023-01-01"))
                end_date = st.date_input("To", value=pd.to_datetime("2024-12-31"))
        
        with col2:
            st.markdown("**👥 Specific Customers**")
            use_customer_filter = st.checkbox("Filter by customers")
            selected_customers = []
            
            if use_customer_filter:
                available_customers = get_available_customers(session)
                if available_customers:
                    selected_customers = st.multiselect(
                        "Select customers:",
                        options=available_customers,
                        help="Choose specific customers for comparison"
                    )
        
        # Build filters dictionary
        filters = {}
        if use_date_filter and start_date and end_date:
            filters['start_date'] = start_date.strftime('%Y-%m-%d')
            filters['end_date'] = end_date.strftime('%Y-%m-%d')
        
        if use_customer_filter and selected_customers:
            filters['customer_ids'] = selected_customers
        
        # Show active filters
        if filters:
            st.success("✅ Filters applied - analysis will focus on filtered data")
    
    st.markdown("")
    
    # File uploader with better styling
    st.markdown("## 📄 Upload Your Purchase Order")
    st.markdown("Upload your purchase order or quote PDF to get instant negotiation recommendations")
    
    uploaded_file = st.file_uploader(
        "Choose your PDF file", 
        type=['pdf'],
        help="Upload a purchase order or quote PDF (max 200MB)"
    )
    
    if uploaded_file is not None:
        with st.spinner("🔄 Processing your purchase order..."):
            final_filename, ai_extract_filename, pdf_content = upload_pdf_to_stage(session, uploaded_file, stage_name)
        
        if final_filename and ai_extract_filename and pdf_content:
            st.session_state['final_filename'] = final_filename
            st.session_state['ai_extract_filename'] = ai_extract_filename
            st.session_state['pdf_content'] = pdf_content
            st.session_state['upload_successful'] = True
            
            with st.spinner("🤖 Analyzing your purchase order for negotiation opportunities..."):
                extracted_data = extract_data_with_ai(
                    session, 
                    stage_name, 
                    ai_extract_filename
                )
            
            if extracted_data:
                st.session_state['extracted_data'] = extracted_data
                st.success("✅ Analysis complete! See your negotiation recommendations below.")
        else:
            st.error("❌ Upload failed - please try again with a valid PDF")
    
    # Skip PDF and JSON display - focus on negotiation analysis
    
    # Negotiation Analysis Section
    if st.session_state['upload_successful'] and st.session_state['extracted_data'] is not None:
        st.markdown("---")
        st.markdown("## 🎯 Negotiation Recommendations")
        
        extracted_data = st.session_state['extracted_data']
        
        # Parse extracted_data if it's a string
        if isinstance(extracted_data, str):
            try:
                extracted_data = json.loads(extracted_data)
                st.success("✅ Successfully parsed JSON data")
            except Exception as e:
                st.error(f"Failed to parse extracted data as JSON: {str(e)}")
                extracted_data = None
        
        # Parse the extracted data to get line items
        if extracted_data and 'response' in extracted_data and 'description' in extracted_data['response'] and isinstance(extracted_data['response']['description'], list):
            response_data = extracted_data['response']
            for i, description in enumerate(response_data['description']):
                with st.expander(f"📦 {description[:50]}{'...' if len(description) > 50 else ''}"):
                    
                    # Get quote item details and convert strings to numbers
                    quantity_str = response_data.get('quantity', ['0'])[i] if i < len(response_data.get('quantity', [])) else '0'
                    unit_price_str = response_data.get('unit_price', ['0'])[i] if i < len(response_data.get('unit_price', [])) else '0'
                    total_price_str = response_data.get('total_price', ['0'])[i] if i < len(response_data.get('total_price', [])) else '0'
                    
                    # Convert to numbers
                    try:
                        quantity = int(quantity_str) if quantity_str else 0
                        unit_price = float(unit_price_str) if unit_price_str else 0.0
                        total_price = float(total_price_str) if total_price_str else 0.0
                    except (ValueError, TypeError):
                        quantity = 0
                        unit_price = 0.0
                        total_price = 0.0
                    
                    # Show quote details
                    col1, col2, col3 = st.columns(3)
                    with col1:
                        st.metric("Quantity", quantity)
                    with col2:
                        st.metric("Unit Price", f"${unit_price:,.2f}")
                    with col3:
                        st.metric("Total Price", f"${total_price:,.2f}")
                    
                    # Search for similar products with filters
                    with st.spinner(f"🔍 Searching for similar products..."):
                        similar_products = find_similar_products(session, description, filters)
                    
                    if similar_products:
                        # Analyze negotiation potential
                        quote_item = {
                            'description': description,
                            'quantity': quantity,
                            'unit_price': unit_price,
                            'total_price': total_price
                        }
                        analysis = analyze_negotiation_potential(quote_item, similar_products)
                        
                        # Show recommendation
                        st.markdown("### 💰 Negotiation Recommendation")
                        if analysis['recommendation'] == 'NEGOTIATE':
                            st.error(f"🔴 **{analysis['recommendation']}** ({analysis['confidence']} confidence)")
                        elif analysis['recommendation'] == 'CONSIDER NEGOTIATING':
                            st.warning(f"🟡 **{analysis['recommendation']}** ({analysis['confidence']} confidence)")
                        elif analysis['recommendation'] == 'GOOD PRICE':
                            st.success(f"🟢 **{analysis['recommendation']}** ({analysis['confidence']} confidence)")
                        else:
                            st.info(f"🔵 **{analysis['recommendation']}** ({analysis['confidence']} confidence)")
                        
                        st.write(f"**Reason:** {analysis['reason']}")
                        
                        # Show similar products
                        st.markdown("### 📋 Similar Historical Products")
                        
                        # Create dataframe for similar products
                        similar_data = []
                        for product in similar_products:
                            # Get rate, quantity, and file_path from the parsed data
                            rate = product.get('RATE', 0)
                            quantity = product.get('QUANTITY', 0)
                            file_path = product.get('FILE_PATH', '')
                            
                            # Format unit price display
                            unit_price_display = f"${rate:,.2f}" if rate > 0 else "N/A"
                            
                            # Format quantity display
                            quantity_display = f"{quantity:.0f}" if quantity > 0 else "N/A"
                            
                            # Format file path display (show just the filename)
                            filename = file_path.split('/')[-1] if file_path else "N/A"
                            
                            similar_data.append({
                                'Customer ID': product.get('CUSTOMER_ID', 'N/A'),
                                'Invoice #': product.get('INVOICE_NUMBER', 'N/A'),
                                'Product': product.get('PRODUCT_NAME_DESCRIPTION', 'N/A'),
                                'Product ID': product.get('PRODUCT_ID', 'N/A'),
                                'Unit Price': unit_price_display,
                                'Quantity': quantity_display,
                                'Total': f"${product.get('LINE_ITEM_AMOUNT', 0):,.2f}",
                                'File': filename,
                                'Similarity': f"{product.get('SCORE', 0):.3f}"
                            })
                        
                        if similar_data:
                            df = pd.DataFrame(similar_data)
                            st.dataframe(df, use_container_width=True)
                            
                            # Show historical invoice information
                            st.markdown("### 📄 Historical Invoice Details")
                            for j, product in enumerate(similar_products):
                                file_path = product.get('FILE_PATH', '')
                                if file_path:
                                    filename = file_path.split('/')[-1]
                                    invoice_num = product.get('INVOICE_NUMBER', 'N/A')
                                    customer_id = product.get('CUSTOMER_ID', 'N/A')
                                    
                                    # Construct full stage path
                                    full_stage_path = f'@"DEMODB"."INVOICE_ANALYSIS"."INVOICE_DOCUMENTS"/{filename}'
                                    
                                    with st.expander(f"📄 {filename} - Invoice #{invoice_num} - Customer: {customer_id}"):
                                        st.write(f"**File Path:** `{file_path}`")
                                        st.write(f"**Full Stage Path:** `{full_stage_path}`")
                                        st.write(f"**Invoice Number:** {invoice_num}")
                                        st.write(f"**Customer ID:** {customer_id}")
                                        st.write(f"**Product:** {product.get('PRODUCT_NAME_DESCRIPTION', 'N/A')}")
                                        st.write(f"**Unit Price:** ${product.get('RATE', 0):,.2f}" if product.get('RATE', 0) > 0 else "**Unit Price:** N/A")
                                        st.write(f"**Quantity:** {product.get('QUANTITY', 0):.0f}" if product.get('QUANTITY', 0) > 0 else "**Quantity:** N/A")
                                        st.write(f"**Total Amount:** ${product.get('LINE_ITEM_AMOUNT', 0):,.2f}")
                                        st.write(f"**Similarity Score:** {product.get('SCORE', 0):.3f}")
                                        
                                        # Get presigned URL for download with unique key
                                        unique_key = f"url_{filename}_{i}_{j}"
                                        if st.button(f"🔗 Get Download Link", key=unique_key):
                                            with st.spinner(f"Getting download link for {filename}..."):
                                                try:
                                                    presigned_url = get_presigned_url(session, filename, "DEMODB.INVOICE_ANALYSIS.INVOICE_DOCUMENTS")
                                                    if presigned_url:
                                                        st.success(f"✅ Download link ready!")
                                                        st.markdown(f"**Download Link:** [Click here to download {filename}]({presigned_url})")
                                                        st.code(presigned_url)
                                                    else:
                                                        st.error(f"❌ Could not get download link for {filename}")
                                                except Exception as e:
                                                    st.error(f"❌ Error getting download link for {filename}: {str(e)}")
                        
                    else:
                        st.warning("⚠️ No similar products found in historical data")
                        st.info("This could mean:")
                        st.info("• The product is new/unique")
                        st.info("• Similarity threshold is too high")
                        st.info("• No historical data available")

if __name__ == "__main__":
    main()