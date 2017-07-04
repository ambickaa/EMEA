@isTest
public class AccountListOfOrdersRSAControllerTest{

    public static testmethod void TestCon(){
    
        Test_REST_DataFactoryEast.TestData();
        ID FarmId = Test_REST_DataFactoryEast.Farm.id;               
        Util.setCurrentAccount(FarmId);  
                         
        List<Order__c> OrdersQ= [SELECT Name, Type_RSA__c, Status_RSA__c, Signed_RSA__c, LastModifiedDate, RecordTypeID,
                                  Cancellation_Reason_RSA__c, version_Id_RSA__c,consigned__c, (select ID FROM Attachments)
                                FROM Order__c
                                WHERE AccountRef_RSA__c = :Util.currentAccount.ID 
                                AND CreatedDate >= :UtilREST.currentYearRSA2.YearStartDate__c  AND CreatedDate<=:UtilREST.currentYearRSA2.YearEndDate__c 
                                ORDER BY Name,version_Id_RSA__c];
          
        AccountListOfOrdersRSAController Controller=new AccountListOfOrdersRSAController();
    
        System.AssertEquals(OrdersQ,Controller.orders);
        System.debug('Enric '+Controller);
        System.Assert(Controller.DataSum !=Null);
    }
}