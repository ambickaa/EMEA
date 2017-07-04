@isTest
public class Test_REST_DelLogicalEntityOrderEast{
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        
		TriggerOrderUpdateBudgetOnline.fromRest=true;
		
        List<Order__c> ForDelOrd= new List<Order__c>();
        List<Campaign> ForDelCam= new List<Campaign>();
        List<CampaignLineItem__c> ForDelCLI= new List<CampaignLineItem__c>();
        
        ForDelOrd.addAll(Test_REST_DataFactoryEast.foList);
        
        Division__c DOSR= new Division__c(Name='OSR',Standard__c=true);
        Division__c DCer= new Division__c(Name='Cereal',Standard__c=true);
        
        List<Division__C> div2In = new List<Division__c>{DOSR,DCer};       
        insert div2In;
          
        Campaign Camp = new Campaign ( Name='OSR2011', EndDate=Date.newinstance(2011,11,11),  
                                       YearV2__c=Test_REST_DataFactoryEast.Last.id,CountryRef__c=Test_REST_DataFactoryEast.c.id, 
                                       StartDate=Date.newinstance(2011,02,02), DivisionRef__c = DOSR.id ); 
        Campaign Campx = new Campaign ( Name='Cereal2011', EndDate=Date.newinstance(2011,11,11),  
                                       YearV2__c=Test_REST_DataFactoryEast.Last.id,CountryRef__c=Test_REST_DataFactoryEast.c.id, 
                                       StartDate=Date.newinstance(2011,02,02), DivisionRef__c = DCer.id ); 
        List<Campaign> cmp2In = new List<Campaign>{Camp,campx};
		insert cmp2In;
        
        ForDelCam.add(Camp);          
        ForDelCam.add(Campx);
        ForDelCam.add(Test_REST_DataFactoryEast.Ca);          
        
        CampaignLineItem__c cli;             
        for(Integer i=0; i<Test_REST_DataFactoryEast.regPerEntity; i++){
      	  cli=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=Test_REST_DataFactoryEast.Provider.id, Forecast__c=500+i, 
                                     Agreed__c=600+i,PoG__c=700+i,CampaignRef__c= camp.id,PlantingDensity__c= '30000', 
                                     ProductCatalogEntryRef__c= Test_REST_DataFactoryEast.pceList.get(i).id,
                                     Ownerid=Util.currentUser.ID, FarmRef__c= Test_REST_DataFactoryEast.Farm.id, 
                                     PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(i).id, 
                                     FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(i).id,Type__c= 'Charged',
                                     ProductRef__c= Test_REST_DataFactoryEast.pList.get(i).id);
        ForDelCLI.add(cli);}
        for(Integer i=0; i<Test_REST_DataFactoryEast.regPerEntity; i++){
     	   cli=new CampaignLineItem__c( RecordTypeId= Util.recordType.get('CampaignLineItem__c:Sales'), 
                                     DistributorRef__c=Test_REST_DataFactoryEast.Provider.id, Forecast__c=500+i, 
                                     Agreed__c=600+i,PoG__c=700+i,CampaignRef__c= campx.id,PlantingDensity__c= '30000', 
                                     ProductCatalogEntryRef__c= Test_REST_DataFactoryEast.pceList.get(i).id,
                                     Ownerid=Util.currentUser.ID, FarmRef__c= Test_REST_DataFactoryEast.Farm.id, 
                                     PreliminaryOrderRef_RSA__c=Test_REST_DataFactoryEast.poList.get(i).id, 
                                     FinalOrderRef_RSA__c=Test_REST_DataFactoryEast.foList.get(i).id,Type__c= 'Charged',
                                     ProductRef__c= Test_REST_DataFactoryEast.pList.get(i).id);
        ForDelCLI.add(cli);}
        insert ForDelCLI;
        ForDelCli.AddAll(Test_REST_DataFactoryEast.cList);
         
        REST_DelLogicalEntityOrderEast.REST_DelLogicalEntity_Order params = new REST_DelLogicalEntityOrderEast.REST_DelLogicalEntity_Order();
        params.orders=ForDelOrd;
        params.campaigns=ForDelCam;
        params.CampaignLineItems=ForDelCLI;
                     
        REST_DelLogicalEntityOrderEast.REST_DelLogicalEntity_Order returned = REST_DelLogicalEntityOrderEast.getDeletedOrders(params);
             
        System.AssertEquals(returned.campaigns.Size(),2);
        System.AssertEquals(returned.orders.Size(),0);
        //System.AssertEquals(returned.campaignlineitems.Size(),Test_REST_DataFactoryEast.regPerEntity);
                
        Test.stopTest();
        
     }
     public static testmethod void ExTest(){

        Test_REST_DataFactoryEast.TestData();
   
        REST_DelLogicalEntityOrderEast.REST_DelLogicalEntity_Order params = new REST_DelLogicalEntityOrderEast.REST_DelLogicalEntity_Order();
        params = REST_DelLogicalEntityOrderEast.getExample();
        System.Assert(params.orders.Size()==2);
        System.Assert(params.campaignLineItems.Size()==2);
     }
}