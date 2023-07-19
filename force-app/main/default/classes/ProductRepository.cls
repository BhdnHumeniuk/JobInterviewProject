public with sharing class ProductRepository {
  public static Map<Id, List<PricebookEntry>> getAvailablePricebookEntries(Map<Id, String> orderIdsToSearchKeywords) {
    Map<Id, Id> orderIdsToPricebook2Ids = getOrderPricebook2Ids(orderIdsToSearchKeywords.keySet());
    return getOrderPricebookEntries(orderIdsToPricebook2Ids, orderIdsToSearchKeywords);
  }

  private static Map<Id, Id> getOrderPricebook2Ids(Set<Id> orderIds) {
    Map<Id, Id> orderIdsToPricebook2Ids = new Map<Id, Id>();
    for (Id orderId : orderIds) {
      Order order = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];
      orderIdsToPricebook2Ids.put(orderId, order.Pricebook2Id);
    }
    return orderIdsToPricebook2Ids;
  }

  private static Map<Id, List<PricebookEntry>> getOrderPricebookEntries(Map<Id, Id> orderIdsToPricebook2Ids, Map<Id, String> orderIdsToSearchKeywords) {
    Map<Id, List<PricebookEntry>> orderIdsToPricebookEntries = new Map<Id, List<PricebookEntry>>();
    for (Id orderId : orderIdsToPricebook2Ids.keySet()) {
      Id pricebook2Id = orderIdsToPricebook2Ids.get(orderId);
      String searchKeyword = orderIdsToSearchKeywords.get(orderId);

      List<PricebookEntry> pricebookEntries = [
        SELECT Id, Product2.Name, UnitPrice
        FROM PricebookEntry
        WHERE Pricebook2Id = :pricebook2Id AND IsActive = TRUE AND Product2.Name LIKE :('%' + searchKeyword + '%')
      ];

      orderIdsToPricebookEntries.put(orderId, pricebookEntries);
    }
    return orderIdsToPricebookEntries;
  }

  public static Map<Id, PricebookEntry> getPricebookEntriesMap(Set<Id> pricebookEntryIds) {
    Map<Id, PricebookEntry> pricebookEntriesMap = new Map<Id, PricebookEntry>([SELECT Id, UnitPrice FROM PricebookEntry WHERE Id IN :pricebookEntryIds]);
    return pricebookEntriesMap;
  }
}
