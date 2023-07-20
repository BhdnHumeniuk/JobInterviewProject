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

    Pricebook2 testPricebook = new Pricebook2(Name = 'Test Pricebook');
    insert testPricebook;

    PricebookEntry testPricebookEntry = TestDataFactory.createTestPricebookEntry(testPricebook.Id, testProducts[0].Id);
    insert testPricebookEntry;
  }

  @IsTest
  static void testGetAvailablePricebookEntries() {
    List<Account> testAccounts = TestDataFactory.createTestAccounts(1);
    insert testAccounts;
    Account testAccount = testAccounts[0];
    Order testOrder = TestDataFactory.createTestOrder(testAccount.Id, Test.getStandardPricebookId());
    insert testOrder;

    Test.startTest();
    List<PricebookEntry> entries = ProductRepository.getAvailablePricebookEntries(testOrder.Id, 'Test Product');
    Test.stopTest();

    System.assertNotEquals(null, entries, 'Pricebook entries should not be null');
    System.assertEquals(1000, entries.size(), 'Incorrect number of pricebook entries');
  }

  @IsTest
  static void testGetPricebookEntries() {
    Pricebook2 testPricebook = [SELECT Id, Name FROM Pricebook2 LIMIT 1];
    PricebookEntry testPricebookEntry = [SELECT Id, Product2.Name, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :testPricebook.Id LIMIT 1];

    Test.startTest();
    PricebookEntry result = ProductRepository.getPricebookEntries(testPricebookEntry.Id);
    Test.stopTest();

    System.assertNotEquals(null, result);
    System.assertEquals(testPricebookEntry.Id, result.Id);
  }
}
