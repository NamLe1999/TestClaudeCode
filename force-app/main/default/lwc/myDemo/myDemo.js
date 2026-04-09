import { LightningElement, track } from 'lwc';
import ASSETS from '@salesforce/resourceUrl/gdc_TestSkill';

export default class MyDemo extends LightningElement {
    @track isDesktop = false;

    bannerUrl       = `${ASSETS}/bannerImg.png`;
    fileEditUrl     = `${ASSETS}/file-edit.svg`;
    fileSearchUrl   = `${ASSETS}/file-search.svg`;
    messageTextUrl  = `${ASSETS}/message-text.svg`;
    hourglassUrl    = `${ASSETS}/hourglass.svg`;
    thumbUpUrl      = `${ASSETS}/thumb-up.svg`;
    polygonUrl      = `${ASSETS}/polygon.svg`;
    arrowUrl        = `${ASSETS}/arrow.svg`;

    positions = [
        {
            id: '1',
            title: 'Administrator',
            badge: '경력 모집',
            fields: [
                { id: '1-1', label: 'Employment Type',       value: 'Full-time' },
                { id: '1-2', label: 'Experience Level',      value: 'Experienced' },
                { id: '1-3', label: 'Job Position',          value: 'Administrator' },
                { id: '1-4', label: 'Educatioal Background', value: 'No specific requirement' }
            ],
            jobDescription: 'Business process analysis and Salesforce solution administration (BA)'
        },
        {
            id: '2',
            title: 'Developer',
            badge: '경력 모집',
            fields: [
                { id: '2-1', label: 'Employment Type',       value: 'Full-time' },
                { id: '2-2', label: 'Experience Level',      value: 'Experienced' },
                { id: '2-3', label: 'Job Position',          value: 'Developer' },
                { id: '2-4', label: 'Educatioal Background', value: 'No specific requirement' }
            ],
            jobDescription: 'Salesforce interface customization and system integration with external platforms'
        },
        {
            id: '3',
            title: 'PM',
            badge: '경력 모집',
            fields: [
                { id: '3-1', label: 'Employment Type',       value: 'Full-time' },
                { id: '3-2', label: 'Experience Level',      value: 'Experienced' },
                { id: '3-3', label: 'Job Position',          value: 'PM' },
                { id: '3-4', label: 'Educatioal Background', value: 'No specific requirement' }
            ],
            jobDescription: 'Project Manager for cloud-based system design and development'
        }
    ];

    get viewportClass() {
        return this.isDesktop ? 'body viewport--desktop' : 'body viewport--mobile';
    }

    _resizeObserver;

    connectedCallback() {
        this._detectViewport();
        this._resizeObserver = new ResizeObserver(() => this._detectViewport());
        this._resizeObserver.observe(document.body);
    }

    disconnectedCallback() {
        if (this._resizeObserver) {
            this._resizeObserver.disconnect();
        }
    }

    _detectViewport() {
        this.isDesktop = window.innerWidth >= 1024;
    }
}
