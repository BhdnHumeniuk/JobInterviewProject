@IsTest
public class OrderRepositoryTest {
  @TestSetup
  static void setupTestData() {
    List<Product2> products = TestDataFactory.createTestProducts(1000);
    insert products;

    Id standardPricebookId = Test.getStandardPricebookId();
    List<PricebookEntry> pricebookEntries = TestDataFactory.createTestPricebookEntries(standardPricebookId, products);
    insert pricebookEntries;

    Account testAccount = TestDataFactory.createTestAccount('Test Account');
    insert testAccount;

    Order testOrder = TestDataFactory.createTestOrder(testAccount.Id, standardPricebookId);
    insert testOrder;

    List<OrderItem> testOrderItems = TestDataFactory.createTestOrderItems(new List<Order>{ testOrder }, pricebookEntries);
    insert testOrderItems;
  }

  @IsTest
  static void testGetOrderProducts() {
    List<OrderItem> orderItems = OrderRepository.getOrderProducts([SELECT Id FROM Order LIMIT 1][0].Id);

    System.assertNotEquals(0, orderItems.size(), 'No OrderItem records found');
    for (OrderItem item : orderItems) {
      System.assertNotEquals(null, item.Product2.Name, 'Product Name is null');
      System.assertNotEquals(null, item.Quantity, 'Quantity is null');
      System.assertNotEquals(null, item.UnitPrice, 'UnitPrice is null');
    }
  }

  @IsTest
  static void testGetUpdatedOrder() {
    Id orderId = [SELECT Id FROM Order LIMIT 1][0].Id;
    Order updatedOrder = OrderRepository.getUpdatedOrder(orderId);

    System.assertNotEquals(null, updatedOrder, 'Order not found');
    System.assertNotEquals(null, updatedOrder.Status, 'Order Status is null');
  }

  @IsTest
  static void testGetOrderStatus() {
    Id orderId = [SELECT Id FROM Order LIMIT 1][0].Id;
    String orderStatus = OrderRepository.getOrderStatus(orderId);

    System.assertNotEquals(null, orderStatus, 'Order Status is null');
  }

  @IsTest
  static void testActivateOrder() {
    Id orderId = [SELECT Id FROM Order WHERE Status = 'Draft' LIMIT 1][0].Id;

    Test.startTest();
    OrderRepository.activateOrder(orderId);
    Test.stopTest();

    Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :orderId LIMIT 1];
    System.assertEquals('Activated', updatedOrder.Status, 'Order not activated');
  }

  @IsTest
  static void testUpsertOrderItem() {
    OrderItem testOrderItem = [SELECT Id FROM OrderItem LIMIT 1];
    testOrderItem.Quantity = 3;

    Test.startTest();
    OrderRepository.upsertOrderItem(testOrderItem);
    Test.stopTest();

    OrderItem updatedOrderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :testOrderItem.Id LIMIT 1];
    System.assertEquals(3, updatedOrderItem.Quantity, 'OrderItem not upserted');
  }

  @IsTest
  static void testDeleteOrderItem() {
    OrderItem testOrderItem = [SELECT Id FROM OrderItem LIMIT 1];

    Test.startTest();
    OrderRepository.deleteOrderItem(testOrderItem);
    Test.stopTest();

    List<OrderItem> deletedOrderItems = [SELECT Id FROM OrderItem WHERE Id = :testOrderItem.Id];
    System.assertEquals(0, deletedOrderItems.size(), 'OrderItem not deleted');
  }
}
