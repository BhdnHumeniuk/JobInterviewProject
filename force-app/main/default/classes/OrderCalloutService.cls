public with sharing class OrderCalloutService {
  @future(callout=true)
  public static void sendOrderInformation(Id orderId) {
    Order order = [SELECT Id, AccountId, OrderNumber, Type, Status FROM Order WHERE Id = :orderId LIMIT 1];
    List<OrderItem> orderItems = OrderRepository.getOrderItemsForOrder(orderId);

    Map<String, Object> requestBodyMap = new Map<String, Object>();
    requestBodyMap.put('accountNumber', order.AccountId);
    requestBodyMap.put('orderNumber', order.OrderNumber);
    requestBodyMap.put('type', order.Type);
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

    Confirmation_order_setting__c customSetting = Confirmation_order_setting__c.getInstance();

    String endpointUrl;
    if (customSetting != null && !String.isBlank(customSetting.URL__c)) {
      endpointUrl = customSetting.URL__c;
    } else {
      endpointUrl = 'https://default.requestcatcher.com';
    }

    HttpResponse response = CalloutService.makePostCallout(endpointUrl, requestBody);

    if (response.getStatusCode() == 200) {
      System.debug('Callout successful. Response: ' + response.getBody());
    } else {
      System.debug('Callout failed with error. Status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
    }
  }
}
