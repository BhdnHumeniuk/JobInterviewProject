/**
 * CalloutService class provides a static method to make HTTP POST callouts.
 * It includes a method to create and send an HTTP request with the specified endpoint URL and request body.
 */
@IsTest
public class TestDataFactory {
  public static Account createTestAccount(String name) {
    return new Account(Name = name);
  }

  public static List<Account> createTestAccounts(Integer count) {
    List<Account> accounts = new List<Account>();
    for (Integer i = 0; i < count; i++) {
      accounts.add(new Account(Name = 'Test Account ' + i));
    }
    return accounts;
  }

  public static Product2 createTestProduct(String name, Boolean isActive, String family) {
    return new Product2(Name = name, IsActive = isActive, Family = family);
  }

  public static List<Product2> createTestProducts(Integer count) {
    List<Product2> products = new List<Product2>();
    for (Integer i = 0; i < count; i++) {
      products.add(new Product2(Name = 'Test Product ' + i, IsActive = true, Family = 'Test Family ' + i));
    }
    return products;
  }

  public static PricebookEntry createTestPricebookEntry(Id pricebookId, Id productId) {
    return new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = productId, IsActive = true, UnitPrice = 100);
  }

  public static List<PricebookEntry> createTestPricebookEntries(Id pricebookId, List<Product2> products) {
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    for (Product2 product : products) {
      pricebookEntries.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, IsActive = true, UnitPrice = 100));
    }
    return pricebookEntries;
  }

  public static Order createTestOrder(Id accountId, Id pricebookId) {
    return new Order(AccountId = accountId, Pricebook2Id = pricebookId, Status = 'Draft', EffectiveDate = Date.today(), EndDate = Date.today().addDays(4));
  }

  public static List<Order> createTestOrders(List<Account> accounts, Id pricebookId) {
    List<Order> orders = new List<Order>();
    for (Account account : accounts) {
      orders.add(new Order(AccountId = account.Id, Pricebook2Id = pricebookId, Status = 'Draft', EffectiveDate = Date.today(), EndDate = Date.today().addDays(4)));
    }
    return orders;
  }

  public static OrderItem createTestOrderItem(Id orderId, Id pricebookEntryId) {
    return new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, Quantity = 2, UnitPrice = 100);
  }

  public static List<OrderItem> createTestOrderItems(List<Order> orders, List<PricebookEntry> pricebookEntries) {
    List<OrderItem> orderItems = new List<OrderItem>();
    for (Integer i = 0; i < orders.size(); i++) {
      OrderItem orderItem = new OrderItem();
      orderItem.OrderId = orders[i].Id;
      orderItem.PricebookEntryId = pricebookEntries[i].Id;
      orderItem.Quantity = 2;
      orderItem.UnitPrice = 100;
      orderItems.add(orderItem);
    }
    return orderItems;
  }

  public static List<Order> createTestOrdersWithProducts(List<Account> accounts, Id pricebookId, List<Product2> products) {
    List<Order> orders = new List<Order>();
    List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
    for (Product2 product : products) {
      pricebookEntries.add(new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, IsActive = true, UnitPrice = 100));
    }
    insert pricebookEntries;

    for (Account account : accounts) {
      Order testOrder = new Order(AccountId = account.Id, Pricebook2Id = pricebookId, Status = 'Draft', EffectiveDate = Date.today(), EndDate = Date.today().addDays(4));
      insert testOrder;

      List<OrderItem> orderItems = new List<OrderItem>();
      for (PricebookEntry entry : pricebookEntries) {
        orderItems.add(new OrderItem(OrderId = testOrder.Id, PricebookEntryId = entry.Id, Quantity = 2, UnitPrice = 100));
      }
      insert orderItems;

      orders.add(testOrder);
    }
    return orders;
  }
}
