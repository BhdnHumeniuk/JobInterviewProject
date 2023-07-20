public with sharing class ProductRepository {
  public static List<PricebookEntry> getAvailablePricebookEntries(Id orderId, String searchKeyword) {
    Order order = OrderRepository.getPricebookFromOrder(orderId);

    return [
      SELECT Id, Product2.Name, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :order.Pricebook2Id AND IsActive = TRUE AND Product2.Name LIKE :('%' + searchKeyword + '%')
    ];
  }

  public static PricebookEntry getPricebookEntries(Id pricebookEntryId) {
    return [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :pricebookEntryId];
  }
}
