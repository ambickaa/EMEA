@isTest
public class Test_REST_DelLogicalEntityAcreagesEast{
    public static testmethod void DelTest(){
    
    	/* Insert a list of past year acreages and a current year acreage, function must return last year acreages to be deleted */
        Test_REST_DataFactoryEast.TestData();
        
        List<Acreage__c> ForDel= new List<Acreage__c>();
        Acreage__c Acr=new Acreage__c( AcrFarmRef__c=Test_REST_DataFactoryEast.Farm.id, AcrTotalAcreages__c=100, 
        			                   Land_fallow__c=false, Dry_Land__c=false, Irrigation__c=false, 
        			                   AcrSecondHarvest__c=false,
                                       RecordTypeId=Test_REST_DataFactoryEast.Appg.id, idDevice__c=168, 
                                       AcrProductRef__c=Test_REST_DataFactoryEast.pr1.id, 
                                       AcrYearRef__c=Test_REST_DataFactoryEast.Last.ID,
                                       AcrProductGroupRef__c=Test_REST_DataFactoryEast.pgg.id, 
                                       AcrProductTypeRef__c=Test_REST_DataFactoryEast.pgt.id);
		insert Acr;
        ForDel.addAll(Test_REST_DataFactoryEast.acrlist);
        ForDel.add(Acr); 
        
        REST_DelLogicalEntityAcreagesEast.REST_DelLogicalEntity_Acreage params = new REST_DelLogicalEntityAcreagesEast.REST_DelLogicalEntity_Acreage();
        params.acreages=ForDel;
          
        REST_DelLogicalEntityAcreagesEast.REST_DelLogicalEntity_Acreage returned = REST_DelLogicalEntityAcreagesEast.getDeletedAcreages(params);

        System.AssertEquals(returned.acreages.Size(),1);
    }
    public static testmethod void ExTest(){

          Test_REST_DataFactoryEast.TestData();

          REST_DelLogicalEntityAcreagesEast.REST_DelLogicalEntity_Acreage params = new REST_DelLogicalEntityAcreagesEast.REST_DelLogicalEntity_Acreage();
          params = REST_DelLogicalEntityAcreagesEast.getExample();
          
          System.Assert(params.acreages.Size()>0);
     }
}