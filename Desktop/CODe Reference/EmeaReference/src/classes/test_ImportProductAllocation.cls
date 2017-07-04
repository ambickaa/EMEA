@isTest

public class test_ImportProductAllocation{
    
    public static RecordType accountRecordType, productRecordType, opportunityRecordType;
    
 public static testMethod void testImportProductAllocation(){
        /*----------- Test Data Creation----------------------*/
    Id currentUser=UserInfo.getUserId();
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    
    User cUser=new User(TXT_Division__c='17',TXT_Sales_Org__c='ES01',Username='test123zxcvsdoire@test.com', LastName='test', Email='test@test.com', TXT_Distribution_Channel__c='00', Alias='TEST',
    CommunityNickname='TEST', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', ProfileId=p.Id, LanguageLocaleKey='en_US');
    insert cUser;
            
    RecordType rt=[Select id,Name FROM RecordType WHERE SobjectType='Account' and Name='Dist./Ret./PoS' limit 1]; // Name= Group/Farm/Site ¿?
    productRecordType = [SELECT Id FROM RecordType WHERE Name = 'CP Sales Product' AND SobjectType = 'Product2'  LIMIT 1];
    system.runAs(cUser){
        
        Year__c fYear = new Year__c (Current_Year__c = true);
                insert fYear;
        
        Country__c country = new Country__c(Name = cUser.Country, Units_of_Measurement__c = 'Basic Units');
                insert country;
        

        Product2 prod = new Product2(isActive=true,  Name = 'product1', Family='CP', ProductSAPCode__c = 'SAPCode1', recordTypeId = productRecordType.Id);
                insert prod;
                      
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = system.Test.getstandardPricebookId(), gc_integration_key__c='ACS/SAP00001', Product2Id = prod.Id, UnitPrice = 1, IsActive = true);
                insert standardPrice; 
    
          String alloExtId = cUser.id + '-' + priceBookEntry.productcode + '-' + '2016';
        
        Allocation__c alloc = new Allocation__c (TXT_External_ID__c = alloExtId);
                insert alloc;
        List<Allocation__c> importResult = [SELECT  Name FROM Allocation__c WHERE TXT_External_ID__c = : alloExtId limit 1];
        
        string codiSAP = '000000000012121451';
        
        string client = '0001009195';
        
        system.debug('https://gsc-customer-care-orders-np.agro.services/gsc-emea-product/v1/products/atp/customer/'+client+'/sales-org/'+ cUser.TXT_Sales_Org__c +'/dist-channel/'+  cUser.TXT_Distribution_Channel__c +'/lob/'+cUser.TXT_Division__c+'/material/'+ codiSAP);
            
        
        Test.startTest();
    
        ImportProductAllocation ipa = new ImportProductAllocation();
        ImportProductAllocation.quantityFromSAP('SAPCode1', 'RandomString');
        
        
        
       

        
        }
    }   
}