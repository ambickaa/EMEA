@isTest
private class TerritoryMgtUserUpdAccountBatchTest {

    static testMethod void batchTester() {
        
        /* Insert of a Data Background to fill all required fields on account, tm, etc.*/

        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                
        Country__c c = new Country__c (Name ='Spain', TacticalPlanSetting__c = 'German');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(2014, 12, 31), CurrentYear_RSA__c=false,
                                     YearStartDate__c=date.newinstance(2014, 1, 1)); 
        insert lastI;                             
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), CurrentYear_RSA__c=true,
                                   YearStartDate__c=date.newinstance(2015, 1, 1), YearPreviousYear__c=lastI.id); 
        insert year;
        System.debug('Enric years'+Util.currentYear.id+util.lastYear.Id);
        /* Insert of a User to verify the Account Sharing */
        
        User admin = [select Id from User where Id = :UserInfo.getUserId()];
        User salesRep;

        System.runAs(admin){
            UserRole srRole= [Select PortalType, PortalAccountId From UserRole where DeveloperName =:'Sales_Representative_RSA' limit 1];
            Profile srprofile = [select Id,name from Profile where Name =:'RSA_Sales Representative' limit 1];
            String timestamp=String.valueOf(System.now()).replace(' ', '').replace(':','_').replace('-','_');
            salesRep =  new User(Alias = 'SAREPA', Email=timestamp+'@sr.com', EmailEncodingKey='UTF-8', LastName='sarepre', LanguageLocaleKey='en_US', OrderPrefix_RSA__c='XYZ', 
                                 LocaleSidKey='en_US', ProfileId = srprofile.Id, UserRoleID = srRole.Id, TimeZoneSidKey='America/Los_Angeles', UserName=timestamp+'@sr.com');
            insert salesRep;
        }  
              
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
        
        Campaign caYear = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, OwnerId=Util.currentUser.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2016,11,11), StartDate=Date.newinstance(2015,02,02));   
        Campaign caYearSR = new Campaign(name = 'year campaign', YearV2__c=year.id, CountryRef__c=c.id, OwnerId=salesRep.id, DivisionRef__c = divi.id,
                                       EndDate = Date.newinstance(2016,11,11), StartDate=Date.newinstance(2015,02,02));                                            
        insert new List<Campaign>{caYear, caYearSR};
            
        TerritoryManagement__c tM = new TerritoryManagement__c(DE_CountryRef__c=c.id, DE_StateProvince__c='Barcelona', DE_LandKreis__c='Barcelona', 
                                                              DE_Landkreis2__c='Barcelona', DE_CP__c='08620', DE_Ort__c='Barcelona');
        insert tM;  
        
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),DE_Territory_Key__c=tM.id,
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id);
        insert farm; 
        
        TerritoryManagementUser__c tMU = new TerritoryManagementUser__c (DivisionRef__c=divi.id, DE_TerritoryManagementRef__c=tM.id, DE_UserRef__c=salesRep.id); 
        insert tMU;        
        
        Test.startTest();
        /* Batch is scheduled when everytime the trigger is invoked, but it is not executed. So, batch will be executed directly.*/
           
        TerritoryMgtUserUpdAccountBatch b= new TerritoryMgtUserUpdAccountBatch('everis.salesforce@gmail.com',new Set<Id>{tMU.Id}, false);   
        Database.executeBatch(b,10);
        
        Test.stopTest();
        
        List<AccountShare> asList = [SELECT AccountId, UserorGroupId FROM AccountShare];
        System.debug('Enric SalesRepid'+salesRep.id+'ownerId'+Util.currentuser.id+'accountshare'+asList);
        System.assertEquals(asList.size(), 2);
        System.assert(asList[0].AccountId==farm.id && asList[1].AccountId==farm.id);
       
        Set<Id> users = new Set<Id>();
        for (AccountShare iter: asList){
            users.add(iter.UserorGroupId);
        }
        System.assert(users.contains(salesRep.id) && users.contains(Util.currentUser.id));
    }
}