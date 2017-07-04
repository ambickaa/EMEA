@isTest
public class TEST_PDPControllers{
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        
         PDPCountryGroup__c cg1 = new PDPCountryGroup__c( Name='PDP_ES',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=false, Grouping__c='A', SAP_Country_Code__c='777771');
         PDPCountryGroup__c cg3 = new PDPCountryGroup__c( Name='PDP_HU',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=false, Grouping__c='A', SAP_Country_Code__c='777772');
         PDPCountryGroup__c cg4 = new PDPCountryGroup__c( Name='PDP_AK',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=false, Grouping__c='A', SAP_Country_Code__c='777779');   
         PDPCountryGroup__c cg2 = new PDPCountryGroup__c( Name='PDP_PT',  Repeat_L1__c=true, Repeat_L2__c=false, Repeat_L3__c=true, Country_LVL_2__c=true, Grouping__c='A', SAP_Country_Code__c='777778');
        
         insert New List<PDPCountryGroup__c> {cg1,cg2,cg3,cg4};
        Test.startTest();
        
		      PDPManagerController controller = new PDPManagerController(); 
		      controller.launcher();
		      controller.launcher2();
		      controller.getCreateAliasURL();
		      controller.getCreateSAPCodeURL();
		      controller.getCreateNameURL();
		      controller.test();
		      
		      PDP_TabTxtFileController controller2 = new PDP_TabTxtFileController();
		      
		      try{
		      	controller2.getCountryOptions();
		      }
		      catch(Exception e)
		      {
		      	
		      }
		      
		      try{
		      	controller2.getfilename();
		      }
		      catch(Exception e)
		      {
		      	
		      }
		      
		      try{
		      	controller2.gethierarchyLineItemList();
		      }
		      catch(Exception e)
		      {
		      	
		      }
		      
        Test.stopTest();
    }


}