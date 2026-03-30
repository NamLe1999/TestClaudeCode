import { LightningElement, track } from 'lwc';

export default class TestClaude extends LightningElement {
    @track jobs = [
        {
            id: 'sf-admin',
            title: 'Salesforce Administrator',
            isExpanded: true,
            responsibilities: [
                { id: 'r1', text: 'Analyze client business requirements' },
                { id: 'r2', text: 'Design Salesforce solutions and develop optimization strategies' },
                { id: 'r3', text: 'Provide user training and adoption support' }
            ],
            responsibilitiesCol2: [],
            qualifications: [
                { id: 'q1', text: 'Ability to design functional models across Salesforce services' },
                { id: 'q2', text: 'Business process analysis and documentation skills' },
                { id: 'q3', text: 'Strong client communication and training capabilities' }
            ]
        },
        {
            id: 'sf-dev',
            title: 'Salesforce Developer',
            isExpanded: true,
            responsibilities: [
                { id: 'r1', text: 'Design and develop cloud-based applications' },
                { id: 'r2', text: 'Customize and implement Salesforce platforms (CRM, Service Cloud, etc.)' },
                { id: 'r3', text: 'Integrate APIs and build/maintain backend services' }
            ],
            responsibilitiesCol2: [],
            qualifications: [
                { id: 'q1', text: 'Proficiency in Salesforce technologies such as JavaScript, Apex, and SOQL' },
                { id: 'q2', text: 'Understanding of REST APIs and cloud services' },
                { id: 'q3', text: 'Strong problem-solving skills and collaborative communication' },
                { id: 'q4', text: 'Ability to measure and analyze performance' },
                { id: 'q5', text: 'Deliver CRM functionalities that meet client requirements' },
                { id: 'q6', text: 'Improve service quality, fix bugs, and conduct testing' }
            ]
        },
        {
            id: 'sales-rep',
            title: 'Sales Representative',
            isExpanded: true,
            responsibilities: [
                { id: 'r1', text: 'Identify and acquire new B2B clients and partners' },
                { id: 'r2', text: 'Propose Salesforce, cloud, and IT consulting solutions' },
                { id: 'r3', text: 'Understand client needs and prepare customized proposals and quotations' }
            ],
            responsibilitiesCol2: [
                { id: 'r4', text: 'Lead contract negotiations and manage deal closures' },
                { id: 'r5', text: 'Maintain client relationships and identify upselling opportunities' },
                { id: 'r6', text: 'Manage client communication and issue resolution during projects' }
            ],
            qualifications: []
        },
        { id: 'sf-pm',  title: 'Salesforce PM', isExpanded: false, responsibilities: [], responsibilitiesCol2: [], qualifications: [] },
        { id: 'sf-ba',  title: 'Salesforce BA', isExpanded: false, responsibilities: [], responsibilitiesCol2: [], qualifications: [] },
        { id: 'sf-se',  title: 'Salesforce SE', isExpanded: false, responsibilities: [], responsibilitiesCol2: [], qualifications: [] },
        { id: 'sf-ae',  title: 'Salesforce AE', isExpanded: false, responsibilities: [], responsibilitiesCol2: [], qualifications: [] }
    ];

    get jobsWithMeta() {
        return this.jobs.map(job => ({
            ...job,
            cardClass: job.isExpanded ? 'job-card job-card--expanded' : 'job-card',
            chevronClass: job.isExpanded ? 'job-card__chevron' : 'job-card__chevron job-card__chevron--collapsed',
            hasQualifications: job.qualifications.length > 0,
            hasResponsibilitiesCol2: job.responsibilitiesCol2.length > 0
        }));
    }

    handleToggle(event) {
        const jobId = event.currentTarget.dataset.jobId;
        this.jobs = this.jobs.map(job =>
            job.id === jobId ? { ...job, isExpanded: !job.isExpanded } : job
        );
    }

    handleViewInterview(event) {
        const jobId = event.currentTarget.dataset.jobId;
        this.dispatchEvent(new CustomEvent('viewinterview', {
            detail: { jobId },
            bubbles: true,
            composed: true
        }));
    }

    handleApply(event) {
        const jobId = event.currentTarget.dataset.jobId;
        this.dispatchEvent(new CustomEvent('apply', {
            detail: { jobId },
            bubbles: true,
            composed: true
        }));
    }
}
