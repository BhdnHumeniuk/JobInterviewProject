public with sharing class ProductController {
  @AuraEnabled(cacheable=true)
  public static List<AvailableProductWrapper> getAvailableProducts(Map<Id, String> orderIdsToSearchKeywords) {
    List<AvailableProductWrapper> products = new List<AvailableProductWrapper>();
    Map<Id, List<PricebookEntry>> orderIdsToPricebookEntries = ProductRepository.getAvailablePricebookEntries(orderIdsToSearchKeywords);
    Set<Id> allOrderIds = orderIdsToSearchKeywords.keySet();

    List<OrderItem> orderItems = OrderRepository.getOrderItems(allOrderIds);
    Map<Id, List<OrderItem>> orderIdsToOrderItems = new Map<Id, List<OrderItem>>();

    for (OrderItem orderItem : orderItems) {
      Id orderId = orderItem.OrderId;
      if (!orderIdsToOrderItems.containsKey(orderId)) {
        orderIdsToOrderItems.put(orderId, new List<OrderItem>());
      }
      orderIdsToOrderItems.get(orderId).add(orderItem);
    }

    for (Id orderId : orderIdsToPricebookEntries.keySet()) {
      List<PricebookEntry> pricebookEntries = orderIdsToPricebookEntries.get(orderId);
      List<OrderItem> items = orderIdsToOrderItems.containsKey(orderId) ? orderIdsToOrderItems.get(orderId) : new List<OrderItem>();

      for (PricebookEntry entry : pricebookEntries) {
        Boolean isAddedToOrder = isProductAlreadyAdded(items, entry.Product2Id);
        products.add(new AvailableProductWrapper(entry, isAddedToOrder));
      }
    }

    return products;
  }

  @AuraEnabled
  public static void addProductsToOrders(Map<Id, Id> orderIdsToPricebookEntryIds) {
    Set<Id> pricebookEntryIds = new Set<Id>(orderIdsToPricebookEntryIds.values());
    Map<Id, PricebookEntry> pricebookEntriesMap = ProductRepository.getPricebookEntriesMap(pricebookEntryIds);

    Set<Id> allOrderIds = new Set<Id>(orderIdsToPricebookEntryIds.keySet());
    List<OrderItem> allOrderItems = OrderRepository.getAllOrderItems(allOrderIds, pricebookEntryIds);

    Map<Id, List<OrderItem>> orderIdsToOrderItems = new Map<Id, List<OrderItem>>();

    for (OrderItem orderItem : allOrderItems) {
      Id orderId = orderItem.OrderId;
      if (!orderIdsToOrderItems.containsKey(orderId)) {
        orderIdsToOrderItems.put(orderId, new List<OrderItem>());
      }
      orderIdsToOrderItems.get(orderId).add(orderItem);
    }

    List<OrderItem> orderItemsToUpsert = new List<OrderItem>();

    for (Id orderId : orderIdsToPricebookEntryIds.keySet()) {
      Id pricebookEntryId = orderIdsToPricebookEntryIds.get(orderId);
      PricebookEntry entry = pricebookEntriesMap.get(pricebookEntryId);
      List<OrderItem> items = orderIdsToOrderItems.containsKey(orderId) ? orderIdsToOrderItems.get(orderId) : new List<OrderItem>();
      OrderItem orderItem;

      for (OrderItem item : items) {
        if (item.PricebookEntryId == pricebookEntryId) {
          orderItem = item;
          break;
        }
      }

      if (orderItem != null) {
        orderItem.Quantity += 1;
      } else {
        orderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, Quantity = 1, UnitPrice = entry.UnitPrice);
      }
      orderItemsToUpsert.add(orderItem);
    }
    OrderRepository.upsertOrderItems(orderItemsToUpsert);
  }

  private static Boolean isProductAlreadyAdded(List<OrderItem> orderItems, Id productId) {
    Map<Id, OrderItem> productIdToOrderItemMap = new Map<Id, OrderItem>();

    for (OrderItem orderItem : orderItems) {
      productIdToOrderItemMap.put(orderItem.Product2Id, orderItem);
    }

    return productIdToOrderItemMap.containsKey(productId);
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
