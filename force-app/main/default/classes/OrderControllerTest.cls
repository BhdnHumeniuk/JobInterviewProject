@IsTest
private class OrderControllerTest {
  @TestSetup
  static void setupTestData() {
    Account testAccount = TestDataFactory.createTestAccount('Test Account');
    insert testAccount;

    List<Product2> testProducts = TestDataFactory.createTestProducts(200);
    insert testProducts;

    Id pricebookId = Test.getStandardPricebookId();

    List<Order> testOrders = TestDataFactory.createTestOrdersWithProducts(new List<Account>{ testAccount }, pricebookId, testProducts);
  }

  @IsTest
  static void testGetOrderProducts() {
    List<Order> testOrders = [SELECT Id FROM Order LIMIT 1];
    if (testOrders.isEmpty()) {
      System.assert(false, 'No test orders found');
      return;
    }

    Test.startTest();
    List<OrderItem> result = OrderController.getOrderProducts(testOrders[0].Id);
    Test.stopTest();

    System.assertNotEquals(null, result, 'Order items should not be null');
  }

  @IsTest
  static void testDeleteProductFromOrder() {
    List<OrderItem> testOrderItems = [SELECT Id, Quantity FROM OrderItem WHERE Quantity > 1 LIMIT 1];
    if (testOrderItems.isEmpty()) {
      System.assert(false, 'No test order items with quantity > 1 found');
      return;
    }
    OrderItem testOrderItem = testOrderItems[0];

    Test.startTest();
    OrderController.deleteProductFromOrder(testOrderItem.Id);
    Test.stopTest();

    OrderItem updatedOrderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :testOrderItem.Id LIMIT 1];

    if (updatedOrderItem == null) {
      System.assert(false, 'Order item not found after deletion');
    } else {
      if (testOrderItem.Quantity > 1) {
        System.assertEquals(testOrderItem.Quantity - 1, updatedOrderItem.Quantity, 'Order item quantity not decremented correctly');
      } else {
        System.assertEquals(null, updatedOrderItem, 'Order item should be deleted');

        List<OrderItem> deletedOrderItems = [SELECT Id FROM OrderItem WHERE Id = :testOrderItem.Id];
        System.assertEquals(0, deletedOrderItems.size(), 'OrderRepository.deleteOrderItem method was not called or did not delete the order item');
      }
    }
  }

  @IsTest
  static void testGetOrderStatus() {
    List<Order> testOrders = [SELECT Id FROM Order LIMIT 1];
    if (testOrders.isEmpty()) {
      System.assert(false, 'No test orders found');
      return;
    }

    Test.startTest();
    String result = OrderController.getOrderStatus(testOrders[0].Id);
    Test.stopTest();

    System.assertNotEquals(null, result, 'Order status should not be null');
  }

  @IsTest
  static void testActivateOrder() {
    Account testAccount = TestDataFactory.createTestAccount('Test Account');
    insert testAccount;

    List<Product2> testProducts = TestDataFactory.createTestProducts(5);
    insert testProducts;

    Id pricebookId = Test.getStandardPricebookId();

    List<Order> testOrders = TestDataFactory.createTestOrdersWithProducts(new List<Account>{ testAccount }, pricebookId, testProducts);
    System.assertEquals(1, testOrders.size(), 'Expected one test order to be created');

    Order testOrder = testOrders[0];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new HttpCalloutMockTest());
    OrderController.activateOrder(testOrder.Id);
    Test.stopTest();

    Order activatedOrder = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id];
    System.assertEquals('Activated', activatedOrder.Status, 'Order status should be "Activated" after activation');
  }
}
