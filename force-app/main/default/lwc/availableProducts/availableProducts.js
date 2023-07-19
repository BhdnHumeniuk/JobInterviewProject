import { LightningElement, wire, api } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import ORDER_ACTIVATED_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';
import getAvailableProducts from '@salesforce/apex/ProductController.getAvailableProducts';
import addProductsToOrders from '@salesforce/apex/ProductController.addProductsToOrders';
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

    connectedCallback() {
        this.fetchOrderStatus();
        this.subscribeToOrderActivatedMessage();
        this.updatePagination();
    }

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

    updateButtonDisableStatus() {
        this.products = this.products.map((product) => ({
            ...product,
            isAdded: this.isOrderActive
        }));
    }


    @wire(getAvailableProducts, { orderIdsToSearchKeywords: '$orderIdsToSearchKeywords' })
    wiredProducts(result) {
      this.wiredProductsResult = result;
      const { data, error } = result;
      if (data) {
        this.products = this.mapProductData(data);
        this.updatePagination();
      } else if (error) {
        console.error('Error fetching available products:', error);
      }
    }
  
    mapProductData(data) {
      return data.map((product) => ({
        ...product,
        productName: product.pricebookEntry.Product2.Name,
        listPrice: product.pricebookEntry.UnitPrice,
        isAdded: this.isOrderActive
      }));
    }

    get orderIdsToSearchKeywords() {
        const orderIdsToSearchKeywords = {};
        orderIdsToSearchKeywords[this.recordId] = this.searchKeyword;
        return orderIdsToSearchKeywords;
    }

    handleSearch(event) {
        this.searchKeyword = event.target.value;
        this.updatePagination();
    }

    handleRowAction(event) {
        this.isLoading = true;
        const action = event.detail.action;
        const row = event.detail.row;
    
        if (action.name === 'add') {
            const orderIdsToPricebookEntryIds = { [this.recordId]: row.pricebookEntry.Id };
            addProductsToOrders({ orderIdsToPricebookEntryIds })
                .then(() => {
                    showSuccessMessage('Success', 'Product added to order successfully');
                    const message = {
                        recordId: row.pricebookEntry.Id
                    };
                    publish(this.messageContext, ORDER_ACTIVATED_CHANNEL, message);
                    console.log('Sent message from AvailableProducts component:', message);
                })
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
        this.updatePagination();
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
