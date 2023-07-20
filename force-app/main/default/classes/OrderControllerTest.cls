@IsTest
public class OrderControllerTest {
  @TestSetup
  static void setupTestData() {
    List<Account> testAccounts = TestDataFactory.createTestAccounts(2);
    insert testAccounts;

    List<Product2> testProducts = TestDataFactory.createTestProducts(5);
    insert testProducts;

    Id pricebookId = Test.getStandardPricebookId();
    List<PricebookEntry> testPricebookEntries = TestDataFactory.createTestPricebookEntries(pricebookId, testProducts);
    insert testPricebookEntries;

    List<Order> testOrders = TestDataFactory.createTestOrders(testAccounts, pricebookId);
    insert testOrders;

    List<OrderItem> testOrderItems = TestDataFactory.createTestOrderItems(testOrders, testPricebookEntries);
    insert testOrderItems;
  }

  @IsTest
  static void testGetOrderProducts() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();
    List<OrderItem> orderProducts = OrderController.getOrderProducts(testOrder.Id);
    Test.stopTest();

    System.assertNotEquals(null, orderProducts, 'Order products should not be null');
    System.assertNotEquals(0, orderProducts.size(), 'No order products found');
  }

  @IsTest
  static void testDeleteProductFromOrder() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];
    List<OrderItem> testOrderItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :testOrder.Id LIMIT 1];

    testOrderItems[0].Quantity = 2;
    update testOrderItems;

    Test.startTest();
    OrderController.deleteProductFromOrder(new List<Id>{ testOrderItems[0].Id });
    Test.stopTest();

    List<OrderItem> updatedOrderItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :testOrder.Id];
    System.assertEquals(1, updatedOrderItems.size(), 'Order item should be updated or deleted');
  }

  @IsTest
  static void testGetOrderStatus() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();
    Map<Id, String> orderStatusMap = OrderController.getOrderStatus(new List<Id>{ testOrder.Id });
    Test.stopTest();

    System.assertNotEquals(null, orderStatusMap, 'Order status map should not be null');
    System.assertEquals(1, orderStatusMap.size(), 'Incorrect number of orders in the map');
    System.assertEquals('Draft', orderStatusMap.get(testOrder.Id), 'Incorrect order status');
  }

  @IsTest
  static void testActivateOrder() {
    Order testOrder = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();
    OrderController.activateOrder(new List<Id>{ testOrder.Id });
    Test.stopTest();

    List<Order> activatedOrders = [SELECT Id, Status FROM Order WHERE Id = :testOrder.Id AND Status = 'Activated'];
    System.assertEquals(1, activatedOrders.size(), 'Order should be activated');
    System.assertEquals(1, Limits.getDMLStatements(), 'One DML statement should have been used for activation');
  }
}
