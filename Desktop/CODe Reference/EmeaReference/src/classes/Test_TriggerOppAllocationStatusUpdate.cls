@isTest
public class Test_TriggerOppAllocationStatusUpdate 
{
    public static testMethod void Test_OppAllocationStatusUpdate()
    {        
        /*----------- Test Data Creation----------------------*/
        Id currentUser=UserInfo.getUserId();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User currUser = new user(TXT_Division__c='15',TXT_Sales_Org__c='00', Username='UserTest192@test.com', LastName='test3', country='Spain', Email='test@test.com', 
                                Alias='TEST2', CommunityNickname='NickCom', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='UTF-8', 
                                ProfileId=p.Id, LanguageLocaleKey='en_US');
        insert currUser;
        RecordType rt =[SELECT id,Name FROM RecordType WHERE SobjectType='Account' and Name='Dist./Ret./PoS' limit 1]; 
            system.runAs(currUser){
                // Opportunity Creation
                Id pricebookId = Test.getStandardPricebookId();
                // system.debug('@@kiakaha: '+ pricebookId);
                // pricebook2 pbk=[select id from pricebook2 where id=:pricebookId ];
                Country__c cat = new Country__c(Name='Catalonia', TXT_Country_ISO_Code__c='CAT');
                insert cat;
                
                RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Dist./Ret./PoS' AND SobjectType = 'Account' LIMIT 1];
                Account vend = new Account(Name = 'Monsanto Vendor', Category__c = 'Distributor', recordTypeId = accountRecordType.Id);    /*  , Status__c = 'Active'  */
                insert vend;
                Product2 prdct = new Product2(Name = 'product1', Family='CP', ProductCartonPerPallet__c=17, DE_BasicUnits__c=10, 
                                                ProductVendor__c = vend.Id, ProductSAPCode__c='h4kun4m47474'); /* DivisionRef__c = d.Id, recordTypeId = productRecordType.Id */
                insert prdct;
                PriceBookEntry pbe = new PriceBookEntry(isActive = True, Pricebook2Id = pricebookId, Product2Id = prdct.Id, UnitPrice = 40);    /* , StandardPrice=174, ProductCode='57391'  */
                insert pbe;
                
                // Year__c y = ();
                // insert y;
                Year__c y = new Year__c(Name='2017', YearStartDate__c=date.newinstance(2016,11,1), YearEndDate__c=date.newinstance(2999,10,31), Current_Year__c=true);
                insert y;
                
                Allocation__c al = new Allocation__c(NUM_Allocation_Units__c=44440, LKP_Fiscal_Year__c=y.id, LKP_Product__c=prdct.id, 
                                                    LKP_User_Name__c=currUser.id, TXT_External_ID__c= string.valueof(currUser.id).substring(0,15)+'-'+string.valueOf(prdct.id).substring(0,15)+'-'+y.name);  // 
                insert al;
                
                // PriceBook2 pbk2 = new PriceBook2(Name='testPraisbuc', PICK_Product_family__c='Monfast', CountryRef__c=cat.id);
                // insert pbk2;
                // RecordType oppRT =[SELECT id,Name FROM RecordType WHERE SobjectType='Opportunity' and Name='Sales Italy FOC' limit 1];
                Id oppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sales Italy FOC').getRecordTypeId();
                system.debug('@@ tenim RT? : ' + oppRT);
                Opportunity opp = new Opportunity(CloseDate=Date.newInstance(2018, 10, 21), Pricebook2Id=pricebookId, StageName='Pending Approval', 
                                                RecordTypeId=oppRT, PICK_Status__c='Not Submitted', TXT_Additional_Comments__c='bibbyPro', Owner=currUser);    /*  , TXT_SAP_Order_number__c  */
                insert opp;
                system.debug('@@whoisit : ' + opp.TXT_Additional_Comments__c);
                system.debug('@@ tenim RT? 2 : ' + opp.RecordTypeId);
                
                // OpportunityLineItem Creation
                
                OpportunityLineItem oLine = new OpportunityLineItem( pricebookentryId=pbe.Id, quantity=4444, OpportunityId=opp.Id);    /*  ProductCode?¿  product2id = prdct.Id,  */
                insert oLine;
                
                
                opp.TXT_SAP_status_description__c='Error trying to connect to the server';
                update opp;
                                                
                opp.PICK_Status__c='Submitted';
                opp.TXT_SAP_Order_number__c ='123456';
                update opp;  

                // Prepare data to get into the setRemoveConsLog deleting part.
                                
                // allocation_consume_log__c acl = new allocation_consume_log__c(MD_Allocation__c=al.id, LKP_Opportunity__c=opp.id, NUM_Qty__c=4,
                                                                // TXT_Order_SAP__c=opp.name);    // , TXT_External_ID__c=+'-'++'-'+
                // insert acl;
                
                opp.TXT_SAP_Order_number__c =null;
                opp.TXT_Additional_Comments__c = 'randomchange';
                update opp;
                
            }                
    }
}