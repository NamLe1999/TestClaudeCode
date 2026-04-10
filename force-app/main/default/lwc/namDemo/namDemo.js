import { LightningElement, track } from 'lwc';
import ASSETS from '@salesforce/resourceUrl/gdc_TestSkill';

export default class NamDemo extends LightningElement {

    // ── Viewport state ──────────────────────────────────────
    @track _viewportWidth = typeof window !== 'undefined' ? window.innerWidth : 0;

    get isMobile()  { return this._viewportWidth < 768; }
    get isDesktop() { return this._viewportWidth >= 1024; }

    get viewportClass() {
        if (this.isDesktop) return 'namdemo-root viewport--desktop';
        return 'namdemo-root viewport--mobile'; // mobile + tablet (<1024px)
    }

    // ── Hero background (desktop only) ──────────────────────
    // Actual file in gdc_TestSkill: bannerImg.png
    heroBgUrl = `${ASSETS}/bannerImg.png`;

    get heroBgStyle() {
        return `background-image: url(${this.heroBgUrl});`;
    }

    // ── Desktop decorative ellipses for value cards ──────────
    // NOTE: These files do not yet exist in gdc_TestSkill.
    // Add ellipse1.png – ellipse5.png to the static resource folder.
    ellipse1Url = `${ASSETS}/ellipse1.png`;
    ellipse2Url = `${ASSETS}/ellipse2.png`;
    ellipse3Url = `${ASSETS}/ellipse3.png`;
    ellipse4Url = `${ASSETS}/ellipse4.png`;
    ellipse5Url = `${ASSETS}/ellipse5.png`;

    // ── Mobile decorative ellipses for value cards ───────────
    // NOTE: These files do not yet exist in gdc_TestSkill.
    // Add ellipse1-m.png – ellipse6-m.png to the static resource folder.
    mEllipse1Url = `${ASSETS}/ellipse1-m.png`;
    mEllipse2Url = `${ASSETS}/ellipse2-m.png`;
    mEllipse3Url = `${ASSETS}/ellipse3-m.png`;
    mEllipse4Url = `${ASSETS}/ellipse4-m.png`;
    mEllipse5Url = `${ASSETS}/ellipse5-m.png`;
    mEllipse6Url = `${ASSETS}/ellipse6-m.png`;

    // ── Recruitment process step icons ───────────────────────
    // File names match actual files in gdc_TestSkill (no "icon-" prefix)
    iconFileEditUrl    = `${ASSETS}/file-edit.svg`;
    iconPolygonUrl     = `${ASSETS}/polygon.svg`;
    iconFileSearchUrl  = `${ASSETS}/file-search.svg`;
    iconMessageTextUrl = `${ASSETS}/message-text.svg`;
    iconHourglassUrl   = `${ASSETS}/hourglass.svg`;
    iconThumbUpUrl     = `${ASSETS}/thumb-up.svg`;

    // ── Apply button arrow ───────────────────────────────────
    iconArrowUrl = `${ASSETS}/arrow.svg`;

    // ── Lifecycle ────────────────────────────────────────────
    _resizeObserver;

    connectedCallback() {
        this._updateViewport();
        this._resizeObserver = new ResizeObserver(() => this._updateViewport());
        this._resizeObserver.observe(document.body);
    }

    disconnectedCallback() {
        if (this._resizeObserver) {
            this._resizeObserver.disconnect();
        }
    }

    _updateViewport() {
        this._viewportWidth = window.innerWidth;
    }
}
