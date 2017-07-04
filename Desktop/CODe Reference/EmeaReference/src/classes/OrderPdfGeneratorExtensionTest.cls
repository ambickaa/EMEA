@isTest
public class OrderPdfGeneratorExtensionTest {
	
	public static testmethod void testController()
	{
        Test_REST_DataFactoryEast.TestData();
		
		test.startTest();		
				
	  Order__c ppoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.RecordType.get('Order__c:PreliminaryOrder'),shouldCopy_RSA__c=false
                                       );
            
            Order__c ffoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed',
                                          PreliminaryOrderRef_RSA__c= ppoo.id, shouldCopy_RSA__c=false,
                                          RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'),
                                          DeliveryInstructions__c='test',Reason__c='lalala');      
         
         insert ppoo;
         insert ffoo;
	
		OrderPdfGeneratorExtension controller = new OrderPdfGeneratorExtension(new ApexPages.StandardController(ppoo));
		OrderPdfGeneratorExtension controller2 = new OrderPdfGeneratorExtension(new ApexPages.StandardController(ffoo));
		
		try{
			controller.save();
		}
		catch(Exception e)
		{
			
		}
		test.stopTest();
	}
}