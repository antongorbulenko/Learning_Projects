/**
 * Created by agorbulenko on 21-Jun-19.
 */

public with sharing class ProductTableController {
    public Contact contact { get; set; }
    public Id productId { get; set; }
    public Product_Table__c detailProduct { get; set; }
    public Product_Table__c productToBuy { get; set; }
    public List<Product_Table__c> productTables { get; set; }
    public Integer unitCount { get; set; }

    public ProductTableController() {
        contact = new Contact();
        productTables = [SELECT Product_Name__c,Name,Product_Description__c,Unit_Price__c,Image_URL__c FROM Product_Table__c LIMIT 100];
    }

    public void buy() {
        upsert contact Email;
        Boolean isErrorsOnThePage = false;

        if (unitCount <= 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                    Label.InvalidValueOfField));
        }
        if (isErrorsOnThePage == false && unitCount > 0 && getProductForPurchase().Units_Available__c > unitCount) {
            Order_Table__c newOrderTable = new Order_Table__c(
                    Product_Table__c = productId,
                    Units__c = unitCount,
                    Contact__c = contact.Id,
                    Order_Amount__c = unitCount * getProductForPurchase().Unit_Price__c
            );
            insert newOrderTable;

            Product_Table__c productTableToUpdate = [
                    SELECT Name, Units_Available__c
                    FROM Product_Table__c
                    WHERE Id = :productId
            ];

            productTableToUpdate.Units_Available__c -= unitCount;
            update productTableToUpdate;

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,
                    Label.SuccessfulPurchase));
            contact.clear();
            unitCount = 1;
        }
    }


    public PageReference detailPageReference() {
        PageReference detailPage = Page.ProductDetailPage;
        return detailPage;
    }

    public PageReference buyPageReference() {
        PageReference buyPage = Page.BuyPage;
        return buyPage;
    }

    public PageReference productTablePageReference() {
        PageReference productTablePage = Page.ProductTablePage;
        return productTablePage;
    }

    public Product_Table__c getProductTableDetail() {
        detailProduct = [
                SELECT Product_Name__c,Name,Product_Description__c,Image_URL__c
                FROM Product_Table__c
                WHERE Id = :productId
        ];
        return detailProduct;
    }

    public Product_Table__c getProductForPurchase() {
        productToBuy = [
                SELECT Name, Image_URL__c,Product_Name__c, Product_Description__c, Unit_Price__c, Units_Available__c
                FROM Product_Table__c
                WHERE Id = :productId
        ];
        return productToBuy;
    }
}