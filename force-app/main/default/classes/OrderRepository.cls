public with sharing class OrderRepository {
  public static List<OrderItem> getOrderProduct(Id orderId) {
    return [SELECT Id, Product2.Name, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
  }

  public static Order getUpdatedOrder(Set<Id> orderIds) {
    return [SELECT Id, Status FROM Order WHERE Id IN :orderIds];
  }

  public static Map<Id, String> getOrderStatus(Set<Id> orderIds) {
    Map<Id, String> orderIdToStatus = new Map<Id, String>();
    for (Order order : [SELECT Id, Status FROM Order WHERE Id IN :orderIds]) {
      orderIdToStatus.put(order.Id, order.Status);
    }
    return orderIdToStatus;
  }

  public static void activateOrders(Set<Id> orderIds) {
    List<Order> ordersToUpdate = new List<Order>();
    for (Id orderId : orderIds) {
      ordersToUpdate.add(new Order(Id = orderId, Status = 'Activated'));
    }
    update ordersToUpdate;
  }

  public static List<OrderItem> getOrderItems(Set<Id> allOrderIds) {
    return [SELECT Product2Id, OrderId FROM OrderItem WHERE OrderId IN :allOrderIds];
  }

  public static List<OrderItem> getOrderItemsById(Set<Id> orderItemIds) {
    return [SELECT Id, Quantity FROM OrderItem WHERE Id = :orderItemIds];
  }

  public static List<OrderItem> getAllOrderItems(Set<Id> allOrderIds, Set<Id> pricebookEntryIds) {
    return [
      SELECT Id, Quantity, OrderId, PricebookEntryId
      FROM OrderItem
      WHERE OrderId IN :allOrderIds AND PricebookEntryId IN :pricebookEntryIds
    ];
  }

  public static void upsertOrderItems(List<OrderItem> orderItems) {
    upsert orderItems;
  }

  public static void deleteOrderItem(List<OrderItem> orderItem) {
    delete orderItem;
  }
}
