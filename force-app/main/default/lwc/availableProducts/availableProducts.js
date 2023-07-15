import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAvailableProducts from '@salesforce/apex/AvailableProductsRepository.getAvailableProducts';
import addProductToOrder from '@salesforce/apex/AvailableProductsRepository.addProductToOrder';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

const columns = [
    { label: 'Name', fieldName: 'productName', type: 'text', sortable: true },
    { label: 'List Price', fieldName: 'listPrice', type: 'currency', sortable: true },
    { label: 'Action', type: 'button', typeAttributes: { label: 'Add', name: 'add', disabled: { fieldName: 'isAdded' } } }
];

export default class AvailableProducts extends LightningElement {
    
    searchKeyword = '';
    products = [];
    columns = columns;
    sortDirection = 'asc';
    sortedBy;

    @api recordId;

    @wire(getAvailableProducts, { orderId: '$recordId', searchKeyword: '$searchKeyword' })
    wiredProducts({ data, error }) {
        if (data) {
            this.products = data.map(product => {
                return { ...product, productName: product.pricebookEntry.Product2.Name, listPrice: product.pricebookEntry.UnitPrice };
            });
        } else if (error) {
            console.error('Error fetching available products:', error);
        }
    }

    handleSearch(event) {
        this.searchKeyword = event.target.value;
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'add') {
            addProductToOrder({ orderId: this.recordId, pricebookEntryId: row.pricebookEntry.Id })
                .then(() => {
                    return refreshApex(this.wiredProducts);
                })
                .then(() => {
                    showSuccessMessage('Success', 'Product added to order successfully');
                })
                .catch(error => {
                    console.error('Error adding product to order:', error);
                    showErrorMessage('Error', 'Failed to add product to order');
                });
        }
    }

    handleSort(event) {
        const { fieldName: sortField, sortDirection } = event.detail;
        this.sortedBy = sortField;
        this.sortDirection = sortDirection === 'asc' ? 'asc' : 'desc';
        this.sortData(sortField, this.sortDirection);
    }

    sortData(sortField, sortDirection) {
        const data = JSON.parse(JSON.stringify(this.products));
        data.sort((a, b) => {
            let sortValue = 0;
            const valueA = a[sortField] || '';
            const valueB = b[sortField] || '';
            if (sortDirection === 'asc') {
                sortValue = valueA > valueB ? 1 : -1;
            } else if (sortDirection === 'desc') {
                sortValue = valueA < valueB ? 1 : -1;
            }
            return sortValue;
        });
        this.products = data;
    }
}