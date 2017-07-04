@RestResource(urlMapping='/getDeletedLogicalEntity/Acreage/*')
global with sharing class REST_DelLogicalEntityAcreagesEast{

    @HttpPost
    global static REST_DelLogicalEntity_Acreage getDeletedAcreages(REST_DelLogicalEntity_Acreage paramInfo)
    {
        REST_DelLogicalEntity_Acreage returned = new REST_DelLogicalEntity_Acreage();
     		
        returned.acreages = new List<Acreage__c>();
		
        Map<ID,Acreage__c> paramInfoAcreages = new Map<ID,Acreage__c>(paramInfo.acreages);
        Set<ID> paramInfoAcreageIDs = paramInfoAcreages.keySet();
        
        Map<ID,Acreage__c> currentAcreages = new Map<ID,Acreage__c>(
        [SELECT ID FROM Acreage__c WHERE ID IN :paramInfoAcreageIDs AND  AcrYearRef__c=:Util.currentYear.Id  
        	AND AcrProviderRef__r.Name!=null AND AcrFarmRef__r.Name!=null ]);
        Set<ID> currentAcreageIDs = currentAcreages.keySet();
        
        paramInfoAcreageIDs.removeAll(currentAcreageIDs);
        for(ID i : paramInfoAcreageIDs){ 
            returned.acreages.add(paramInfoAcreages.get(i));
        }
        
        return returned;
    }
    @HttpGet
    global static REST_DelLogicalEntity_Acreage getExample()
    {
        REST_DelLogicalEntity_Acreage returned = new REST_DelLogicalEntity_Acreage();
        
        returned.acreages = [SELECT ID FROM Acreage__c];
        
        return returned;
    }
    
    global class REST_DelLogicalEntity_Acreage {
        public List<Acreage__c> acreages;
    }
    
   
}