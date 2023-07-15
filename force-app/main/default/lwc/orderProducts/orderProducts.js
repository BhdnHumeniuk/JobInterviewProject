import { LightningElement, wire, api, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getOrderProducts from '@salesforce/apex/OrderProductsRepository.getOrderProducts';
import activateOrder from '@salesforce/apex/OrderProductsRepository.activateOrder';
import { showSuccessMessage, showErrorMessage } from "c/showMessageHelper";

const columns = [
    { label: 'Name', fieldName: 'productName', type: 'text', sortable: true },
    { label: 'Quantity', fieldName: 'quantity', type: 'number', sortable: true },
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency', sortable: true },
    { label: 'Total Price', fieldName: 'totalPrice', type: 'currency', sortable: true },
    { label: 'Action', type: 'button', typeAttributes: { label: 'Remove', name: 'remove', disabled: { fieldName: 'disableRemove' } } }
];

export default class OrderProducts extends LightningElement {
    @api recordId;
    @track orderProducts = [];
    columns = columns;
    isOrderActivated = false;

    @wire(getOrderProducts, { orderId: '$recordId' })
    wiredOrderProducts({ data, error }) {
        if (data) {
            this.orderProducts = data.map(product => {
                return {
                    ...product,
                    productName: product.Product2.Name,
                    unitPrice: product.UnitPrice,
                    totalPrice: product.UnitPrice * product.Quantity,
                    disableRemove: this.isOrderActivated
                };
            });
        } else if (error) {
            console.error('Error fetching order products:', error);
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
        if (this.isOrderActivated) {
            showErrorMessage('Error', 'Order is already activated. Cannot remove products.');
            return;
        }

        deleteProductFromOrder({ orderId: this.recordId, orderItemId })
            .then(() => {
                return refreshApex(this.wiredOrderProducts);
            })
            .then(() => {
                showSuccessMessage('Success', 'Product removed from order successfully');
            })
            .catch(error => {
                console.error('Error removing product from order:', error);
                showErrorMessage('Error', 'Failed to remove product from order');
            });
    }

    handleActivateOrder() {
        activateOrder({ orderId: this.recordId })
            .then(() => {
                this.isOrderActivated = true;
                this.updateRemoveButtons();
                showSuccessMessage('Success', 'Order and products activated successfully');
            })
            .catch(error => {
                console.error('Error activating order:', error);
                showErrorMessage('Error', 'Failed to activate order');
            });
    }

    updateRemoveButtons() {
        this.orderProducts = this.orderProducts.map(product => {
            return { ...product, disableRemove: true };
        });
    }
}
