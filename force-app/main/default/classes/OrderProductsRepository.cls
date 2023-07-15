public with sharing class OrderProductsRepository {
  @AuraEnabled(cacheable=true)
  public static List<OrderItem> getOrderProducts(Id orderId) {
    return [SELECT Id, Product2.Name, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
  }

  @AuraEnabled
  public static void deleteProductFromOrder(Id orderId, Id orderItemId) {
    OrderItem orderItem = new OrderItem(Id = orderItemId);
    delete orderItem;
  }

  @AuraEnabled
  public static void activateOrder(Id orderId) {
    Order order = new Order(Id = orderId);
    List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :orderId];

    update order;
    update orderItems;
  }
}
