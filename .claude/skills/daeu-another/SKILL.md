---
name: daeu-another
description: "Convert Figma designs into Lightning Web Components (LWC) for Salesforce. Use this skill whenever the user wants to read a Figma file and generate LWC code, translate UI designs into Salesforce components, convert mockups or wireframes into .html/.js/.css LWC files, or asks anything involving Figma and LWC, design to Salesforce component, Figma to component, or thiet ke Figma sang LWC. Always trigger this skill when Figma design context is combined with any mention of LWC, Salesforce, or web components."
---

# Figma → Lightning Web Component (LWC)

## Overview

This skill guides Claude to read designs from Figma (via Figma MCP) and convert them into standard Salesforce Lightning Web Components — including `.html`, `.js`, `.css`, and `.js-meta.xml` files.

### 🔒 Mandatory Principle — Faithful to Figma Design

> **Claude must reproduce exactly what Figma describes. Do not change, add, remove, or "improve" any information compared to the original design.**

| Element | Rule |
|---------|------|
| **Text / Label** | Copy verbatim from Figma, no paraphrasing, no fixing typos |
| **Colors** | Use exact hex/rgba from Figma, don't choose similar colors |
| **Font size / weight** | Use exact Figma values, no rounding |
| **Spacing / padding / margin** | Use exact px values from Figma |
| **Element order** | Preserve layout order from Figma |
| **Images / Icons** | Use exact assets from Figma, don't replace with placeholders |
| **States (hover, disabled, active)** | Implement exactly as described in Figma |

**Only exception allowed:** Adjust layout by viewport (responsive) — mobile/tablet/desktop — as described in Step 2. All other changes require user consent.

---

## Step 1 — Receive Figma URLs (Web / Tablet / Mobile UI)

User can provide **up to 3 Figma URLs** for different screen sizes:

| Type | Description | Viewport Range | Required? |
|------|-------------|----------------|-----------|
| **Web UI** | Design for desktop screens | ≥ 1024px | Optional |
| **Tablet UI** | Design for tablet screens | 768px - 1023px | Optional |
| **Mobile UI** | Design for mobile screens | < 768px | Optional |

**IMPORTANT:** At least **1 Figma URL must be provided**. If user skips a device, that device UI will NOT be designed.

### Ask user for Figma URLs

**Always ask explicitly for all 3 URLs:**

> "Please provide Figma URLs for your designs:
> 
> **Web UI** (desktop ≥1024px): _[URL or 'skip']_
> **Tablet UI** (768-1023px): _[URL or 'skip']_
> **Mobile UI** (<768px): _[URL or 'skip']_
>
> You can skip any version by typing 'skip' or leaving it blank. **At least one URL is required.**"

### How to extract `nodeId` from Figma URL

```
URL: https://www.figma.com/design/NIvfVEYEUQPyAdDPoNj4hG/Design-File?node-id=2689-36710&m=dev
                                   ↑                                  ↑
              fileKey = "NIvfVEYEUQPyAdDPoNj4hG"            nodeId = "2689-36710"
```

### Parse user response

Accept multiple input formats:

**Format 1 — Labeled:**
```
Web: https://www.figma.com/design/xxx?node-id=1-1
Tablet: https://www.figma.com/design/xxx?node-id=1-2
Mobile: skip
```

**Format 2 — Line by line (in order: Web, Tablet, Mobile):**
```
https://www.figma.com/design/xxx?node-id=1-1
https://www.figma.com/design/xxx?node-id=1-2
skip
```

**Format 3 — Only what's provided:**
```
Web: https://www.figma.com/design/xxx?node-id=1-1
Mobile: https://www.figma.com/design/xxx?node-id=1-3
```

**Format 4 — Single URL (will only design for that device):**
```
https://www.figma.com/design/xxx?node-id=1-1
```

### Read provided Figma nodes

**Step 1: Validate at least 1 URL provided**

```javascript
const urls = {
  web: userProvidedWebUrl || null,
  tablet: userProvidedTabletUrl || null,
  mobile: userProvidedMobileUrl || null
};

// At least one must be non-null
if (!urls.web && !urls.tablet && !urls.mobile) {
  throw new Error("At least one Figma URL is required");
}
```

**Step 2: Call tool_search first**
```
tool_search(query="figma get design context screenshot")
```

**Step 3: Read only provided Figma nodes**

```javascript
// Only call for URLs that were provided
if (urls.web) {
  Figma:get_screenshot(nodeId="<webNodeId>")
  Figma:get_design_context(nodeId="<webNodeId>")
}

if (urls.tablet) {
  Figma:get_screenshot(nodeId="<tabletNodeId>")
  Figma:get_design_context(nodeId="<tabletNodeId>")
}

if (urls.mobile) {
  Figma:get_screenshot(nodeId="<mobileNodeId>")
  Figma:get_design_context(nodeId="<mobileNodeId>")
}

// Design tokens (optional, use from any provided URL)
if (urls.web) {
  Figma:get_variable_defs(nodeId="<webNodeId>")
} else if (urls.tablet) {
  Figma:get_variable_defs(nodeId="<tabletNodeId>")
} else {
  Figma:get_variable_defs(nodeId="<mobileNodeId>")
}
```

### Component Naming
 
Handle component name in the following priority order:
 
**1. User already provided name** (in initial command)
→ Use directly, convert to proper LWC format:
 
| User Input | Folder / Class Name | HTML Tag |
|------------|---------------------|----------|
| `AccountCard` | `accountCard` | `<c-account-card>` |
| `account-card` | `accountCard` | `<c-account-card>` |
| `My Account Card` | `myAccountCard` | `<c-my-account-card>` |
| `gdc_ContactUs` | `gdc_ContactUs` | `<c-gdc_-contact-us>` |
 
**2. User didn't provide name** → Ask:
> "What name would you like for this component?
> _(Press Enter or type **skip** for me to choose a suitable name from the Figma design)_"
 
**3. User skips** → Infer name from Figma:
- Prefer taking **layer/frame** name from **any provided design** (Web > Tablet > Mobile priority)
- If layer name is unclear (e.g., `Frame 42`, `Group 7`) → name based on **design content** (e.g., `productCard`, `loginForm`, `navHeader`)
- Notify user: _"I'll name the component `productCard` based on the design. You can rename it later."_
 
**LWC Naming Rules:**
- Use **camelCase** for folder and class names
- Only use **letters, numbers** — no spaces, no special characters
- Don't start with numbers
- Don't use reserved words: `component`, `lwc`, `salesforce`
 
---

## Step 2 — Scale UI by Viewport (Responsive)

**CRITICAL RULE: Only build UI for devices with provided Figma URLs. No inheritance or fallback to other devices.**

### Responsive Strategy by Provided URLs

**If Web only provided:**
→ Build ONLY Web UI (≥1024px). Component will NOT work on tablet or mobile.

**If Tablet only provided:**
→ Build ONLY Tablet UI (768-1023px). Component will NOT work on desktop or mobile.

**If Mobile only provided:**
→ Build ONLY Mobile UI (<768px). Component will NOT work on desktop or tablet.

**If Web + Mobile provided:**
→ Build Web UI (≥1024px) + Mobile UI (<768px). Tablet viewport (768-1023px) will use Mobile UI styles.

**If Web + Tablet provided:**
→ Build Web UI (≥1024px) + Tablet UI (768-1023px). Mobile viewport (<768px) will NOT be handled.

**If Tablet + Mobile provided:**
→ Build Tablet UI (768-1023px) + Mobile UI (<768px). Desktop viewport (≥1024px) will NOT be handled.

**If Web + Tablet + Mobile provided:**
→ Build all three with full responsive support.

### Standard Breakpoints

```css
/* Define breakpoints — add at the top of CSS file */
:host {
    /* Breakpoint variables */
    --bp-mobile:  480px;
    --bp-tablet:  768px;
    --bp-desktop: 1024px;
    --bp-wide:    1280px;
}
```

### CSS Media Queries Examples

#### Example 1: Web Only (No Responsive)

```css
/* Single viewport - no media queries needed */
.container {
    display: flex;
    flex-direction: row;
    padding: var(--lwc-spacingLarge, 1.5rem);
}

.sidebar {
    display: block;
    width: 280px;
}

.main-content {
    flex: 1;
}
```

#### Example 2: Web + Mobile (Tablet uses Mobile styles)

```css
/* Base styles from Mobile UI */
.container {
    display: flex;
    flex-direction: column;
    padding: var(--lwc-spacingSmall, 0.5rem);
}

.sidebar { display: none; }
.nav-bottom { display: flex; }

/* Desktop only (≥1024px) - from Web UI */
@media (min-width: 1024px) {
    .container {
        flex-direction: row;
        padding: var(--lwc-spacingLarge, 1.5rem);
    }
    
    .sidebar { display: block; }
    .nav-bottom { display: none; }
}

/* Note: Tablet viewport (768-1023px) uses Mobile UI styles */
```

#### Example 3: Web + Tablet + Mobile (Full Responsive)

```css
/* Base styles from Mobile UI */
.container {
    display: flex;
    flex-direction: column;
    padding: var(--lwc-spacingSmall, 0.5rem);
}

.sidebar { display: none; }
.nav-bottom { display: flex; }

/* Tablet (≥768px) - from Tablet UI */
@media (min-width: 768px) {
    .container {
        padding: var(--lwc-spacingMedium, 1rem);
    }
    
    .nav-bottom { display: none; }
    .nav-top { display: flex; }
}

/* Desktop (≥1024px) - from Web UI */
@media (min-width: 1024px) {
    .container {
        flex-direction: row;
        padding: var(--lwc-spacingLarge, 1.5rem);
    }
    
    .sidebar { display: block; }
    .nav-top { display: none; }
}
```

### Responsive in JavaScript

**Detect which viewports are supported:**

```javascript
// componentName.js
import { LightningElement, track } from 'lwc';

export default class ComponentName extends LightningElement {
    // Only declare variables for provided viewports
    @track isMobile = false;   // Only if Mobile UI provided
    @track isTablet = false;   // Only if Tablet UI provided
    @track isDesktop = false;  // Only if Web UI provided

    _resizeObserver;

    connectedCallback() {
        this.detectViewport();
        this._resizeObserver = new ResizeObserver(() => this.detectViewport());
        this._resizeObserver.observe(document.body);
    }

    disconnectedCallback() {
        if (this._resizeObserver) {
            this._resizeObserver.disconnect();
        }
    }

    detectViewport() {
        const width = window.innerWidth;
        
        // Only set flags for provided viewports
        // Example: If only Web + Mobile provided
        this.isMobile  = width < 768;      // Mobile UI provided
        this.isDesktop = width >= 1024;    // Web UI provided
        // isTablet is NOT declared - Tablet UI not provided
    }

    get viewportClass() {
        // Only return classes for provided viewports
        if (this.isMobile)  return 'viewport--mobile';
        if (this.isDesktop) return 'viewport--desktop';
        return '';  // No tablet class - not provided
    }
}
```

### Conditional Rendering Examples

#### Example 1: Web Only

```html
<template>
    <div class="container">
        <!-- Only Web UI elements - no conditional rendering -->
        <div class="sidebar">
            <!-- Sidebar from Web UI -->
        </div>
        
        <div class="main-content">
            <!-- Content from Web UI -->
        </div>
    </div>
</template>
```

#### Example 2: Web + Mobile (No Tablet)

```html
<template>
    <div class={viewportClass}>

        <!-- Desktop only (from Web UI) -->
        <template if:true={isDesktop}>
            <div class="sidebar">
                <!-- Sidebar from Web UI -->
            </div>
        </template>

        <div class="main-content">
            <!-- Content adapts via CSS -->
        </div>

        <!-- Mobile only (from Mobile UI) -->
        <template if:true={isMobile}>
            <div class="nav-bottom">
                <!-- Bottom nav from Mobile UI -->
            </div>
        </template>

        <!-- Note: No tablet-specific elements -->
    </div>
</template>
```

#### Example 3: All Three Provided

```html
<template>
    <div class={viewportClass}>

        <!-- Desktop only (from Web UI) -->
        <template if:true={isDesktop}>
            <div class="sidebar">
                <!-- Sidebar from Web UI -->
            </div>
        </template>

        <!-- Tablet only (from Tablet UI) -->
        <template if:true={isTablet}>
            <nav class="nav-top">
                <!-- Top nav from Tablet UI -->
            </nav>
        </template>

        <div class="main-content">
            <!-- Content adapts via CSS -->
        </div>

        <!-- Mobile only (from Mobile UI) -->
        <template if:true={isMobile}>
            <div class="nav-bottom">
                <!-- Bottom nav from Mobile UI -->
            </div>
        </template>

    </div>
</template>
```

### Important Notes

- ✅ **Only build for provided devices** — no guessing or inheritance
- ✅ **If Web only** → component works ONLY on desktop (≥1024px)
- ✅ **If Mobile only** → component works ONLY on mobile (<768px)
- ✅ **If Tablet only** → component works ONLY on tablet (768-1023px)
- ✅ **Gaps in coverage are intentional** — if user skips a device, that's their choice
- ✅ **CSS mobile-first approach** — base styles from lowest provided viewport
- ✅ **Media queries only for provided viewports**

---

## Step 2b — 🔴 CRITICAL: Proportional Scaling (No Hard-coded Values)

> **This is a mandatory rule. Fixed pixel values for dimensions, gaps, and spacing cause the UI to break at different viewport widths within the same device category. All layout-affecting values MUST be converted to fluid/proportional equivalents.**

### The Problem with Fixed Values

Figma designs are created at a specific canvas width (e.g., 1440px). If Claude copies px values directly:
- At viewport **1600px** → elements look too small / too much whitespace
- At viewport **1200px** → elements overflow / get cramped

**This is wrong — DO NOT do this:**
```css
/* ❌ WRONG: Fixed values copied directly from Figma */
.container {
    width: 1200px;
    padding: 48px;
    gap: 24px;
}

.card {
    width: 380px;
    height: 260px;
    border-radius: 12px;
}

.sidebar {
    width: 280px;
}
```

### Mandatory Conversion Rules

When Claude reads **any fixed px value** from Figma for the properties below, it **MUST** convert to a proportional/fluid equivalent:

| Property | Fixed (❌ Forbidden) | Fluid (✅ Required) |
|----------|----------------------|---------------------|
| **Container width** | `width: 1200px` | `width: 100%; max-width: 1200px` |
| **Element width** | `width: 380px` | `width: clamp(280px, 26.4vw, 380px)` or `width: 100%` in flex/grid |
| **Element height** | `height: 260px` | `min-height: 260px; height: auto` or `aspect-ratio: 38/26` |
| **padding** | `padding: 48px` | `padding: clamp(24px, 3.33vw, 48px)` |
| **gap / column-gap / row-gap** | `gap: 24px` | `gap: clamp(12px, 1.67vw, 24px)` |
| **margin** | `margin: 32px` | `margin: clamp(16px, 2.22vw, 32px)` |
| **font-size** | `font-size: 32px` | `font-size: clamp(20px, 2.22vw, 32px)` |
| **border-radius** | `border-radius: 12px` | Keep fixed — small decorative values OK |
| **border-width** | `border: 2px` | Keep fixed — stroke widths are fine as-is |
| **icon size** | `width: 24px; height: 24px` | Keep fixed — icons are intentionally fixed |

### clamp() Formula

```
clamp(MIN, PREFERRED, MAX)

PREFERRED = (figma_value / figma_canvas_width) * 100vw
MIN       = figma_value * 0.5   (half of original, minimum usable size)
MAX       = figma_value         (original Figma value = upper bound)
```

**Example — Figma canvas is 1440px wide, gap is 24px:**
```
PREFERRED = (24 / 1440) * 100 = 1.67vw
MIN       = 12px
MAX       = 24px
→ gap: clamp(12px, 1.67vw, 24px)
```

**Example — padding is 48px on 1440px canvas:**
```
PREFERRED = (48 / 1440) * 100 = 3.33vw
MIN       = 24px
MAX       = 48px
→ padding: clamp(24px, 3.33vw, 48px)
```

### Proportional Width with flex / grid (preferred over clamp for columns)

Instead of fixed widths on child elements, use **flex proportions** or **CSS Grid fr units**:

```css
/* ❌ WRONG */
.sidebar { width: 280px; }
.main-content { width: 920px; }

/* ✅ CORRECT — proportion preserved (280:920 ≈ 23%:77%) */
.layout {
    display: flex;
    gap: clamp(16px, 1.67vw, 24px);
}
.sidebar { flex: 0 0 23%; }          /* or flex-basis: 23% */
.main-content { flex: 1; }           /* takes remaining space */

/* ✅ CORRECT — CSS Grid alternative */
.layout {
    display: grid;
    grid-template-columns: 23fr 77fr;  /* ratio from Figma */
    gap: clamp(16px, 1.67vw, 24px);
}
```

**For card grids — use auto-fill/auto-fit:**
```css
/* ❌ WRONG */
.card-grid { gap: 24px; }
.card { width: 380px; height: 260px; }

/* ✅ CORRECT */
.card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(clamp(240px, 26vw, 380px), 1fr));
    gap: clamp(12px, 1.67vw, 24px);
}
.card {
    width: 100%;                    /* fills grid cell */
    aspect-ratio: 38 / 26;         /* preserves height proportion */
}
```

### Height Handling

- **Fixed heights → use `aspect-ratio` or `min-height`** (never lock height in px for containers)
- **Image containers → always use `aspect-ratio`**
- **Text containers → never fix height**, let content determine height

```css
/* ❌ WRONG */
.hero { height: 480px; }
.card-image-wrap { height: 200px; }

/* ✅ CORRECT */
.hero {
    min-height: clamp(240px, 33.3vw, 480px);
    height: auto;
}
.card-image-wrap {
    aspect-ratio: 16 / 9;   /* or whatever ratio from Figma */
    width: 100%;
    overflow: hidden;
}
.card-image-wrap img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
```

### CSS Custom Properties for Scale Tokens

Define viewport-aware scale tokens at `:host` level to keep all fluid values in one place:

```css
:host {
    /* ── Scale tokens (fluid, based on 1440px canvas) ── */
    --scale-gap-sm:  clamp(8px,  0.83vw, 12px);
    --scale-gap-md:  clamp(12px, 1.67vw, 24px);
    --scale-gap-lg:  clamp(20px, 2.78vw, 40px);

    --scale-pad-sm:  clamp(12px, 1.67vw, 24px);
    --scale-pad-md:  clamp(24px, 3.33vw, 48px);
    --scale-pad-lg:  clamp(32px, 4.44vw, 64px);

    --scale-text-sm: clamp(12px, 1vw,    14px);
    --scale-text-md: clamp(14px, 1.11vw, 16px);
    --scale-text-lg: clamp(18px, 1.67vw, 24px);
    --scale-text-xl: clamp(24px, 2.22vw, 32px);
}

/* Usage */
.container {
    padding: var(--scale-pad-md);
    gap: var(--scale-gap-md);
}
h2 {
    font-size: var(--scale-text-xl);
}
```

### Detection Checklist — Values Claude MUST Convert

When reading Figma design context, Claude scans for **all occurrences** of these and converts each one:

```
SCAN AND CONVERT:
  ✦ width: <number>px      → % / fr / clamp / 100% (context-dependent)
  ✦ height: <number>px     → aspect-ratio / min-height / auto
  ✦ gap: <number>px        → clamp(...)
  ✦ padding: <number>px    → clamp(...)
  ✦ margin: <number>px     → clamp(...)
  ✦ font-size: <number>px  → clamp(...)
  ✦ column-gap: <number>px → clamp(...)
  ✦ row-gap: <number>px    → clamp(...)

DO NOT CONVERT (keep fixed):
  ✦ border-width (e.g., border: 1px solid)
  ✦ border-radius (small decorative values)
  ✦ icon width/height (e.g., 16px, 20px, 24px)
  ✦ outline / box-shadow offsets
  ✦ min-width / max-width constraints used as guards
```

### Full Example — Before and After

**Figma values (1440px canvas):**
- Container padding: `48px`
- Card gap: `24px`
- Card width: `380px`, height: `260px`
- Heading font-size: `32px`
- Sidebar width: `280px`

```css
/* ❌ BEFORE — direct Figma copy */
.container { padding: 48px; }
.card-grid { gap: 24px; }
.card { width: 380px; height: 260px; }
.heading { font-size: 32px; }
.sidebar { width: 280px; }
.main { width: 920px; }

/* ✅ AFTER — proportional scaling */
:host {
    --canvas: 1440; /* reference canvas width */
}

.container {
    padding: clamp(24px, 3.33vw, 48px);      /* 48/1440*100 = 3.33vw */
}

.card-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(clamp(240px, 26.4vw, 380px), 1fr));
    gap: clamp(12px, 1.67vw, 24px);           /* 24/1440*100 = 1.67vw */
}

.card {
    width: 100%;
    aspect-ratio: 380 / 260;                  /* exact ratio from Figma */
}

.heading {
    font-size: clamp(20px, 2.22vw, 32px);    /* 32/1440*100 = 2.22vw */
}

.layout {
    display: flex;
    gap: clamp(12px, 1.67vw, 24px);
}
.sidebar {
    flex: 0 0 19.4%;                          /* 280/1440*100 = 19.4% */
}
.main {
    flex: 1;
}
```

---

### Standard Breakpoints

```css
/* Define breakpoints — add at the top of CSS file */
:host {
    /* Breakpoint variables */
    --bp-mobile:  480px;
    --bp-tablet:  768px;
    --bp-desktop: 1024px;
    --bp-wide:    1280px;
}
```

### CSS Media Queries for LWC

```css
/* ── Mobile first: base styles = mobile layout ── */
.container {
    display: flex;
    flex-direction: column;
    padding: var(--lwc-spacingSmall, 0.5rem);
    gap: var(--lwc-spacingSmall, 0.5rem);
}

.sidebar { display: none; }  /* Hide sidebar on mobile */
.nav-bottom { display: flex; } /* Show bottom nav on mobile */

/* ── Tablet (≥ 768px) ── */
@media (min-width: 768px) {
    .container {
        padding: var(--lwc-spacingMedium, 1rem);
        gap: var(--lwc-spacingMedium, 1rem);
    }
    .nav-bottom { display: none; }
}

/* ── Desktop (≥ 1024px) ── */
@media (min-width: 1024px) {
    .container {
        flex-direction: row;
        padding: var(--lwc-spacingLarge, 1.5rem);
    }
    .sidebar {
        display: block;
        width: 280px;
        flex-shrink: 0;
    }
    .main-content { flex: 1; }
}

/* ── Wide screen (≥ 1280px) ── */
@media (min-width: 1280px) {
    .container {
        max-width: 1440px;
        margin: 0 auto;
    }
}
```

### Responsive in JavaScript (detect viewport)

```javascript
// componentName.js
import { LightningElement, track } from 'lwc';

export default class ComponentName extends LightningElement {
    @track isMobile = false;
    @track isTablet = false;
    @track isDesktop = false;

    _resizeObserver;

    connectedCallback() {
        this.detectViewport();
        // Listen for size changes
        this._resizeObserver = new ResizeObserver(() => this.detectViewport());
        this._resizeObserver.observe(document.body);
    }

    disconnectedCallback() {
        if (this._resizeObserver) {
            this._resizeObserver.disconnect();
        }
    }

    detectViewport() {
        const width = window.innerWidth;
        this.isMobile  = width < 768;
        this.isTablet  = width >= 768 && width < 1024;
        this.isDesktop = width >= 1024;
    }

    get viewportClass() {
        if (this.isMobile)  return 'viewport--mobile';
        if (this.isTablet)  return 'viewport--tablet';
        return 'viewport--desktop';
    }
}
```

### Conditional rendering by viewport in HTML

```html
<template>
    <div class={viewportClass}>

        <!-- Show on desktop only (from Web UI Figma) -->
        <template if:true={isDesktop}>
            <div class="sidebar">
                <!-- Sidebar layout from Web UI -->
            </div>
        </template>

        <!-- Main layout — responsive via CSS -->
        <div class="main-content">
            <!-- Shared content for both viewports -->
        </div>

        <!-- Show on mobile only (from Mobile UI Figma) -->
        <template if:true={isMobile}>
            <div class="nav-bottom">
                <!-- Bottom navigation from Mobile UI -->
            </div>
        </template>

    </div>
</template>
```

### SLDS Responsive Grid

```html
<!-- Use SLDS grid to auto-scale columns -->
<div class="slds-grid slds-wrap slds-gutters">
    <!-- Desktop: 3 cols | Tablet: 2 cols | Mobile: 1 col -->
    <div class="slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-3">
        <!-- Card item -->
    </div>
</div>
```

---

## Step 7 — Mapping Figma → LWC

| Figma Element | LWC Equivalent |
|---------------|----------------|
| Frame/Group | `<div>` with flex/grid CSS |
| Auto Layout (row) | `display: flex; flex-direction: row` |
| Auto Layout (column) | `display: flex; flex-direction: column` |
| Button | `<lightning-button>` |
| Input field | `<lightning-input>` |
| Dropdown | `<lightning-combobox>` |
| Card | `<lightning-card>` |
| Icon | `<lightning-icon icon-name="utility:check">` |
| Badge | `<lightning-badge>` |
| Modal | `<lightning-modal>` (API 55+) |
| Data table | `<lightning-datatable>` |
| Tab | `<lightning-tabset>` + `<lightning-tab>` |
| Text | `<p>`, `<span>`, `<h1>-<h6>` with SLDS typography |
| Image | `<img>` with static resource |

---
 
## Step 8 — Handle Images and SVG Icons in LWC

### Asset handling from Static Resource folder

**IMPORTANT:** Both **raster images** and **SVG icons** are stored in the same Static Resource folder. All assets use the same import.

| Asset Type | Source | Output in LWC |
|------------|--------|---------------|
| **Raster images** (jpg, png, webp) | Existing Static Resource folder | `<img src={imageUrl}>` |
| **SVG icons** | Existing Static Resource folder | `<img src={iconUrl}>` |
| **Background image** | Existing Static Resource folder | `style={bgStyle}` + JS getter |

---

### Ask user for existing Static Resource folder path

Before writing code, ask user:
> "What is the **folder path** on your computer where images and SVG icons are stored?
> _(Example: `C:\Projects\salesforce\staticresources\myComponentAssets` or `/Users/name/salesforce/staticresources/myComponentAssets`)_"

**Extract Static Resource name from path:**
- Path: `C:\Projects\salesforce\staticresources\myComponentAssets` → Static Resource name: `myComponentAssets`
- Path: `/Users/name/salesforce/staticresources\productAssets` → Static Resource name: `productAssets`
- Path: `C:\Dev\sf\staticresources\icons` → Static Resource name: `icons`

The **last folder name in the path** is the Static Resource name used in Salesforce.

---

### Handle all assets from existing folder

**JavaScript — import Static Resource and reference all assets:**
```javascript
import { LightningElement } from 'lwc';
// Static Resource name extracted from folder path
import ASSETS from '@salesforce/resourceUrl/myComponentAssets';

export default class ComponentName extends LightningElement {
    // Raster images from Static Resource folder
    bannerUrl = `${ASSETS}/banner.jpg`;
    logoUrl = `${ASSETS}/logo.png`;
    productImageUrl = `${ASSETS}/product-image-1.jpg`;
    
    // SVG icons from Static Resource folder
    iconSearchUrl = `${ASSETS}/icon-search.svg`;
    iconMenuUrl = `${ASSETS}/icon-menu.svg`;
    iconFileEditUrl = `${ASSETS}/icon-file-edit.svg`;
    iconHeartUrl = `${ASSETS}/icon-heart.svg`;
    iconArrowUrl = `${ASSETS}/icon-arrow.svg`;
    
    // Background images (used in inline style)
    get heroBgStyle() {
        return `background-image: url(${this.bannerUrl}); background-size: cover;`;
    }
}
```

**HTML — use both raster images and SVG icons:**
```html
<template>
    <header class="main-header">
        <!-- Logo (raster image from Static Resource) -->
        <img src={logoUrl} alt="Company Logo" class="logo" />
        
        <!-- Search icon (SVG from Static Resource) -->
        <button class="search-btn">
            <img src={iconSearchUrl} alt="Search" class="icon" />
        </button>
        
        <!-- Menu icon (SVG from Static Resource) -->
        <button class="menu-btn">
            <img src={iconMenuUrl} alt="Menu" class="icon" />
        </button>
    </header>
    
    <!-- Hero section with background image -->
    <div class="hero" style={heroBgStyle}>
        <h1>Hero Title</h1>
    </div>
    
    <!-- Product card -->
    <div class="product-card">
        <img src={productImageUrl} alt="Product" class="card-image" />
        
        <div class="card-content">
            <h3>Product Title</h3>
            <p>Product description here</p>
            
            <div class="card-actions">
                <!-- Button with SVG icon from Static Resource -->
                <button class="btn-primary">
                    <img src={iconArrowUrl} alt="" class="icon-small" />
                    Add to Cart
                </button>
                
                <!-- Icon button with SVG from Static Resource -->
                <button class="btn-icon" aria-label="Add to favorites">
                    <img src={iconHeartUrl} alt="" class="icon-small" />
                </button>
            </div>
        </div>
    </div>
    
    <!-- File edit button with SVG icon -->
    <button class="edit-btn">
        <img src={iconFileEditUrl} alt="Edit" class="icon-mini" />
    </button>
</template>
```

**CSS — styling for images and SVG icons:**
```css
/* componentName.css */

/* Logo */
.logo {
    width: 120px;
    height: auto;
}

/* Product images */
.card-image {
    width: 100%;
    height: auto;
    object-fit: cover;
}

/* SVG icon sizes */
.icon {
    width: 24px;
    height: 24px;
}

.icon-small {
    width: 20px;
    height: 20px;
}

.icon-mini {
    width: 16px;
    height: 16px;
}

/* Icon containers */
button img,
a img {
    display: inline-block;
    vertical-align: middle;
}

/* Icon colors - SVG can inherit color via CSS filter or use default SVG colors */
.search-btn .icon {
    /* SVG will use its own colors from the file */
}

/* Background image styling */
.hero {
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    min-height: 400px;
}

/* Responsive icon sizes */
@media (max-width: 768px) {
    .icon {
        width: 20px;
        height: 20px;
    }
    
    .icon-small {
        width: 18px;
        height: 18px;
    }
}
```

---

### Important notes about Static Resource assets

**✅ Advantages:**
- All assets (images + SVG) in one location
- Easy to manage and deploy
- Works offline in Salesforce
- Consistent approach for all asset types

**📁 Folder structure example:**
```
staticresources/
└── myComponentAssets/
    ├── banner.jpg
    ├── logo.png
    ├── product-image-1.jpg
    ├── icon-search.svg
    ├── icon-menu.svg
    ├── icon-file-edit.svg
    ├── icon-heart.svg
    └── icon-arrow.svg
```

**⚠️ Important:**
- File names must match exactly in JavaScript
- SVG files keep their colors and styling from the design tool
- Use descriptive file names (e.g., `icon-search.svg` not `icon1.svg`)
- Static Resource has **5MB size limit** — compress large images if needed

---

### Summary

- **Both raster images AND SVG icons** → Use from same Static Resource folder
- **Single import** → `import ASSETS from '@salesforce/resourceUrl/...'`
- **Static Resource name** → Auto-extracted from folder path (last folder name)
- **All assets** → Reference via `${ASSETS}/filename.ext`
- **No inline SVG** → All SVG files stored in Static Resource folder
- **SLDS icons** → Prefer `<lightning-icon>` if available in SLDS for standard icons

---

### Handle raster images from existing folder

**JavaScript — import Static Resource and reference images:**
```javascript
import { LightningElement } from 'lwc';
import ASSETS from '@salesforce/resourceUrl/myComponentAssets';

export default class ComponentName extends LightningElement {
    // Reference images from existing Static Resource folder
    // File names must match actual files in the folder user provided
    bannerUrl = `${ASSETS}/banner.jpg`;
    logoUrl = `${ASSETS}/logo.png`;
    productImageUrl = `${ASSETS}/product-image-1.jpg`;
    
    // Background images (used in inline style)
    get heroBgStyle() {
        return `background-image: url(${this.bannerUrl}); background-size: cover;`;
    }
}
```

**HTML — use raster images:**
```html
<template>
    <header class="main-header">
        <!-- Logo (raster image from Static Resource) -->
        <img src={logoUrl} alt="Company Logo" class="logo" />
    </header>
    
    <!-- Hero section with background image -->
    <div class="hero" style={heroBgStyle}>
        <h1>Hero Title</h1>
    </div>
    
    <!-- Product image -->
    <div class="product-card">
        <img src={productImageUrl} alt="Product" />
    </div>
</template>
```

---

## Step 9 — Create Metadata File

**Before creating .js-meta.xml file, always ask user for apiVersion:**

> "What **apiVersion** would you like to use?
> _(Press Enter or leave blank to use default apiVersion **65.0**)_"

**Handle user response:**
- If user provides a number (e.g., `68.0`, `67`, `66`) → use that value
- If user presses Enter or leaves blank → use default `65.0`
- Auto-add `.0` if user only provides integer (e.g., `67` → `67.0`)

**Create metadata file with user's apiVersion:**

```xml
<!-- componentName.js-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>65.0</apiVersion>  <!-- Replace with user's input or default 65.0 -->
    <isExposed>true</isExposed>
    <targets>
        <target>lightningCommunity__Page</target>
        <target>lightningCommunity__Default</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <property name="title" type="String" label="Title" default="My Component"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

**Examples:**
- User inputs `68.0` → `<apiVersion>68.0</apiVersion>`
- User inputs `67` → `<apiVersion>67.0</apiVersion>` (auto-add `.0`)
- User presses Enter → `<apiVersion>65.0</apiVersion>` (default)
- User leaves blank → `<apiVersion>65.0</apiVersion>` (default)

---
 
## Step 10 — Output
 
Create LWC files in `/mnt/user-data/outputs/` following Salesforce structure:
 
```
outputs/
└── lwc/
    └── {componentName}/
        ├── {componentName}.html
        ├── {componentName}.js
        ├── {componentName}.css
        └── {componentName}.js-meta.xml
```

**Note:** Static Resource folder already exists on user's computer. No need to create it.
 
Then use `present_files` to deliver all files to user.

---

## Important Notes

- **🔒 Faithful to Figma** — Reproduce exactly: text, colors, spacing, element order. Do not change, add, or remove any information. Only exception: adjust responsive by viewport.
- **Don't use `document.querySelector`** — use `this.template.querySelector`
- **Don't import external libraries** (jQuery, Bootstrap) — LWC sandbox doesn't allow
- **Always handle errors** in async calls
- **`@api` props must be primitive** or plain object, avoid direct mutation
- **CSS don't use `!important`** — use `:host` specificity
- **Component name is camelCase** (e.g., `myAccountCard`), Salesforce auto-converts to kebab-case in HTML
- **Comment truly important functions**
- **HTML comments to distinguish between sections**

---

## Quick Reference — SLDS Utility Classes

```
slds-p-around_{size}     → padding all sides
slds-m-bottom_{size}     → margin-bottom
slds-text-heading_medium → typography heading
slds-theme_default       → default white background
slds-box                 → card-like container
slds-grid                → flexbox grid
slds-col                 → grid column
slds-size_{n}-of-{total} → responsive width (e.g., slds-size_1-of-2)
```

Sizes: `xxx-small` | `xx-small` | `x-small` | `small` | `medium` | `large` | `x-large`