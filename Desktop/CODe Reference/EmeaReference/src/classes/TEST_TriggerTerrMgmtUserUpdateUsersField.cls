@isTest
public with sharing class TEST_TriggerTerrMgmtUserUpdateUsersField {
    
    public static testmethod void test(){
    
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                
        Country__c c = new Country__c (Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
        insert c;
 
        Year__c lastI = new Year__c (Name='2013', Current_Year__c=false, YearEndDate__c=date.newinstance(2013, 12, 31), 
                                     YearStartDate__c=date.newinstance(2013, 1, 1)); 
        insert lastI;
        Year__c year= new Year__c (Name='2014', Current_Year__c=true, YearEndDate__c=date.newinstance(2020, 12, 31), 
                                   YearStartDate__c=date.newinstance(2014, 1, 1), YearPreviousYear__c=lastI.id); 
        insert year;
        
        // General Data Insert
        
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Monsanto Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', CountryID__c=c.id, OwnerID=Util.currentUser.id );
        insert new List<Account> {farm, provider};
        
        Test.StartTest();
        TerritoryManagement__c tM=new TerritoryManagement__c(DE_StateProvince__c='dka',
                  DE_LandKreis__c='dka', DE_Landkreis2__c='dka', DE_CP__c='dka', Name='AN', DE_PrimaryKey__c='dka', DE_CountryRef__c=c.id);
        insert tM; 
           
        TerritoryManagementUser__c tMU  =new TerritoryManagementUser__c(DivisionRef__c=divi.id, DE_TerritoryManagementRef__c=tM.id, DE_UserRef__c=Util.currentUser.Id);
        insert tMU;
        Test.StopTest();
        TerritoryManagement__c tMQ = [SELECT TXT_SharedUsers__c FROM TerritoryManagement__c LIMIT 1];
        System.assertEquals(tMQ.TXT_SharedUsers__c, Util.CurrentUser.Alias);   
    }
}