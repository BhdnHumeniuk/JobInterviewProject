public with sharing class ProductRepository {
  public static List<PricebookEntry> getAvailablePricebookEntries(Id orderId, String searchKeyword) {
    Order order = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];

    return [
      SELECT Id, Product2.Name, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :order.Pricebook2Id AND IsActive = TRUE AND Product2.Name LIKE :('%' + searchKeyword + '%')
    ];
  }

  public static OrderItem getOrderItem(Id orderId, Id pricebookEntryId) {
    try {
      return [SELECT Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId AND PricebookEntryId = :pricebookEntryId LIMIT 1];
    } catch (QueryException e) {
      return null;
    }
  }

  public static void upsertOrderItem(OrderItem orderItem) {
    upsert orderItem;
  }
}
