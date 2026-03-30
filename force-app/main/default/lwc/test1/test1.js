import { LightningElement } from 'lwc';

export default class Test1 extends LightningElement {
    heroImageUrl = 'https://www.figma.com/api/mcp/asset/4d16067f-80de-4fd6-bbac-e4b4400be29f';
    ellipse1Url  = 'https://www.figma.com/api/mcp/asset/cf4f2327-54f1-4dee-a4e7-81d104b2293d';
    ellipse2Url  = 'https://www.figma.com/api/mcp/asset/17af3734-a27c-46d8-bf27-304fbc3925e0';
    ellipse3Url  = 'https://www.figma.com/api/mcp/asset/0a036a7b-4249-42bd-85a8-48af652ec6e9';
    ellipse4Url  = 'https://www.figma.com/api/mcp/asset/57bb1284-a2c3-4d27-a7ad-73bad878b828';
    ellipse5Url  = 'https://www.figma.com/api/mcp/asset/c45e0ac3-632a-48ee-aae2-f65f359fa208';
    iconFileEdit = 'https://www.figma.com/api/mcp/asset/fb56a15b-195c-490f-abe4-ddd61be5e2c3';
    iconPolygon  = 'https://www.figma.com/api/mcp/asset/ba1f3a14-8ea2-432d-99b1-be7c86f42317';
    iconFileSearch = 'https://www.figma.com/api/mcp/asset/8d97244d-1a3f-4be5-938f-22b33b421bb2';
    iconMessage  = 'https://www.figma.com/api/mcp/asset/7a59881d-22b8-4635-b747-43f780c164bc';
    iconHourglass = 'https://www.figma.com/api/mcp/asset/6b89828f-f93e-4f9b-b8ea-7ae67982199d';
    iconThumbUp  = 'https://www.figma.com/api/mcp/asset/ea92b694-e7c2-44f5-9ad7-2c77d6801117';
    iconArrow    = 'https://www.figma.com/api/mcp/asset/acb13b84-015c-41aa-9b4b-9d0557129a88';

    get heroStyle() {
        return `background-image: url('${this.heroImageUrl}'); background-size: cover; background-position: center;`;
    }

    positions = [
        {
            id: 1,
            title: 'Administrator',
            badge: '경력 모집',
            fields: [
                { label: 'Employment Type', value: 'Full-time' },
                { label: 'Experience Level', value: 'Experienced' },
                { label: 'Job Position', value: 'Administrator' },
                { label: 'Educational Background', value: 'No specific requirement' }
            ],
            description: 'Business process analysis and Salesforce solution administration (BA)'
        },
        {
            id: 2,
            title: 'Developer',
            badge: '경력 모집',
            fields: [
                { label: 'Employment Type', value: 'Full-time' },
                { label: 'Experience Level', value: 'Experienced' },
                { label: 'Job Position', value: 'Developer' },
                { label: 'Educational Background', value: 'No specific requirement' }
            ],
            description: 'Salesforce interface customization and system integration with external platforms'
        },
        {
            id: 3,
            title: 'PM',
            badge: '경력 모집',
            fields: [
                { label: 'Employment Type', value: 'Full-time' },
                { label: 'Experience Level', value: 'Experienced' },
                { label: 'Job Position', value: 'PM' },
                { label: 'Educational Background', value: 'No specific requirement' }
            ],
            description: 'Project Manager for cloud-based system design and development'
        }
    ];
}
