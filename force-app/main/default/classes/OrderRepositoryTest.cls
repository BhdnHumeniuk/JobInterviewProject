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
  static void testGetOrderItemsForOrder() {
    List<OrderItem> orderItems = OrderRepository.getOrderItemsForOrder([SELECT Id FROM Order LIMIT 1][0].Id);

    System.assertNotEquals(0, orderItems.size(), 'No OrderItem records found');
    for (OrderItem item : orderItems) {
      System.assertNotEquals(null, item.Product2.Name, 'Product Name is null');
      System.assertNotEquals(null, item.Quantity, 'Quantity is null');
      System.assertNotEquals(null, item.UnitPrice, 'UnitPrice is null');
    }
  }

  @IsTest
  static void testGetOrderStatusMapByIds() {
    Set<Id> orderIds = new Set<Id>();
    orderIds.add([SELECT Id FROM Order LIMIT 1][0].Id);

    Map<Id, String> orderStatusMap = OrderRepository.getOrderStatusMapByIds(orderIds);

    System.assertNotEquals(0, orderStatusMap.size(), 'No Order records found');
    System.assertNotEquals(null, orderStatusMap.get(orderIds.iterator().next()), 'Order Status is null');
  }

  @IsTest
  static void testGetPricebookFromOrder() {
    Id orderId = [SELECT Id FROM Order LIMIT 1][0].Id;
    Order order = OrderRepository.getPricebookFromOrder(orderId);

    System.assertNotEquals(null, order, 'Order not found');
    System.assertNotEquals(null, order.Pricebook2Id, 'Pricebook2Id is null');
  }

  @IsTest
  static void testActivateOrdersByIds() {
    Set<Id> orderIds = new Set<Id>();
    orderIds.add([SELECT Id FROM Order WHERE Status = 'Draft' LIMIT 1][0].Id);

    Test.startTest();
    OrderRepository.activateOrdersByIds(orderIds);
    Test.stopTest();

    Order updatedOrder = [SELECT Id, Status FROM Order WHERE Id = :orderIds.iterator().next() LIMIT 1];
    System.assertEquals('Activated', updatedOrder.Status, 'Order not activated');
  }

  @IsTest
  static void testGetAllOrderItemsForOrdersById() {
    Set<Id> orderItemIds = new Set<Id>();
    orderItemIds.add([SELECT Id FROM OrderItem LIMIT 1][0].Id);

    List<OrderItem> orderItems = OrderRepository.getAllOrderItemsForOrdersById(orderItemIds);

    System.assertNotEquals(0, orderItems.size(), 'No OrderItem records found');
    for (OrderItem item : orderItems) {
      System.assertNotEquals(null, item.Quantity, 'Quantity is null');
    }
  }

  // @IsTest
  // static void testGetAllOrderItems() {
  //   Set<Id> allOrderIds = new Set<Id>();
  //   allOrderIds.add([SELECT Id FROM Order LIMIT 1][0].Id);

  //   Set<Id> pricebookEntryIds = new Set<Id>();
  //   pricebookEntryIds.add([SELECT Id FROM PricebookEntry LIMIT 1][0].Id);

  //   List<OrderItem> orderItems = OrderRepository.getAllOrderItems(allOrderIds, pricebookEntryIds);

  //   System.assertNotEquals(0, orderItems.size(), 'No OrderItem records found');
  //   for (OrderItem item : orderItems) {
  //     System.assertNotEquals(null, item.Quantity, 'Quantity is null');
  //     System.assertNotEquals(null, item.OrderId, 'OrderId is null');
  //     System.assertNotEquals(null, item.PricebookEntryId, 'PricebookEntryId is null');
  //   }
  // }

  @IsTest
  static void testUpsertOrderItems() {
    List<OrderItem> testOrderItems = [SELECT Id, Quantity FROM OrderItem LIMIT 1];
    testOrderItems[0].Quantity = 3;

    Test.startTest();
    OrderRepository.upsertOrderItems(testOrderItems);
    Test.stopTest();

    OrderItem updatedOrderItem = [SELECT Id, Quantity FROM OrderItem WHERE Id = :testOrderItems[0].Id LIMIT 1];
    System.assertEquals(3, updatedOrderItem.Quantity, 'OrderItem not upserted');
  }

  @IsTest
  static void testDeleteOrderItem() {
    List<OrderItem> testOrderItems = [SELECT Id FROM OrderItem LIMIT 1];

    Test.startTest();
    OrderRepository.deleteOrderItem(testOrderItems);
    Test.stopTest();

    List<OrderItem> deletedOrderItems = [SELECT Id FROM OrderItem WHERE Id = :testOrderItems[0].Id];
    System.assertEquals(0, deletedOrderItems.size(), 'OrderItem not deleted');
  }
}
