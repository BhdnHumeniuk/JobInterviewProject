public with sharing class ProductController {
  @AuraEnabled(cacheable=true)
  public static List<AvailableProductWrapper> getAvailableProducts(Id orderId, String searchKeyword) {
    List<AvailableProductWrapper> products = new List<AvailableProductWrapper>();
    Map<Id, String> orderIdsToSearchKeywords = new Map<Id, String>();
    orderIdsToSearchKeywords.put(orderId, searchKeyword);

    Map<Id, List<PricebookEntry>> orderIdsToPricebookEntries = ProductRepository.getAvailablePricebookEntries(orderIdsToSearchKeywords);
    List<OrderItem> orderItems = new List<OrderItem>();

    if (orderId != null) {
      orderItems = [SELECT Product2Id FROM OrderItem WHERE OrderId = :orderId];
    }

    for (PricebookEntry entry : orderIdsToPricebookEntries.get(orderId)) {
      Boolean isAddedToOrder = isProductAlreadyAdded(orderItems, entry.Product2Id);
      products.add(new AvailableProductWrapper(entry, isAddedToOrder));
    }

    return products;
  }

  @AuraEnabled
  public static void addProductToOrder(Id orderId, Id pricebookEntryId) {
    PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :pricebookEntryId];
    Map<Id, Id> orderIdsToPricebookEntryIds = new Map<Id, Id>();
    orderIdsToPricebookEntryIds.put(orderId, pricebookEntryId);

    Map<Id, OrderItem> orderItemsMap = ProductRepository.getOrderItems(orderIdsToPricebookEntryIds);
    OrderItem orderItem = orderItemsMap.get(orderId);

    if (orderItem != null) {
      orderItem.Quantity += 1;
    } else {
      orderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, Quantity = 1, UnitPrice = entry.UnitPrice);
    }

    List<OrderItem> orderItems = new List<OrderItem>();
    orderItems.add(orderItem);

    ProductRepository.upsertOrderItems(orderItems);
  }

  private static Boolean isProductAlreadyAdded(List<OrderItem> orderItems, Id productId) {
    for (OrderItem orderItem : orderItems) {
      if (orderItem.Product2Id == productId) {
        return true;
      }
    }
    return false;
  }

  public class AvailableProductWrapper {
    @AuraEnabled
    public PricebookEntry pricebookEntry { get; set; }

    @AuraEnabled
    public Boolean isAddedToOrder { get; set; }

    public AvailableProductWrapper(PricebookEntry entry, Boolean isAdded) {
      pricebookEntry = entry;
      isAddedToOrder = isAdded;
    }
  }
}
