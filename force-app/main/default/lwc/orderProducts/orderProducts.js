import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import ORDER_ACTIVATED_CHANNEL from '@salesforce/messageChannel/LightningMessageService__c';
import getOrderProducts from '@salesforce/apex/OrderController.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderController.activateOrder';
import deleteProductFromOrder from '@salesforce/apex/OrderController.deleteProductFromOrder';
import getOrderStatus from '@salesforce/apex/OrderController.getOrderStatus';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

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
    
    connectedCallback() {
        this.fetchOrderProducts();
        this.fetchOrderStatus();
        this.updatePagination();
        this.subscribeToAddProductChannel();
    }

    fetchOrderProducts() {
        getOrderProducts({ orderIds: this.recordId })
          .then((data) => {
            const mergedOrderProducts = Object.values(data).flatMap(orderItems => orderItems);
            this.orderProducts = mergedOrderProducts.map((product) => {
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
          })
          .catch((error) => {
            console.error('Error fetching order products:', error);
          });
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
        this.orderProducts = this.orderProducts.map((product) => {
            return { ...product, disableRemove: this.isOrderActive };
        });
        this.isActivateButtonDisabled = this.isOrderActive;
    }

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

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        if (action.name === 'remove') {
            this.removeProductFromOrder(row.Id);
        }
    }

    removeProductFromOrder(orderItemIds) {
        if (this.isOrderActive) {
            showErrorMessage('Error', 'Order is already activated. Cannot remove products.');
            return;
        }
    
        this.decreaseQuantity(orderItemIds[0]);
    
        const originalProducts = JSON.parse(JSON.stringify(this.orderProducts));
    
        deleteProductFromOrder({ orderItemIds })
            .then(() => {
                return refreshApex(this.wiredOrderProductsResult);
            })
            .then(() => {
                showSuccessMessage('Success', 'Product removed from order successfully');
            })
            .catch((error) => {
                console.error('Error removing product from order:', error);
                this.orderProducts = originalProducts;
                showErrorMessage('Error', 'Failed to remove product from order');
            });
    }

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

    handleSort(event) {
        const { fieldName: sortField, sortDirection } = event.detail;
        this.sortedBy = sortField;
        this.sortDirection = sortDirection === 'asc' ? 'asc' : 'desc';
        this.sortData(sortField, this.sortDirection);
    }

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

    handleItemsPerPageChange(event) {
        this.itemsPerPage = event.target.value;
        this.currentPage = 1;
        this.updatePagination();
    }

    updatePagination() {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.itemsPerPage * this.currentPage;
        this.visibleProducts = this.orderProducts.slice(start, end);
    }

    handleUpdatePagination(event) {
        this.visibleProducts = event.detail.records;
    }

    increaseQuantity(productId) {
        const updatedProducts = this.orderProducts.map((product) => {
            if (product.Product2.Id === productId) {
                return {
                    ...product,
                    Quantity: product.Quantity + 1,
                    totalPrice: (product.Quantity + 1) * product.unitPrice
                };
            }
            return product;
        });
        this.orderProducts = updatedProducts;
    }

    decreaseQuantity(productId) {
        const updatedProducts = this.orderProducts.map((product) => {
            if (product.Product2.Id === productId) {
                const newQuantity = product.Quantity - 1;
                return {
                    ...product,
                    Quantity: newQuantity,
                    totalPrice: newQuantity * product.unitPrice
                };
            }
            return product;
        });
        this.orderProducts = updatedProducts;
    }

    subscribeToAddProductChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ORDER_ACTIVATED_CHANNEL,
            (message) => {
                const productId = message.recordId;
                this.increaseQuantity(productId);
                refreshApex(this.wiredOrderProductsResult); 
            }
        );
    }
}
