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

  @AuraEnabled(cacheable=true)
  public static Order getUpdatedOrder(Id orderId) {
    return [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
  }

  @AuraEnabled
  public static String getOrderStatus(Id orderId) {
    Order order = [SELECT Status FROM Order WHERE Id = :orderId LIMIT 1];
    return order.Status;
  }

  @AuraEnabled
  public static void activateOrder(Id orderId) {
    Order orderToUpdate = new Order(Id = orderId, Status = 'Activated');
    update orderToUpdate;
    sendOrderInformation(orderId);
  }

  private static void sendOrderInformation(Id orderId) {
    Order order = [SELECT Id, AccountId, OrderNumber, Status FROM Order WHERE Id = :orderId LIMIT 1];
    List<OrderItem> orderItems = getOrderProducts(orderId);

    Map<String, Object> requestBodyMap = new Map<String, Object>();
    requestBodyMap.put('accountNumber', order.AccountId);
    requestBodyMap.put('orderNumber', order.OrderNumber);
    requestBodyMap.put('type', 'order type');
    requestBodyMap.put('status', order.Status);

    List<Map<String, Object>> orderProductsList = new List<Map<String, Object>>();
    for (OrderItem item : orderItems) {
      Map<String, Object> orderProductMap = new Map<String, Object>();
      orderProductMap.put('name', item.Product2.Name);
      orderProductMap.put('code', item.Product2Id);
      orderProductMap.put('unitPrice', item.UnitPrice);
      orderProductMap.put('quantity', item.Quantity);
      orderProductsList.add(orderProductMap);
    }
    requestBodyMap.put('orderProducts', orderProductsList);

    String requestBody = JSON.serialize(requestBodyMap);

    String endpointUrl = 'https://myproject.requestcatcher.com/test';
    HttpResponse response = CalloutService.makePostCallout(endpointUrl, requestBody);

    if (response.getStatusCode() == 200) {
      System.debug('Callout successful. Response: ' + response.getBody());
    } else {
      System.debug('Callout failed with error. Status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
    }
  }
}
