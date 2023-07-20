/**
 * @description This helper file contains functions to show toast messages (success, error, or custom) to provide feedback
 *              to the user based on specific actions or events.
 *
 * @method showSuccessMessage(title, message) - Display a success toast message with the provided title and message.
 * @method showErrorMessage(title, message) - Display an error toast message with the provided title and message.
 * @method showMessage(type, title, message) - Display a custom toast message with the provided type, title, and message.
 *                                              The type can be "success", "error", or any other valid variant.
 */
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const showSuccessMessage = (title, message) => {
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: "success"
        })
    );
};

const showErrorMessage = (title, message) => {
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: "error"
        })
    );
};

const showMessage = (type = "success", title, message) => {
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        })
    );
};

export { showSuccessMessage, showErrorMessage, showMessage };