/**
 * Created by agorbulenko on 01-Jul-19.
 */
@isTest
private with sharing class ProductTableControllerTest {
    @TestSetup
    private static void createData() {
        OrgConfiguration__c perm = new OrgConfiguration__c(Period_Term__c = 5);
        insert perm;

        Product_Table__c productTable = new Product_Table__c(

                Name = 'Tachki 3',
                Units_Available__c = 10,
                Unit_Price__c = 2500,
                Added_Date__c = Date.today()
        );
        insert productTable;
    }

    @IsTest
    static void mainLogic() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = 'Tachki 3'
        ];

        Contact contact = new Contact(

                LastName = 'Testinsky',
                Email = 'email@test.com'
        );

        ProductTableController controller = new ProductTableController();
        controller.productId = productTable.Id;
        controller.detailProduct = controller.getProductTableDetail();
        controller.detailPageReference();
        controller.buyPageReference();
        controller.productTablePageReference();
        controller.unitCount = 2;
        controller.contact.LastName = contact.LastName;
        controller.contact.Email = contact.Email;
        controller.buy();

        List <Order_Table__c> orderTable = [
                SELECT Name, Product_Table__c, Units__c, Contact__c, Order_Amount__c
                FROM Order_Table__c
                WHERE Product_Table__c = :productTable.Id
        ];

        Id idContact = orderTable[0].Contact__c;
        Contact contFromBase = [
                SELECT LastName, Email
                FROM Contact
                WHERE Id = :idContact
        ];

        System.assertEquals(orderTable[0].Units__c, 2);
        System.assertEquals(orderTable[0].Product_Table__c, productTable.Id);
        System.assertEquals(orderTable[0].Order_Amount__c, 5000);
        System.assertEquals(contFromBase.LastName, 'Testinsky');
        System.assertEquals(contFromBase.Email, 'email@test.com');
    }

    @IsTest
    static void reassignTest() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = :'Tachki 3'
        ];

        Contact contact = new Contact(

                LastName = 'Testinsky',
                Email = 'email@test.com'
        );
        insert contact;

        ProductTableController controller = new ProductTableController();
        controller.productId = productTable.Id;
        controller.unitCount = 2;
        controller.contact.LastName = contact.LastName;
        controller.contact.Email = contact.Email;
        controller.buy();

        Contact contFromBase = [
                SELECT LastName, Email
                FROM Contact
                WHERE Id = :contact.Id
        ];

        System.assertEquals(contFromBase.LastName, 'Testinsky');
        System.assertEquals(contFromBase.Email, 'email@test.com');
    }

    @IsTest
    static void anotherContactUseEmailTest() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = :'Tachki 3'
        ];

        Contact contact = new Contact(

                LastName = 'Testinsky',
                Email = 'email@test.com'
        );
        insert contact;

        ProductTableController controller = new ProductTableController();
        controller.productId = productTable.Id;
        controller.unitCount = 2;
        controller.contact.LastName = 'Tod Howard';
        controller.contact.Email = contact.Email;
        controller.buy();

        Contact contFromBase = [
                SELECT LastName, Email
                FROM Contact
                WHERE Id = :contact.Id
        ];

        System.assertNotEquals(contFromBase.LastName, controller.contact.LastName);
    }

    @IsTest
    static void countNotAvail() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = :'Tachki 3'
        ];

        Contact contact = new Contact(

                LastName = 'Testinsky',
                Email = 'email@test.com'
        );
        ProductTableController controller = new ProductTableController();
        controller.productId = productTable.Id;
        controller.unitCount = 20;
        controller.contact.LastName = contact.LastName;
        controller.contact.Email = contact.Email;
        controller.buy();

        System.assert (productTable.Units_Available__c < controller.unitCount);
    }


    @IsTest
    static void notZeroOrderTest() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = :'Tachki 3'
        ];

        Contact contact = new Contact(

                LastName = 'Testinsky',
                Email = 'email@test.com'
        );

        ProductTableController controller = new ProductTableController();
        controller.productId = productTable.Id;
        controller.unitCount = 0;
        controller.contact.LastName = contact.LastName;
        controller.contact.Email = contact.Email;
        controller.buy();

        System.assert (productTable.Units_Available__c == 10);
    }

    @IsTest
    static void buyAllTest() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = :'Tachki 3'
        ];

        Contact contact = new Contact(

                LastName = 'Testinsky',
                Email = 'email@test.com'
        );

        ProductTableController controller = new ProductTableController();
        controller.productId = productTable.Id;
        controller.unitCount = 10;
        controller.contact.LastName = contact.LastName;
        controller.contact.Email = contact.Email;
        controller.buy();

        Product_Table__c prod = [
                SELECT Units_Available__c
                FROM Product_Table__c
                WHERE Id = :productTable.Id
        ];

        System.assertEquals (Integer.valueOf(prod.Units_Available__c),10);
    }

    @IsTest
    private static void firstPage() {

        Product_Table__c productTable = [
                SELECT Name, Unit_Price__c, Units_Available__c, Added_Date__c
                FROM Product_Table__c
                WHERE Name = :'Tachki 3'
        ];

        ProductTableController controller = new ProductTableController();
        Product_Table__c prod = new Product_Table__c();
        for (Product_Table__c pr : controller.productTables) {

            if (pr.Name == 'Tachki 3') {
                prod.Name = pr.Name;
            }
        }
        System.assertEquals(prod.Name, productTable.Name);
    }
}