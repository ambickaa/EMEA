@Istest
public with sharing class Test_LogicalEntityLookupController {
	private static testmethod void testGetLookupOneIteration(){
		DateTime now = System.now();
		SystemSettings__c s1 = new SystemSettings__c( Name='RSA_MAX_VOLUME_DISCOUNT',Value__C='4');
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='RSA_MIN_VOLUME_DISCOUNT',Value__C='0');
        SystemSettings__c s5 = new SystemSettings__c( Name='RSA_STEPSIZE_VOLUME_DISCOUNT',Value__C='0');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');
        SystemSettings__c s8 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s9 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='2013-12-07 01:00:00');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7,s8,s9};
        insert ssList;
        List<Country__c> countries = new List<Country__c>();                        
        Country__c c = new Country__c (Name ='South Africa', TacticalPlanSetting__c = 'RSA');      
        countries.add(c);
        insert countries;
        
        User u = [SELECT Name,ID, Country FROM User WHERE ID = :UserInfo.getUserId()];
        u.Country = countries[0].Name;
        update u;
        
        List<Year__c> years = new List<Year__c>();          
        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
           							 YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        years.add(lastYear);    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
           						   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
           						   YearPreviousYear__c=lastYear.id);
         years.add(year);
        insert years;
        Profile pSR = [SELECT Id FROM Profile WHERE Name='RSA_Sales Representative'];
        
        Profile pRM = [SELECT Id FROM Profile WHERE Name='RSA_Regional Manager'];
        
        
        List<User> users =new List<User>();
        User uRM = new User(Alias = 'RManager', Email='sugfhser@test.com', 
      							EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
      							LocaleSidKey='en_US', ProfileId = pRM.Id, 
      							TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='usersadasdas@test.com');
        users.add(uRM);
        
        User uSR = new User(Alias = 'standart', Email='suser@test.com', 
      							EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
      							LocaleSidKey='en_US', ProfileId = pSR.Id, ManagerId=uRM.Id,
      							TimeZoneSidKey='America/Los_Angeles',OrderPrefix_RSA__c='AAA', UserName='usersadfghddas@test.com');
        
        
        users.add(uSR);
        insert users;
       List<Division__c> divisions = new List<Division__c>(); 
        Division__c divi= new Division__c(Name='Corn',Standard__c=true);
        divisions.add(divi);
        insert divisions;
        EnhancedDocument__c terms = new EnhancedDocument__c(Name='South Africa',Language__c='Afrikaans',Type__c='Terms and Conditions',Content__c='hola');
        insert terms;
        EnhancedDocument__c tech = new EnhancedDocument__c(Name='South Africa',Language__c='Afrikaans',Type__c='Technology Stewardship Agreement',Content__c='hola');
		insert tech;
		EnhancedDocument__c datas = new EnhancedDocument__c(Name='South Africa',Language__c='Afrikaans',Type__c='Data Privacy Consent',Content__c='hola');
        insert datas;
      	EnhancedDocument__c agree = new EnhancedDocument__c(Name='South Africa',Language__c='Afrikaans',Type__c='Storage Agreement',Content__c='hola');
        insert agree;
      
        
       
		
		REST_Request req = new REST_Request();
        req.pagetimestamp= now.addDays(-1);
        req.lastId = '0';
        req.mode = 1;
        req.maxtimestamp = now;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
		   RestResponse respons = new RestResponse();
		   request.requestURI = '/getLogicalEntity/LookupEast_2SM/*';  //Request URL
		   request.httpMethod = 'POST';//HTTP Request Type
		   request.requestBody = Blob.valueof(JsonMsg);
		   RestContext.request = request;
		   RestContext.response= respons;

        Test.startTest();
        
        REST_LogicalEntityLookupEastSM.REST_LogicalEntity_Lookup res = new REST_LogicalEntityLookupEastSM.REST_LogicalEntity_Lookup();
        res = REST_LogicalEntityLookupEastSM.getLookups(req);
        System.assertEquals(res.years.size(),years.size());
        System.assertEquals(res.divisions.size(),divisions.size());
        System.assertEquals(res.countries.size(),countries.size());
        //System.assertEquals(res.users.get(0).Id,Util.CurrentUser.id);
        Test.stopTest();
	}
	
	
}