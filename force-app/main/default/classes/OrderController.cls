/**
 * OrderController class provides Aura-enabled methods to interact with the OrderRepository class and perform actions on Orders.
 * It includes methods to get order products, delete products from an order, get order statuses, and activate orders.
 */
public with sharing class OrderController {
  // Returns a list of OrderItems for a given Order Id by calling the corresponding method in OrderRepository.
  @AuraEnabled(cacheable=true)
  public static List<OrderItem> getOrderProducts(Id orderId) {
    return OrderRepository.getOrderItemsForOrder(orderId);
  }

  // Deletes products (OrderItems) from an order based on the given list of OrderItem Ids by calling the corresponding method in OrderRepository.
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
      OrderRepository.deleteOrderItems(itemsToDelete);
    }
  }

  // Returns a map of Order Ids to their respective Status values for a given list of Order Ids by calling the corresponding method in OrderRepository.
  @AuraEnabled
  public static Map<Id, String> getOrderStatus(List<Id> orderIds) {
    Map<Id, String> orderStatusMap = OrderRepository.getOrderStatusMapByIds(new Set<Id>(orderIds));
    return orderStatusMap;
  }

  // Activates orders with the specified list of Order Ids by calling the corresponding method in OrderRepository.
  @AuraEnabled
  public static void activateOrder(List<Id> orderIds) {
    OrderRepository.activateOrdersByIds(new Set<Id>(orderIds));
    for (Id orderId : orderIds) {
      OrderCalloutService.sendOrderInformation(orderId);
    }
  }
}
