@isTest
public class Test_REST_DelLogicalEntityTerMan{
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        
        List<TerritoryManagement__c> ForDel= new List<TerritoryManagement__c>();
        
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++){
            TerritoryManagement__c TM=new TerritoryManagement__c(
                      DE_StateProvince__c='dka'+String.Valueof(i),
                      DE_LandKreis__c='dka'+String.Valueof(i),
                      DE_Landkreis2__c='dka'+String.Valueof(i),
                      DE_CP__c='dka'+String.Valueof(i),
                      Name='AN'+String.Valueof(i),
                      DE_PrimaryKey__c='dka'+String.Valueof(i),
                      DE_CountryRef__c=Test_REST_DataFactoryEast.c.id);
             ForDel.add(TM);}
        insert ForDel;
        delete ForDel;
        
		
        REST_DelLogicalEntityTerritoryManagement.REST_DelLogicalEntity_Territory params = new REST_DelLogicalEntityTerritoryManagement.REST_DelLogicalEntity_Territory();
        params.territories=ForDel;
             
        REST_DelLogicalEntityTerritoryManagement.REST_DelLogicalEntity_Territory returned = REST_DelLogicalEntityTerritoryManagement.getDeletedTerritories(params);
		System.AssertEquals(returned.territories.Size(),Test_REST_DataFactoryEast.RegPerEntity);
    	Test.stopTest();
     }
     
    public static testmethod void ExTest(){

          Test_REST_DataFactoryEast.TestData();
          test.StartTest();
          
            TerritoryManagement__c TM=new TerritoryManagement__c(
                      DE_StateProvince__c='dka',
                      DE_LandKreis__c='dka',
                      DE_Landkreis2__c='dka',
                      DE_CP__c='dka',
                      Name='AN',
                      DE_PrimaryKey__c='dka',
                      DE_CountryRef__c=Test_REST_DataFactoryEast.c.id);
             insert TM;
           
          REST_DelLogicalEntityTerritoryManagement.REST_DelLogicalEntity_Territory params = new REST_DelLogicalEntityTerritoryManagement.REST_DelLogicalEntity_Territory();
          params = REST_DelLogicalEntityTerritoryManagement.getExample();
          
          test.stopTest();
          System.Assert(params.territories.Size()==1);
     }
}