public class TriggerPreviousYearSales implements Triggers.Handler
{
    public Boolean isRSA = false;
    
    public void handle()
    {
        List<ID> productsToQuery= new List<ID>();
        List<ID> divisionsToQuery = new List<ID>();
        List<ID> ownersID = new List<ID>();
        List<ID> FarmsToQuery=new List<ID>();
        
        Map<String,Integer> SalesPY= new Map<String,Integer>();
        Map<String,Integer> SalesPYTax= new Map<String,Integer>();
        Map<String,Integer> SalesPYFR= new Map<String,Integer>();
        Map<String,Integer> SalesPYGen= new Map<String,Integer>();
        

        for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.new)
        {
            if(cli.Country__c=='South Africa' && !isRSA)
            {
                isRSA=true;
            }
            if(cli.RecordTypeId=='012D000000035B2IAI')
            {    productsToQuery.add(cli.ProductRef__c);
                 ownersID.add(cli.OwnerId);
                 farmsToQuery.add(cli.FarmRef__c);
                 SalesPY.put((String)cli.ProductRef__c+'_'+(String)cli.OwnerId+'_'+(String)cli.FarmRef__c,0);
                 SalesPYTax.put((String)cli.ProductRef__c+'_'+(String)cli.OwnerId+'_'+(String)cli.FarmRef__c,0);
                 SalesPYFR.put((String)cli.ProductRef__c+'_'+(String)cli.OwnerId+'_'+(String)cli.FarmRef__c,0);
                 SalesPYGen.put((String)cli.ProductRef__c+'_'+(String)cli.OwnerId+'_'+(String)cli.FarmRef__c,0);
                 
            }     
        }

        if(!isRSA) 
        {
            
			for(AggregateResult a0 : [
                 SELECT Sum(PoG__c) PoG, ProductRef__c  Product, FarmRef__c Farm
                 FROM CampaignLineItem__c WHERE  
                   CampaignRef__r.StatusCode__c=300
                    AND ProductRef__c in: productsToQuery AND Status__c!='Cancelled' AND Type__c='Charged' AND FarmRef__c!=null
                    AND FarmRef__c in:farmsToQuery
                    AND (CampaignRef__r.CountryRef__r.TacticalPlanSetting__c!='Generic' AND CampaignRef__r.CountryRef__r.TacticalPlanSetting__c!='French')
                 GROUP BY ProductRef__c,FarmRef__c 
                                    ])
            {
                SalesPY.put((String)a0.get('Product')+'_'+(String)a0.get('Farm'),Integer.valueof(a0.get('PoG')));
            }
            
            for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.new)
            {
                if(cli.ProductRef__c!=null && cli.FarmRef__c!=null)
                    cli.POGPY__c=SalesPY.get(cli.ProductRef__c+'_'+cli.FarmRef__c);                   
            
            }
        }
        else
        {

            for(AggregateResult a0 : [
                 SELECT Sum(PoG__c) PoG, ProductRef__c Product, CatalogType_RSA__c  cat, CampaignRef__r.OwnerId OwnerCLI, FarmRef__c Farm
                 FROM CampaignLineItem__c WHERE  
                    CampaignRef__r.OwnerId in: ownersID  AND CampaignRef__r.StatusCode__c=300
                    AND ProductRef__c in: productsToQuery  AND Type__c='Charged' AND FarmRef__c!=null
                    AND FarmRef__c in:farmsToQuery AND (FinalOrderRef_RSA__r.Status_RSA__c='Closed' OR FinalOrderRef_RSA__r.Status_RSA__c='Approved')
                     AND FinalOrderRef_RSA__r.Signed_RSA__c=true
                 GROUP BY ProductRef__c,CampaignRef__r.OwnerId,FarmRef__c,CatalogType_RSA__c
                                    ])
            {
            	if((String)a0.get('cat')=='Regular')
              	  SalesPY.put((String)a0.get('Product')+'_'+(String)a0.get('OwnerCLI')+'_'+(String)a0.get('Farm'),Integer.valueof(a0.get('PoG')));
                else if ((String)a0.get('cat')=='Tax')
             	  SalesPYTax.put((String)a0.get('Product')+'_'+(String)a0.get('OwnerCLI')+'_'+(String)a0.get('Farm'),Integer.valueof(a0.get('PoG')));
                else if ((String)a0.get('cat')=='Feb Receipt')
             	  SalesPYFR.put((String)a0.get('Product')+'_'+(String)a0.get('OwnerCLI')+'_'+(String)a0.get('Farm'),Integer.valueof(a0.get('PoG')));  
         	  	else if ((String)a0.get('cat')=='General')
             	  SalesPYGen.put((String)a0.get('Product')+'_'+(String)a0.get('OwnerCLI')+'_'+(String)a0.get('Farm'),Integer.valueof(a0.get('PoG')));  
            }
            
            
            for(CampaignLineItem__c cli: (List<CampaignLineItem__c>)trigger.new)
            {
                if(cli.ProductRef__c!=null && cli.FarmRef__c!=null)
                {
                	if(cli.CatalogType_RSA__c=='Regular' || cli.CatalogType_RSA__c=='Feb Receipt' || cli.CatalogType_RSA__c=='General')
                    	cli.POGPY__c=SalesPY.get(cli.ProductRef__c+'_'+cli.OwnerId+'_'+cli.FarmRef__c)
                    	+SalesPYFR.get(cli.ProductRef__c+'_'+cli.OwnerId+'_'+cli.FarmRef__c)
                    	+SalesPYGen.get(cli.ProductRef__c+'_'+cli.OwnerId+'_'+cli.FarmRef__c);                    
            		else if(cli.CatalogType_RSA__c=='Tax')
                    	cli.POGPY__c=SalesPYTax.get(cli.ProductRef__c+'_'+cli.OwnerId+'_'+cli.FarmRef__c);                                		
                }
            }
        }
        
        
        
    }
}