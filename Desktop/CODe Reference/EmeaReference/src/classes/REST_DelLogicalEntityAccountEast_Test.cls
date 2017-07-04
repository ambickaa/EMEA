@isTest
public class REST_DelLogicalEntityAccountEast_Test {
public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        List<Account> Acc2Del= Test_REST_DataFactoryEast.aList;
        List<Contact> Con2Del = Test_REST_DataFactoryEast.conList;
        List<Touchpoint_Program__c> TPP2Del = Test_REST_DataFactoryEast.TPPList;

                
        REST_DelLogicalEntityAccountContrEast.REST_DelLogicalEntity_Account params = new REST_DelLogicalEntityAccountContrEast.REST_DelLogicalEntity_Account();
        params.accounts=new List<Account>();
        params.contacts=new List<Contact>();
        params.touchpoints=new List<Touchpoint_Program__c>();

        params.accounts.addAll(Acc2Del);
        params.contacts.addAll(Con2Del);
        params.touchpoints.addAll(TPP2Del);

          
        REST_DelLogicalEntityAccountContrEast.REST_DelLogicalEntity_Account returned = REST_DelLogicalEntityAccountContrEast.getDeletedAccounts(params);                
        
        System.AssertEquals(returned.accounts.Size(),0);
        System.AssertEquals(returned.contacts.Size(),0);
        System.AssertEquals(returned.touchpoints.Size(),0);

   
        delete Acc2Del;
        
        returned = REST_DelLogicalEntityAccountContrEast.getDeletedAccounts(params);                
        
        System.AssertEquals(returned.accounts.Size(),Test_REST_DataFactoryEast.regPerEntity);
        System.AssertEquals(returned.contacts.Size(),Test_REST_DataFactoryEast.regPerEntity);

        test.stopTest();
    }
    public static testmethod void ExTest(){

          Test_REST_DataFactoryEast.TestData();
      test.startTest();
          REST_DelLogicalEntityAccountContrEast.REST_DelLogicalEntity_Account params = new REST_DelLogicalEntityAccountContrEast.REST_DelLogicalEntity_Account();
          params = REST_DelLogicalEntityAccountContrEast.getExample();
          
          System.Assert(params.accounts.Size()>0);
          test.stopTest();
     }
}