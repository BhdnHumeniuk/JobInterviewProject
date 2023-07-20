public with sharing class OrderRepository {
  public static List<OrderItem> getOrderItemsForOrder(Id orderId) {
    return [SELECT Id, Product2Id, OrderId, Product2.Name, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
  }

  public static Map<Id, String> getOrderStatusMapByIds(Set<Id> orderIds) {
    Map<Id, String> orderIdToStatus = new Map<Id, String>();
    for (Order order : [SELECT Id, Status FROM Order WHERE Id IN :orderIds]) {
      orderIdToStatus.put(order.Id, order.Status);
    }
    return orderIdToStatus;
  }

  public static Order getPricebookFromOrder(Id orderId) {
    return [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];
  }

  public static void activateOrdersByIds(Set<Id> orderIds) {
    List<Order> ordersToUpdate = new List<Order>();
    for (Id orderId : orderIds) {
      ordersToUpdate.add(new Order(Id = orderId, Status = 'Activated'));
    }

    try {
      update ordersToUpdate;
    } catch (DmlException ex) {
      System.debug('Error occurred while updating orders: ' + ex.getMessage());
    }
  }

  public static List<OrderItem> getAllOrderItemsForOrdersById(Set<Id> orderItemIds) {
    return [SELECT Id, Quantity FROM OrderItem WHERE Id IN :orderItemIds];
  }

  public static OrderItem getAllOrderItems(Id allOrderIds, Id pricebookEntryIds) {
    return [
      SELECT Id, Quantity, OrderId, PricebookEntryId
      FROM OrderItem
      WHERE OrderId = :allOrderIds AND PricebookEntryId = :pricebookEntryIds
    ];
  }

  public static void upsertOrderItems(List<OrderItem> orderItems) {
    try {
      upsert orderItems;
    } catch (DmlException ex) {
      System.debug('Error occurred while upserting order items: ' + ex.getMessage());
    }
  }

  public static void upsertOrderItem(OrderItem orderItems) {
    try {
      upsert orderItems;
    } catch (DmlException ex) {
      System.debug('Error occurred while upserting order items: ' + ex.getMessage());
    }
  }

  public static void deleteOrderItems(List<OrderItem> orderItems) {
    try {
      delete orderItems;
    } catch (DmlException ex) {
      System.debug('Error occurred while deleting order items: ' + ex.getMessage());
    }
  }
}
