public with sharing class OrderController {
  @AuraEnabled(cacheable=true)
  public static Map<Id, List<OrderItem>> getOrderProducts(List<Id> orderIds) {
    return OrderRepository.getOrderProducts(new Set<Id>(orderIds));
  }

  @AuraEnabled
  public static void deleteProductFromOrder(List<Id> orderItemIds) {
    List<OrderItem> orderItems = OrderRepository.getOrderItems(new Set<Id>(orderItemIds));
    List<OrderItem> itemsToUpdate = new List<OrderItem>();
    List<OrderItem> itemsToDelete = new List<OrderItem>();

    for (OrderItem orderItem : orderItems) {
      if (orderItem.Quantity > 1) {
        orderItem.Quantity--;
        itemsToUpdate.add(orderItem);
      } else {
        itemsToDelete.add(orderItem);
      }
    }

    if (!itemsToUpdate.isEmpty()) {
      OrderRepository.upsertOrderItems(itemsToUpdate);
    }

    if (!itemsToDelete.isEmpty()) {
      OrderRepository.deleteOrderItem(itemsToDelete);
    }
  }

  @AuraEnabled
  public static Map<Id, String> getOrderStatus(List<Id> orderIds) {
    Map<Id, String> orderStatusMap = OrderRepository.getOrderStatus(new Set<Id>(orderIds));
    return orderStatusMap;
  }

  @AuraEnabled
  public static void activateOrder(List<Id> orderIds) {
    OrderRepository.activateOrders(new Set<Id>(orderIds));
    for (Id orderId : orderIds) {
      OrderCalloutService.sendOrderInformation(orderId);
    }
  }

  public class AvailableProductWrapper {
    @AuraEnabled
    public PricebookEntry pricebookEntry { get; set; }
    @AuraEnabled
    public Boolean isAddedToOrder { get; set; }

    public AvailableProductWrapper(PricebookEntry entry, Boolean isAddedToOrder) {
      this.pricebookEntry = entry;
      this.isAddedToOrder = isAddedToOrder;
    }
  }
}
