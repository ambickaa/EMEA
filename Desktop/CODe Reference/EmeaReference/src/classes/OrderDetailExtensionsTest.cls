@IsTest
public class OrderDetailExtensionsTest {
	
  	public static testmethod void test()
	{
		Test_REST_DataFactoryEast.TestData();
     	test.StartTest();
		
		
		Order__c ppoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed', 
                                       RecordTypeID=Util.RecordType.get('Order__c:PreliminaryOrder'),shouldCopy_RSA__c=false);
        Order__c ffoo = new order__c( AccountRef_RSA__c= Test_REST_DataFactoryEast.aList.get(10).id, Status_RSA__c='Closed',
                                          PreliminaryOrderRef_RSA__c= ppoo.id, shouldCopy_RSA__c=false,
                                          RecordTypeID=Util.RecordType.get('Order__c:FinalOrder'));            
                                       
        insert ppoo;
        insert ffoo;
       	
       	Map<String,String> strMap = new Map<String,String>();
       	strMap.put('id',(string)ppoo.Id);
       	
       	Util.urlParameters=strMap;
                  
		OrderDetailExtensions controller = new OrderDetailExtensions();
		
	
	
		
		try{
			controller.save();
		}catch(Exception e)
		{
			
		}
		try{
			controller.DeleteAll();			
		}catch(Exception e)
		{
			
		}	
		try{
			controller.Cancel();			
		}catch(Exception e)
		{
			
		}
		try{
			controller.Edit();			
		}catch(Exception e)
		{
			
		}		
		try{
			controller.Add();			
		}catch(Exception e)
		{
			
		}	
		
		strMap.put('id',(string)ffoo.Id);	
       	Util.urlParameters=strMap;				
		OrderDetailExtensions controller2 = new OrderDetailExtensions();
				
			
		try{
			controller2.save();
		}catch(Exception e)
		{
			
		}
		try{
			controller2.DeleteAll();			
		}catch(Exception e)
		{
			
		}	
		try{
			controller2.Cancel();			
		}catch(Exception e)
		{
			
		}
		try{
			controller2.Edit();			
		}catch(Exception e)
		{
			
		}		
		try{
			controller2.Add();			
		}catch(Exception e)
		{
			
		}						
			
	}

}