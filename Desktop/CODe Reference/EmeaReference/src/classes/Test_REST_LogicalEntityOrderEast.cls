@isTest
public class Test_REST_LogicalEntityOrderEast{
    public static testmethod void testOE(){
        Test_REST_DataFactoryEast.TestData();

        /*VoucherCampaign__c  vca = new VoucherCampaign__c (Name='VoucherCampaign',YearRef__c = Test_REST_DataFactoryEast.Year.id, StartDate__c = Date.newinstance(2013,02,02), EndDate__c= Date.newinstance(2018,11,11), 
                                      CountryRef__c= Test_REST_DataFactoryEast.c.id, BagSize__c=80, DivisionRef__c= Test_REST_DataFactoryEast.Divi.id, MinProducts__c=1, Currency__c='EUR',
                                      MinTotalBags__c=1, isTechnology__c=true, Discount_Type__c='In Bags',Template__c='VouchersGenerators',isDataPrivacy__c=true, isTermsAndConditions__c=true);
        insert vca;*/ 
        
        System.Test.startTest();
        
        
       /* RecordType SaC = [SELECT Id FROM RecordType WHERE SobjectType = 'ProductCatalog__c' and DeveloperName = 'SalesProductCatalog'];
        Country__c C = new Country__c(Name = 'HQ', TacticalPlanSetting__c = 'Standard');
        insert C;
        
        User us = new User(Id = UserInfo.getUserId(), Country = 'HQ');
        update us;
        
        Year__c Year= new Year__c (Name='2016', Current_Year__c=true, YearEndDate__c=date.newinstance(2016, 08, 31), 
            YearStartDate__c=date.newinstance(2015, 09, 1),CurrentYear_RSA__c=true); 
            insert Year;
        
        Division__c Divi= new Division__c(Name='Corn',Standard__c=true); insert Divi;
        
        Campaign ca = new Campaign(name = 'Test Campaign Acti', YearV2__c=Year.id, CountryRef__c=C.id, OwnerId=Util.CurrentUser.id,
                          EndDate=Date.newinstance(2018,11,11), statuscode__c=200, 
                          StartDate=Date.newinstance(2016,01,01), DivisionRef__c = Divi.id);*/
        
     //DateTime timecheck = background(100);
     Datetime timecheck = System.now();
     
     REST_Request req = new REST_Request();
        req.pagetimestamp= timecheck;
        req.lastId = '0';
        req.mode = 0;
        req.maxtimestamp = timecheck;
        req.lastItem = 0;
        String JsonMsg=JSON.serialize(req);
        RestRequest request = new RestRequest();
           RestResponse respons = new RestResponse();
           request.requestURI = '/getLogicalEntity/OrderEast_2*';  //Request URL
           request.httpMethod = 'POST';//HTTP Request Type
           request.requestBody = Blob.valueof(JsonMsg);
           RestContext.request = request;
           RestContext.response= respons;
    
    
    
    REST_LogicalEntityOrderEast.REST_LogicalEntity_Order TestOE = REST_LogicalEntityOrderEast.getOrders(REQ);
    //REST_LogicalEntityOrderEast.REST_LogicalEntity_Order TestOE2 = REST_LogicalEntityOrderEast.getOrders(REQ2);
    Test.stopTest(); 
    }

}