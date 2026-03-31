---
name: daeu-figma-to-lwc
description: "Convert Figma designs into Lightning Web Components (LWC) for Salesforce. Use this skill whenever the user wants to read a Figma file and generate LWC code, translate UI designs into Salesforce components, convert mockups or wireframes into .html/.js/.css LWC files, or asks anything involving Figma and LWC, design to Salesforce component, Figma to component, or thiet ke Figma sang LWC. Always trigger this skill when Figma design context is combined with any mention of LWC, Salesforce, or web components."
---

# Figma → Lightning Web Component (LWC)

## Tổng quan

Skill này hướng dẫn Claude đọc thiết kế từ Figma (qua Figma MCP) và chuyển đổi thành Lightning Web Component chuẩn Salesforce — bao gồm file `.html`, `.js`, `.css`, và `.js-meta.xml`.

---

## Bước 1 — Nhận URL Figma (Web UI + Mobile UI)

User cần cung cấp **2 URL Figma** riêng biệt:

| Loại | Mô tả | Ví dụ URL |
|------|-------|-----------|
| **Web UI** 	| Thiết kế cho màn hình desktop 	| `@https://www.figma.com/design/xxx/...?node-id=1-1` |
| **Mobile UI** | Thiết kế cho màn hình điện thoại 	| `@https://www.figma.com/design/xxx/...?node-id=1-2` |

### Cách trích xuất `nodeId` từ URL Figma

```
URL: @https://www.figma.com/design/NIvfVEYEUQPyAdDPoNj4hG/-%EB%8C%80%EC%9C%A0%EB%84%A5%EC%8A%A4%ED%8B%B0%EC%96%B4--Design-type-_%EA%B3%B5%EC%9C%A0%EC%9A%A9--%EB%B3%B5%EC%82%AC-?node-id=2689-36710&m=dev
											↑																																	     ↑
							fileKey = "NIvfVEYEUQPyAdDPoNj4hG"																												nodeId = "2689-36710"
```

Nếu user chỉ cung cấp 1 URL, hỏi lại:
> "Bạn có URL Figma cho **Mobile UI** không? Nếu không có, tôi sẽ tự suy luận layout mobile từ Web UI."

### Đọc cả 2 node song song

Luôn gọi `tool_search` trước:
```
tool_search(query="figma get design context screenshot")
```

Sau đó gọi **đồng thời** cho cả 2 URL:

```
// Web UI
Figma:get_screenshot(nodeId="<webNodeId>")
Figma:get_design_context(nodeId="<webNodeId>")

// Mobile UI
Figma:get_screenshot(nodeId="<mobileNodeId>")
Figma:get_design_context(nodeId="<mobileNodeId>")

// Design tokens (tùy chọn, dùng chung)
Figma:get_variable_defs(nodeId="<webNodeId>")
```

### Đặt tên Component
 
Xử lý tên component theo thứ tự ưu tiên sau:
 
**1. User đã cung cấp tên** (trong câu lệnh ban đầu)
→ Dùng trực tiếp, convert sang đúng format LWC:
 
| Input của user 	| Tên thư mục / class 	| Tag trong HTML |
|-------------------|-----------------------|----------------|
| `AccountCard` 	| `accountCard` 		| `<c-account-card>` |
| `account-card` 	| `accountCard` 		| `<c-account-card>` |
| `My Account Card` | `myAccountCard` 		| `<c-my-account-card>` |
| `gdc_ContactUs` 	| `gdc_ContactUs` 		| `<c-gdc_-contact-us>` |
 
**2. User không cung cấp tên** → Hỏi lại:
> "Bạn muốn đặt tên gì cho component này?
> _(Nhấn Enter hoặc gõ **bỏ qua** để tôi tự chọn tên phù hợp từ thiết kế Figma)_"
 
**3. User bỏ qua** → Tự suy luận tên từ Figma:
- Ưu tiên lấy tên **layer/frame** của node trong Figma (từ `get_design_context`)
- Nếu tên layer không rõ nghĩa (vd: `Frame 42`, `Group 7`) → đặt tên dựa theo **nội dung thiết kế** (vd: `productCard`, `loginForm`, `navHeader`)
- Thông báo cho user: _"Tôi sẽ đặt tên component là `productCard` dựa theo thiết kế. Bạn có thể đổi tên sau."_
 
**Quy tắc đặt tên LWC:**
- Dùng **camelCase** cho tên thư mục và class
- Chỉ dùng **chữ cái, số** — không dấu cách, không ký tự đặc biệt
- Không bắt đầu bằng số
- Không dùng từ reserved: `component`, `lwc`, `salesforce`
 
---

### So sánh 2 thiết kế

Sau khi đọc xong, lập bảng diff giữa Web và Mobile:

| 		Yếu tố 		| 		Web UI 		| 		Mobile UI 		|
|-------------------|-------------------|-----------------------|
| Layout 			| Grid nhiều cột 	| Single column 		|
| Navigation 		| Sidebar / Top nav | Bottom tab bar 		|
| Font size 		| Base 16px 		| Base 14px 			|
| Spacing 			| Rộng hơn 			| Compact hơn 			|
| Ẩn/hiện elements 	| Hiển thị đầy đủ 	| Một số element bị ẩn 	|

---

## Bước 2 — Scale UI theo Viewport (Responsive)

Dựa trên 2 thiết kế Figma, xây dựng hệ thống breakpoint thống nhất trong LWC.

### Breakpoints chuẩn

```css
/* Định nghĩa breakpoints — thêm vào đầu CSS file */
:host {
    /* Breakpoint variables */
    --bp-mobile:  480px;
    --bp-tablet:  768px;
    --bp-desktop: 1024px;
    --bp-wide:    1280px;
}
```

### CSS Media Queries cho LWC

```css
/* ── Mobile first: base styles = mobile layout ── */
.container {
    display: flex;
    flex-direction: column;
    padding: var(--lwc-spacingSmall, 0.5rem);
    gap: var(--lwc-spacingSmall, 0.5rem);
}

.sidebar { display: none; }  /* Ẩn sidebar trên mobile */
.nav-bottom { display: flex; } /* Hiện bottom nav trên mobile */

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

### Responsive trong JavaScript (detect viewport)

```javascript
// tenComponent.js
import { LightningElement, track } from 'lwc';

export default class TenComponent extends LightningElement {
    @track isMobile = false;
    @track isTablet = false;
    @track isDesktop = false;

    _resizeObserver;

    connectedCallback() {
        this.detectViewport();
        // Lắng nghe thay đổi kích thước
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

### Conditional rendering theo viewport trong HTML

```html
<template>
    <div class={viewportClass}>

        <!-- Chỉ hiện trên desktop (từ Web UI Figma) -->
        <template if:true={isDesktop}>
            <div class="sidebar">
                <!-- Sidebar layout từ Web UI -->
            </div>
        </template>

        <!-- Layout chính — responsive theo CSS -->
        <div class="main-content">
            <!-- Shared content cho cả 2 viewport -->
        </div>

        <!-- Chỉ hiện trên mobile (từ Mobile UI Figma) -->
        <template if:true={isMobile}>
            <div class="nav-bottom">
                <!-- Bottom navigation từ Mobile UI -->
            </div>
        </template>

    </div>
</template>
```

### SLDS Responsive Grid

```html
<!-- Dùng SLDS grid để tự động scale số cột -->
<div class="slds-grid slds-wrap slds-gutters">
    <!-- Desktop: 3 cột | Tablet: 2 cột | Mobile: 1 cột -->
    <div class="slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-3">
        <!-- Card item -->
    </div>
</div>
```

| SLDS Class 			| Áp dụng khi |
|-----------------------|-------------|
| `slds-size_*` 		| Mọi viewport (mobile first) |
| `slds-small-size_*` 	| ≥ 480px |
| `slds-medium-size_*` 	| ≥ 768px (tablet) |
| `slds-large-size_*` 	| ≥ 1024px (desktop) |

---

## Bước 4 — Phân tích thiết kế chi tiết

Trước khi viết code, xác định:

| Yếu tố | Cần xác định |
|--------|-------------|
| **Component name** | Tên từ Figma hoặc user cung cấp (dùng camelCase cho LWC) |
| **Layout** | Flex / Grid / Fixed? Responsive breakpoints? |
| **Màu sắc** | Hex/RGB values, map sang CSS custom properties |
| **Typography** | Font family, size, weight, line-height |
| **Spacing** | Padding, margin, gap — convert sang `rem` hoặc SLDS tokens |
| **Interactivity** | Buttons, inputs, events nào cần handle? |
| **Data** | Component nhận `@api` props gì? Có `@track` state không? |
| **SLDS** | Có thể dùng Salesforce Lightning Design System classes không? |

---

## Bước 5 — Cấu trúc file LWC

Mỗi LWC gồm 4 file, lưu vào thư mục cùng tên component:

```
force-app/main/default/lwc/
└── tenComponent/
    ├── tenComponent.html       ← Template
    ├── tenComponent.js         ← Controller
    ├── tenComponent.css        ← Styles
    └── tenComponent.js-meta.xml ← Metadata
```

---

## Bước 6 — Viết code

### 4.1 — HTML Template

```html
<!-- tenComponent.html -->
<template>
    <div class="container slds-p-around_medium">
        
        <template if:true={isLoading}>
            <lightning-spinner alternative-text="Loading"></lightning-spinner>
        </template>

        <template for:each={items} for:item="item">
            <div key={item.id} class="item">
                <span>{item.label}</span>
            </div>
        </template>

        <lightning-button 
            label="Submit" 
            onclick={handleSubmit}
            variant="brand">
        </lightning-button>
    </div>
</template>
```

**Quy tắc HTML:**
- Luôn có thẻ `<template>` root
- Dùng `key=` khi dùng `for:each`
- Ưu tiên `<lightning-*>` components thay vì HTML thuần
- Không dùng `id` trùng lặp
- Ưu tiên khả năng tái sử dụng giữa các component

### 4.2 — JavaScript Controller

```javascript
// tenComponent.js
import { LightningElement, api, track, wire } from 'lwc';

export default class TenComponent extends LightningElement {
    @api recordId;
    @api title = 'Default Title';

    @track items = [];
    @track isLoading = false;
    @track errorMessage;

    connectedCallback() {
        this.loadData();
    }

    handleSubmit(event) {
        event.preventDefault();
    }

    fireCustomEvent(payload) {
        const evt = new CustomEvent('myevent', { detail: payload });
        this.dispatchEvent(evt);
    }

    get hasItems() {
        return this.items && this.items.length > 0;
    }

    async loadData() {
        this.isLoading = true;
        try {
            // Gọi Apex hoặc wire
        } catch (error) {
            this.errorMessage = error.message;
        } finally {
            this.isLoading = false;
        }
    }
}
```

### 4.3 — CSS

```css
/* tenComponent.css */
:host {
    display: block;
}

.container {
    padding: var(--lwc-spacingMedium, 1rem);
    background-color: var(--lwc-colorBackgroundAlt, #f3f3f3);
    border-radius: var(--lwc-borderRadiusMedium, 4px);
}

.primary-color {
    color: var(--lwc-brandColorPrimary, #0070d2);
}

@media (max-width: 768px) {
    .container {
        padding: var(--lwc-spacingSmall, 0.5rem);
    }
}
```

**Quy tắc CSS:**
- Dùng `--lwc-*` tokens thay hardcode màu khi có thể
- `:host` thay vì root element class
- CSS tự động scoped, không cần namespace

### 4.4 — Metadata

**Trước khi tạo file metadata, luôn tra cứu API version mới nhất:**
 
```
web_search("Salesforce latest API version <current_year>")
```
 
Đọc kết quả từ trang chính thức `developer.salesforce.com` hoặc release notes Salesforce để xác định version số. Ví dụ: Spring '26 = API 63.0, Summer '26 = API 64.0, v.v. (3 release mỗi năm, mỗi release tăng 1).
 
Sau khi có version, điền vào `<apiVersion>`:
 
```xml
<!-- tenComponent.js-meta.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>{{LATEST_API_VERSION}}</apiVersion>  <!-- Thay bằng version tìm được -->
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <property name="title" type="String" label="Tiêu đề" default="My Component"/>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```
 
> **Lưu ý:** Nếu search không trả về kết quả rõ ràng, dùng version dự phòng `62.0` (Winter '26) và thông báo cho user để họ xác nhận.
---

## Bước 7 — Mapping Figma → LWC

| Figma Element 		| LWC Equivalent |
|-----------------------|----------------|
| Frame/Group 			| `<div>` với flex/grid CSS |
| Auto Layout (row) 	| `display: flex; flex-direction: row` |
| Auto Layout (column) 	| `display: flex; flex-direction: column` |
| Button 				| `<lightning-button>` |
| Input field 			| `<lightning-input>` |
| Dropdown 				| `<lightning-combobox>` |
| Card 					| `<lightning-card>` |
| Icon 					| `<lightning-icon icon-name="utility:check">` |
| Badge 				| `<lightning-badge>` |
| Modal 				| `<lightning-modal>` (API 55+) |
| Data table 			| `<lightning-datatable>` |
| Tab 					| `<lightning-tabset>` + `<lightning-tab>` |
| Text 					| `<p>`, `<span>`, `<h1>-<h6>` với SLDS typography |
| Image 				| `<img>` với static resource |

---
 
## Bước 8 — Xử lý hình ảnh từ Figma → Static Resource
 
### Đặt tên thư mục Static Resource
 
Hỏi user trước khi xử lý ảnh:
> "Bạn muốn đặt tên thư mục Static Resource là gì?
> _(Nhấn Enter hoặc gõ **bỏ qua** để dùng tên mặc định `{componentName}Assets`)_"
 
**Quy tắc đặt tên Static Resource:**
- Chỉ dùng chữ cái, số, dấu gạch dưới (`_`)
- Không dấu cách, không dấu gạch ngang
- Ví dụ hợp lệ: `myAppAssets`, `product_images`, `LoginAssets`
 
---
 
### Phát hiện hình ảnh trong Figma
 
Khi đọc `get_design_context`, **chỉ** lấy các node là ảnh raster (`.png`, `.jpg`, `.jpeg`, `.webp`):
- `IMAGE` — hình ảnh nhúng trực tiếp
- `RECTANGLE` với `fills[].type = "IMAGE"` — shape có fill là ảnh raster
 
**Bỏ qua hoàn toàn:**
- `VECTOR` — file SVG, icon dạng vector
- `COMPONENT` / `INSTANCE` chứa icon SVG
- Bất kỳ node nào export ra `.svg`
 
> **Lý do:** SVG trong Salesforce nên dùng `<lightning-icon>` hoặc inline SVG trong HTML — không lưu vào Static Resource.
 
Dùng `Figma:get_screenshot` để export từng image node raster:
```
Figma:get_screenshot(nodeId="<imageNodeId>")
```
 
---
 
### Cấu trúc thư mục Static Resource
 
Ảnh được lưu tạm vào thư mục, sau đó **đóng gói thành file `.zip`** trước khi deploy lên Salesforce:
 
```
staticresources/
├── {tenThuMuc}.resource-meta.xml   ← Metadata (không nằm trong zip)
└── {tenThuMuc}.zip                 ← File zip chứa toàn bộ ảnh
    ├── banner.png
    ├── product_card_bg.jpg
    └── hero_image.webp
```
 
> **Lưu ý:** Không tạo subfolder bên trong zip — toàn bộ ảnh nằm ở root của zip.
 
**File metadata bắt buộc** (`{tenThuMuc}.resource-meta.xml`):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<StaticResource xmlns="http://soap.sforce.com/2006/04/metadata">
    <cacheControl>Public</cacheControl>
    <contentType>application/zip</contentType>
    <description>Static resources for {componentName} component</description>
</StaticResource>
```
 
---
 
### Đặt tên file ảnh
 
Khi lưu ảnh, đặt tên dựa theo **tên layer trong Figma**:
- Lấy tên layer → convert sang `snake_case`
- Bỏ ký tự đặc biệt, dấu cách thành `_`
- Chỉ chấp nhận extension: `.png`, `.jpg`, `.jpeg`, `.webp`
 
| Tên layer Figma | Tên file lưu |
|----------------|-------------|
| `Hero Banner` | `hero_banner.png` |
| `Product Card BG` | `product_card_bg.jpg` |
| `Profile Photo` | `profile_photo.png` |
| `Background Image` | `background_image.webp` |
 
---
 
### Import và dùng ảnh trong LWC
 
**JavaScript — import Static Resource:**
```javascript
import { LightningElement } from 'lwc';
import ASSETS from '@salesforce/resourceUrl/{tenThuMuc}';
 
export default class TenComponent extends LightningElement {
    // Tạo URL cho từng ảnh
    bannerUrl  = `${ASSETS}/banner.png`;
    logoUrl    = `${ASSETS}/logo.svg`;
    bgUrl      = `${ASSETS}/product_card_bg.jpg`;
}
```
 
**HTML — dùng trong template:**
```html
<template>
    <!-- Ảnh thông thường -->
    <img src={bannerUrl} alt="Hero Banner" />
 
    <!-- Background qua inline style -->
    <div style={cardStyle}></div>
</template>
```
 
**CSS — background image:**
```javascript
// Dùng getter trong JS vì LWC không cho phép template literals trong HTML
get cardStyle() {
    return `background-image: url(${this.bgUrl}); background-size: cover;`;
}
```
 
---
 
### Output Static Resource
 
**Bước 1:** Lưu ảnh vào thư mục tạm:
```bash
mkdir -p /home/claude/staticresources/{tenThuMuc}
# Lưu từng ảnh export từ Figma vào đây
```
 
**Bước 2:** Đóng gói thành file `.zip` bằng Python:
```python
import zipfile
import os
 
folder = "/home/claude/staticresources/{tenThuMuc}"
zip_path = "/mnt/user-data/outputs/staticresources/{tenThuMuc}.zip"
 
os.makedirs(os.path.dirname(zip_path), exist_ok=True)
 
with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
    for filename in os.listdir(folder):
        file_path = os.path.join(folder, filename)
        if os.path.isfile(file_path):
            zf.write(file_path, arcname=filename)  # arcname=filename → ảnh nằm ở root zip
 
print(f"Đã tạo: {zip_path}")
```
 
**Bước 3:** Lưu file metadata ra cùng cấp với zip:
```bash
/mnt/user-data/outputs/staticresources/{tenThuMuc}.resource-meta.xml
```
 
---
 
## Bước 9 — Output
 
Tạo toàn bộ file vào `/mnt/user-data/outputs/` theo đúng cấu trúc Salesforce:
 
```
outputs/
├── lwc/
│   └── {componentName}/
│       ├── {componentName}.html
│       ├── {componentName}.js
│       ├── {componentName}.css
│       └── {componentName}.js-meta.xml
└── staticresources/
    ├── {tenThuMuc}.resource-meta.xml
    └── {tenThuMuc}/
        ├── image1.png
        ├── image2.svg
        └── ...
```
 
Sau đó dùng `present_files` để giao toàn bộ file cho user.

---

## Lưu ý quan trọng

- **Không dùng `document.querySelector`** — dùng `this.template.querySelector`
- **Không import thư viện ngoài** (jQuery, Bootstrap) — LWC sandbox không cho phép
- **Luôn handle error** trong async calls
- **`@api` props phải là primitive** hoặc plain object, tránh mutate trực tiếp
- **CSS không dùng `!important`** — dùng `:host` specificity
- **Tên component là camelCase** (vd: `myAccountCard`), Salesforce tự convert sang kebab-case trong HTML
- **Comment những function thật sự quan trong**
- **Phần HTML comment để có thể phân biệt giữa các section**
---

## Tham khảo nhanh — SLDS Utility Classes

```
slds-p-around_{size}     → padding tất cả các chiều
slds-m-bottom_{size}     → margin-bottom
slds-text-heading_medium → typography heading
slds-theme_default       → nền trắng mặc định
slds-box                 → card-like container
slds-grid                → flexbox grid
slds-col                 → grid column
slds-size_{n}-of-{total} → responsive width (vd: slds-size_1-of-2)
```

Kích thước: `xxx-small` | `xx-small` | `x-small` | `small` | `medium` | `large` | `x-large`