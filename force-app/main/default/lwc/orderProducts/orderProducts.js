import { LightningElement, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderProducts from '@salesforce/apex/OrderProductsRepository.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderProductsRepository.activateOrder';
import deleteProductFromOrder from '@salesforce/apex/OrderProductsRepository.deleteProductFromOrder';
import getOrderStatus from '@salesforce/apex/OrderProductsRepository.getOrderStatus';
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
    isLoading = false;

    @api recordId;
    wiredOrderProductsResult;

    connectedCallback() {
        this.fetchOrderProducts();
        this.fetchOrderStatus();
    }

    fetchOrderProducts() {
        getOrderProducts({ orderId: this.recordId })
            .then((data) => {
                this.orderProducts = data.map((product) => {
                    return {
                        ...product,
                        productName: product.Product2.Name,
                        unitPrice: product.UnitPrice,
                        quantityValue: product.Quantity,
                        totalPrice: product.UnitPrice * product.Quantity,
                        disableRemove: this.isOrderActive
                    };
                });
            })
            .catch((error) => {
                console.error('Error fetching order products:', error);
            });
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

    removeProductFromOrder(orderItemId) {
        if (this.isOrderActive) {
            showErrorMessage('Error', 'Order is already activated. Cannot remove products.');
            return;
        }

        this.isLoading = true;
        deleteProductFromOrder({ orderItemId })
            .then(() => {
                return refreshApex(this.wiredOrderProductsResult);
            })
            .then(() => {
                showSuccessMessage('Success', 'Product removed from order successfully');
                this.fetchOrderProducts(); // Обновление списка товаров
            })
            .catch((error) => {
                console.error('Error removing product from order:', error);
                showErrorMessage('Error', 'Failed to remove product from order');
            })
            .finally(() => (this.isLoading = false));
    }

    handleActivateOrder() {
        if (this.isOrderActive) {
            showErrorMessage('Error', 'Order is already activated.');
            return;
        }

        this.isLoading = true;
        activateOrder({ orderId: this.recordId })
            .then(() => {
                this.isOrderActive = true;
                this.updateButtonDisableStatus();
                showSuccessMessage('Success', 'Order activated successfully');
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
    }
}
