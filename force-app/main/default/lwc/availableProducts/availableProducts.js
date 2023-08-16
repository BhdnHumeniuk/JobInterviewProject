import { LightningElement, wire, api } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';

import ORDER_ACTIVATED_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';
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
    products = [];
    searchKeyword = '';
    columns = columns;
    sortDirection = 'asc';
    sortedBy;
    isOrderActive;
    
    currentPage = 1;
    itemsPerPage = 5;
    visibleProducts = [];

    isLoading = false;
    
    @api recordId;

    @wire(MessageContext)
    messageContext;

    // Method called during component initialization to fetch the order status and update button disable status.
    connectedCallback() {
        this.fetchOrderStatus();
        this.subscribeToOrderActivatedMessage();
    }

    // Method to fetch the order status for the current recordId.
    fetchOrderStatus() {
        getOrderStatus({ orderIds: this.recordId })
            .then((orderStatusMap) => {
                const orderStatus = orderStatusMap[this.recordId];
                this.isOrderActive = orderStatus === 'Activated';
                this.updateButtonDisableStatus();
            })
            .catch((error) => {
                console.error('Error fetching order status:', error);
            });
    }

    // Method to update the 'isAdded' property of products to enable/disable the 'Add' button based on the order status.
    updateButtonDisableStatus() {
        this.products = this.products.map((product) => ({
            ...product,
            isAdded: this.isOrderActive
        }));
    }

    // Wire method to get available products based on orderId and searchKeyword.
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
            this.updatePagination();
        } else if (error) {
            console.error('Error fetching available products:', error);
        }
    }

    // Method to handle the search input and update the searchKeyword for filtering products.
    handleSearch(event) {
        this.searchKeyword = event.target.value;
        this.updatePagination();
    }

    // Method to handle the 'Add' button action on a product row.
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;

        if (action.name === 'add') {
            addProductToOrder({ orderId: this.recordId, pricebookEntryId: row.pricebookEntry.Id })
                .then(() => {
                    refreshApex(this.wiredOrderProductsResult); 
                    this.dispatchEvent(new RefreshEvent());
                    publish(this.messageContext, ORDER_ACTIVATED_CHANNEL, {type: 'ProductAddToOrder', payload: true});
                    showSuccessMessage('Success', 'Product added to order successfully');
                })
                .catch((error) => {
                    console.error('Error adding product to order:', error);
                    showErrorMessage('Error', 'Failed to add product to order');
                });
        }
    }

    // Method to handle sorting of columns in the data table.
    handleSort(event) {
        const { fieldName: sortField, sortDirection } = event.detail;
        this.sortedBy = sortField;
        this.sortDirection = sortDirection === 'asc' ? 'asc' : 'desc';
        this.sortData(sortField, this.sortDirection);
        this.updatePagination();
    }

    // Method to sort the products data based on the selected column and direction.
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

    // Method to handle the change of items per page for pagination.
    handleItemsPerPageChange(event) {
        this.itemsPerPage = event.target.value;
        this.currentPage = 1;
        this.updatePagination();
    }

    // Method to update the visible products based on the current page and items per page.
    updatePagination() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.itemsPerPage * this.currentPage;
        this.visibleProducts = this.products.slice(start, end);
    }

    handleRecordSizeChange(event) {
        const newRecordSize = event.detail.recordSize;
        this.itemsPerPage = parseInt(newRecordSize, 10);
        this.currentPage = 1;
        this.updatePagination();
    }

    // Method to handle the event dispatched from the pagination child component and update visible products.
    handleUpdatePagination(event) {
        this.visibleProducts = event.detail.records;
    }

    // Method to subscribe to the order activated message channel and fetch the updated order status when notified.
    subscribeToOrderActivatedMessage() {
        this.subscription = subscribe(
            this.messageContext,
            ORDER_ACTIVATED_CHANNEL,
            (message) => {
                const { orderId } = message;
                if (orderId === this.recordId) {
                    this.fetchOrderStatus();
                }
            }
        );
    }
}
