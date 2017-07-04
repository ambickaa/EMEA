@isTest
public class Test_REST_SendLogicalEntityAcreagesEast{

    public static testMethod void TestSendAcreages() {
    
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();

        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage paramsAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage();
        paramsAcr.statuscode=null;
        paramsAcr.statusDescription='';   
        paramsAcr.acreages = new list<REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject>(); 

        REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject rAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject();     
        rAcr.action='Insert'; 
        rAcr.acreage=new Acreage__c( AcrFarmRef__c=Test_REST_DataFactoryEast.Farm.id, Land_fallow__c=false, Dry_Land__c=false, 
                                     AcrProviderRef__c=Test_REST_DataFactoryEast.Provider.id, AcrTotalAcreages__c=100,
                                     Irrigation__c=false, AcrSecondHarvest__c=false, RecordTypeId=Test_REST_DataFactoryEast.App.Id,
                                     idDevice__c=100, AcrYearRef__c=Test_REST_DataFactoryEast.Year.ID, 
                                     AcrProductRef__c=Test_REST_DataFactoryEast.pr1.id,
                                     AcrProductGroupRef__c=Test_REST_DataFactoryEast.pgg.id,
                                     AcrProductTypeRef__c=Test_REST_DataFactoryEast.pgt.id);           
         paramsAcr.acreages.add(rAcr);
           
         Test_REST_DataFactoryEast.acrList.clear();
            
            Test_REST_DataFactoryEast.acrList = [ SELECT Id,AcrFarmRef__c,AcrProviderRef__c,AcrTotalAcreages__c,Land_fallow__c,
                            Irrigation__c,AcrSecondHarvest__c, RecordTypeId,AcrYearRef__c,AcrProductGroupRef__c,Dry_Land__c,
                            AcrProductTypeRef__c, idDevice__c, LastModifiedDate FROM Acreage__c ];
                     
            for(Integer i=0; i<Test_REST_DataFactoryEast.regPerEntity;i++){
             	rAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject();     
                  if(Math.mod(i,2)==0) rAcr.action='Update';
                      else rAcr.action='Delete';      
              rAcr.LastModifiedDate=system.now();    
              rAcr.acreage=Test_REST_DataFactoryEast.acrList.get(i);
              paramsAcr.acreages.add(rAcr);}
    
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage outAcreages = REST_SendLogicalEntityAcreagesEastSM.sendAcreages(paramsAcr);
    
        //for(REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject clio : outAcreages.acreages){
        //System.assertEquals(100,clio.statusCode);
        //} 
        Test.stopTest();
        
    }
    
    
    public static testMethod void PrevDel() {
        
        Test_REST_DataFactoryEast.TestData();
        Test.startTest();
        
        Acreage__c Acr =new Acreage__c( AcrFarmRef__c=Test_REST_DataFactoryEast.Farm.id, Land_fallow__c=false, Dry_Land__c=false, 
                             AcrProviderRef__c=Test_REST_DataFactoryEast.Provider.id, AcrTotalAcreages__c=100,
                             Irrigation__c=false, AcrSecondHarvest__c=false, RecordTypeId=Test_REST_DataFactoryEast.App.Id,
                             idDevice__c=100, AcrYearRef__c=Test_REST_DataFactoryEast.Year.ID, 
                             AcrProductRef__c=Test_REST_DataFactoryEast.pr1.id,AcrProductTypeRef__c=Test_REST_DataFactoryEast.pgt.id,
                             AcrProductGroupRef__c=Test_REST_DataFactoryEast.pgg.id);
        insert Acr;
      
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage paramsAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage();
        paramsAcr.statuscode=null;
        paramsAcr.statusDescription='';   
        paramsAcr.acreages = new list<REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject>(); 
          
        REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject rAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject();     
        rAcr.action='Delete'; 
        rAcr.acreage= Acr;        
        paramsAcr.acreages.add(rAcr);

        Delete Acr;
        
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage outAcreages = REST_SendLogicalEntityAcreagesEastSM.sendAcreages(paramsAcr);
            
        System.assertEquals(201,outAcreages.statusCode);
        for(REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject clio : outAcreages.acreages){
          System.assertEquals(201,clio.statusCode);} 
          
        Test.StopTest();
          
    } 
    public static testMethod void MisMatch() {
    
        Test_REST_DataFactoryEast.TestData();

        Test.Starttest();

        Acreage__c Acr =new Acreage__c( AcrFarmRef__c=Test_REST_DataFactoryEast.Farm.id, Land_fallow__c=false, Dry_Land__c=false, 
                             AcrProviderRef__c=Test_REST_DataFactoryEast.Provider.id, AcrTotalAcreages__c=100,
                             Irrigation__c=false, AcrSecondHarvest__c=false, RecordTypeId=Test_REST_DataFactoryEast.App.Id,
                             idDevice__c=100, AcrYearRef__c=Test_REST_DataFactoryEast.Year.ID, 
                             AcrProductRef__c=Test_REST_DataFactoryEast.pr1.id,AcrProductTypeRef__c=Test_REST_DataFactoryEast.pgt.id,
                             AcrProductGroupRef__c=Test_REST_DataFactoryEast.pgg.id);
        insert Acr;
                
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage paramsAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage();
        paramsAcr.statuscode=null;
        paramsAcr.statusDescription='';   
        paramsAcr.acreages = new list<REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject>(); 
          
        REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject rAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject();     
        rAcr.action='Update'; 
        rAcr.acreage= Acr;        
        paramsAcr.acreages.add(rAcr);
        
        Update Acr;
        
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage outAcreages = REST_SendLogicalEntityAcreagesEastSM.sendAcreages(paramsAcr);
        System.assertEquals(200,outAcreages.statusCode);
        for(REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject clio : outAcreages.acreages){
          System.assertEquals(200,clio.statusCode);} 
          
        Test.Stoptest();
    }      
    public static testMethod void DMLError() {
    
        Test_REST_DataFactoryEast.TestData();

        Test.Starttest();

        Acreage__c Acr =new Acreage__c( AcrFarmRef__c=Test_REST_DataFactoryEast.Farm.id, Land_fallow__c=false, Dry_Land__c=false, 
                             AcrProviderRef__c=Test_REST_DataFactoryEast.Provider.id, AcrTotalAcreages__c=100,
                             Irrigation__c=false, AcrSecondHarvest__c=false, RecordTypeId=Test_REST_DataFactoryEast.App.Id,
                             idDevice__c=100, AcrYearRef__c=Test_REST_DataFactoryEast.Year.ID, 
                             AcrProductRef__c=Test_REST_DataFactoryEast.pr1.id,AcrProductTypeRef__c=Test_REST_DataFactoryEast.pgt.id,
                             AcrProductGroupRef__c=Test_REST_DataFactoryEast.pgg.id);
        insert Acr;                     
                             
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage paramsAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage();
        paramsAcr.statuscode=null;
        paramsAcr.statusDescription='';
        paramsAcr.acreages = new list<REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject>(); 
          
        REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject rAcr = new REST_SendLogicalEntityAcreagesEastSM.REST_AcreageObject();     
        rAcr.action='Insert'; 
        rAcr.acreage= Acr;        
        paramsAcr.acreages.add(rAcr);
        
        REST_SendLogicalEntityAcreagesEastSM.REST_SendLogicalEntityAcreage outAcreages = REST_SendLogicalEntityAcreagesEastSM.sendAcreages(paramsAcr);
        System.assertEquals(999,outAcreages.statusCode);
          
        Test.Stoptest();
	}
}