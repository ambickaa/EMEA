@isTest
public class Test_onStock{

    @isTest
    public static void testOnOrder(){
        try{            
            insert new Stock__c(User_RSA__c = UserInfo.getUserID(),Quantity_RSA__c = 0,TaxQuantity_RSA__c = 0);
        }catch(Exception e){}
    }

}