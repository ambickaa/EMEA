@isTest
private class Test_OrderCancellation {

    @isTest
    public static void testOrderCancellation(){ 
            TestInit.init();
            //Country__c c = new Country__c(Name = 'South Africa',TacticalPlanSetting__c = 'RSA');
            List<Country__c> countries= TestInit.countries;
           
            Account  testAccount = TestInit.createNewFarmer();
            insert testAccount;

         
            
            Order__c order1= new Order__c(AccountRef_RSA__c = testAccount.id,type_RSA__c ='Tax',Status_RSA__c='Closed');
            insert order1;
            Order__c order2= new Order__c(AccountRef_RSA__c = testAccount.id,type_RSA__c ='Tax',Status_RSA__c='Closed',Cancellation_Reason_RSA__c='cancelled');
            insert order2;
            order2.Status_RSA__c='Cancelled';
            update order2;
            list<Id> ordersId = new list<Id>();
            list<String> cancels=new list<String>();
            cancels.add('cancelled');
            ordersId.add(order1.Id);

            Test.startTest();
            try{
            	OrderCancellation.cancelOrder(ordersId,cancels);            	
            	cancels.add('cancelled2');
	            ordersId.add(order2.Id);
	            OrderCancellation.cancelOrder(ordersId,cancels);
            }
            catch(DMLException e){            	
            }	

            Test.stopTest();
            OrderCancellation.generatePDF();
       
    }
}