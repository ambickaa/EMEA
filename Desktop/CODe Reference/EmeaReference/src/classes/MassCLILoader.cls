global class MassCLILoader implements Database.Batchable<sObject>{  


/*Support Team 17/09/2014

This batch copied the CLIs from previous year to current year. 
- It won't copy the CampaignLineItems with inactive owner.
- The current campaign of owner cli must be created before the batch executation
and activated it.
- The batch don't created the PCE if in the current capaign doesn't exist, it ignore these clis

Inputs:
    previousYear: Previous year.
    actualYear: Current year.
    div: Division.
    aditionalCond: Some aditional condition to CLI Query.
    advance: Is a boolean tha sets the campaign status code. 

Call example: 
Database.executeBatch(new MassCLILoader('2014','2015','Roundup','Germany',true,''),100)  -> Standard Query. 


    
*/

public Boolean Loader=true;
public String toQuery;

global final String cQuery;
global final String cPreviousYear ;
global final String cYear;
global final String cDivision;
global final String cCountry;
global final Integer cStatusCodeTo;
global final Integer cStatusCodeFrom;
global  Map<ID,ID> prodVsPCE; // current season PCE of last year product 
global  Set<ID> prodInPC; // prod in current season pcatalog

global  Map<ID,ID> prodVsPCE_Tax; // current season PCE of last year product 
global  Set<ID> prodInPC_Tax;
global  Map<ID,ID> prodVsPCE_FR; // current season PCE of last year product 
global  Set<ID> prodInPC_FR;

global final Map<ID,Campaign> userVsCampaign;

global MassCLILoader(String previousYear, String actualYear, String div, String country,boolean advance, String query)
{
    
    
    
    cPreviousYear=previousYear;
    cYear=actualYear;
    cDivision=div;
    cCountry=country;
    cQuery=query;   
   	if(advance){
    	 cStatusCodeTo = 100;
    	 cStatusCodeFrom = 200;
    }
    else{
    	 cStatusCodeTo =200;
    	 cStatusCodeFrom=300;
    }   
    //active campaign
    prodVsPCE = new Map<ID,ID>();   
    prodvsPCE_Tax= new Map<ID,ID>();
    prodVsPCE_FR = new Map<ID,ID>();    
    
    prodInPC = new Set<ID>();
    prodInPC_Tax = new Set<ID>();
    prodInPC_FR = new Set<ID>();
    
    userVsCampaign = new Map<ID,Campaign>();
    
    Set<Id> activeSalesCatalogs = new set<id>();
    Set<Id> activeSalesCatalogs_Tax = new set<id>();
    
    for( Campaign cpg : [ SELECT  ID, Name, CompetitorPCMRef__c, SalesPCMRef__c , TaxSalesPCMRef_RSA__c,
                                        TaxSalesPCMRef_RSA__r.Name, SalesPCMRef__r.Name,CompetitorPCMRef__r.Name,
                                        OwnerId
                                      FROM Campaign WHERE StatusCode__c=:cStatusCodeTo
                                      AND CountryRef__r.Name=:cCountry AND DivisionRef__r.Name=:cDivision
                                      AND YearV2__r.Name=:cYear
                                      ] )
     {
        userVsCampaign.put(cpg.OwnerId,cpg);
         if((cpg.TaxSalesPCMRef_RSA__c!=null) && (!cpg.TaxSalesPCMRef_RSA__r.Name.contains('Marketing')) )              
            activeSalesCatalogs_Tax.add(cpg.TaxSalesPCMRef_RSA__c);
         if((cpg.SalesPCMRef__c!=null) && (!cpg.SalesPCMRef__r.Name.contains('Marketing')))                                         
            activeSalesCatalogs.add(cpg.SalesPCMRef__c);
         if(!cCountry.equalsIgnoreCase('South Africa')) // ADD COMPETITOR CATALOG FOR NON RSA COUNTRIES
             if((cpg.CompetitorPCMRef__c!=null)&&(!cpg.CompetitorPCMRef__r.Name.contains('Marketing')))                                         
                activeSalesCatalogs.add(cpg.CompetitorPCMRef__c);           
     }

    for(ProductCatalogEntry__c pce: [SELECT ID, ProductRef__c, PriceOld__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c in: activeSalesCatalogs ])
    {
        if(pce.ProductRef__c!=null)
        {
                prodInPC.add(pce.ProductRef__c);
                prodVsPCE.put(pce.ProductRef__c,pce.ID);
            if(pce.PriceOld__c!= null && pce.PriceOld__c>0)
            {
                prodInPC_FR.add(pce.ProductRef__c);
                prodVsPCE_FR.put(pce.ProductRef__c,pce.ID);
            }
        }
    }   
    
    for(ProductCatalogEntry__c pce: [SELECT ID, ProductRef__c FROM ProductCatalogEntry__c WHERE ProductCatalogRef__c in: activeSalesCatalogs_Tax ])
    {
        if(pce.ProductRef__c!=null)
        {
            prodInPC_Tax.add(pce.ProductRef__c);
            prodvsPCE_Tax.put(pce.ProductRef__c,pce.ID);
        }
    }   
    
}

global Database.querylocator start(Database.BatchableContext BC){
    if(Loader)
    {         
       String RecordTypeId=Util.recordType.get('CampaignLineItem__c:Sales');
       toQuery=cQuery;
       if(cCountry.equalsIgnoreCase('South Africa') && toQuery.equalsIgnoreCase(''))
       {    
            String approved='Approved';
            String closed='Closed';   
            toQuery='SELECT DistributorRef__c, PlantingDensity__c, Ultrashort_Irrigation_RSA__c, Pos__c, Provider__c, RecordTypeId,  Agreed__c,  POG__c , ProductCatalogEntryRef__c,  CatalogType_RSA__c, Inventory__c, Forecast__c, FarmRef__c,FarmRef__r.OwnerId, Quantity__c,  CampaignRef__c, Type__c, ProductRef__c, Status__c   FROM CampaignLineItem__c WHERE CampaignRef__r.StatusCode__c=:cStatusCodeFrom AND CampaignRef__r.CountryRef__r.Name=:cCountry AND CampaignRef__R.YearV2__r.Name=:cPreviousYear AND CampaignRef__r.DivisionRef__r.Name=:cDivision AND RecordTypeId=:RecordTypeId';    
            toQuery=toQuery+' AND (FinalOrderRef_RSA__r.Status_RSA__c=:closed OR FinalOrderRef_RSA__r.Status_RSA__c=:approved) AND FinalOrderRef_RSA__r.Signed_RSA__c=true';
       }
       else if( cCountry!='South Africa' && toQuery.equalsIgnoreCase(''))
       {    
            String charged='Charged';
           toQuery='SELECT DistributorRef__c, Pos__c, Provider__c, RecordTypeId,  Agreed__c,  POG__c , ProductCatalogEntryRef__c, CatalogType_RSA__c, Inventory__c, Forecast__c, FarmRef__c,FarmRef__r.OwnerId, OwnerId, Quantity__c,  CampaignRef__c, Type__c, ProductRef__c, Status__c  FROM CampaignLineItem__c WHERE CampaignRef__r.StatusCode__c=:cStatusCodeFrom AND CampaignRef__r.CountryRef__r.Name=:cCountry AND CampaignRef__R.YearV2__r.Name=:cPreviousYear AND CampaignRef__r.DivisionRef__r.Name=:cDivision AND RecordTypeId=:RecordTypeId AND Type__c=:charged AND POG__c!=0 AND POG__c!=null ';
       }
                     
    }  
    return Database.getQueryLocator(toQuery);}

global void execute(Database.BatchableContext BC, List<sObject> scope){

    if(Loader)
    {
       List<CampaignLineItem__c> cliToInsert = new List<CampaignLineItem__c>();    
       
       if(cCountry.equalsIgnoreCase('South Africa'))
       {    
           for(sObject s : scope)
           {
                CampaignLineItem__c cli = (CampaignLineItem__c)s;
            
                if(cli.CatalogType_RSA__c=='Tax')
                {
                    if(prodInPC_Tax.contains(cli.ProductRef__c))
                    {   
                            if(userVsCampaign.get(cli.FarmRef__r.OwnerId)!=null && prodVsPCE_TAX.get(cli.ProductRef__c)!=null)
                            cliToInsert.add(new CampaignLineItem__c(
                                        DistributorRef__c=cli.DistributorRef__c, 
                                        Pos__c=cli.Pos__c, 
                                        Ultrashort_Irrigation_RSA__c=cli.Ultrashort_Irrigation_RSA__c,                                  
                                        RecordTypeId=cli.RecordTypeId,  
                                        //Agreed__c=cli.Agreed__c,
                                        //POG__c=cli.POG__c , 
                                        PlantingDensity__c=cli.PlantingDensity__c,
                                        ProductCatalogEntryRef__c=prodVsPCE_TAX.get(cli.ProductRef__c),             
                                        CatalogType_RSA__c=cli.CatalogType_RSA__c, 
                                        //Inventory__c=cli.Inventory__c, 
                                        //Forecast__c=cli.Forecast__c, 
                                        FarmRef__c=cli.FarmRef__c, 
                                        //Quantity__c=cli.Quantity__c,  
                                        CampaignRef__c=userVsCampaign.get(cli.FarmRef__r.OwnerId).Id, 
                                        Type__c=cli.Type__c,
                                        ProductRef__c=cli.ProductRef__c, 
                                        Status__c=cli.Status__c,
                                        OwnerId=cli.FarmRef__r.OwnerId      
                              ));                           
                    } 
                }
                else if(cli.CatalogType_RSA__c=='Regular')
                {
                        
                    if(prodInPC.contains(cli.ProductRef__c))
                    {   
                            if(userVsCampaign.get(cli.FarmRef__r.OwnerId)!=null && prodVsPCE.get(cli.ProductRef__c)!=null)                  
                            cliToInsert.add(new CampaignLineItem__c(
                                        DistributorRef__c=cli.DistributorRef__c, 
                                        Pos__c=cli.Pos__c,  
                                        Ultrashort_Irrigation_RSA__c=cli.Ultrashort_Irrigation_RSA__c,                                                                                                                                      
                                        RecordTypeId=cli.RecordTypeId,
                                        PlantingDensity__c=cli.PlantingDensity__c,                                        
                                        //Agreed__c=cli.Agreed__c,
                                        //POG__c=cli.POG__c , 
                                        ProductCatalogEntryRef__c=prodVsPCE.get(cli.ProductRef__c),             
                                        CatalogType_RSA__c=cli.CatalogType_RSA__c, 
                                        //Inventory__c=cli.Inventory__c, 
                                        //Forecast__c=cli.Forecast__c, 
                                        FarmRef__c=cli.FarmRef__c, 
                                        //Quantity__c=cli.Quantity__c,  
                                        CampaignRef__c=userVsCampaign.get(cli.FarmRef__r.OwnerId).Id, 
                                        Type__c=cli.Type__c,
                                        ProductRef__c=cli.ProductRef__c, 
                                        Status__c=cli.Status__c,
                                        OwnerId=cli.FarmRef__r.OwnerId      
                              ));                           
                    }               
                }else if(cli.CatalogType_RSA__c=='Feb Receipt')
                {
                    if(prodInPC_FR.contains(cli.ProductRef__c))
                    {   
                            if(userVsCampaign.get(cli.FarmRef__r.OwnerId)!=null && prodVsPCE_FR.get(cli.ProductRef__c)!=null)                                       
                            cliToInsert.add(new CampaignLineItem__c(
                                        DistributorRef__c=cli.DistributorRef__c, 
                                        Pos__c=cli.Pos__c,  
                                        Ultrashort_Irrigation_RSA__c=cli.Ultrashort_Irrigation_RSA__c,                                                                                                      
                                        RecordTypeId=cli.RecordTypeId,  
                                        PlantingDensity__c=cli.PlantingDensity__c,                                      
                                        //Agreed__c=cli.Agreed__c,
                                        //POG__c=cli.POG__c , 
                                        ProductCatalogEntryRef__c=prodVsPCE_FR.get(cli.ProductRef__c),              
                                        CatalogType_RSA__c=cli.CatalogType_RSA__c, 
                                        //Inventory__c=cli.Inventory__c, 
                                        //Forecast__c=cli.Forecast__c, 
                                        FarmRef__c=cli.FarmRef__c, 
                                        //Quantity__c=cli.Quantity__c,  
                                        CampaignRef__c=userVsCampaign.get(cli.FarmRef__r.OwnerId).Id, 
                                        Type__c=cli.Type__c,
                                        ProductRef__c=cli.ProductRef__c, 
                                        Status__c=cli.Status__c,
                                        OwnerId=cli.FarmRef__r.OwnerId  
                              ));                           
                    } 
                }
                
            }
        }       
        else
        {
            for(sObject s : scope)
            {
                CampaignLineItem__c cli = (CampaignLineItem__c)s;
                if(prodInPC.contains(cli.ProductRef__c))
                {   
                        if(userVsCampaign.get(cli.OwnerId)!=null && prodVsPCE.get(cli.ProductRef__c)!=null &&cli.OwnerId!=null)                 
                        cliToInsert.add(new CampaignLineItem__c(
                                    DistributorRef__c=cli.DistributorRef__c, 
                                    Pos__c=cli.Pos__c,                                                              
                                    RecordTypeId=cli.RecordTypeId,  
                                    //Agreed__c=cli.Agreed__c,
                                    //POG__c=cli.POG__c , 
                                    ProductCatalogEntryRef__c=prodVsPCE.get(cli.ProductRef__c),             
                                    CatalogType_RSA__c=cli.CatalogType_RSA__c, 
                                    //Inventory__c=cli.Inventory__c, 
                                    //Forecast__c=cli.Forecast__c, 
                                    FarmRef__c=cli.FarmRef__c, 
                                    //Quantity__c=cli.Quantity__c,  
                                    CampaignRef__c=userVsCampaign.get(cli.OwnerId).Id, 
                                    Type__c=cli.Type__c,
                                    ProductRef__c=cli.ProductRef__c, 
                                    Status__c=cli.Status__c,
                                    LKP_PY_CLI__c=cli.id,
                                    OwnerId=(userVsCampaign.get(cli.OwnerId)!=null?cli.FarmRef__r.OwnerId:cli.OwnerId )     
                          ));                           
                }   
            }   
        }
               
       Savepoint sp = Database.setSavepoint();     
       try{
            insert(cliToInsert);
       }
       catch(Exception e)
       {
            system.debug('Exception: '+e);
            Database.rollback(sp);      
       }
    }
}
global void finish(Database.BatchableContext BC){

    
}
    

}