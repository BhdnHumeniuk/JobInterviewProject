/**
 * @description This utility file contains the implementation of a pagination component to display a limited number of records
 *              per page and navigate between pages. It also provides event-based communication to update the visible records
 *              when the pagination changes.
 *
 * @api public
 *
 * @property {number} currentPage - The current active page number.
 * @property {number} totalRecords - The total number of records to paginate.
 * @property {number} recordSize - The number of records to display per page. Default is 5.
 * @property {number} totalPage - The total number of pages based on the totalRecords and recordSize.
 * @property {Array} visibleRecords - The subset of records displayed on the current active page.
 * @property {Array} recordSizeOptions - Options to select the number of records to display per page.
 *
 * @method get records() - Getter method to retrieve the visibleRecords property.
 * @method set records(data) - Setter method to set the totalRecords and update the pagination when data is provided.
 * @method get disablePrevious() - Getter method to check if the "Previous" button should be disabled.
 * @method get disableNext() - Getter method to check if the "Next" button should be disabled.
 * @method previousHandler() - Method to handle the "Previous" button click and update to the previous page.
 * @method nextHandler() - Method to handle the "Next" button click and update to the next page.
 * @method updateRecords() - Method to update the visibleRecords based on the currentPage and recordSize.
 * @method handleItemsPerPageChange(event) - Method to handle the change of items per page and update pagination accordingly.
 */
import { LightningElement, api } from 'lwc';

export default class Pagination extends LightningElement {
    currentPage = 1;
    totalRecords;
    @api recordSize = 5;
    totalPage = 0;
    visibleRecords = [];
    recordSizeOptions = [
        { label: '5', value: '5' },
        { label: '10', value: '10' },
        { label: '20', value: '20' },
        { label: '50', value: '50' }
    ];

    get records() {
        return this.visibleRecords;
    }

    @api
    set records(data) {
        if (data) {
            this.totalRecords = data;
            this.recordSize = Number(this.recordSize);
            this.totalPage = Math.ceil(data.length / this.recordSize);
            this.updateRecords();
        }
    }

    get disablePrevious() {
        return this.currentPage <= 1;
    }

    get disableNext() {
        return this.currentPage >= this.totalPage;
    }

    previousHandler() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.updateRecords();
        }
    }

    nextHandler() {
        if (this.currentPage < this.totalPage) {
            this.currentPage = this.currentPage + 1;
            this.updateRecords();
        }
    }

    updateRecords() {
        const start = (this.currentPage - 1) * this.recordSize;
        const end = this.recordSize * this.currentPage;
        this.visibleRecords = this.totalRecords.slice(start, end);
        this.dispatchEvent(
            new CustomEvent('update', {
                detail: {
                    records: this.visibleRecords
                }
            })
        );
    }

    handleItemsPerPageChange(event) {
        this.recordSize = event.detail.value;
        this.totalPage = Math.ceil(this.totalRecords.length / this.recordSize);
        this.currentPage = 1;
        this.updateRecords();
    }
}
