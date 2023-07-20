/**
 * ProductRepository class provides methods to interact with the PricebookEntry object in Salesforce.
 * It includes methods for querying available PricebookEntries based on an Order Id and search keyword.
 */
public with sharing class ProductRepository {
  // Returns a list of available PricebookEntries for a given Order Id and search keyword.
  public static List<PricebookEntry> getAvailablePricebookEntries(Id orderId, String searchKeyword) {
    Order order = OrderRepository.getPricebookFromOrder(orderId);
    return [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :order.Pricebook2Id AND IsActive = TRUE AND Product2.Name LIKE :('%' + searchKeyword + '%')];
  }

  // Returns a specific PricebookEntry based on the given PricebookEntry Id.
  public static PricebookEntry getPricebookEntries(Id pricebookEntryId) {
    return [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :pricebookEntryId];
  }
}
