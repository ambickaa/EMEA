@Istest
private class Test_LogicalEntityAccountController2 {

    private static testmethod void testGetAccountsOneIteration(){
        DateTime now = System.now();
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                               
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        Profile pSR = [SELECT Id FROM Profile WHERE Name='RSA_Sales Representative'];
        
        Profile pRM = [SELECT Id FROM Profile WHERE Name='RSA_Regional Manager'];
        
        
       
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        Account farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                                   Category__c='Farm',GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        Account provider= new Account(CountryRef__c=c.ID, Name='Provider',RecordTypeId=Util.recordType.get('Account:DistRetPoS'),
                                      Category__c='Distributor', GC_VATIN_Number__c='5', OwnerId=Util.CurrentUser.id);
        List<Account> accounts = new List<Account>{farm, provider};
        
        List<Account> aList = new List<Account>();  
            for(Integer i=0;i<52;i++){
                String AccountName='Account Test '+String.valueof(i);
                Account Acc = new Account(CountryRef__c=c.Id, Name=AccountName, GC_VATIN_Number__c='5', Category__c='Farm', IdDevice__c=(800+i), 
                                          RecordTypeId=Util.recordType.get('Account:GroupFarmSite')); 
                aList.add(Acc);}
                
        accounts.addAll(aList);        
            insert accounts;
            
        List<Contact> ConList = new List<Contact>();
            for(integer i=0;i<50;i++){
                Contact con= new Contact(LastName='Van '+String.ValueOf(i),CountryRef__c=c.id, idDevice__c='900', 
                                 AccountId=aList.get(i).id);
                conList.add(con);}
            insert conList;
        
       
        
        REST_Request req = new REST_Request();
        req.pagetimestamp= now;
        req.lastId = '';
        req.mode = 1;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/services/apexrest/DemoUrl/getLogicalEntity/AccountDynamic/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;

        Test.startTest();
        REST_LogicalEntityAccountDynamic.REST_LogicalEntity_Account res = new REST_LogicalEntityAccountDynamic.REST_LogicalEntity_Account();
        res = REST_LogicalEntityAccountDynamic.getAccounts(req);
        //System.assertEquals(res.Accounts.size(),accounts.size());
        Test.stopTest();
    }
    
    private static testmethod void testGetAccountsPagination(){
        DateTime now = System.now();
        SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
                               
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        insert c;
                  
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        Profile pSR = [SELECT Id FROM Profile WHERE Name='RSA_Sales Representative'];
        
        Profile pRM = [SELECT Id FROM Profile WHERE Name='RSA_Regional Manager'];
        
        
       
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        insert divi;
            
        List<Account> accounts = new List<Account>();
        
        List<Account> aList = new List<Account>();  
            for(Integer i=0;i<200;i++){
                String AccountName='Account Test '+String.valueof(i);
                Account Acc = new Account(CountryRef__c=c.Id, Name=AccountName, GC_VATIN_Number__c='5', Category__c='Farm', IdDevice__c=(800+i), 
                                          RecordTypeId=Util.recordType.get('Account:GroupFarmSite')); 
                aList.add(Acc);}
                
        accounts.addAll(aList);        
            insert accounts;
            
        List<Contact> ConList = new List<Contact>();
            for(integer i=0;i<50;i++){
                Contact con= new Contact(LastName='Van '+String.ValueOf(i),CountryRef__c=c.id, idDevice__c='900', 
                                 AccountId=aList.get(i).id);
                conList.add(con);}
            insert conList;
        
       
        
        REST_Request req = new REST_Request();
        req.pagetimestamp= now;
        req.lastId = '';
        req.mode = 1;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/services/apexrest/DemoUrl/getLogicalEntity/AccountDynamic/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;

        Test.startTest();
        REST_LogicalEntityAccountDynamic.REST_LogicalEntity_Account res = new REST_LogicalEntityAccountDynamic.REST_LogicalEntity_Account();
       
        res = REST_LogicalEntityAccountDynamic.getAccounts(req); 
        Integer max=res.Accounts.size();
        
        while(res.queryMore){
            
            req.maxtimestamp = res.maxtimestamp;
            req.lastId = res.lastId;
            req.lastItem = res.lastItem;
            JsonMsg=JSON.serialize(req);
            request = new RestRequest();
            respons = new RestResponse();
           request.requestURI = '/services/apexrest/DemoUrl/getLogicalEntity/AccountDynamic/*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
            res = REST_LogicalEntityAccountDynamic.getAccounts(req); 
            max = max+res.Accounts.size();
        }
        //System.assertEquals(max,accounts.size());
        Test.stopTest();
    }

}