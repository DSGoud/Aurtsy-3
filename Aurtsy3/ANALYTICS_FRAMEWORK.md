# Aurtsy Analytics Framework: "The Why Engine"

## Core Philosophy
Move beyond "what happened" (History) to **"why it happened"** (Insights). 
Instead of generic health metrics (steps, calories), we track **Regulation**, **Resilience**, and **Context**.

---

## 1. The Regulation Battery (Current Capacity)
**Goal**: Visualize the child's current resilience level to help caregivers adjust demands.

**Visual**: A "Fuel Gauge" or Battery icon.

**The Formula**:
`Resilience = (Inputs) - (Drains)`

| Component | Data Source | Impact |
|-----------|-------------|--------|
| **Inputs** (Recharge) | • Sleep Quality (>80%)<br>• Protein-rich meals<br>• Positive sensory activities<br>• Successful communication | **+ Charge** |
| **Drains** (Deplete) | • Poor sleep<br>• Sensory overload events<br>• Transitions<br>• **Unresolved Requests** (Open Loops)<br>• High sugar intake | **- Drain** |

**Actionable Insight**: 
> "Battery is at 30%. 2 unresolved requests and poor sleep detected. Recommend low-demand activities."

---

## 2. "The Open Loop" (Unresolved Requests)
**Goal**: Track denied or delayed requests that may be "ticking time bombs" for behavior.

**Visual**: A "Pending Items" list or "Closure Rate" metric.

**Tracking**:
- **Request**: "Asked for iPad"
- **Outcome**: `GRANTED`, `DENIED`, `DELAYED`, `UNRESOLVED`
- **Latency**: Time since request.

**Actionable Insight**:
> "John asked for a snack 2 hours ago (Denied). He hasn't eaten since. This 'open loop' may be driving current anxiety."

---

## 3. Dietary Context & Food Seeking
**Goal**: Distinguish between *nutritional need* and *sensory/anxious seeking*.

**Metrics**:
1.  **Food Seeking Frequency**: Count of "asking for food" events vs. actual meals.
    *   *High Seeking + Low Eating* = Possible anxiety/sensory seeking.
2.  **Nutritional Impact**:
    *   *Sugar Crash Detection*: Correlate high-sugar intake with behavior spikes 30-90 mins later.
    *   *Protein Buffer*: Track protein intake as a stabilizing factor.

---

## 4. The Behavior Detective (ABC Analysis)
**Goal**: Identify patterns in triggers and effective interventions.

**Visuals**:
1.  **Top Triggers (Antecedents)**: Bar chart.
    *   e.g., "Transitions (40%)", "Denied Access (30%)", "Sensory (20%)".
2.  **What Works (Consequences)**: Ranked list of effective interventions.
    *   e.g., "Deep Pressure (80% success)", "Verbal Reasoning (10% success)".
3.  **Time-of-Day Heatmap**:
    *   Visual grid showing incident density by hour (e.g., "The 4 PM Crash").

---

## 5. The "Why" Engine (Correlations)
**Goal**: Find hidden relationships between different data types.

**Correlations to Track**:
- **Sleep vs. Meltdowns**: Impact of previous night's sleep on today's severity.
- **Hydration vs. Focus**: Fluid intake impact on activity duration.
- **Screen Time vs. Transition Issues**: Meltdowns occurring immediately after screen time ends.

---

## Data Requirements (AI Extraction)

To power this, the AI (Ollama) must extract specific structured fields from voice notes:

1.  **Request Events**:
    *   `request_object`: "cookie", "iPad"
    *   `request_status`: `GRANTED` | `DENIED` | `DELAYED`
2.  **Dietary Details**:
    *   `sugar_content`: `HIGH` | `LOW` (inferred)
    *   `protein_content`: `HIGH` | `LOW` (inferred)
3.  **Behavior Context**:
    *   `antecedent`: Explicit trigger
    *   `intervention`: Specific action taken
    *   `outcome`: `IMPROVED` | `NO_CHANGE` | `WORSENED`

---

## User Interface Strategy

**Tab Name**: **Insights** (replacing Analytics)

**Layout**:
1.  **Top Card**: **Regulation Battery** (The "Now" status).
2.  **Section 1**: **Open Loops** (Immediate risks).
3.  **Section 2**: **Patterns** (Triggers, Heatmaps).
4.  **Section 3**: **Correlations** ("Did you know?").
