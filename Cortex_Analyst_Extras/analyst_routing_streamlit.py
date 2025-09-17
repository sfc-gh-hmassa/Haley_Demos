"""
Cortex Analyst App
====================
This app allows users to interact with their data using natural language.
"""
import json  # To handle JSON data
import time
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Union

import _snowflake  # For interacting with Snowflake-specific APIs
import pandas as pd
import streamlit as st  # Streamlit library for building the web app
from snowflake.snowpark.context import (
    get_active_session,
)  # To interact with Snowflake sessions
from snowflake.snowpark.exceptions import SnowparkSQLException

# List of available semantic model paths in the format: <DATABASE>.<SCHEMA>.<STAGE>/<FILE-NAME>
# Each path points to a YAML file defining a semantic model

AVAILABLE_SEMANTIC_MODELS_PATHS = [
    {"semantic_model_file":"CORTEX_AGENTS_DEMO.SNOWPRINT.SEMANTIC_MODELS/snowprint_customer_jobs.yaml"},
    {"semantic_model_file":"CORTEX_AGENTS_DEMO.MAIN.SEMANTIC_MODELS/sales_orders.yaml"}
]
API_ENDPOINT = "/api/v2/cortex/analyst/message"
FEEDBACK_API_ENDPOINT = "/api/v2/cortex/analyst/feedback"
API_TIMEOUT = 50000  # in milliseconds

# Initialize a Snowpark session for executing queries
session = get_active_session()


def main():
    # Initialize session state
    if "messages" not in st.session_state:
        reset_session_state()
    
    # Ensure all required session state variables are initialized
    if "active_suggestion" not in st.session_state:
        st.session_state.active_suggestion = None
    if "warnings" not in st.session_state:
        st.session_state.warnings = []
    if "form_submitted" not in st.session_state:
        st.session_state.form_submitted = {}
    
    show_header_and_sidebar()
    if len(st.session_state.messages) == 0:
        process_user_input("What questions can I ask?")
    display_conversation()
    handle_user_inputs()
    handle_error_notifications()
    display_warnings()


def reset_session_state():
    """Reset important session state elements."""
    st.session_state.messages = []  # List to store conversation messages
    st.session_state.active_suggestion = None  # Currently selected suggestion
    st.session_state.warnings = []  # List to store warnings
    st.session_state.form_submitted = (
        {}
    )  # Dictionary to store feedback submission for each request


def show_header_and_sidebar():
    """Display the header and sidebar of the app."""
    # Set the title and introductory text of the app
    st.title("🧠 Cortex Analyst - Multi-Model Demo")
    st.markdown(
        "**Welcome to Cortex Analyst with Automatic Routing!** Ask questions about your data and the system will automatically choose the most relevant semantic model. Try asking about both customer jobs and sales data!"
    )

    # Sidebar with information about automatic routing
    with st.sidebar:
        st.markdown("### 🧠 Automatic Model Routing")
        st.info("Cortex Analyst automatically selects the best semantic model based on your question!")
        
        st.markdown("**Available Models:**")
        for i, model in enumerate(AVAILABLE_SEMANTIC_MODELS_PATHS, 1):
            model_name = model["semantic_model_file"].split("/")[-1].replace(".yaml", "")
            st.write(f"{i}. **{model_name}**")
            st.caption(f"   `{model['semantic_model_file']}`")
        
        st.divider()
        # Center this button
        _, btn_container, _ = st.columns([2, 6, 2])
        if btn_container.button("Clear Chat History", use_container_width=True):
            reset_session_state()


def handle_user_inputs():
    """Handle user inputs from the chat interface."""
    # Handle chat input
    user_input = st.chat_input("What is your question?")
    if user_input:
        process_user_input(user_input)
    # Handle suggested question click
    elif st.session_state.active_suggestion is not None:
        suggestion = st.session_state.active_suggestion
        st.session_state.active_suggestion = None
        process_user_input(suggestion)


def handle_error_notifications():
    if st.session_state.get("fire_API_error_notify"):
        st.toast("An API error has occured!", icon="🚨")
        st.session_state["fire_API_error_notify"] = False


def process_user_input(prompt: str):
    """
    Process user input and update the conversation history.

    Args:
        prompt (str): The user's input.
    """
    # Clear previous warnings at the start of a new request
    st.session_state.warnings = []

    # Create a new message, append to history and display imidiately
    new_user_message = {
        "role": "user",
        "content": [{"type": "text", "text": prompt}],
    }
    st.session_state.messages.append(new_user_message)
    with st.chat_message("user"):
        user_msg_index = len(st.session_state.messages) - 1
        display_message(new_user_message["content"], user_msg_index)

    # Show progress indicator inside analyst chat message while waiting for response
    with st.chat_message("analyst"):
        with st.spinner("Waiting for Analyst's response..."):
            time.sleep(1)
            response, error_msg = get_analyst_response(st.session_state.messages)
            if error_msg is None:
                analyst_message = {
                    "role": "analyst",
                    "content": response["message"]["content"],
                    "request_id": response["request_id"],
                }
            else:
                analyst_message = {
                    "role": "analyst",
                    "content": [{"type": "text", "text": error_msg}],
                    "request_id": response["request_id"],
                }
                st.session_state["fire_API_error_notify"] = True

            if "warnings" in response:
                st.session_state.warnings = response["warnings"]

            st.session_state.messages.append(analyst_message)
            st.rerun()


def display_warnings():
    """
    Display warnings to the user.
    """
    warnings = st.session_state.warnings
    for warning in warnings:
        st.warning(warning["message"], icon="⚠️")


def get_analyst_response(messages: List[Dict]) -> Tuple[Dict, Optional[str]]:
    """
    Send chat history to the Cortex Analyst API and return the response.

    Args:
        messages (List[Dict]): The conversation history.

    Returns:
        Optional[Dict]: The response from the Cortex Analyst API.
    """
    # Prepare the request body with the user's prompt
    # Use all available semantic models for automatic routing
    semantic_models = []
    for model_path in AVAILABLE_SEMANTIC_MODELS_PATHS:
        semantic_models.append({
            "semantic_model_file": f"@{model_path['semantic_model_file']}"
        })
    
    request_body = {
        "messages": messages,
        "semantic_models": semantic_models,
    }

    # Send a POST request to the Cortex Analyst API endpoint
    # Adjusted to use positional arguments as per the API's requirement
    resp = _snowflake.send_snow_api_request(
        "POST",  # method
        API_ENDPOINT,  # path
        {},  # headers
        {},  # params
        request_body,  # body
        None,  # request_guid
        API_TIMEOUT,  # timeout in milliseconds
    )

    # Content is a string with serialized JSON object
    parsed_content = json.loads(resp["content"])

    # Check if the response is successful
    if resp["status"] < 400:
        # Return the content of the response as a JSON object
        return parsed_content, None
    else:
        # Craft readable error message
        error_msg = f"""
🚨 An Analyst API error has occurred 🚨

* response code: `{resp['status']}`
* request-id: `{parsed_content['request_id']}`
* error code: `{parsed_content['error_code']}`

Message:
```
{parsed_content['message']}
```
        """
        return parsed_content, error_msg


def display_conversation():
    """
    Display the conversation history between the user and the assistant.
    """
    for idx, message in enumerate(st.session_state.messages):
        role = message["role"]
        content = message["content"]
        with st.chat_message(role):
            if role == "analyst":
                display_message(content, idx, message["request_id"])
            else:
                display_message(content, idx)


def display_message(
    content,
    message_index: int,
    request_id: Union[str, None] = None,
):
    """
    Display a single message content.

    Args:
        content: The message content (can be string or list of dicts).
        message_index (int): The index of the message.
    """
    # Handle different content types
    if isinstance(content, str):
        # Simple text content
        st.markdown(content)
        return
    
    if not isinstance(content, list):
        # If it's not a list, try to display as text
        st.write(str(content))
        return
    
    # Handle list of content items
    for item in content:
        if not isinstance(item, dict):
            # If item is not a dict, display as text
            st.write(str(item))
            continue
            
        item_type = item.get("type", "")
        
        if item_type == "text":
            st.markdown(item.get("text", ""))
        elif item_type == "suggestions":
            # Display suggestions as buttons
            suggestions = item.get("suggestions", [])
            for suggestion_index, suggestion in enumerate(suggestions):
                if st.button(
                    suggestion, key=f"suggestion_{message_index}_{suggestion_index}"
                ):
                    st.session_state.active_suggestion = suggestion
        elif item_type == "sql":
            # Get the original user question from the most recent user message
            user_question = ""
            for msg in reversed(st.session_state.messages):
                if msg["role"] == "user" and msg["content"]:
                    user_question = msg["content"][0].get("text", "")
                    break
            
            # Display the SQL query and results
            display_sql_query(
                item.get("statement", ""), message_index, item.get("confidence", {}), request_id, user_question
            )
        else:
            # Handle other content types if necessary
            st.write(item)


@st.cache_data(show_spinner=False)
def get_query_exec_result(query: str) -> Tuple[Optional[pd.DataFrame], Optional[str]]:
    """
    Execute the SQL query and convert the results to a pandas DataFrame.

    Args:
        query (str): The SQL query.

    Returns:
        Tuple[Optional[pd.DataFrame], Optional[str]]: The query results and the error message.
    """
    global session
    try:
        df = session.sql(query).to_pandas()
        return df, None
    except SnowparkSQLException as e:
        return None, str(e)


def parse_and_style_answer(answer: str) -> str:
    """
    Parse the LLM answer and convert <pv> and <ev> tags to styled markdown.
    
    Args:
        answer (str): Raw answer from LLM with <pv> and <ev> tags
    
    Returns:
        str: Styled markdown with proper formatting
    """
    import re
    
    # Replace <pv>value</pv> with bold highlighted primary values
    answer = re.sub(r'<pv>(.*?)</pv>', r'**\1**', answer)
    
    # Replace <ev>value</ev> with italic explanatory values  
    answer = re.sub(r'<ev>(.*?)</ev>', r'*\1*', answer)
    
    return answer


def generate_natural_language_answer(user_question: str, sql_query: str, df: pd.DataFrame) -> str:
    """
    Generate a natural language answer using SNOWFLAKE.CORTEX.COMPLETE based on the SQL results.
    
    Args:
        user_question (str): The original user question
        sql_query (str): The SQL query that was generated
        df (pd.DataFrame): The results from executing the SQL query
    
    Returns:
        str: Natural language answer explaining the results
    """
    global session
    
    # Prepare the SQL results for the completion prompt
    if df.empty:
        sql_results = "No data was returned from the query."
    else:
        # Convert the entire dataframe to a string representation
        sql_results = df.to_string(index=False, max_rows=100)  # Limit to 100 rows for context
    
    # Get semantic model information (simplified - could be enhanced to read actual YAML)
    semantic_model = "Multiple semantic models available including customer jobs and sales order data."
    
    # Create the completion prompt using the specified template
    completion_prompt = f"""You are a state-of-the-art AI data analyst.
Please generate an answer to the following user question: {user_question}. Please just provide a concise and informative answer, without reformulating the question.
You will be shown:
    1. DATABASE definition.
    2. user QUESTION.
    3. SQL QUERY that you previously generated.
    4. relevant CONTEXT from the DATABASE, which is the result of the SQL query.
For any value that comes from the database context and directly answers the question (PRIMARY VALUE), please enclose it within <pv> and </pv> tags. For example,
if the user asks "What is the total sales in March 2021?", and the total sales in March 2021 is 1000, you should write "The total sales in March 2021 is <pv>1000</pv>.".
For any value that comes from the database context and is not a PRIMARY VALUE but rather an additional EXPLANATORY VALUE, please enclose it within <ev> and </ev> tags.
For example, if the user asks which month had the highest sales, and the highest sales were in April with the total sales of 2000, you should write
"The month with the highest sales is <pv>April</pv> with the total sales of <ev>2000</ev>.".
1. DATABASE definition:
```
{semantic_model}
```
2. user QUESTION:
```
{user_question}
```
3. SQL QUERY that you previously generated:
```
{sql_query}
```
4. relevant CONTEXT from the DATABASE, which is the result of the SQL query:
```
{sql_results}
```"""
    
    try:
        # Use SNOWFLAKE.CORTEX.COMPLETE to generate the natural language answer
        # Use parameterized query to avoid escaping issues
        completion_sql = """
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'mixtral-8x7b',
            ?
        ) as answer
        """
        
        result = session.sql(completion_sql, params=[completion_prompt]).collect()
        if result and len(result) > 0:
            raw_answer = result[0]['ANSWER']
            # Parse and style the answer to handle <pv> and <ev> tags
            styled_answer = parse_and_style_answer(raw_answer)
            return styled_answer
        else:
            return "I was able to retrieve the data, but couldn't generate a summary. Please review the results above."
            
    except Exception as e:
        st.error(f"Error generating natural language answer: {str(e)}")
        return "I was able to retrieve the data, but couldn't generate a summary. Please review the results above."


def display_sql_confidence(confidence: dict):
    if confidence is None:
        return
    verified_query_used = confidence["verified_query_used"]
    with st.popover(
        "Verified Query Used",
        help="The verified query from [Verified Query Repository](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/verified-query-repository), used to generate the SQL",
    ):
        with st.container():
            if verified_query_used is None:
                st.text(
                    "There is no query from the Verified Query Repository used to generate this SQL answer"
                )
                return
            st.text(f"Name: {verified_query_used['name']}")
            st.text(f"Question: {verified_query_used['question']}")
            st.text(f"Verified by: {verified_query_used['verified_by']}")
            st.text(
                f"Verified at: {datetime.fromtimestamp(verified_query_used['verified_at'])}"
            )
            st.text("SQL query:")
            st.code(verified_query_used["sql"], language="sql", wrap_lines=True)


def display_sql_query(
    sql: str, message_index: int, confidence: dict, request_id: Union[str, None] = None, user_question: str = ""
):
    """
    Executes the SQL query and displays the results in form of data frame and charts.

    Args:
        sql (str): The SQL query.
        message_index (int): The index of the message.
        confidence (dict): The confidence information of SQL query generation
        request_id (str): Request id from user request
        user_question (str): The original user question
    """

    # Execute the SQL query first
    with st.spinner("Running SQL..."):
        df, err_msg = get_query_exec_result(sql)
    
    # Generate natural language answer if we have data
    if df is not None and not df.empty and user_question:
        with st.spinner("Generating natural language answer..."):
            nl_answer = generate_natural_language_answer(user_question, sql, df)
        
        # Display the natural language answer first (most prominent)
        st.markdown("### 📝 Answer")
        st.markdown(nl_answer)
        st.divider()

    # Display the SQL query
    with st.expander("SQL Query", expanded=False):
        st.code(sql, language="sql")
        display_sql_confidence(confidence)

    # Display the results of the SQL query
    with st.expander("Results", expanded=True):
        if df is None:
            st.error(f"Could not execute generated SQL query. Error: {err_msg}")
        elif df.empty:
            st.write("Query returned no data")
        else:
            # Show query results in two tabs
            data_tab, chart_tab = st.tabs(["Data 📄", "Chart 📉"])
            with data_tab:
                st.dataframe(df, use_container_width=True)

            with chart_tab:
                display_charts_tab(df, message_index)
    if request_id:
        display_feedback_section(request_id)


def display_charts_tab(df: pd.DataFrame, message_index: int) -> None:
    """
    Display the charts tab.

    Args:
        df (pd.DataFrame): The query results.
        message_index (int): The index of the message.
    """
    # There should be at least 2 columns to draw charts
    if len(df.columns) >= 2:
        all_cols_set = set(df.columns)
        col1, col2 = st.columns(2)
        x_col = col1.selectbox(
            "X axis", all_cols_set, key=f"x_col_select_{message_index}"
        )
        y_col = col2.selectbox(
            "Y axis",
            all_cols_set.difference({x_col}),
            key=f"y_col_select_{message_index}",
        )
        chart_type = st.selectbox(
            "Select chart type",
            options=["Line Chart 📈", "Bar Chart 📊"],
            key=f"chart_type_{message_index}",
        )
        if chart_type == "Line Chart 📈":
            st.line_chart(df.set_index(x_col)[y_col])
        elif chart_type == "Bar Chart 📊":
            st.bar_chart(df.set_index(x_col)[y_col])
    else:
        st.write("At least 2 columns are required")


def display_feedback_section(request_id: str):
    with st.popover("📝 Query Feedback"):
        if request_id not in st.session_state.form_submitted:
            with st.form(f"feedback_form_{request_id}", clear_on_submit=True):
                positive = st.radio(
                    "Rate the generated SQL", options=["👍", "👎"], horizontal=True
                )
                positive = positive == "👍"
                submit_disabled = (
                    request_id in st.session_state.form_submitted
                    and st.session_state.form_submitted[request_id]
                )

                feedback_message = st.text_input("Optional feedback message")
                submitted = st.form_submit_button("Submit", disabled=submit_disabled)
                if submitted:
                    err_msg = submit_feedback(request_id, positive, feedback_message)
                    st.session_state.form_submitted[request_id] = {"error": err_msg}
                    st.session_state.popover_open = False
                    st.rerun()
        elif (
            request_id in st.session_state.form_submitted
            and st.session_state.form_submitted[request_id]["error"] is None
        ):
            st.success("Feedback submitted", icon="✅")
        else:
            st.error(st.session_state.form_submitted[request_id]["error"])


def submit_feedback(
    request_id: str, positive: bool, feedback_message: str
) -> Optional[str]:
    request_body = {
        "request_id": request_id,
        "positive": positive,
        "feedback_message": feedback_message,
    }
    resp = _snowflake.send_snow_api_request(
        "POST",  # method
        FEEDBACK_API_ENDPOINT,  # path
        {},  # headers
        {},  # params
        request_body,  # body
        None,  # request_guid
        API_TIMEOUT,  # timeout in milliseconds
    )
    if resp["status"] == 200:
        return None

    parsed_content = json.loads(resp["content"])
    # Craft readable error message
    err_msg = f"""
        🚨 An Analyst API error has occurred 🚨
        
        * response code: `{resp['status']}`
        * request-id: `{parsed_content['request_id']}`
        * error code: `{parsed_content['error_code']}`
        
        Message:
        ```
        {parsed_content['message']}
        ```
        """
    return err_msg


if __name__ == "__main__":
    main()