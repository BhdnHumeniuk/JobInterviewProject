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
    @api recordId;

    searchKeyword = '';
    products = [];
    columns = columns;
    wiredProductsResult;
    sortDirection = 'asc';
    sortedBy;

    @wire(getAvailableProducts, { orderId: '$recordId', searchKeyword: '$searchKeyword', sortField: 'Name' })
    wiredProducts(result) {
        this.wiredProductsResult = result;
        if (result.data) {
            this.products = result.data.map(product => {
                return { ...product, productName: product.pricebookEntry.Product2.Name, listPrice: product.pricebookEntry.UnitPrice };
            });
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
                    return refreshApex(this.wiredProductsResult);
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
}
