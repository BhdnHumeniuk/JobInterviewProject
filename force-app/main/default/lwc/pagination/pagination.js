import { LightningElement, api, wire } from 'lwc';

export default class Pagination extends LightningElement {
    currentPage = 1;
    totalRecords;
    _recordSize;
    totalPage = 0;

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

    @api
    get recordSize() {
        return this._recordSize;
    }

    set recordSize(value) {
        this._recordSize = value;
        this.updateTotalPage();
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

    updateTotalPage() {
        this.totalPage = Math.ceil(this.totalRecords.length / this.recordSize);
        console.log(this.totalPage);
        this.updateRecords();
    }
}
