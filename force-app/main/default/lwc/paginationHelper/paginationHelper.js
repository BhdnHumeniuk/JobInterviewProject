import { LightningElement, api } from 'lwc';

export default class PaginationHelper extends LightningElement {
    @api recordSize;
    recordSizeOptions = [
        { label: '5', value: '5' },
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' }
    ];

    handleRecordSizeChange(event) {
        const selectedValue = event.target.value;
        this.recordSize = selectedValue;

        const customEvent = new CustomEvent('recordsizechange', {
            detail: { recordSize: selectedValue }
        });
        this.dispatchEvent(customEvent);
    }
}
