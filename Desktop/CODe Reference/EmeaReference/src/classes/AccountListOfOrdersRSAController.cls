public with sharing class AccountListOfOrdersRSAController
{
    public List<Order__c> orders {get;set;}
    public Map<ID, Double>dataSum {get;set;}
    
    
    public AccountListOfOrdersRSAController()
    {
      /*objectFactory = new TacticalPlanItalyFactory();
        mode = 'tacticalEdit';
        jumperTag = 'tacticalPlanList';
        */
    
        init();
    }

    private void init()
    {

    /*Query to find the orders to show*/
    orders=new List<Order__C>();
        
    orders = 
          [
            SELECT 
              Name,
              Type_RSA__c,
              Status_RSA__c,
              Signed_RSA__c,
              LastModifiedDate,
              RecordTypeID,
              Cancellation_Reason_RSA__c,
              version_Id_RSA__c,
              consigned__c,
              CreatedDate,
              (select ID FROM Attachments)
   
          FROM Order__c 
          WHERE AccountRef_RSA__c = :Util.currentAccount.ID
          AND CreatedDate >= :UtilREST.currentYearRSA2.YearPreviousYear__r.YearPreviousYear__r.YearStartDate__c
          AND CreatedDate<=:UtilREST.currentYearRSA2.YearEndDate__c
          ORDER BY Name, version_Id_RSA__c
          
        ];
    
      /*Query to calculate the column Amount */
        List<AggregateResult> allPreliminaries =
        [
            SELECT
              sum(Agreed__c) sumAgreed,
              PreliminaryOrderRef_RSA__c
            
            FROM CampaignLineItem__c
            WHERE FarmRef__c = :Util.currentAccount.ID AND PreliminaryOrderRef_RSA__c != null AND PreliminaryOrderRef_RSA__c IN :orders 
            GROUP By PreliminaryOrderRef_RSA__c
        ];
        
        
        List<AggregateResult> allFinals =
        [
            SELECT
              sum(POG__c) sumPOG,
              finalOrderRef_RSA__c
            
            FROM CampaignLineItem__c
            WHERE FarmRef__c = :Util.currentAccount.ID AND finalOrderRef_RSA__c != null AND finalOrderRef_RSA__c IN :orders 
            GROUP By finalOrderRef_RSA__c
        ];
        
        dataSum = new Map <ID, Double>();
  
        for(AggregateResult agreFin : allFinals){
            /*if Agreed is null, enter the column POG*/           
                dataSum.put((ID)agreFin.get('finalOrderRef_RSA__c'),Double.valueOf(agreFin.get('sumPOG')));            
        }
        for(AggregateResult agrePre : allPreliminaries){
            /*if Agreed is null, enter the column POG*/           
                dataSum.put((ID)agrePre.get('PreliminaryOrderRef_RSA__c'),Double.valueOf(agrePre.get('sumAgreed')));            
        }
        
    }                
}