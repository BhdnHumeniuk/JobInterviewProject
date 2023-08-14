# Project Description - TravelForce Trip Management Salesforce DX Project

## Overview
The TravelForce Trip Management Salesforce DX project aims to streamline the trip planning process for TravelForce employees and enhance the customer experience. This project involves creating custom Lightning Web Components (LWC) that will be integrated into the Salesforce interface. The LWCs will enable users to manage trips efficiently, select suitable flights, and automate booking processes. The solution will improve the organization's trip management capabilities while ensuring scalability and flexibility for future enhancements.

## Components and Functionality
### Flight Search Component
- The "Flight Search" component will be integrated into the Trip record page.
- It will display a list of flights that match the preferred trip start date and have available tickets.
- The list will prioritize flights with available tickets, promoting efficient ticket distribution.
- Users can select a flight from the list, which will automatically populate the Flight lookup field on the Trip record.
- If a flight is selected, the Trip's status will be updated to "Flight booked"; otherwise, it will be set to "Flight search."

### Flight Details Component
- The "Flight Details" component will be integrated into the Trip record page.
- Section “Flight Information”: The component presents the flight number and start date, allowing users to identify the flight's primary attributes quickly.
- Section “Ticket Details”: Displayed prominently are the ticket number and ticket name, which offer insight into the specific ticket associated with the flight. These details enable users to better understand the passenger or customer linked to the ticket.
- In scenarios where a user needs to cancel a flight booking, the component provides a “Cancel Booking” button. Clicking this button initiates the cancellation process and removes the flight's association with the Trip record.

### Ticket Booking Automation
- Once a flight is selected for a Trip, the system will automatically book the first available ticket for that flight.
- The booking process includes associating the Trip's Contact with the selected Ticket.
- Ticket booking status and availability will be handled seamlessly to ensure accurate booking operations.

### External API Integration
- After successful ticket booking, the system will send relevant data to an external API for further processing.
- The API integration will utilize the provided API documentation, with the base URL set to "https://private-1ce70-testassign.apiary-mock.com."
- Data sent to the API will include information about the booked Ticket, Flight, and associated Contact.

### Deployment and Technical Requirements
- The project will be managed using Salesforce DX (SFDX) and version control through a public repository (e.g., GitHub).
- Lightning Web Components (LWC) will be developed for user interface enhancements.
- Apex will handle business logic, data processing, and external API communication.
- Test coverage of 86% for Apex classes will be implemented to ensure code quality and reliability.
- The solution will be designed with modularity and scalability in mind to accommodate future developments.
- The custom components will be designed for seamless integration with the existing Salesforce interface.
- The system will handle large data sets effectively to support future growth in data volume.

### API Integration and Configuration
To enable communication with the external API, the following steps will be taken:

1. Create Custom Setting:
   - Label: Confirmation Ticket Setting
   - Object Name: Confirmation_Ticket_Setting
   - Fields: 
     - URL__c (URL): Store the base URL of the external API.

2. Setup Remote Site Settings:
   - Remote Site Name: TravelForceAPI
   - Remote Site URL: [URL__c from the custom setting]

With the custom setting and remote site settings properly configured, the Salesforce application will be able to communicate with the specified external API. Requests will be sent to the API to book tickets, and responses will be handled as per defined requirements.

## Resources
For development and deployment, the following resources will be utilized:
- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/): Official documentation for Salesforce extensions in Visual Studio Code.
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm): Step-by-step guide for setting up Salesforce CLI.
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm): Comprehensive guide to Salesforce DX development.
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm): Complete reference for Salesforce CLI commands.

## Final Remarks
The TravelForce Trip Management Salesforce DX project aims to enhance trip planning, streamline ticket booking, and enable seamless external API integration. By leveraging Salesforce DX, Lightning Web Components, and Apex, the solution will provide TravelForce with an efficient and user-friendly trip management system. The project emphasizes modularity, scalability, and code quality, ensuring the solution's effectiveness for current and future needs.
