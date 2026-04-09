import { LightningElement } from 'lwc';
import CULTURE_RESOURCE from '@salesforce/resourceUrl/gdc_CultureResource';

export default class GdcCulture extends LightningElement {
    convinceImageUrl = `${CULTURE_RESOURCE}/convince_image.jpg`;
    rewardImageUrl   = `${CULTURE_RESOURCE}/reward_image.jpg`;
    togetherImageUrl = `${CULTURE_RESOURCE}/together_image.jpg`;
    familyImageUrl   = `${CULTURE_RESOURCE}/family_image.jpg`;
}
