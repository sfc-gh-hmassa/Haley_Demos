import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from snowflake.snowpark.context import get_active_session

session = get_active_session()

MODEL_DB = "WAFER_YIELD_DEMO"
MODEL_SCHEMA = "ML_MODELS"
MODEL_NAME = "WAFER_YIELD_CHAMPION"
MODEL_VERSION = "V1"
PREDICTIONS_TABLE = "WAFER_YIELD_DEMO.INFERENCE.WAFER_YIELD_PREDICTIONS"
INFERENCE_INPUT = "WAFER_YIELD_DEMO.INFERENCE.WAFER_INFERENCE_INPUT"

st.set_page_config(page_title="Wafer Yield Prediction", layout="wide")
st.title("Wafer Yield Prediction Dashboard")

model_meta = session.sql(f"""
    SELECT * FROM TABLE(
        {MODEL_DB}.INFORMATION_SCHEMA.MODEL_VERSIONS(
            MODEL_NAME => '{MODEL_NAME}',
            SCHEMA_NAME => '{MODEL_SCHEMA}'
        )
    ) WHERE VERSION_NAME = '{MODEL_VERSION}'
""").to_pandas()

with st.sidebar:
    st.header("Model Registry")
    st.markdown(f"**{MODEL_DB}.{MODEL_SCHEMA}.{MODEL_NAME}**")
    st.markdown(f"Version: `{MODEL_VERSION}`")

    if not model_meta.empty:
        import json
        metadata = json.loads(model_meta.iloc[0].get("METADATA", "{}"))
        metrics = metadata.get("metrics", {})

        st.divider()
        st.subheader("Champion Metrics")
        col1, col2 = st.columns(2)
        col1.metric("Accuracy", f"{metrics.get('accuracy', 0):.1%}")
        col2.metric("ROC AUC", f"{metrics.get('roc_auc', 0):.3f}")
        col1.metric("Precision", f"{metrics.get('precision', 0):.1%}")
        col2.metric("Recall", f"{metrics.get('recall', 0):.1%}")

        st.divider()
        st.caption(f"Winner: {metrics.get('winner_name', 'N/A')}")
        st.caption(f"Params: {metrics.get('total_params', 'N/A'):,}")
        st.caption(f"Framework: PyTorch")

tab1, tab2, tab3 = st.tabs(["Batch Predictions", "Wafer Lookup", "Historical Runs"])

with tab1:
    st.subheader("Run Predictions on Test Wafers")

    lots = session.sql(f"""
        SELECT DISTINCT p.LOT_ID
        FROM {PREDICTIONS_TABLE} pred
        JOIN WAFER_YIELD_DEMO.RAW_DATA.WAFER_PROCESS_DATA p
            ON pred."WAFER_ID" = p.WAFER_ID
        ORDER BY p.LOT_ID
        LIMIT 100
    """).to_pandas()

    lot_options = ["All Lots"] + lots["LOT_ID"].tolist()
    selected_lot = st.selectbox("Filter by LOT_ID", lot_options)

    latest_run = session.sql(f"""
        SELECT MAX("RUN_ID") as latest FROM {PREDICTIONS_TABLE}
    """).to_pandas().iloc[0]["LATEST"]

    if selected_lot == "All Lots":
        preds_df = session.sql(f"""
            SELECT "WAFER_ID", "output_feature_0" as YIELD_PROB, "MODEL_NAME", "MODEL_VERSION"
            FROM {PREDICTIONS_TABLE}
            WHERE "RUN_ID" = '{latest_run}'
            LIMIT 500
        """).to_pandas()
    else:
        preds_df = session.sql(f"""
            SELECT pred."WAFER_ID", pred."output_feature_0" as YIELD_PROB,
                   pred."MODEL_NAME", pred."MODEL_VERSION"
            FROM {PREDICTIONS_TABLE} pred
            JOIN WAFER_YIELD_DEMO.RAW_DATA.WAFER_PROCESS_DATA p
                ON pred."WAFER_ID" = p.WAFER_ID
            WHERE pred."RUN_ID" = '{latest_run}' AND p.LOT_ID = '{selected_lot}'
        """).to_pandas()

    if not preds_df.empty:
        preds_df["PREDICTION"] = preds_df["YIELD_PROB"].apply(lambda x: "GOOD" if x >= 0.5 else "FAIL")

        col1, col2, col3, col4 = st.columns(4)
        total = len(preds_df)
        good = (preds_df["PREDICTION"] == "GOOD").sum()
        fail = total - good
        avg_prob = preds_df["YIELD_PROB"].mean()

        col1.metric("Total Wafers", f"{total:,}")
        col2.metric("Predicted Good", f"{good:,}", delta=f"{good/total:.0%}")
        col3.metric("Predicted Fail", f"{fail:,}", delta=f"-{fail/total:.0%}")
        col4.metric("Avg Probability", f"{avg_prob:.3f}")

        c1, c2 = st.columns(2)
        with c1:
            fig_hist = px.histogram(
                preds_df, x="YIELD_PROB", nbins=40,
                color="PREDICTION",
                color_discrete_map={"GOOD": "#2ecc71", "FAIL": "#e74c3c"},
                title="Yield Probability Distribution"
            )
            fig_hist.update_layout(bargap=0.05)
            st.plotly_chart(fig_hist, use_container_width=True)

        with c2:
            fig_pie = px.pie(
                preds_df, names="PREDICTION",
                color="PREDICTION",
                color_discrete_map={"GOOD": "#2ecc71", "FAIL": "#e74c3c"},
                title="Prediction Breakdown"
            )
            st.plotly_chart(fig_pie, use_container_width=True)

        st.dataframe(
            preds_df[["WAFER_ID", "YIELD_PROB", "PREDICTION"]].sort_values("YIELD_PROB", ascending=True),
            use_container_width=True,
            height=400
        )
    else:
        st.info("No predictions found. Run Notebook 03 first.")

with tab2:
    st.subheader("Single Wafer Prediction Lookup")

    wafer_search = st.text_input("Enter Wafer ID (e.g. WFR_0015595)")

    if wafer_search:
        wafer_data = session.sql(f"""
            SELECT *
            FROM {PREDICTIONS_TABLE}
            WHERE "WAFER_ID" = '{wafer_search}' AND "RUN_ID" = '{latest_run}'
        """).to_pandas()

        if not wafer_data.empty:
            row = wafer_data.iloc[0]
            prob = row["output_feature_0"]
            prediction = "GOOD" if prob >= 0.5 else "FAIL"
            color = "#2ecc71" if prediction == "GOOD" else "#e74c3c"

            c1, c2 = st.columns([1, 2])
            with c1:
                fig_gauge = go.Figure(go.Indicator(
                    mode="gauge+number",
                    value=prob * 100,
                    title={"text": f"{wafer_search}"},
                    number={"suffix": "%"},
                    gauge={
                        "axis": {"range": [0, 100]},
                        "bar": {"color": color},
                        "steps": [
                            {"range": [0, 50], "color": "#fadbd8"},
                            {"range": [50, 100], "color": "#d5f5e3"},
                        ],
                        "threshold": {
                            "line": {"color": "black", "width": 3},
                            "thickness": 0.8,
                            "value": 50,
                        },
                    },
                ))
                fig_gauge.update_layout(height=300)
                st.plotly_chart(fig_gauge, use_container_width=True)
                st.markdown(f"### Prediction: :{('green' if prediction == 'GOOD' else 'red')}[{prediction}]")

            with c2:
                st.markdown("**Feature Values**")
                feature_cols = [c for c in wafer_data.columns if c not in [
                    "WAFER_ID", "output_feature_0", "RUN_ID",
                    "INFERENCE_TIMESTAMP_UTC", "MODEL_NAME", "MODEL_VERSION"
                ]]
                feature_df = wafer_data[feature_cols].T.reset_index()
                feature_df.columns = ["Feature", "Value"]
                st.dataframe(feature_df, use_container_width=True, height=400)
        else:
            st.warning(f"Wafer `{wafer_search}` not found in latest predictions.")

with tab3:
    st.subheader("Historical Inference Runs")

    runs_df = session.sql(f"""
        SELECT "RUN_ID",
               COUNT(*) as WAFER_COUNT,
               AVG("output_feature_0") as AVG_YIELD_PROB,
               SUM(CASE WHEN "output_feature_0" >= 0.5 THEN 1 ELSE 0 END) as GOOD_COUNT,
               SUM(CASE WHEN "output_feature_0" < 0.5 THEN 1 ELSE 0 END) as FAIL_COUNT,
               MIN("INFERENCE_TIMESTAMP_UTC") as RUN_TIMESTAMP
        FROM {PREDICTIONS_TABLE}
        GROUP BY "RUN_ID"
        ORDER BY RUN_TIMESTAMP DESC
    """).to_pandas()

    if not runs_df.empty:
        runs_df["YIELD_RATE"] = runs_df["GOOD_COUNT"] / runs_df["WAFER_COUNT"]

        st.dataframe(
            runs_df[["RUN_ID", "RUN_TIMESTAMP", "WAFER_COUNT", "GOOD_COUNT", "FAIL_COUNT", "YIELD_RATE", "AVG_YIELD_PROB"]],
            use_container_width=True,
            column_config={
                "YIELD_RATE": st.column_config.ProgressColumn("Yield Rate", min_value=0, max_value=1, format="%.1%%"),
                "AVG_YIELD_PROB": st.column_config.NumberColumn("Avg Prob", format="%.4f"),
            }
        )

        if len(runs_df) > 1:
            fig_trend = px.line(
                runs_df.sort_values("RUN_TIMESTAMP"),
                x="RUN_TIMESTAMP", y="YIELD_RATE",
                markers=True,
                title="Yield Rate Across Inference Runs"
            )
            fig_trend.update_layout(yaxis_tickformat=".0%")
            st.plotly_chart(fig_trend, use_container_width=True)
    else:
        st.info("No historical runs found.")

st.divider()
st.caption(f"Model: {MODEL_DB}.{MODEL_SCHEMA}.{MODEL_NAME} {MODEL_VERSION} | Powered by Snowflake Model Registry")
