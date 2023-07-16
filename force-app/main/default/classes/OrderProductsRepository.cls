public with sharing class OrderProductsRepository {
  @AuraEnabled(cacheable=true)
  public static List<OrderItem> getOrderProducts(Id orderId) {
    return [SELECT Id, Product2.Name, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
  }

  @AuraEnabled
  public static void deleteProductFromOrder(Id orderItemId) {
    OrderItem orderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :orderItemId LIMIT 1];
    if (orderItem != null) {
      if (orderItem.Quantity > 1) {
        orderItem.Quantity--;
        update orderItem;
      } else {
        delete orderItem;
      }
    }
  }

  @AuraEnabled
  public static void activateOrder(Id orderId) {
    Order orderToUpdate = new Order(Id = orderId, Status = 'Activated');
    update orderToUpdate;
  }

  @AuraEnabled(cacheable=true)
  public static Order getUpdatedOrder(Id orderId) {
    return [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
  }
}
