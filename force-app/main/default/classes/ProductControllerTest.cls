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

    List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry LIMIT 1];
    OrderItem existingOrderItem = new OrderItem(OrderId = testOrder.Id, PricebookEntryId = pricebookEntries[0].Id, Quantity = 2, UnitPrice = pricebookEntries[0].UnitPrice);
    insert existingOrderItem;

    Test.startTest();
    ProductController.addProductToOrder(testOrder.Id, pricebookEntries[0].Id);
    Test.stopTest();

    OrderItem updatedOrderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :existingOrderItem.Id];
    System.assertEquals(3, updatedOrderItem.Quantity, 'Incorrect quantity after adding the product to the order');
  }
}
