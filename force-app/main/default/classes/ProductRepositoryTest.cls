@IsTest
private class ProductRepositoryTest {
  @TestSetup
  static void setupTestData() {
    Account testAccount = TestDataFactory.createTestAccount('Test Account');
    insert testAccount;

    List<Product2> testProducts = TestDataFactory.createTestProducts(5);
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
    System.assertEquals(5, entries.size(), 'Incorrect number of pricebook entries');
  }

  @IsTest
  static void testGetPricebookEntriesMapByIds() {
    List<PricebookEntry> testPricebookEntries = [SELECT Id FROM PricebookEntry WHERE IsActive = TRUE LIMIT 1];

    Test.startTest();
    Set<Id> pricebookEntryIds = new Set<Id>{ testPricebookEntries[0].Id };
    Map<Id, PricebookEntry> entriesMap = ProductRepository.getPricebookEntriesMapByIds(pricebookEntryIds);
    Test.stopTest();

    System.assertNotEquals(null, entriesMap, 'Pricebook entries map should not be null');
    System.assertEquals(1, entriesMap.size(), 'Incorrect number of pricebook entries in the map');
    System.assertEquals(testPricebookEntries[0].Id, entriesMap.get(testPricebookEntries[0].Id).Id, 'Incorrect PricebookEntry in the map');
  }
}
