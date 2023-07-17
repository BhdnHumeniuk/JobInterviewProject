public with sharing class OrderController {
  @AuraEnabled(cacheable=true)
  public static List<OrderItem> getOrderProducts(Id orderId) {
    return OrderRepository.getOrderProducts(orderId);
  }

  @AuraEnabled
  public static void deleteProductFromOrder(Id orderItemId) {
    OrderItem orderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :orderItemId LIMIT 1];
    if (orderItem != null) {
      if (orderItem.Quantity > 1) {
        orderItem.Quantity--;
        OrderRepository.upsertOrderItem(orderItem);
      } else {
        OrderRepository.deleteOrderItem(orderItem);
      }
    }
  }

  @AuraEnabled
  public static String getOrderStatus(Id orderId) {
    return OrderRepository.getOrderStatus(orderId);
  }

  @AuraEnabled
  public static void activateOrder(Id orderId) {
    OrderRepository.activateOrder(orderId);
    OrderCalloutService.sendOrderInformation(orderId);
  }
}
