import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import ORDER_ACTIVATED_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';
import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderController.activateOrder';
import deleteProductFromOrder from '@salesforce/apex/OrderController.deleteProductFromOrder';
import getOrderStatus from '@salesforce/apex/OrderController.getOrderStatus';

const columns = [
    { label: 'Name', fieldName: 'productName', type: 'text', sortable: true },
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency', sortable: true },
    { label: 'Quantity', fieldName: 'quantityValue', type: 'number', sortable: true },
    { label: 'Total Price', fieldName: 'totalPrice', type: 'currency', sortable: true },
    { label: 'Action', type: 'button', typeAttributes: { label: 'Remove', name: 'remove', disabled: { fieldName: 'disableRemove' } } }
];

export default class OrderProducts extends LightningElement {
    orderProducts = [];
    columns = columns;
    isOrderActive = false;

    currentPage = 1;
    itemsPerPage = 5;
    visibleProducts = [];

    isLoading = false;

    @api recordId;

    @wire(MessageContext)
    messageContext;
 
    // Method called during component initialization to fetch the order products, order status, and subscribe to the add product channel.
    connectedCallback() {
        refreshApex(this.wiredOrderProductsResult);
        this.fetchOrderStatus();
        this.subscribeToAddProductChannel();
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

    // Method to update the 'disableRemove' property of order products based on the order status.
    updateButtonDisableStatus() {
        this.orderProducts = this.orderProducts.map((product) => {
            return { ...product, disableRemove: this.isOrderActive };
        });
        this.isActivateButtonDisabled = this.isOrderActive;
    }

    // Wire method to get order products based on the orderId.
    @wire(getOrderProducts, { orderId: '$recordId' })
    wiredOrderProducts(result) {
        this.wiredOrderProductsResult = result;
        if (result.data) {
            this.orderProducts = result.data.map((product) => {
                return {
                    ...product,
                    productName: product.Product2.Name,
                    unitPrice: product.UnitPrice,
                    quantityValue: product.Quantity,
                    totalPrice: product.UnitPrice * product.Quantity,
                    disableRemove: this.isOrderActive
                };
            });
            this.updatePagination();
        } else if (result.error) {
            console.error('Error fetching order products:', result.error);
        }
    }

    // Method to handle the 'Remove' button action on a product row.
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'remove') {
            this.removeProductFromOrder(row.Id);
        }
    }

    // Method to remove a product from the order based on the given order item Ids.
    removeProductFromOrder(orderItemIds) {
        if (this.isOrderActive) {
            showErrorMessage('Error', 'Order is already activated. Cannot remove products.');
            return;
        }
        deleteProductFromOrder({ orderItemIds })
            .then(() => {
                refreshApex(this.wiredOrderProductsResult); 
                this.dispatchEvent(new RefreshEvent());
                showSuccessMessage('Success', 'Product removed from order successfully');
            })
            .catch((error) => {
                console.error('Error removing product from order:', error);
                showErrorMessage('Error', 'Failed to remove product from order');
            });
    }

    // Method to handle the 'Activate Order' button click.
    handleActivateOrder() {
        if (this.isOrderActive) {
            showErrorMessage('Error', 'Order is already activated.');
            return;
        }

        this.isLoading = true;
        activateOrder({ orderIds: this.recordId })
            .then(() => {
                this.isOrderActive = true;
                this.updateButtonDisableStatus();
                showSuccessMessage('Success', 'Order activated successfully');
                const message = { orderId: this.recordId };
                publish(this.messageContext, ORDER_ACTIVATED_CHANNEL, message);
            })
            .catch((error) => {
                console.error('Error activating order:', error);
                showErrorMessage('Error', 'Failed to activate order');
            })
            .finally(() => (this.isLoading = false));
    }

    // Method to handle sorting of columns in the data table.
    handleSort(event) {
        const { fieldName: sortField, sortDirection } = event.detail;
        this.sortedBy = sortField;
        this.sortDirection = sortDirection === 'asc' ? 'asc' : 'desc';
        this.sortData(sortField, this.sortDirection);
    }

    // Method to sort the order products data based on the selected column and direction.
    sortData(sortField, sortDirection) {
        const data = JSON.parse(JSON.stringify(this.orderProducts));
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
        this.orderProducts = data;
        this.updatePagination();
    }

    // Method to handle the change of items per page for pagination.
    handleItemsPerPageChange(event) {
        this.itemsPerPage = event.target.value;
        this.currentPage = 1;
        this.updatePagination();
    }

    // Method to update the visible order products based on the current page and items per page.
    updatePagination() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.itemsPerPage * this.currentPage;
        this.visibleProducts = this.orderProducts.slice(start, end);
    }

    //Method to update itemsPerPage.
    handleRecordSizeChange(event) {
        const newRecordSize = event.detail.recordSize;
        this.itemsPerPage = parseInt(newRecordSize, 10);
        this.currentPage = 1;
        this.updatePagination();
    }

    // Method to handle the event dispatched from the pagination child component and update visible order products.
    handleUpdatePagination(event) {
        this.visibleProducts = event.detail.records;
    }

    // Method to subscribe to the add product channel and update the quantity of the product.
    subscribeToAddProductChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ORDER_ACTIVATED_CHANNEL,
            (message) => {
                if (message.type === 'ProductAddToOrder') {
                refreshApex(this.wiredOrderProductsResult); 
                }
            }
        );
    }
}
