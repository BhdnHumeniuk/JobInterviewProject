public with sharing class ProductController {
  @AuraEnabled(cacheable=true)
  public static List<AvailableProductWrapper> getAvailableProducts(Id orderId, String searchKeyword) {
    List<AvailableProductWrapper> products = new List<AvailableProductWrapper>();
    List<PricebookEntry> pricebookEntries = ProductRepository.getAvailablePricebookEntries(orderId, searchKeyword);

    if (orderId != null) {
      List<OrderItem> orderItems = [SELECT Product2Id FROM OrderItem WHERE OrderId = :orderId];

      for (OrderItem item : orderItems) {
        for (PricebookEntry entry : pricebookEntries) {
          if (entry.Product2Id == item.Product2Id) {
            products.add(new AvailableProductWrapper(entry, true));
            break;
          }
        }
      }
    }

    for (PricebookEntry entry : pricebookEntries) {
      if (!isProductAlreadyAdded(products, entry.Product2Id)) {
        products.add(new AvailableProductWrapper(entry, false));
      }
    }

    return products;
  }

  @AuraEnabled
  public static void addProductToOrder(Id orderId, Id pricebookEntryId) {
    PricebookEntry entry = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Id = :pricebookEntryId];
    OrderItem orderItem = ProductRepository.getOrderItem(orderId, pricebookEntryId);

    if (orderItem != null) {
      orderItem.Quantity += 1;
    } else {
      orderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, Quantity = 1, UnitPrice = entry.UnitPrice);
    }

    ProductRepository.upsertOrderItem(orderItem);
  }

  private static Boolean isProductAlreadyAdded(List<AvailableProductWrapper> products, Id productId) {
    for (AvailableProductWrapper product : products) {
      if (product.pricebookEntry.Product2Id == productId) {
        return true;
      }
    }
    return false;
  }

  public class AvailableProductWrapper {
    @AuraEnabled
    public PricebookEntry pricebookEntry { get; set; }

    @AuraEnabled
    public Boolean isAddedToOrder { get; set; }

    public AvailableProductWrapper(PricebookEntry entry, Boolean isAdded) {
      pricebookEntry = entry;
      isAddedToOrder = isAdded;
    }
  }
}
