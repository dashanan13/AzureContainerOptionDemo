# Social Media Scheduler

## 1. Goal

The goal of this application is to provide a **multi-user, multi-platform social media scheduler** with an intuitive web interface. Each user can connect one account per platform, create posts with platform-specific previews, schedule posts, and monitor engagement. The application consolidates operational, analytics, and account management functionality in a **single streamlined web interface**.

---

## 2. Users

- Supports **multiple users**.
- Each user has **one account per platform**.
- Users can switch between accounts using **horizontal user tabs**.

---

## 3. Supported Platforms

- Instagram (IG)  
- X (Twitter)  
- Facebook (FB)  
- YouTube (YT)  
- LinkedIn  

Users can connect accounts via OAuth in the **Settings tab**.

---

## 4. Application Layout

### 4.1 User Tabs

- **Horizontal tabs** at the top of the application for switching between users.
- **Vertical tabs** within each user account for feature navigation:
  - Dashboard  
  - Compose  
  - Analytics  
  - Settings  

**Example:**


### User Tabs Layout (Example)

```
+----------------------------------------------------------+
| USERS: [ User 1 ▼ | User 2 | User 3 | + Add User ]      |
+----------------------------------------------------------+
| Vertical Tabs:                                           |
| [ Dashboard ] [ Compose ] [ Analytics ] [ Settings ]    |
```

---

## 5. Tab Details

### 5.1 Dashboard

**Purpose:** Operational hub to view upcoming posts, activity, and alerts.

**Sections:**

1. **Quick Stats** – Horizontal table:
   - Platforms Connected  
   - Scheduled Posts  
   - Failed Posts  
   - Drafts  

2. **Upcoming Posts (Scrollable with Filters)**
   - Filters: Date, Platform (connected only), Keyword search  
   - Scrollable list shows **next 10 posts**, with scrollbar for more  
   - Each row includes:
     - Schedule (Date & Time)  
     - Platforms  
     - Post Title  
     - Status: Scheduled / Pending / Error  
     - Edit button → opens Compose with original content  

3. **Activity**
   - Log of recent posting activity:
     - Platform  
     - Status: Posted successfully / Failed  
     - Timestamp  

4. **Alerts**
   - Critical operational issues (e.g., disconnected accounts) with required actions

---

### 5.2 Compose

**Purpose:** Create or edit posts with platform-specific previews and scheduling.

**Sections:**

1. **Post Content**
   - Text area for base text  
   - Image upload (pre-edited images only)  
   - Hashtags, location, tagged users  

2. **Platform Previews (Horizontal Row)**
   - Only for connected platforms  
   - Each preview includes:
     - Editable text field  
     - **Regenerate button** (uses LLM to rewrite text for that platform)  
     - Schedule section (Date & Time)  

3. **Schedule**
   - Checkbox: “Apply same schedule to all platforms”  
   - Schedule button to finalize post  

**Behavior Notes:**
- Editing preserves original content; no auto-regeneration unless requested  
- Horizontal previews reduce vertical scrolling

---

### 5.3 Analytics

**Purpose:** Read-only performance metrics and trends.

**Sections:**

1. **Date Range Selector** – Last 7 Days, Last 30 Days, Custom  
2. **Overall Performance** – Aggregated metrics: Views, Likes, Comments, Engagement Rate  
3. **Engagement Trends Graph** – Line graph, toggle per platform  
4. **Platform Breakdown** – Views, Likes, Comments, Growth trend per platform  
5. **Top Posts** – Most engaging posts across all platforms  

**Behavior Notes:**
- Graphs and tables are **read-only**  
- Toggle buttons allow per-platform visibility

---

### 5.4 Settings

**Purpose:** Manage accounts, notifications, timezone, and user preferences.

**Sections:**

1. **Accounts**
   - Connect/disconnect one account per platform  
   - Displays: Platform, Username, Status, Action (Connect/Disconnect)  
   - Only connected accounts can be scheduled  

2. **Notifications**
   - Email notifications: post success/failure  
   - Push notifications: post success/failure  
   - Weekly engagement summary (optional)  

3. **Timezone**
   - User-selectable timezone  

4. **Other Options**
   - Language selection  
   - Dark mode toggle  
   - Delete account button  

---

## 6. Functional Requirements

1. Multi-user support with separate account data and posts  
2. Multi-platform posting, with platform-specific previews  
3. Editable platform previews with optional LLM regeneration  
4. Scheduling per platform, with option to apply same schedule to all  
5. Activity and alerts displayed on Dashboard  
6. Analytics for engagement metrics, trends, top posts (read-only)  
7. Settings include accounts, notifications, timezone, preferences  
8. Scrollable and filterable upcoming posts list  

---

## 7. Non-functional Requirements

- Web-based and responsive design  
- Horizontal user tabs, vertical feature tabs  
- Minimal DB usage: no historical published posts stored  
- Compact, scrollable lists and horizontal previews  
- Secure: OAuth for social account connections  
- Scalable for many scheduled posts per user  

---

## 8. Summary Tab Structure

```
Horizontal User Tabs: [ User 1 | User 2 | + Add User ]
Vertical Tabs per User: [ Dashboard | Compose | Analytics | Settings ]
```



- **Dashboard** → Operational hub: upcoming posts, activity, alerts  
- **Compose** → Post creation/editing, horizontal previews, scheduling  
- **Analytics** → Engagement metrics, trends, top posts  
- **Settings** → Accounts, notifications, timezone, preferences  

---

**End of Requirement Document**
