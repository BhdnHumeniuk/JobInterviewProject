public with sharing class ProductRepository {
  public static Map<Id, List<PricebookEntry>> getAvailablePricebookEntries(Map<Id, String> orderIdsToSearchKeywords) {
    Map<Id, Id> orderIdsToPricebook2Ids = new Map<Id, Id>();

    for (Id orderId : orderIdsToSearchKeywords.keySet()) {
      Order order = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];
      orderIdsToPricebook2Ids.put(orderId, order.Pricebook2Id);
    }

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

  public static Map<Id, OrderItem> getOrderItems(Map<Id, Id> orderIdsToPricebookEntryIds) {
    Map<Id, OrderItem> orderItemsMap = new Map<Id, OrderItem>();

    List<OrderItem> orderItems = [
      SELECT Id, Quantity, UnitPrice, OrderId, PricebookEntryId
      FROM OrderItem
      WHERE OrderId IN :orderIdsToPricebookEntryIds.keySet() AND PricebookEntryId IN :orderIdsToPricebookEntryIds.values()
    ];

    Map<Id, Map<Id, OrderItem>> orderIdToPricebookEntryToOrderItemMap = new Map<Id, Map<Id, OrderItem>>();

    for (OrderItem orderItem : orderItems) {
      Id orderId = orderItem.OrderId;
      Id pricebookEntryId = orderItem.PricebookEntryId;

      if (!orderIdToPricebookEntryToOrderItemMap.containsKey(orderId)) {
        orderIdToPricebookEntryToOrderItemMap.put(orderId, new Map<Id, OrderItem>());
      }
      orderIdToPricebookEntryToOrderItemMap.get(orderId).put(pricebookEntryId, orderItem);
    }

    for (Id orderId : orderIdsToPricebookEntryIds.keySet()) {
      Id pricebookEntryId = orderIdsToPricebookEntryIds.get(orderId);

      if (orderIdToPricebookEntryToOrderItemMap.containsKey(orderId) && orderIdToPricebookEntryToOrderItemMap.get(orderId).containsKey(pricebookEntryId)) {
        orderItemsMap.put(orderId, orderIdToPricebookEntryToOrderItemMap.get(orderId).get(pricebookEntryId));
      } else {
        orderItemsMap.put(orderId, null);
      }
    }

    return orderItemsMap;
  }

  public static void upsertOrderItems(List<OrderItem> orderItems) {
    upsert orderItems;
  }
}
