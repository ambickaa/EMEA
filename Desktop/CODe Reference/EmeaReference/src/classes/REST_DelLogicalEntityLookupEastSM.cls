@RestResource(urlMapping='/getDeletedLogicalEntity/Lookup2SM/*')
global without sharing class REST_DelLogicalEntityLookupEastSM{

    @HttpPost
    global static REST_DelLogicalEntity_Lookup getDeletedAccounts(REST_DelLogicalEntity_Lookup paramInfo)
    {
        REST_DelLogicalEntity_Lookup returned = new REST_DelLogicalEntity_Lookup();
        
        returned.divisions = new List<division__c>();
        Map<ID,division__c> paramInfodivisions = new Map<ID,division__c>(paramInfo.divisions);
        Set<ID> paramInfodivisionIDs = paramInfodivisions.keySet();
        
        Map<ID,division__c> currentdivisions = new Map<ID,division__c>([SELECT ID FROM division__c WHERE ID IN :paramInfodivisionIDs AND (Name = 'Corn' OR Name = 'OSR')]);
        Set<ID> currentdivisionIDs = currentdivisions.keySet();
        
        paramInfoDivisionIDs.removeAll(currentdivisionIDs);
        for(ID i : paramInfoDivisionIDs){
            returned.divisions.add(paramInfoDivisions.get(i));
        }
        
        returned.countries = new List<country__c>();
        Map<ID,country__c> paramInfocountries = new Map<ID,country__c>(paramInfo.countries);
        Set<ID> paramInfocountryIDs = paramInfocountries.keySet();
        
        Map<ID,country__c> currentCountries = new Map<ID,country__c>([SELECT ID FROM country__c WHERE ID IN :paramInfocountryIDs]);
        Set<ID> currentcountryIDs = currentcountries.keySet();
        
        paramInfoCountryIDs.removeAll(currentCountryIDs);
        for(ID i : paramInfoCountryIDs){
            returned.countries.add(paramInfoCountries.get(i));
        }
        
        
        returned.years = new List<Year__c>();
        Map<ID,year__c> paramInfoyears = new Map<ID,year__c>(paramInfo.years);
        Set<ID> paramInfoYearIDs = paramInfoyears.keySet();
        
        Map<ID,year__c> currentyears = new Map<ID,year__c>([SELECT ID FROM year__c WHERE ID IN :paramInfoyearIDs]);
        Set<ID> currentyearIDs = currentyears.keySet();
        
        paramInfoyearIDs.removeAll(currentyearIDs);
        for(ID i : paramInfoyearIDs){
            returned.years.add(paramInfoyears.get(i));
        }
        
        //Voucher start
        if(paramInfo.discounts!=null && paramInfo.discounts.size() > 0)
        {
            returned.discounts = new List<Discount__c>();
            Map<ID,Discount__c> paramInfodiscounts = new Map<ID,Discount__c>(paramInfo.discounts);
            Set<ID> paramInfoDiscountIDs = paramInfodiscounts.keySet();
            
            Map<ID,Discount__c> currentdiscounts = new Map<ID,Discount__c>([SELECT ID FROM Discount__c WHERE ID IN :paramInfoDiscountIDs  AND Active__c=true 
                    AND VoucherCampaignRef__c in:UtilREST.VoucherCampaigns]);
            Set<ID> currentDiscountIDs = currentdiscounts.keySet();
             
            paramInfoDiscountIDs.removeAll(currentDiscountIDs);
            for(ID i : paramInfoDiscountIDs){
                returned.discounts.add(paramInfodiscounts.get(i));
            }
        }
        
        //voucher end
        if(paramInfo.discountsRSA != null && paramInfo.discountsRSA.size() >0)
        {
            returned.discountsRSA = new List<DiscountMasterTable_RSA__c>();
            Map<ID,DiscountMasterTable_RSA__c> paramInfodiscountsRSA = new Map<ID,DiscountMasterTable_RSA__c>(paramInfo.discountsRSA);
            Set<ID> paramInfoDiscountRSAIDs = paramInfodiscountsRSA.keySet();
            
            Map<ID,DiscountMasterTable_RSA__c> currentdiscountsRSA = new Map<ID,DiscountMasterTable_RSA__c>([SELECT ID FROM DiscountMasterTable_RSA__c WHERE ID IN :paramInfoDiscountRSAIDs  AND Year_RSA__c=:UtilREST.currentYearRSA]);
            Set<ID> currentDiscountRSAIDs = currentdiscountsRSA.keySet();
             
            paramInfoDiscountRSAIDs.removeAll(currentDiscountRSAIDs);
            for(ID i : paramInfoDiscountRSAIDs){
                returned.discountsRSA.add(paramInfodiscountsRSA.get(i));
            }
        }
        
        //TEST
        
        returned.productgroups = new List<Product_Grouping__c>();
        Map<ID,Product_Grouping__c> paramInfoproductgroups = new Map<ID,Product_Grouping__c>(paramInfo.productgroups);
        Set<ID> paramInfoproductgroupsIDs = paramInfoproductgroups.keySet();
        
        Map<ID,Product_Grouping__c> currentproductgroups = new Map<ID,Product_Grouping__c>([SELECT ID FROM Product_Grouping__c WHERE ID IN :paramInfoproductgroupsIDs]);
        Set<ID> currentproductgroupsIDs = currentproductgroups.keySet();
        
        paramInfoproductgroupsIDs.removeAll(currentproductgroupsIDs);
        for(ID i : paramInfoproductgroupsIDs){
            returned.productgroups.add(paramInfoproductgroups.get(i));
        }

        returned.producttypes = new List<Product_Grouping__c>();
        Map<ID,Product_Grouping__c> paramInfoproducttypes = new Map<ID,Product_Grouping__c>(paramInfo.producttypes);
        Set<ID> paramInfoproducttypesIDs = paramInfoproducttypes.keySet();
        
        Map<ID,Product_Grouping__c> currentproducttypes = new Map<ID,Product_Grouping__c>([SELECT ID FROM Product_Grouping__c WHERE ID IN :paramInfoproducttypesIDs]);
        Set<ID> currentproducttypesIDs = currentproducttypes.keySet();
        
        paramInfoproducttypesIDs.removeAll(currentproducttypesIDs);
        for(ID i : paramInfoproducttypesIDs){
            returned.producttypes.add(paramInfoproducttypes.get(i));
        }       
        
        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Lookup getExample()
    {
        REST_DelLogicalEntity_Lookup returned = new REST_DelLogicalEntity_Lookup();
        
        returned.years = [SELECT ID,idDevice__c FROM Year__c LIMIT 1];
        returned.divisions = [SELECT ID,idDevice__c FROM Division__c LIMIT 1];
        returned.countries = [SELECT ID,idDevice__c FROM Country__c LIMIT 1];
        returned.productgroups = [SELECT ID,idDevice__c FROM Product_Grouping__c LIMIT 1];
        returned.producttypes = [SELECT ID,idDevice__c FROM Product_Grouping__c LIMIT 1];
        returned.discounts = [SELECT ID,idDevice__c FROM Discount__c LIMIT 1];
        returned.discountsRSA = [SELECT ID,idDevice__c FROM DiscountMasterTable_RSA__c LIMIT 1];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Lookup {
        public List<Division__c> divisions;
        public List<Country__c> countries;
        public List<Year__c> years;
        public List<Product_Grouping__c> productgroups;
        public List<Product_Grouping__c> producttypes;
        public List<Discount__c> discounts;
        public List<DiscountMasterTable_RSA__c> discountsRSA;
        
    }
    
  /*  static testMethod void testRest() {
        // set up the request object
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/getDeletedLogicalEntity/Lookup';
        RestContext.request.addHeader('email', 'sr13@fullbox.mto');
        // Invoke the method directly
        
        REST_DelLogicalEntity_Lookup param = new REST_DelLogicalEntity_Lookup();
        param.divisions = new List<Division__c>();
        param.countries = new List<Country__c>();
        param.years = new List<Year__c>();

        
        REST_DelLogicalEntityLookupController.getDeletedAccounts(param);
    }*/
}