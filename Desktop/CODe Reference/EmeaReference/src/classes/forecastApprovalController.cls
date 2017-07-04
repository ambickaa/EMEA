public with sharing class forecastApprovalController {

    public Campaign getCurrentForecast() {
        try{
            return [Select Name, ApprovalStatus_RSA__c, (SELECT ID FROM ProcessInstances order by SystemModStamp desc limit 1) Status from Campaign where OwnerID = :userSelected AND yearV2__c = :Util.currentYear.Id];
        }catch(Exception e){return null;}
    }
    
    
    public forecastDetails getForecastDetail(){
        forecastDetails returned = new forecastDetails();
        List<AggregateResult> data =  [
            SELECT 
                ProductCatalogEntryRef__c,
                SUM(Forecast__c) Aggregated 
            FROM CampaignLineItem__c 
            WHERE 
                ownerID = :userSelected AND
                ProductCatalogEntryRef__c != null AND
                Forecast__c != null
            GROUP BY 
                ProductCatalogEntryRef__c
            ];
        
        Set<ID> productIDs = new Set<ID>();
        for(AggregateResult ar : data){
            productIDs.add((ID)ar.get('ProductCatalogEntryRef__c'));
        }
        Map<Id, ProductCatalogEntry__c> products = new Map<ID, ProductCatalogEntry__c>(
            [
                SELECT 
                    productRef__r.Name,
                    productRef__r.productkernelsize__c,
                    productRef__r.ProductTreatment__c
                FROM ProductCatalogEntry__c 
                WHERE ID in :productIDs]);
        
        ProductCatalogEntry__c forProduct;

        for(AggregateResult ar : data){
            forProduct = products.get(String.valueOf(ar.get('ProductCatalogEntryRef__c')));

            returned.add(
            
                String.valueOf(forProduct.productRef__r.Name),
                forProduct.productRef__r.productkernelsize__c,
                String.valueOf(forProduct.productRef__r.ProductTreatment__c),
                Integer.valueOf(ar.get('Aggregated'))
            );
        }

        return returned;
    } 

    public void doApprove(){
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve'); //This is the action that is approve in your case, you can set it to Reject also
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Use the ID from the newly created item to specify the item to be worked  
        
        req2.setWorkitemId([SELECT ID FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in (SELECT ID FROM ProcessInstance WHERE TargetObjectID = :getCurrentForecast().id) limit 1].ID);
        // Submit the request for approval  
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        Boolean allApproved = true;
        for(Campaign c : getMyTeamCampaigns()){
            for(ProcessInstance pi : c.ProcessInstances){
                if ( pi.status != 'Approved' ){
                    allApproved = false;
                }
            }
        }
        if(allApproved){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
        
            
            User currentUser = [SELECT manager.email FROM User WHERE id = :UserInfo.getUserID()];
            if(currentUser.manager != null)
                email.setSubject( UserInfo.getName() + ' approved all its subordinates Forecasts' );
                email.setToAddresses( new String[]{currentUser.manager.email} );
                email.setPlainTextBody( 'The user ' + UserInfo.getName() + ' has approved all its subordinates Forecasts' );

                Messaging.SendEmailResult [] r = 
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }
    }
    
    public void doReject(){
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Rejecting request.');
        req2.setAction('Reject'); //This is the action that is approve in your case, you can set it to Reject also
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Use the ID from the newly created item to specify the item to be worked  
        req2.setWorkitemId([SELECT ID FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in (SELECT ID FROM ProcessInstance WHERE TargetObjectID = :getCurrentForecast().id) limit 1].ID);
        // Submit the request for approval  
        Approval.ProcessResult result2 =  Approval.process(req2);
    }
    public ID userSelected {get;set;}
    public List<Campaign> getMyTeamCampaigns(){
        return [SELECT OwnerID, Owner.Name, LastModifiedDate, TotalCampaignBudget__c, (SELECT Status FROM ProcessInstances order by SystemModStamp desc limit 1) Status from Campaign where yearV2__c = :Util.currentYear.Id AND Owner.managerID = :UserInfo.getUserID()];
    }
    
    public class forecastDetails{
        public Integer aggregateSUM {get;set;}
        public List<Hybrid> items {get;set;}
        
        public forecastDetails(){
            aggregateSUM = 0;
            items = new List<Hybrid>();
        }
        public void add(String product, String kernel, String Treatment, Integer bags){
            aggregateSUM += bags;
            items.add(new Hybrid(product,kernel,treatment, bags));
        }
    }
    
    public class Hybrid{
        public String product {get;set;}
        public String kernel {get;set;}
        public String treatment {get;set;}
        public Integer bags {get;set;}
        public Hybrid (String product, String kernel, String treatment, Integer bags){
            this.product = product;
            this.kernel = kernel;
            this.treatment = treatment;
            this.bags = bags;
        }
    }
}