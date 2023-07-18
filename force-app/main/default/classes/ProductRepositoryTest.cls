@IsTest
private class ProductRepositoryTest {
  @TestSetup
  static void setupTestData() {
    Account testAccount = TestDataFactory.createTestAccount('Test Account');
    insert testAccount;

    List<Product2> testProducts = TestDataFactory.createTestProducts(1000);
    insert testProducts;

    Id pricebookId = Test.getStandardPricebookId();
    List<PricebookEntry> testPricebookEntries = TestDataFactory.createTestPricebookEntries(pricebookId, testProducts);
    insert testPricebookEntries;

    List<Order> testOrders = TestDataFactory.createTestOrders(new List<Account>{ testAccount }, pricebookId);
    insert testOrders;

    List<OrderItem> testOrderItems = TestDataFactory.createTestOrderItems(testOrders, testPricebookEntries);
    insert testOrderItems;
  }

  @IsTest
  static void testGetAvailablePricebookEntries() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    Order testOrder = TestDataFactory.createTestOrder(testAccount.Id, Test.getStandardPricebookId());
    insert testOrder;

    Test.startTest();
    List<PricebookEntry> entries = ProductRepository.getAvailablePricebookEntries(testOrder.Id, 'Test Product');
    Test.stopTest();

    System.assertNotEquals(null, entries, 'Pricebook entries should not be null');
    System.assertEquals(1000, entries.size(), 'Incorrect number of pricebook entries');
  }

  // @IsTest
  // static void testGetOrderItem() {
  //   List<Order> testOrders = [SELECT Id FROM Order LIMIT 1];
  //   List<PricebookEntry> testPricebookEntries = [SELECT Id FROM PricebookEntry WHERE IsActive = TRUE LIMIT 1];

  //   Test.startTest();
  //   OrderItem result = ProductRepository.getOrderItem(testOrders[0].Id, testPricebookEntries[0].Id);
  //   Test.stopTest();

  //   System.assertNotEquals(null, result, 'OrderItem should not be null');
  //   System.assertEquals(testOrders[0].Id, result.OrderId, 'OrderIds should match');
  //   System.assertEquals(testPricebookEntries[0].Id, result.PricebookEntryId, 'PricebookEntryIds should match');
  //   System.assertEquals(2, result.Quantity, 'Quantity should match');
  //   System.assertEquals(100, result.UnitPrice, 'UnitPrice should match');
  // }

  @IsTest
  static void testGetOrderItem_OrderItemNotFound() {
    List<Order> testOrders = [SELECT Id FROM Order LIMIT 1];

    Test.startTest();
    OrderItem result = ProductRepository.getOrderItem(testOrders[0].Id, null);
    Test.stopTest();

    System.assertEquals(null, result, 'OrderItem should be null when not found');
  }

  @IsTest
  static void testUpsertOrderItem() {
    List<Order> testOrders = [SELECT Id FROM Order LIMIT 1];
    List<PricebookEntry> testPricebookEntries = [SELECT Id FROM PricebookEntry WHERE IsActive = TRUE LIMIT 1];

    OrderItem testOrderItem = TestDataFactory.createTestOrderItem(testOrders[0].Id, testPricebookEntries[0].Id);

    Test.startTest();
    ProductRepository.upsertOrderItem(testOrderItem);
    Test.stopTest();

    System.assertNotEquals(null, testOrderItem.Id, 'OrderItem Id should not be null');
  }
}
