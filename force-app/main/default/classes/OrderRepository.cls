public with sharing class OrderRepository {
  public static List<OrderItem> getOrderProducts(Id orderId) {
    return [SELECT Id, Product2.Name, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
  }

  public static Order getUpdatedOrder(Id orderId) {
    return [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
  }

  public static String getOrderStatus(Id orderId) {
    Order order = [SELECT Status FROM Order WHERE Id = :orderId LIMIT 1];
    return order.Status;
  }

  public static void activateOrder(Id orderId) {
    Order orderToUpdate = new Order(Id = orderId, Status = 'Activated');
    update orderToUpdate;
  }

  public static List<OrderItem> getOrderItems(Set<Id> allOrderIds) {
    return [SELECT Product2Id, OrderId FROM OrderItem WHERE OrderId IN :allOrderIds];
  }

  public static List<OrderItem> getAllOrderItems(Set<Id> allOrderIds, Set<Id> pricebookEntryIds) {
    return [
      SELECT Id, Quantity, OrderId, PricebookEntryId
      FROM OrderItem
      WHERE OrderId IN :allOrderIds AND PricebookEntryId IN :pricebookEntryIds
    ];
  }

  public static void upsertOrderItem(OrderItem orderItem) {
    upsert orderItem;
  }

  public static void upsertOrderItems(List<OrderItem> orderItems) {
    upsert orderItems;
  }

  public static void deleteOrderItem(OrderItem orderItem) {
    delete orderItem;
  }
}
