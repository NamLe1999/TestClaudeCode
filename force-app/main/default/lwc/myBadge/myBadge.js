import { LightningElement, api } from 'lwc';

export default class MyBadge extends LightningElement {
    @api name = 'Nam Le';
    @api dateOfBirth = '1999-01-01';
    @api job = 'Salesforce Developer';
    @api age = '26';
    @api company = 'DAEUnextier';

    get initials() {
        if (!this.name) return '';
        return this.name
            .split(' ')
            .map(word => word.charAt(0).toUpperCase())
            .slice(0, 2)
            .join('');
    }
}
