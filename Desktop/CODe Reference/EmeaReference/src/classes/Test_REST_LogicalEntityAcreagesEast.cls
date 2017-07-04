@isTest 
public class Test_REST_LogicalEntityAcreagesEast{
    
   public static testmethod void getAcr(){
   
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        Datetime timecheck = System.now();
        
        List<Acreage__c> NewAcr = new List<Acreage__c>();
        for (integer i=0; i<Test_REST_DataFactoryEast.regPerEntity; i++){
            Acreage__c acr=new Acreage__c( AcrFarmRef__c=Test_REST_DataFactoryEast.Farmii.id, AcrTotalAcreages__c=100,
                                           AcrProviderRef__c=Test_REST_DataFactoryEast.Provider.id,Land_fallow__c=false,
                                           Dry_Land__c=false,Irrigation__c=false, AcrSecondHarvest__c=false,
                                           RecordTypeId=Test_REST_DataFactoryEast.App.Id, idDevice__c=100+i,
                                           AcrProductRef__c=Test_REST_DataFactoryEast.pr1.id,
                                           AcrYearRef__c=Test_REST_DataFactoryEast.Year.ID, OwnerId=Util.currentUser.ID,
                                           AcrProductGroupRef__c=Test_REST_DataFactoryEast.pgg.Id,
                                           AcrProductTypeRef__c=Test_REST_DataFactoryEast.pgt.Id);
            NewAcr.Add(acr);}
        insert NewAcr;
        NewAcr.AddAll(Test_REST_DataFactoryEast.acrList);
        
        //REST_LogicalEntityAcreagesEast_Old.REST_LogicalEntity_Acreage_old AcrToCheck = REST_LogicalEntityAcreagesEast_old.getAcreages(timecheck);
        //AcrToCheck = REST_LogicalEntityAcreagesEast_old.getAcreages(timecheck);
        //System.debug('Check Object '+AcrToCheck);  
		
		REST_Request req = new REST_Request();
		req.pagetimestamp = timecheck;
		REST_LogicalEntityAcreagesEast.REST_LogicalEntity_Acreage AcrToCheck2 = REST_LogicalEntityAcreagesEast.getAcreages(req);
		                  
        //REST_LogicalEntityAcreagesEast_old.REST_LogicalEntity_Acreage_old Constr = new REST_LogicalEntityAcreagesEast_old.REST_LogicalEntity_Acreage_old(NewAcr, Timecheck);

   Test.stopTest();  
   }    
   
}