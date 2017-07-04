@isTest
public class Test_onOrder{

    @isTest
    public static void testOnOrder(){
           Country__c c = new Country__c(Name = 'South Africa',TacticalPlanSetting__c = 'RSA');
            insert c;
            Account a = new Account(Name = 'TestAccount',CountryRef__c = c.id,BlankVATNumber_RSA__c=true);
            insert a;
            Campaign ca = new Campaign(name = 'testCampaign',StatusCode__c = 200);
            insert ca;
            
            test.startTest();
                //create preliminary orders
                list<Order__c> preliminaryOrderList = new list<Order__c>();
                preliminaryOrderList.add( new Order__c(AccountRef_RSA__c = a.id, recordTypeId = Util.recordType.get('Order__c:PreliminaryOrder')));
                preliminaryOrderList.add( new Order__c(AccountRef_RSA__c = a.id, recordTypeId = Util.recordType.get('Order__c:PreliminaryOrder')));
        		preliminaryOrderList.add( new Order__c(AccountRef_RSA__c = a.id, recordTypeId = Util.recordType.get('Order__c:PreliminaryOrder')));
                insert preliminaryOrderList;
                
                //create final orders
                list<Order__c> finalOrderList = new list<Order__c>();
                finalOrderList.add(new Order__c(AccountRef_RSA__c = a.id, 
                    recordTypeId = Util.recordType.get('Order__c:FinalOrder'),
                    preliminaryOrderRef_RSA__c = preliminaryOrderList[0].id));
                finalOrderList.add(new Order__c(AccountRef_RSA__c = a.id, 
                    recordTypeId = Util.recordType.get('Order__c:FinalOrder'),
                    preliminaryOrderRef_RSA__c = preliminaryOrderList[1].id));
        		 finalOrderList.add(new Order__c(AccountRef_RSA__c = a.id, 
                    recordTypeId = Util.recordType.get('Order__c:FinalOrder'),
                    preliminaryOrderRef_RSA__c = preliminaryOrderList[2].id));
                insert finalOrderList;
                
                list<CampaignLineItem__c> clis = new list<CampaignLineItem__c>();
                clis.add ( new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),
                 FarmRef__c = a.id, CatalogType_RSA__c = 'Tax', CampaignRef__c = ca.Id, Type__c = 'Charged',
                 preliminaryOrderRef_RSA__c = preliminaryOrderList[0].id,finalOrderRef_RSA__c = finalOrderList[0].id));
                clis.add ( new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),
                 FarmRef__c = a.id, CatalogType_RSA__c = 'Regular', CampaignRef__c = ca.Id, Type__c = 'Charged',
                 preliminaryOrderRef_RSA__c = preliminaryOrderList[1].id,finalOrderRef_RSA__c = finalOrderList[1].id));
        		clis.add ( new CampaignLineItem__c(RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales'),
                 FarmRef__c = a.id, CatalogType_RSA__c = 'Regular', CampaignRef__c = ca.Id, Type__c = 'Charged',
                 preliminaryOrderRef_RSA__c = preliminaryOrderList[2].id,finalOrderRef_RSA__c = finalOrderList[2].id));
                insert clis;
                
                finalOrderList[0].Status_RSA__c ='closed';
        		finalOrderList[1].Status_RSA__c ='Waiting for discount approval';
        		finalOrderList[1].Discretionary_Discount_RSA__c = 5.0;
        		finalOrderList[1].Reason__c= 'D08 : Agri Business';
                //finalOrderList[2].Status_RSA__c = 'Approved';
                //finalOrderList[2].Discretionary_Discount_RSA__c = 0.0;
                //finalOrderList[2].VolumeDiscount_RSA__c = 0.0;
        
                //close final orders
                //for (Order__c o:finalOrderList){
                //    o.Status_RSA__c ='closed';
        
               // }
        
                update finalOrderList;
                
                //cancel final orders
                list<Id> finalOrdersId = new list<Id>();
                list<String> cancellationReasons = new list<String>();
                for (Order__C o:finalOrderList){
                    finalOrdersId.add(o.id);
                    cancellationReasons.add('asfd');
                }
                OrderCancellation.cancelOrder(finalOrdersId, cancellationReasons);
            test.stopTest();
    }
    
}