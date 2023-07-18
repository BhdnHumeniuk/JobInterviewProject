@IsTest
private class ProductControllerTest {
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
  static void testGetAvailableProducts() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    Order testOrder = TestDataFactory.createTestOrder(testAccount.Id, Test.getStandardPricebookId());
    insert testOrder;

    Test.startTest();
    List<ProductController.AvailableProductWrapper> products = ProductController.getAvailableProducts(testOrder.Id, 'Test Product');
    Test.stopTest();

    System.assertNotEquals(null, products, 'Product list should not be null');
    System.assertEquals(200, products.size(), 'Incorrect number of available products');
  }

  @IsTest
  static void testAddProductToOrder() {
    Account testAccount = [SELECT Id FROM Account LIMIT 1];
    Order testOrder = TestDataFactory.createTestOrder(testAccount.Id, Test.getStandardPricebookId());
    insert testOrder;

    List<PricebookEntry> testPricebookEntries = [SELECT Id FROM PricebookEntry WHERE IsActive = TRUE LIMIT 1];

    Test.startTest();
    ProductController.addProductToOrder(testOrder.Id, testPricebookEntries[0].Id);
    Test.stopTest();

    List<OrderItem> orderItems = [SELECT Id, Quantity FROM OrderItem WHERE OrderId = :testOrder.Id AND PricebookEntryId = :testPricebookEntries[0].Id];
    System.assertEquals(1, orderItems.size(), 'Order item should be added');
    System.assertEquals(1, orderItems[0].Quantity, 'Quantity should be 1 after adding the product');
  }
}
