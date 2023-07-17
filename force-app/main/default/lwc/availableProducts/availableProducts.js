import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAvailableProducts from '@salesforce/apex/ProductController.getAvailableProducts';
import addProductToOrder from '@salesforce/apex/ProductController.addProductToOrder';
import getOrderStatus from '@salesforce/apex/OrderController.getOrderStatus';

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
    isLoading = false;
    isOrderActive;
    
    currentPage = 1;
    itemsPerPage = 5;
    visibleProducts = [];

    @api recordId;

    connectedCallback() {
        this.fetchOrderStatus();
        this.updatePagination();
    }

    fetchOrderStatus() {
        getOrderStatus({ orderId: this.recordId })
            .then((orderStatus) => {
                this.isOrderActive = orderStatus === 'Activated';
                this.updateButtonDisableStatus();
            })
            .catch((error) => {
                console.error('Error fetching order status:', error);
            });
    }

    updateButtonDisableStatus() {
        this.products = this.products.map((product) => ({
            ...product,
            isAdded: this.isOrderActive
        }));
    }

    @wire(getAvailableProducts, { orderId: '$recordId', searchKeyword: '$searchKeyword' })
    wiredProducts(result) {
        this.wiredProductsResult = result;
        const { data, error } = result;
        if (data) {
            this.products = data.map(product => ({
                ...product,
                productName: product.pricebookEntry.Product2.Name,
                listPrice: product.pricebookEntry.UnitPrice,
                isAdded: this.isOrderActive
            }));
        } else if (error) {
            console.error('Error fetching available products:', error);
        }
    }

    handleSearch(event) {
        this.searchKeyword = event.target.value;
    }

    handleRowAction(event) {
        this.isLoading = true;
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'add') {
            addProductToOrder({ orderId: this.recordId, pricebookEntryId: row.pricebookEntry.Id })
                .then(() => refreshApex(this.wiredProductsResult))
                .then(() => showSuccessMessage('Success', 'Product added to order successfully'))
                .catch((error) => {
                    console.error('Error adding product to order:', error);
                    showErrorMessage('Error', 'Failed to add product to order');
                })
                .finally(() => (this.isLoading = false));
        }
    }

    handleSort(event) {
        const { fieldName: sortField, sortDirection } = event.detail;
        this.sortedBy = sortField;
        this.sortDirection = sortDirection === 'asc' ? 'asc' : 'desc';
        this.sortData(sortField, this.sortDirection);
    }

    sortData(sortField, sortDirection) {
        const data = [...this.products];
        data.sort((a, b) => {
            const valueA = a[sortField] || '';
            const valueB = b[sortField] || '';
            let sortValue = 0;

            if (sortDirection === 'asc') {
                sortValue = valueA > valueB ? 1 : -1;
            } else if (sortDirection === 'desc') {
                sortValue = valueA < valueB ? 1 : -1;
            }

            return sortValue;
        });

        this.products = data;
    }

    handleItemsPerPageChange(event) {
        this.itemsPerPage = event.target.value;
        this.currentPage = 1;
        this.updatePagination();
    }

    updatePagination() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.itemsPerPage * this.currentPage;
        this.visibleProducts = this.products.slice(start, end);
    }

    handleUpdatePagination(event) {
        this.visibleProducts = event.detail.records;
    }
}
