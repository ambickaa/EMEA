@isTest
private class Test_monsantoComIntegration{
   
   static testMethod void test_monsantoComIntegrationTest() {
    List < RecordType > rtypesAccList1 = [SELECT Name, id, developerName FROM RecordType WHERE sObjectType = 'Account'
                                          and isActive = true and developerName = 'Account_Global' Limit 1];
    List < RecordType > rtypesAccList2 = [SELECT Name, id, developerName FROM RecordType WHERE sObjectType = 'Account'
                                          and isActive = true and developerName = 'Account_Global' Limit 1];                                       
          
         //Account acc1=[Select Id ,Name ,GC_SAP_ID__c,Credit_Lmt_Amt__c  from Account where recordTypeId =:  rtypesAccList1[0].Id  limit 1];
        
         Country__c c= new Country__c();
         c.Name='HQ';
         Database.insert(c);
         
         Account acc1 = new Account();
            //acc1.State__c='IL';
            acc1.BillingState='IL';
           // acc1.brand_family_name__c='test802';
            acc1.Name='testAccountest';
           // acc1.Account_key_cd__c = 'testAccount12345'; 
            //acc1.Golden_Ind__c= 'Y';
            acc1.CountryRef__c=c.Id;
            acc1.Industry='test1235';
            acc1.name='test_ac';
            acc1.GC_SAP_ID__c ='0001052697';
            acc1.Credit_Lmt_Amt__c = 356.00;
            acc1.recordTypeId =  rtypesAccList1[0].Id;
            Database.insert(acc1);
            
            Test.startTest();
            Test.setMock(WebServiceMock.class, new Test_monsantoComIntegration.WebServiceMockImpl());
            monsantoComIntegrationservicesCredita.CreditExposureResponse_element  result = new monsantoComIntegrationservicesCredita.CreditExposureResponse_element(); 
            result.EDeltaToLimit = '3456'; 
            
            monsantoComIntegrationservices.getmonsantoComIntegration(acc1.Id);           
            acc1.Credit_Lmt_Amt__c = decimal.valueof(result.EDeltaToLimit);
            //acc1.CreditLimit__c = 3456;
            database.update(acc1);
            //monsantoComIntegrationservices.getmonsantoComIntegration(acc1.Id);
           Test.stopTest();   
            
      }
      static testMethod void test_monsantoComIntegrationTestif() {
    List < RecordType > rtypesAccList1 = [SELECT Name, id, developerName FROM RecordType WHERE sObjectType = 'Account'
                                          and isActive = true and developerName = 'Account_Global' Limit 1];
    List < RecordType > rtypesAccList2 = [SELECT Name, id, developerName FROM RecordType WHERE sObjectType = 'Account'
                                          and isActive = true and developerName = 'Account_Global' Limit 1];                                       
          Country__c c1= new Country__c();
         c1.Name='HQ';
         Database.insert(c1);
         //Account acc1=[Select Id ,Name ,GC_SAP_ID__c,Credit_Lmt_Amt__c  from Account where recordTypeId =:  rtypesAccList1[0].Id  limit 1];
         Account acc1 = new Account();
           // acc1.State__c='IL';
            acc1.BillingState='IL';
           // acc1.brand_family_name__c='test802';
            acc1.Name='testAccountest';
           // acc1.Account_key_cd__c = 'testAccount12345'; 
           // acc1.Golden_Ind__c= 'Y';
           
            acc1.CountryRef__c=c1.Id;
            acc1.Industry='test1235';
            acc1.name='test_ac';
            acc1.GC_SAP_ID__c ='0001052697';
            acc1.Credit_Lmt_Amt__c = 356.00;
            acc1.recordTypeId =  rtypesAccList1[0].Id;
            Database.insert(acc1);
            
            Test.startTest();
            Test.setMock(WebServiceMock.class, new Test_monsantoComIntegration.WebServiceMockImplnew());
            monsantoComIntegrationservicesCredita.CreditExposureResponse_element  result = new monsantoComIntegrationservicesCredita.CreditExposureResponse_element(); 
            result.EDeltaToLimit = '-1'; 
            
            monsantoComIntegrationservices.getmonsantoComIntegration(acc1.Id);           
            acc1.Credit_Lmt_Amt__c = decimal.valueof(result.EDeltaToLimit);
            //acc1.CreditLimit__c = 3456;
            database.update(acc1);
            //monsantoComIntegrationservices.getmonsantoComIntegration(acc1.Id);
           Test.stopTest();   
            
      }
    
   static testMethod void test_monsantoComIntegrations_Test() {
      monsantoComIntegrationservicesCredita.ECustomerCreditDetailsType eccdt = new monsantoComIntegrationservicesCredita.ECustomerCreditDetailsType();
      monsantoComIntegrationservicesCredita.YsdResTabError ysrtError = new  monsantoComIntegrationservicesCredita.YsdResTabError();
      monsantoComIntegrationservicesCredita.CreditExposure_element cex_el = new  monsantoComIntegrationservicesCredita.CreditExposure_element();
      monsantoComIntegrationservicesCredita.CreditExposureResponse_element cer_element = new  monsantoComIntegrationservicesCredita.CreditExposureResponse_element();
      monsantoComIntegrationservicesCredita.YsdResError yrError = new  monsantoComIntegrationservicesCredita.YsdResError();
   }
   static testMethod void test_monsantoComIntegrations_Test1() {
       monsantoComIntegrationservicesSimplet monSim = new monsantoComIntegrationservicesSimplet();
   }
   
   private class WebServiceMockImpl implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof monsantoComIntegrationservicesCredita.CreditExposure_element){
                
                monsantoComIntegrationservicesCredita.CreditExposureResponse_element resObj = new monsantoComIntegrationservicesCredita.CreditExposureResponse_element();
                resObj.EDeltaToLimit = '1234';
                resObj.ECreditlimit='12345';
                response.put('response_x', resObj);
            }
            return;
        }
    }
    private class WebServiceMockImplnew implements WebServiceMock
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof monsantoComIntegrationservicesCredita.CreditExposure_element){
                
                monsantoComIntegrationservicesCredita.CreditExposureResponse_element resObj = new monsantoComIntegrationservicesCredita.CreditExposureResponse_element();
                resObj.EDeltaToLimit = '-1.00';
                resObj.ECreditlimit='12345';
                response.put('response_x', resObj);
            }
            return;
        }
    }
}