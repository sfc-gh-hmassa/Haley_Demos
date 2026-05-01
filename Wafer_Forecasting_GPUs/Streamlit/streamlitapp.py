import time
import json
import streamlit as st
import pandas as pd
import plotly.graph_objects as go
from snowflake.snowpark.context import get_active_session
from snowflake.ml.registry import Registry

session = get_active_session()

MODEL_DB = "WAFER_YIELD_DEMO"
MODEL_SCHEMA = "ML_MODELS"
MODEL_NAME = "WAFER_YIELD_CHAMPION"
MODEL_VERSION = "V1"

SERVICE_DB = "WAFER_YIELD_DEMO"
SERVICE_SCHEMA = "INFERENCE"
SERVICE_NAME = "WAFER_YIELD_REALTIME"
SERVICE_FQN = f"{SERVICE_DB}.{SERVICE_SCHEMA}.{SERVICE_NAME}"

PREDICTIONS_TABLE = "WAFER_YIELD_DEMO.INFERENCE.WAFER_YIELD_PREDICTIONS"
INFERENCE_INPUT = "WAFER_YIELD_DEMO.INFERENCE.WAFER_INFERENCE_INPUT"

DISPLAY_NAMES = {
    "TEMP_MAX": "Peak process temp.",
    "TEMP_MIN": "Min process temp.",
    "TEMP_MEAN": "Avg process temp.",
    "TEMP_STD": "Temp. variability",
    "TEMP_RANGE": "Temp. range",
    "PRESSURE_MAX": "Peak chamber pressure",
    "PRESSURE_MIN": "Min chamber pressure",
    "PRESSURE_MEAN": "Avg chamber pressure",
    "PRESSURE_STD": "Pressure variability",
    "PRESSURE_DELTA_MAX": "Max pressure swing",
    "GAS_FLOW_MAX": "Peak gas flow",
    "GAS_FLOW_MIN": "Min gas flow",
    "GAS_FLOW_MEAN": "Avg gas flow",
    "GAS_FLOW_STD": "Gas flow variability",
    "HUMIDITY_MAX": "Peak humidity",
    "HUMIDITY_MIN": "Min humidity",
    "HUMIDITY_MEAN": "Avg humidity",
    "HUMIDITY_STD": "Humidity variability",
    "CRITICAL_DEFECT_COUNT": "Critical defects",
    "AVG_DEFECT_SEVERITY": "Avg defect severity",
    "PROCESS_HOUR": "Process hour",
    "PROCESS_DAY": "Process day",
}

RISK_THRESHOLDS = {"high": 0.35, "medium": 0.5}

def _display(col: str) -> str:
    return DISPLAY_NAMES.get(col, col.replace("_", " ").title())


st.set_page_config(page_title="Fab Yield Assurance", layout="wide")

THEME_CSS = """
<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap');

html, body, [class*="css"] {
    font-family: 'Inter', sans-serif !important;
}

.stApp {
    background: linear-gradient(180deg, #0a0e1a 0%, #0f1729 50%, #0a0e1a 100%) !important;
}

header[data-testid="stHeader"] {
    background: rgba(10, 14, 26, 0.95) !important;
    backdrop-filter: blur(10px);
}

section[data-testid="stSidebar"] { display: none !important; }

.block-container {
    padding-top: 1rem !important;
    padding-bottom: 1rem !important;
    max-width: 1200px !important;
}

/* ─── Header bar ─── */
.fab-header {
    background: linear-gradient(135deg, #0d1b2a 0%, #1b2838 100%);
    border: 1px solid #1e3a5f;
    border-radius: 12px;
    padding: 20px 28px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.fab-header-left { display: flex; align-items: center; gap: 14px; }
.fab-icon {
    width: 40px; height: 40px; border-radius: 10px;
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    display: flex; align-items: center; justify-content: center;
    font-size: 20px; color: white;
}
.fab-title { font-size: 1.5rem; font-weight: 700; color: #e2e8f0; margin: 0; letter-spacing: -0.02em; }
.fab-subtitle { font-size: 0.8rem; color: #64748b; margin: 0; font-weight: 400; letter-spacing: 0.05em; text-transform: uppercase; }
.fab-status {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 6px 14px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;
}
.fab-status-on { background: rgba(34, 197, 94, 0.15); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.3); }
.fab-status-off { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }
.fab-dot { width: 7px; height: 7px; border-radius: 50%; display: inline-block; }
.fab-dot-on { background: #4ade80; box-shadow: 0 0 6px #4ade80; }
.fab-dot-off { background: #f87171; }

/* ─── Metric cards ─── */
div[data-testid="stMetric"] {
    background: linear-gradient(135deg, #111827 0%, #1a2332 100%) !important;
    border: 1px solid #1e3a5f !important;
    border-radius: 10px !important;
    padding: 16px 20px !important;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3) !important;
}
div[data-testid="stMetric"] label {
    font-size: 0.7rem !important; color: #64748b !important;
    text-transform: uppercase !important; letter-spacing: 0.08em !important; font-weight: 600 !important;
}
div[data-testid="stMetric"] [data-testid="stMetricValue"] {
    font-size: 1.8rem !important; font-weight: 700 !important; color: #e2e8f0 !important;
}

/* ─── Tabs ─── */
.stTabs [data-baseweb="tab-list"] {
    background: #111827 !important;
    border-radius: 10px !important;
    padding: 4px !important;
    gap: 4px !important;
    border: 1px solid #1e293b !important;
}
.stTabs [data-baseweb="tab"] {
    background: transparent !important;
    border-radius: 8px !important;
    color: #64748b !important;
    font-weight: 600 !important;
    font-size: 0.82rem !important;
    padding: 8px 16px !important;
    border: none !important;
}
.stTabs [aria-selected="true"] {
    background: linear-gradient(135deg, #1e3a5f, #1d4ed8) !important;
    color: #e2e8f0 !important;
}
.stTabs [data-baseweb="tab-highlight"] { display: none !important; }
.stTabs [data-baseweb="tab-border"] { display: none !important; }

/* ─── Buttons ─── */
.stButton > button[kind="primary"],
.stButton > button[data-testid="stBaseButton-primary"] {
    background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
    border: none !important;
    border-radius: 8px !important;
    font-weight: 600 !important;
    font-size: 0.9rem !important;
    padding: 10px 24px !important;
    letter-spacing: 0.02em !important;
    box-shadow: 0 4px 14px rgba(37, 99, 235, 0.4) !important;
    transition: all 0.2s ease !important;
}
.stButton > button[kind="primary"]:hover,
.stButton > button[data-testid="stBaseButton-primary"]:hover {
    box-shadow: 0 6px 20px rgba(37, 99, 235, 0.6) !important;
    transform: translateY(-1px) !important;
}

/* ─── Verdict cards ─── */
.verdict-pass {
    background: linear-gradient(135deg, #052e16 0%, #064e3b 100%);
    border: 2px solid #22c55e; border-radius: 16px;
    padding: 32px; text-align: center;
    box-shadow: 0 0 30px rgba(34,197,94,0.15), inset 0 1px 0 rgba(255,255,255,0.05);
}
.verdict-risk {
    background: linear-gradient(135deg, #450a0a 0%, #7f1d1d 100%);
    border: 2px solid #ef4444; border-radius: 16px;
    padding: 32px; text-align: center;
    box-shadow: 0 0 30px rgba(239,68,68,0.15), inset 0 1px 0 rgba(255,255,255,0.05);
}
.verdict-caution {
    background: linear-gradient(135deg, #451a03 0%, #78350f 100%);
    border: 2px solid #f59e0b; border-radius: 16px;
    padding: 32px; text-align: center;
    box-shadow: 0 0 30px rgba(245,158,11,0.15), inset 0 1px 0 rgba(255,255,255,0.05);
}
.verdict-label {
    font-size: 3rem; font-weight: 800; margin: 0;
    letter-spacing: 0.04em; text-shadow: 0 2px 10px rgba(0,0,0,0.3);
}
.verdict-sub {
    font-size: 1rem; color: rgba(255,255,255,0.6); margin-top: 8px; font-weight: 500;
}
.verdict-action {
    display: inline-block; margin-top: 16px; padding: 8px 20px;
    border-radius: 8px; font-size: 0.85rem; font-weight: 600; letter-spacing: 0.02em;
}
.action-hold { background: rgba(239,68,68,0.2); color: #fca5a5; border: 1px solid rgba(239,68,68,0.4); }
.action-inspect { background: rgba(245,158,11,0.2); color: #fcd34d; border: 1px solid rgba(245,158,11,0.4); }
.action-release { background: rgba(34,197,94,0.2); color: #86efac; border: 1px solid rgba(34,197,94,0.4); }

/* ─── Factor bars ─── */
.factor-row {
    display: flex; align-items: center; gap: 12px;
    padding: 10px 16px; border-radius: 8px; margin-bottom: 6px;
    background: rgba(30, 58, 95, 0.3); border: 1px solid #1e3a5f;
}
.factor-name { flex: 0 0 180px; font-size: 0.82rem; color: #94a3b8; font-weight: 500; }
.factor-bar-bg {
    flex: 1; height: 8px; background: #1e293b; border-radius: 4px; overflow: hidden;
}
.factor-bar-fill { height: 100%; border-radius: 4px; }
.factor-val { flex: 0 0 90px; text-align: right; font-size: 0.82rem; color: #e2e8f0; font-weight: 600; }

/* ─── Dataframes / tables ─── */
[data-testid="stDataFrame"] {
    border: 1px solid #1e3a5f !important;
    border-radius: 10px !important;
    overflow: hidden !important;
}

/* ─── Expanders ─── */
details {
    background: #111827 !important;
    border: 1px solid #1e293b !important;
    border-radius: 10px !important;
}
details summary {
    color: #94a3b8 !important; font-weight: 600 !important;
}

/* ─── Inputs ─── */
.stSelectbox > div > div,
.stTextInput > div > div > input {
    background: #111827 !important;
    border: 1px solid #1e3a5f !important;
    border-radius: 8px !important;
    color: #e2e8f0 !important;
}

/* ─── Radio pills ─── */
.stRadio > div { gap: 0 !important; }
.stRadio > div > label {
    background: #111827 !important;
    border: 1px solid #1e3a5f !important;
    color: #94a3b8 !important;
    padding: 8px 18px !important;
    font-weight: 600 !important;
    font-size: 0.82rem !important;
}

/* ─── Dividers ─── */
hr { border-color: #1e293b !important; opacity: 0.5 !important; }

/* ─── Captions ─── */
.stCaption, small { color: #475569 !important; }

/* ─── Markdown text ─── */
.stMarkdown p, .stMarkdown li { color: #cbd5e1 !important; }
.stMarkdown strong { color: #e2e8f0 !important; }

/* ─── Warning/info/success boxes ─── */
.stAlert { border-radius: 10px !important; }

/* ─── Scrollbar ─── */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: #0a0e1a; }
::-webkit-scrollbar-thumb { background: #1e3a5f; border-radius: 3px; }

/* ─── Footer ─── */
.fab-footer {
    text-align: center; padding: 12px; margin-top: 20px;
    color: #334155; font-size: 0.7rem; letter-spacing: 0.05em;
}
</style>
"""
st.markdown(THEME_CSS, unsafe_allow_html=True)


@st.cache_resource
def get_model_version():
    reg = Registry(session=session, database_name=MODEL_DB, schema_name=MODEL_SCHEMA)
    return reg.get_model(MODEL_NAME).version(MODEL_VERSION)


@st.cache_data(ttl=300)
def get_feature_schema():
    rows = session.sql(
        f"SHOW FUNCTIONS IN MODEL {MODEL_DB}.{MODEL_SCHEMA}.{MODEL_NAME} VERSION {MODEL_VERSION}"
    ).collect()
    args_str = rows[0]["arguments"]
    import re
    return re.findall(r'(\w+)\s+FLOAT', args_str)


@st.cache_data(ttl=300)
def get_feature_ranges(feature_cols: list) -> pd.DataFrame:
    agg_pieces = []
    for c in feature_cols:
        agg_pieces.append(f'MIN("{c}") as "MIN_{c}", AVG("{c}") as "AVG_{c}", MAX("{c}") as "MAX_{c}"')
    q = f"SELECT {', '.join(agg_pieces)} FROM {INFERENCE_INPUT}"
    row = session.sql(q).to_pandas().iloc[0]
    records = []
    for c in feature_cols:
        records.append({
            "feature": c,
            "min": float(row[f"MIN_{c}"]) if pd.notna(row[f"MIN_{c}"]) else 0.0,
            "mean": float(row[f"AVG_{c}"]) if pd.notna(row[f"AVG_{c}"]) else 0.0,
            "max": float(row[f"MAX_{c}"]) if pd.notna(row[f"MAX_{c}"]) else 1.0,
        })
    return pd.DataFrame(records).set_index("feature")


@st.cache_data(ttl=60)
def service_is_available() -> bool:
    try:
        rows = session.sql(
            f"SHOW SERVICES LIKE '{SERVICE_NAME}' IN SCHEMA {SERVICE_DB}.{SERVICE_SCHEMA}"
        ).collect()
        return len(rows) > 0
    except Exception:
        return False


@st.cache_data(ttl=300)
def get_sample_wafers(limit: int = 50) -> list:
    rows = session.sql(
        f'SELECT "WAFER_ID" FROM {INFERENCE_INPUT} LIMIT {limit}'
    ).collect()
    return [r["WAFER_ID"] for r in rows]


@st.cache_data(ttl=60)
def get_wafer_features(wafer_id: str, feature_cols: list) -> pd.DataFrame:
    cols = ", ".join(f'"{c}"' for c in feature_cols)
    row = session.sql(
        f'SELECT {cols} FROM {INFERENCE_INPUT} WHERE "WAFER_ID" = \'{wafer_id}\' LIMIT 1'
    ).to_pandas()
    return row.astype("float32")


def run_inference(X: pd.DataFrame):
    mv = get_model_version()
    start = time.perf_counter()
    result = mv.run(X, service_name=SERVICE_FQN)
    latency_ms = (time.perf_counter() - start) * 1000
    result_df = result.to_pandas() if hasattr(result, "to_pandas") else result
    prob_col = next(
        (c for c in result_df.columns if c.lower().startswith("output_feature")),
        result_df.columns[-1],
    )
    return float(result_df.iloc[0][prob_col]), latency_ms


def classify_risk(prob: float):
    if prob < RISK_THRESHOLDS["high"]:
        return "HIGH RISK", "verdict-risk", "#ef4444", "Hold for engineering review", "action-hold"
    elif prob < RISK_THRESHOLDS["medium"]:
        return "AT RISK", "verdict-caution", "#f59e0b", "Flag for additional inspection", "action-inspect"
    else:
        return "PASS", "verdict-pass", "#22c55e", "Release to next stage", "action-release"


def render_verdict(prob: float, latency_ms: float = None):
    label, css_class, color, action, action_class = classify_risk(prob)
    st.markdown(f"""
    <div class="{css_class}">
        <p class="verdict-label" style="color:{color}">{label}</p>
        <p class="verdict-sub">Yield confidence {prob*100:.1f}%</p>
        <span class="verdict-action {action_class}">{action}</span>
    </div>
    """, unsafe_allow_html=True)
    if latency_ms is not None:
        st.caption(f"Scored in {latency_ms:.0f} ms")


def render_contributing_factors(X: pd.DataFrame, feature_cols: list, ranges: pd.DataFrame):
    deviations = []
    for c in feature_cols:
        val = float(X.iloc[0][c])
        r = ranges.loc[c]
        span = r["max"] - r["min"]
        if span > 0:
            z = abs(val - r["mean"]) / span
        else:
            z = 0.0
        deviations.append({"name": _display(c), "value": val,
                           "baseline": r["mean"], "deviation": z, "raw_col": c})
    dev_list = sorted(deviations, key=lambda d: d["deviation"], reverse=True)[:5]
    if not dev_list:
        return

    colors = ["#ef4444", "#f59e0b", "#3b82f6", "#6366f1", "#64748b"]
    html = '<div style="margin-top:16px">'
    html += '<p style="color:#94a3b8; font-size:0.75rem; font-weight:600; text-transform:uppercase; letter-spacing:0.08em; margin-bottom:10px">Top contributing factors</p>'
    for i, d in enumerate(dev_list):
        bar_pct = min(d["deviation"] * 100, 100)
        direction = "above" if d["value"] > d["baseline"] else "below"
        c = colors[i] if i < len(colors) else "#64748b"
        html += f'''<div class="factor-row">
            <span class="factor-name">{d["name"]}</span>
            <div class="factor-bar-bg"><div class="factor-bar-fill" style="width:{bar_pct}%; background:{c}"></div></div>
            <span class="factor-val">{d["value"]:.2f} <span style="color:#64748b;font-size:0.7rem">{direction}</span></span>
        </div>'''
    html += '</div>'
    st.markdown(html, unsafe_allow_html=True)


try:
    feature_cols = get_feature_schema()
except Exception as e:
    st.error(f"Could not load model signature: {e}")
    st.stop()

try:
    ranges = get_feature_ranges(feature_cols)
except Exception:
    ranges = pd.DataFrame(
        [{"feature": c, "min": 0.0, "mean": 0.0, "max": 1.0} for c in feature_cols]
    ).set_index("feature")

spcs_up = service_is_available()

status_class = "fab-status-on" if spcs_up else "fab-status-off"
dot_class = "fab-dot-on" if spcs_up else "fab-dot-off"
status_text = "Service online" if spcs_up else "Service offline"

st.markdown(f"""
<div class="fab-header">
    <div class="fab-header-left">
        <div class="fab-icon">&#9670;</div>
        <div>
            <p class="fab-title">Fab Yield Assurance</p>
            <p class="fab-subtitle">Real-time wafer disposition & monitoring</p>
        </div>
    </div>
    <div class="fab-status {status_class}">
        <span class="fab-dot {dot_class}"></span> {status_text}
    </div>
</div>
""", unsafe_allow_html=True)

tab_score, tab_queue, tab_failures, tab_batch, tab_history = st.tabs(
    ["Score Wafer", "At-Risk Queue", "Recent Failures", "Lot Summary", "Run History"]
)

with tab_score:
    if not spcs_up:
        st.warning("Real-time scoring service is not running. Pre-scored results are still available in other tabs.")

    sample_wafers = get_sample_wafers(50)
    mode = st.radio("", ["Select wafer", "Adjust parameters"], horizontal=True, label_visibility="collapsed")

    if mode == "Select wafer":
        selected_wafer = st.selectbox("Wafer ID", sample_wafers, label_visibility="collapsed",
                                       placeholder="Enter or select wafer ID...")
        if selected_wafer:
            X = get_wafer_features(selected_wafer, feature_cols)
            if st.button("Score", type="primary", use_container_width=True):
                try:
                    prob, latency_ms = run_inference(X)
                    render_verdict(prob, latency_ms)
                    st.divider()
                    render_contributing_factors(X, feature_cols, ranges)
                except Exception as e:
                    st.error(f"Scoring failed: {e}")

    else:
        seed_wafer = st.selectbox("Base wafer", sample_wafers, key="seed",
                                   placeholder="Start from an existing wafer...")
        if seed_wafer:
            baseline = get_wafer_features(seed_wafer, feature_cols)

            if "whatif_seed" not in st.session_state or st.session_state.get("whatif_seed") != seed_wafer:
                st.session_state["whatif_values"] = {c: float(baseline.iloc[0][c]) for c in feature_cols}
                st.session_state["whatif_seed"] = seed_wafer

            def _family(col: str) -> str:
                u = col.upper()
                if u.startswith("TEMP_"):
                    return "Temperature"
                if u.startswith("PRESSURE_"):
                    return "Pressure"
                if u.startswith("GAS_FLOW_"):
                    return "Gas flow"
                if u.startswith("HUMIDITY_"):
                    return "Humidity"
                if "DEFECT" in u or "SEVERITY" in u:
                    return "Defect metrics"
                if u.startswith("PROCESS_") or "HOUR" in u or "DAY" in u:
                    return "Process timing"
                return "Other"

            families = {}
            for c in feature_cols:
                families.setdefault(_family(c), []).append(c)

            updated = {}
            for fam_name in ["Temperature", "Pressure", "Gas flow", "Humidity", "Defect metrics", "Process timing", "Other"]:
                cols_in_family = families.get(fam_name, [])
                if not cols_in_family:
                    continue
                with st.expander(fam_name, expanded=False):
                    grid = st.columns(2)
                    for i, c in enumerate(cols_in_family):
                        r = ranges.loc[c]
                        lo, hi = float(r["min"]), float(r["max"])
                        if hi <= lo:
                            hi = lo + 1.0
                        current = st.session_state["whatif_values"].get(c, float(baseline.iloc[0][c]))
                        current = max(lo, min(hi, current))
                        with grid[i % 2]:
                            updated[c] = st.slider(
                                _display(c), min_value=lo, max_value=hi,
                                value=current, step=max((hi - lo) / 200.0, 1e-4),
                                key=f"wa_{c}",
                            )
            st.session_state["whatif_values"] = updated
            X_edit = pd.DataFrame([updated]).astype("float32")[feature_cols]

            if st.button("Score with adjusted parameters", type="primary", use_container_width=True):
                try:
                    prob_base, _ = run_inference(baseline[feature_cols])
                    prob_edit, latency_ms = run_inference(X_edit)
                    render_verdict(prob_edit, latency_ms)
                    delta = (prob_edit - prob_base) * 100
                    st.caption(f"Baseline confidence: {prob_base*100:.1f}%  |  Change: {delta:+.1f} pp")
                    st.divider()
                    render_contributing_factors(X_edit, feature_cols, ranges)
                except Exception as e:
                    st.error(f"Scoring failed: {e}")


with tab_queue:
    try:
        latest_run = session.sql(f"""
            SELECT MAX("RUN_ID") as latest FROM {PREDICTIONS_TABLE}
        """).to_pandas().iloc[0]["LATEST"]

        risk_df = session.sql(f"""
            SELECT "WAFER_ID",
                   "output_feature_0" as YIELD_PROB
            FROM {PREDICTIONS_TABLE}
            WHERE "RUN_ID" = '{latest_run}' AND "output_feature_0" < {RISK_THRESHOLDS['medium']}
            ORDER BY "output_feature_0" ASC
            LIMIT 200
        """).to_pandas()

        if not risk_df.empty:
            risk_df["SEVERITY"] = risk_df["YIELD_PROB"].apply(
                lambda p: "HIGH" if p < RISK_THRESHOLDS["high"] else "MEDIUM"
            )
            risk_df["CONFIDENCE"] = (risk_df["YIELD_PROB"] * 100).round(1).astype(str) + "%"

            high_ct = (risk_df["SEVERITY"] == "HIGH").sum()
            med_ct = (risk_df["SEVERITY"] == "MEDIUM").sum()

            c1, c2, c3 = st.columns(3)
            c1.metric("Total at-risk wafers", len(risk_df))
            c2.metric("High risk", high_ct)
            c3.metric("Medium risk", med_ct)

            st.dataframe(
                risk_df[["WAFER_ID", "SEVERITY", "CONFIDENCE"]].reset_index(drop=True),
                use_container_width=True,
                height=500,
                column_config={
                    "WAFER_ID": "Wafer",
                    "SEVERITY": "Risk level",
                    "CONFIDENCE": "Yield confidence",
                },
            )
        else:
            st.success("No at-risk wafers in the latest scoring run.")
    except Exception:
        st.info("No prediction data available yet. Run batch scoring first.")


with tab_failures:
    try:
        latest_run = session.sql(f"""
            SELECT MAX("RUN_ID") as latest FROM {PREDICTIONS_TABLE}
        """).to_pandas().iloc[0]["LATEST"]

        fail_df = session.sql(f"""
            SELECT *
            FROM {PREDICTIONS_TABLE}
            WHERE "RUN_ID" = '{latest_run}' AND "output_feature_0" < {RISK_THRESHOLDS['high']}
            ORDER BY "output_feature_0" ASC
            LIMIT 50
        """).to_pandas()

        if not fail_df.empty:
            st.metric("High-risk wafers this run", len(fail_df))

            for idx, row in fail_df.head(10).iterrows():
                wid = row["WAFER_ID"]
                prob = row["output_feature_0"]
                with st.expander(f"{wid}  —  {prob*100:.1f}% yield confidence"):
                    avail_features = [c for c in feature_cols if c in fail_df.columns]
                    if avail_features:
                        X_row = fail_df.loc[[idx], avail_features].astype("float32")
                        render_contributing_factors(X_row, avail_features, ranges)
                    else:
                        st.caption("Feature data not available in predictions table. Score this wafer in the Score tab for full analysis.")
        else:
            st.success("No high-risk wafers detected in the latest run.")
    except Exception:
        st.info("No prediction data available yet.")


with tab_batch:
    try:
        latest_run = session.sql(f"""
            SELECT MAX("RUN_ID") as latest FROM {PREDICTIONS_TABLE}
        """).to_pandas().iloc[0]["LATEST"]

        lots = session.sql(f"""
            SELECT DISTINCT p.LOT_ID
            FROM {PREDICTIONS_TABLE} pred
            JOIN WAFER_YIELD_DEMO.RAW_DATA.WAFER_PROCESS_DATA p
                ON pred."WAFER_ID" = p.WAFER_ID
            ORDER BY p.LOT_ID
            LIMIT 100
        """).to_pandas()

        lot_options = ["All lots"] + lots["LOT_ID"].tolist()
        selected_lot = st.selectbox("Lot", lot_options)

        if selected_lot == "All lots":
            preds_df = session.sql(f"""
                SELECT "WAFER_ID", "output_feature_0" as YIELD_PROB
                FROM {PREDICTIONS_TABLE}
                WHERE "RUN_ID" = '{latest_run}'
                LIMIT 500
            """).to_pandas()
        else:
            preds_df = session.sql(f"""
                SELECT pred."WAFER_ID", pred."output_feature_0" as YIELD_PROB
                FROM {PREDICTIONS_TABLE} pred
                JOIN WAFER_YIELD_DEMO.RAW_DATA.WAFER_PROCESS_DATA p
                    ON pred."WAFER_ID" = p.WAFER_ID
                WHERE pred."RUN_ID" = '{latest_run}' AND p.LOT_ID = '{selected_lot}'
            """).to_pandas()

        if not preds_df.empty:
            preds_df["STATUS"] = preds_df["YIELD_PROB"].apply(
                lambda p: "High risk" if p < RISK_THRESHOLDS["high"]
                else ("At risk" if p < RISK_THRESHOLDS["medium"] else "Pass")
            )

            total = len(preds_df)
            pass_ct = (preds_df["STATUS"] == "Pass").sum()
            risk_ct = total - pass_ct
            yield_rate = pass_ct / total

            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Wafers scored", f"{total:,}")
            c2.metric("Passing", f"{pass_ct:,}")
            c3.metric("At risk", f"{risk_ct:,}")
            c4.metric("Yield rate", f"{yield_rate:.1%}")

            fig = go.Figure(go.Histogram(
                x=preds_df["YIELD_PROB"],
                nbinsx=40,
                marker_color="#3b82f6",
                marker_line_width=0,
                opacity=0.85,
            ))
            fig.add_vline(x=RISK_THRESHOLDS["medium"], line_dash="dash",
                          line_color="#f59e0b", annotation_text="Risk threshold",
                          annotation_font_color="#f59e0b")
            fig.add_vline(x=RISK_THRESHOLDS["high"], line_dash="dash",
                          line_color="#ef4444", annotation_text="High risk",
                          annotation_font_color="#ef4444")
            fig.update_layout(
                xaxis_title="Yield confidence",
                yaxis_title="Wafer count",
                plot_bgcolor="rgba(0,0,0,0)",
                paper_bgcolor="rgba(0,0,0,0)",
                font_color="#94a3b8",
                font_family="Inter",
                height=320,
                margin=dict(l=40, r=20, t=30, b=40),
                xaxis=dict(gridcolor="#1e293b", zerolinecolor="#1e293b"),
                yaxis=dict(gridcolor="#1e293b", zerolinecolor="#1e293b"),
            )
            st.plotly_chart(fig, use_container_width=True)

            st.dataframe(
                preds_df[["WAFER_ID", "YIELD_PROB", "STATUS"]].sort_values("YIELD_PROB", ascending=True),
                use_container_width=True,
                height=400,
                column_config={
                    "WAFER_ID": "Wafer",
                    "YIELD_PROB": st.column_config.NumberColumn("Yield confidence", format="%.3f"),
                    "STATUS": "Disposition",
                },
            )
        else:
            st.info("No scored wafers found for this lot.")
    except Exception:
        st.info("No prediction data available yet. Run batch scoring first.")


with tab_history:
    try:
        runs_df = session.sql(f"""
            SELECT "RUN_ID",
                   COUNT(*) as WAFER_COUNT,
                   AVG("output_feature_0") as AVG_YIELD,
                   SUM(CASE WHEN "output_feature_0" >= {RISK_THRESHOLDS['medium']} THEN 1 ELSE 0 END) as PASS_COUNT,
                   SUM(CASE WHEN "output_feature_0" < {RISK_THRESHOLDS['medium']} THEN 1 ELSE 0 END) as RISK_COUNT,
                   MIN("INFERENCE_TIMESTAMP_UTC") as RUN_TIME
            FROM {PREDICTIONS_TABLE}
            GROUP BY "RUN_ID"
            ORDER BY RUN_TIME DESC
        """).to_pandas()

        if not runs_df.empty:
            runs_df["YIELD_RATE"] = runs_df["PASS_COUNT"] / runs_df["WAFER_COUNT"]

            st.dataframe(
                runs_df[["RUN_ID", "RUN_TIME", "WAFER_COUNT", "PASS_COUNT", "RISK_COUNT", "YIELD_RATE"]],
                use_container_width=True,
                column_config={
                    "RUN_ID": "Run",
                    "RUN_TIME": "Timestamp",
                    "WAFER_COUNT": "Wafers",
                    "PASS_COUNT": "Passing",
                    "RISK_COUNT": "At risk",
                    "YIELD_RATE": st.column_config.ProgressColumn("Yield rate", min_value=0, max_value=1, format="%.1%%"),
                },
            )

            if len(runs_df) > 1:
                fig = go.Figure(go.Scatter(
                    x=runs_df.sort_values("RUN_TIME")["RUN_TIME"],
                    y=runs_df.sort_values("RUN_TIME")["YIELD_RATE"],
                    mode="lines+markers",
                    line=dict(color="#3b82f6", width=2),
                    marker=dict(size=7, color="#3b82f6", line=dict(color="#1d4ed8", width=2)),
                    fill="tozeroy",
                    fillcolor="rgba(59, 130, 246, 0.1)",
                ))
                fig.update_layout(
                    yaxis_title="Yield rate",
                    yaxis_tickformat=".0%",
                    xaxis_title="",
                    plot_bgcolor="rgba(0,0,0,0)",
                    paper_bgcolor="rgba(0,0,0,0)",
                    font_color="#94a3b8",
                    font_family="Inter",
                    height=300,
                    margin=dict(l=40, r=20, t=20, b=40),
                    xaxis=dict(gridcolor="#1e293b"),
                    yaxis=dict(gridcolor="#1e293b"),
                )
                st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("No scoring runs recorded yet.")
    except Exception:
        st.info("No prediction data available yet.")


st.divider()
with st.expander("About the model", expanded=False):
    st.caption(f"Model: {MODEL_DB}.{MODEL_SCHEMA}.{MODEL_NAME} v{MODEL_VERSION}")
    st.caption(f"Service: {SERVICE_FQN} ({'running' if spcs_up else 'offline'})")
    try:
        model_meta = session.sql(
            f"SHOW VERSIONS IN MODEL {MODEL_DB}.{MODEL_SCHEMA}.{MODEL_NAME}"
        ).to_pandas()
        model_meta = model_meta[model_meta["name"] == MODEL_VERSION]
        if not model_meta.empty:
            raw_meta = model_meta.iloc[0].get("metadata", model_meta.iloc[0].get("METADATA", "{}"))
            metadata = json.loads(raw_meta) if isinstance(raw_meta, str) else (raw_meta or {})
            metrics = metadata.get("metrics", {})
            if metrics:
                mc1, mc2, mc3, mc4 = st.columns(4)
                mc1.caption(f"Accuracy: {metrics.get('accuracy', 0):.1%}")
                mc2.caption(f"Precision: {metrics.get('precision', 0):.1%}")
                mc3.caption(f"Recall: {metrics.get('recall', 0):.1%}")
                mc4.caption(f"AUC: {metrics.get('roc_auc', 0):.3f}")
    except Exception:
        pass

st.markdown('<div class="fab-footer">FAB YIELD ASSURANCE SYSTEM</div>', unsafe_allow_html=True)
