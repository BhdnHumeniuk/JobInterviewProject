/**
 * ProductController class provides Aura-enabled methods to interact with the ProductRepository class and perform actions on Products.
 * It includes methods to get available products, add products to an order, and check if a product is already added to the order.
 */
public with sharing class ProductController {
  // Returns a list of available products for a given Order Id and search keyword by calling the corresponding method in ProductRepository.
  @AuraEnabled(cacheable=true)
  public static List<AvailableProductWrapper> getAvailableProducts(Id orderId, String searchKeyword) {
    List<AvailableProductWrapper> products = new List<AvailableProductWrapper>();
    List<PricebookEntry> pricebookEntries = ProductRepository.getAvailablePricebookEntries(orderId, searchKeyword);

    if (orderId != null) {
      List<OrderItem> orderItems = OrderRepository.getOrderItemsForOrder(orderId);

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

  // Adds a product to an order based on the given Order Id and PricebookEntry Id by calling the corresponding method in ProductRepository.
  @AuraEnabled
  public static void addProductToOrder(Id orderId, Id pricebookEntryId) {
    PricebookEntry entry = ProductRepository.getPricebookEntries(pricebookEntryId);
    List<OrderItem> orderItems = OrderRepository.getAllOrderItem(orderId, pricebookEntryId);

    Boolean productFound = false;
    for (OrderItem orderItem : orderItems) {
      if (orderItem != null) {
        orderItem.Quantity += 1;
        productFound = true;
      }
    }

    if (!productFound) {
      OrderItem newOrderItem = new OrderItem(OrderId = orderId, PricebookEntryId = pricebookEntryId, Quantity = 1, UnitPrice = entry.UnitPrice);
      orderItems.add(newOrderItem);
    }

    OrderRepository.upsertOrderItems(orderItems);
  }

  // Checks if a product with a given Product Id is already added to the order by calling a private method.
  private static Boolean isProductAlreadyAdded(List<AvailableProductWrapper> products, Id productId) {
    for (AvailableProductWrapper product : products) {
      if (product.pricebookEntry.Product2Id == productId) {
        return true;
      }
    }
    return false;
  }

  // Wrapper class to hold available products and their addition status to the order.
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
