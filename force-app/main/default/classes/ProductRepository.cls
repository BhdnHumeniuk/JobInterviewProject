public with sharing class ProductRepository {
  public static List<PricebookEntry> getAvailablePricebookEntries(Id orderId, String searchKeyword) {
    Order order = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];

    return [
      SELECT Id, Product2.Name, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :order.Pricebook2Id AND IsActive = TRUE AND Product2.Name LIKE :('%' + searchKeyword + '%')
    ];
  }

  public static Map<Id, PricebookEntry> getPricebookEntriesMap(Set<Id> pricebookEntryIds) {
    Map<Id, PricebookEntry> pricebookEntriesMap = new Map<Id, PricebookEntry>([SELECT Id, UnitPrice FROM PricebookEntry WHERE Id IN :pricebookEntryIds]);
    return pricebookEntriesMap;
  }
}
