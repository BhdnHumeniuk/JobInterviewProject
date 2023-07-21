# Project Description - Order Management Salesforce DX Project

## Overview
This Salesforce DX project aims to enhance the order management process for a customer by allowing them to add products to order without leaving the order detail page. The project involves creating two Lightning Web Components (LWC) that will be placed on the order record page. The first component, "Available Products," will display orderable products suitable for the order based on the order's price book. The second component, "Order Products," will display products that have been added to the current order.

## Components and Functionality
### Available Products Component
- The "Available Products" component will be displayed as a 2-column list showing the Name and List Price of orderable products.
- Products that are already added to the order will appear at the top of the list.
- Each product can only appear once in the list, ensuring no duplicates.
- The list can be sorted by column, providing a more organized view.
- Users can search for products by their names, enabling easier product discovery.
- Users will have the ability to add a product from the list to the order.
  - If the selected product is not yet added to the order, it will be added with a quantity of 1.
  - If the product already exists in the order, the quantity of the existing order product will be increased by 1.

### Order Products Component
- The "Order Products" component will display the order products in a table format, showing the Name, Unit Price, Quantity, and Total Price of each order item.
- The list can be sorted by column to provide better user flexibility.
- The "Order Products" component will have an "Activate" button that sets the status of the order and order items to "Activated."
- Once activated, the end-user will not be able to add new order items or confirm the order for a second time.
- Short video of my solution: https://drive.google.com/file/d/1E1wkVaXJeHbnZe5mc9LMd_hmTZAs3N70/view?usp=sharing

### Deployment and Technical Requirements
- The project will be managed using Salesforce DX (SFDX).
- The solution will be available as a repository on GitHub/Bitbucket for easy access and collaboration.
- Apex will be used for queries and DML operations.
- The development will focus on using LWC components; however, Aura/Vlocity components are acceptable.
- Test coverage of at least 80% for both APEX components is required, ensuring code quality and reliability.
- The solution should be designed with modularity in mind, allowing the components to be independent and easily draggable and droppable at any place in the layout.
- The page should not be reloaded entirely; only the changed or new items should be refreshed/added, providing a smooth user experience.
- The "Activate" button in the "Order Products" component will handle the confirmation of the order in an external system.
- The request format expected by the external system will follow a specific JSON structure.
- Errors and timeouts from the external system need to be handled properly, providing a robust solution.
- The solution should be able to handle a large number of products, exceeding 200, without compromising user experience.

### Sending POST Requests to an External Website
To enable the communication of POST requests with an external website, the following steps will be taken:

Custom Settings Creation:
- Label: Confirmation Order Setting
- Object Name: Confirmation_order_setting
- Field: URL (To store the full address of the external website that will receive the requests)
- Value: The URL will be set to "https://myproject.requestcatcher.com", which is the address of the target website for this use case.

Setup Remote Site Settings:
- Remote Site Name: My Project Request Catcher
- Remote Site URL: https://myproject.requestcatcher.com
  
With the custom settings and remote site settings properly configured, the Salesforce application will have the capability to send POST requests to the specified external website, which is "https://myproject.requestcatcher.com". Any responses received from the external website will be handled as per the defined requirements, ensuring effective error handling and seamless integration with the Salesforce application.

## Resources
For development and deployment, the following resources will be utilized:
- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/): Official documentation for Salesforce extensions in Visual Studio Code.
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm): Step-by-step guide for setting up Salesforce CLI.
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm): Comprehensive guide to Salesforce DX development.
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm): Complete reference for Salesforce CLI commands.

## Final Remarks
This project aims to provide an efficient and user-friendly order management experience for the customer. It will demonstrate the use of Salesforce DX, Lightning Web Components, Apex, and best practices in Salesforce development. The emphasis will be on the design, functionality, and implementation of the solution, showcasing the technical choices made during development. A video demonstrating the solution's acceptance criteria will be provided alongside the codebase to ensure clarity and smooth evaluation.
