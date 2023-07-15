public with sharing class AvailableProductsRepository {
  @AuraEnabled(cacheable=true)
  public static List<ProductWrapper> getAvailableProducts(Id orderId, String searchKeyword) {
    List<ProductWrapper> products = new List<ProductWrapper>();

    Order order = [SELECT Pricebook2Id FROM Order WHERE Id = :orderId];

    List<PricebookEntry> pricebookEntries = [
      SELECT Id, Product2.Name, UnitPrice
      FROM PricebookEntry
      WHERE Pricebook2Id = :order.Pricebook2Id AND IsActive = TRUE AND Product2.Name LIKE :('%' + searchKeyword + '%')
    ];

    if (orderId != null) {
      List<OrderItem> orderItems = [SELECT Product2Id FROM OrderItem WHERE OrderId = :orderId];

      for (OrderItem item : orderItems) {
        for (PricebookEntry entry : pricebookEntries) {
          if (entry.Product2Id == item.Product2Id) {
            products.add(new ProductWrapper(entry, true));
            break;
          }
        }
      }
    }

    for (PricebookEntry entry : pricebookEntries) {
      if (!isProductAlreadyAdded(products, entry.Product2Id)) {
        products.add(new ProductWrapper(entry, false));
      }
    }

    return products;
  }

  @AuraEnabled
  public static void addProductToOrder(Id orderId, Id pricebookEntryId) {
    PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :pricebookEntryId];

    OrderItem orderItem;
    try {
      orderItem = [SELECT Id, Quantity, UnitPrice FROM OrderItem WHERE OrderId = :orderId AND PricebookEntryId = :pricebookEntryId LIMIT 1];
    } catch (QueryException e) {
      orderItem = null;
    }

    if (orderItem != null) {
      orderItem.Quantity += 1;
    } else {
      orderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, Quantity = 1, UnitPrice = entry.UnitPrice);
    }

    upsert orderItem;
  }

  private static Boolean isProductAlreadyAdded(List<ProductWrapper> products, Id productId) {
    for (ProductWrapper product : products) {
      if (product.pricebookEntry.Product2Id == productId) {
        return true;
      }
    }
    return false;
  }

  public class ProductWrapper {
    @AuraEnabled
    public PricebookEntry pricebookEntry { get; set; }

    @AuraEnabled
    public Boolean isAddedToOrder { get; set; }

    public ProductWrapper(PricebookEntry entry, Boolean isAdded) {
      pricebookEntry = entry;
      isAddedToOrder = isAdded;
    }
  }
}
