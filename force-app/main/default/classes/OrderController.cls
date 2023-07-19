public with sharing class OrderController {
  @AuraEnabled(cacheable=true)
  public static List<OrderItem> getOrderProducts(Id orderId) {
    return OrderRepository.getOrderItemsForOrder(orderId);
  }

  @AuraEnabled
  public static void deleteProductFromOrder(List<Id> orderItemIds) {
    List<OrderItem> orderItems = OrderRepository.getAllOrderItemsForOrdersById(new Set<Id>(orderItemIds));

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
    Map<Id, String> orderStatusMap = OrderRepository.getOrderStatusMapByIds(new Set<Id>(orderIds));
    return orderStatusMap;
  }

  @AuraEnabled
  public static void activateOrder(List<Id> orderIds) {
    OrderRepository.activateOrdersByIds(new Set<Id>(orderIds));
    for (Id orderId : orderIds) {
      OrderCalloutService.sendOrderInformation(orderId);
    }
  }
}
