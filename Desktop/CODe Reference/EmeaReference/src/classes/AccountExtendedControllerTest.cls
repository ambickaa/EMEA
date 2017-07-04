@IsTest
public with sharing class AccountExtendedControllerTest {
	public static testmethod void basicTest(){
		ContentVersion testContentInsert =new ContentVersion(); 
         testContentInsert.ContentURL='http://www.google.com/'; 
         testContentInsert.Title ='Google.com'; 

         insert testContentInsert; 
			AccountExtendedController controller = new AccountExtendedController(new ApexPages.standardController(testContentInsert));
	}
}