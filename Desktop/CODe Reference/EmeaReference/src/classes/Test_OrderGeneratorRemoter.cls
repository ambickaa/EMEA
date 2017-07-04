@isTest
private class Test_OrderGeneratorRemoter {

 public static testMethod void testHandle(){
  
  	Test.startTest();
     OrderGeneratorRemoter controller = new OrderGeneratorRemoter();
	
	try{
		 controller.launcher(); 				
	}catch(Exception e)
	{
	}
    Test.stopTest();
 }


}