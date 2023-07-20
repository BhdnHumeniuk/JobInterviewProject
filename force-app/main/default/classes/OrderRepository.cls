/**
 * OrderRepository class provides methods to interact with Order and OrderItem objects in Salesforce.
 * It includes methods for querying order items, updating order status, and performing DML operations on order items.
 */
public with sharing class OrderRepository {
  // Returns a list of OrderItems for a given Order Id.
  public static List<OrderItem> getOrderItemsForOrder(Id orderId) {
    return [SELECT Id, Product2Id, OrderId, Product2.Name, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId];
  }

  // Returns a map of Order Ids to their respective Status values for a given set of Order Ids.
  public static Map<Id, String> getOrderStatusMapByIds(Set<Id> orderIds) {
    Map<Id, String> orderIdToStatus = new Map<Id, String>();
    for (Order order : [SELECT Id, Status FROM Order WHERE Id IN :orderIds]) {
      orderIdToStatus.put(order.Id, order.Status);
    }
    return orderIdToStatus;
  }

  // Returns the Pricebook associated with a given Order Id.
  public static Order getPricebookFromOrder(Id orderId) {
    return [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];
  }

  // Activates the orders with the specified Order Ids by updating their Status to 'Activated'.
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

  // Returns a list of OrderItems for a given set of OrderItem Ids.
  public static List<OrderItem> getAllOrderItemsForOrdersById(Set<Id> orderItemIds) {
    return [SELECT Id, Quantity FROM OrderItem WHERE Id IN :orderItemIds];
  }

  // Returns a list of OrderItems for a given Order Id and PricebookEntry Id.
  public static List<OrderItem> getAllOrderItem(Id orderIds, Id pricebookEntryIds) {
    return [SELECT Id, Quantity, OrderId, PricebookEntryId FROM OrderItem WHERE OrderId = :orderIds AND PricebookEntryId = :pricebookEntryIds];
  }

  // Upserts a list of OrderItems (inserts or updates) and catches any DML exceptions.
  public static void upsertOrderItems(List<OrderItem> orderItems) {
    try {
      upsert orderItems;
    } catch (DmlException ex) {
      System.debug('Error occurred while upserting order items: ' + ex.getMessage());
    }
  }

  // Upserts an OrderItem (inserts or updates) and catches any DML exceptions.
  public static void upsertOrderItem(OrderItem orderItems) {
    try {
      upsert orderItems;
    } catch (DmlException ex) {
      System.debug('Error occurred while upserting order items: ' + ex.getMessage());
    }
  }

  // Deletes a list of OrderItems and catches any DML exceptions.
  public static void deleteOrderItems(List<OrderItem> orderItems) {
    try {
      delete orderItems;
    } catch (DmlException ex) {
      System.debug('Error occurred while deleting order items: ' + ex.getMessage());
    }
  }
}
