@isTest
public class Test_AllocationManagerController {

    private static testmethod void testAllocationManagerControllerRegionalManager(){
        

        //setUp user Toffanin (regional Manager)
        User toffanin  = [SELECT Id FROM User WHERE Id='005D0000002Egxu'];
        AllocationManagerController allocationController=  new AllocationManagerController();
        System.RunAs(toffanin){
        allocationController.productIdentifier='01tD0000002ydhG';
        allocationController.initializeItems();
        allocationController.loadList();
        System.assert(allocationController.productList!=null , 'La lista de productos es nula');
        allocationController.initializeAllocationWrapper();
        
        system.assert(allocationController.allocationWrapperList!=null, 'La lista de productos es nula');
        //system.assert(allocationController.regionalManagerBool);

    }
       
     
        //Allocation__c ghostalloc = allocationController.createNewGhostAllocation('0000001', toffanin);
        
     //   System.assertEquals('005D0000002Egxu', ghostalloc.LKP_User_Name__c);
        
        
     }
    
    private static testmethod void testAllocationManagerControllerCountryLead(){
         AllocationManagerController allocationController=  new AllocationManagerController();
         // setup user tartari (country lead) -comment
        // User tartari = [SELECT Id from User Where Id = '005D0000002EgxV']; -comment
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User cUser=new User(TXT_Division__c='17',TXT_Sales_Org__c='ES01',Username='test123zxcvsdoire@test.com', LastName='test', /* Name='Donald',  */
                        Email='test@test.com', TXT_Distribution_Channel__c='00', Alias='TEST', CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', 
                        LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US', ManagerId=currentUser);
        insert cUser;    // Id, Name,profile.name ,country
        
        Year__c fYear = new Year__c (Current_Year__c = true);
        insert fYear;
        
        System.runAs(cUser){
            allocationController.initializeItems();
            allocationController.loadList();
            allocationController.initializeAllocationWrapper();
            Allocation__c allocTest = new  Allocation__c();
            allocTest.NUM_Allocation_Units__c=10;
            allocTest.TXT_External_ID__c='000000001';
            allocTest.LKP_Fiscal_Year__c=fYear.id;
            allocTest.LKP_Product__c='01tD0000002ydhG';
            allocTest.LKP_User_Name__c= '005D0000002Egz2';
            
            insert allocTest;
            allocTest = [Select Id, NUM_Allocation_Units__c,FRML_Avalaible_Units__c,NUM_Consumed_units__c,NUM_Consumed_ROLL__c,
                                         TXT_External_ID__c,LKP_Fiscal_Year__c,LKP_Product__c,LKP_Product__r.Name, LKP_Product__r.Id,
                                         LKP_User_Name__c,LKP_User_Name__r.name,LKP_User_Name__r.Id from Allocation__c where  TXT_External_ID__c ='000000001'];
            System.debug(allocTest);
            AllocationManagerController.AllocationWrapper testWrapper = new  AllocationManagerController.AllocationWrapper(10 ,allocTest, cUser.id);
            System.debug(testWrapper);
            System.assertNotEquals(true, allocationController.regionalManagerBool);
            Allocation__c result =  allocationController.ApplyValueChanges(testWrapper);
            System.assertEquals(20,result.NUM_Allocation_Units__c);
            allocationController.saveAllocationChanges();
            
        }
    }
    
    private static testmethod void testAllocationManagerControllerNoRole(){
         AllocationManagerController allocationController=  new AllocationManagerController();
           //setup no permisions user
        User everis = [sELECT Id from User Where alias = 'everis'];
        
        System.runAs(everis){
            
            allocationController.initializeItems();
            allocationController.loadList();
            allocationController.initializeAllocationWrapper();
            System.assert(allocationController.allocationWrapperList.isEmpty());
            
            
            
        }
        
        
    }
    
    
}