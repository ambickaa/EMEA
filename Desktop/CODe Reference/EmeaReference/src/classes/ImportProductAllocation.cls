global with sharing class ImportProductAllocation {
    
    public static Allocation__c quantityFromSAP(/*id oppId,*/string SAPcode,string customer)
    {
       //opportunity opp=[select id,TXTA_Division__c,TXT_Distribution_Channel__c,TXTA_Sales_Org__c from Opportunity WHERE id=:oppId];
       user usr=[select id,TXT_Division__c,TXT_Distribution_Channel__c,TXT_Sales_Org__c from user WHERE id=:(UserInfo.getUserId())];
        integer quantitySAP=0;
        
        
        
        // Create data for the main method's Allocation query.
        Year__c fYer = new Year__c();
        fYer = [SELECT Name, Current_Year__c FROM Year__c WHERE Current_Year__c=True LIMIT 1];
        String alloExtId = String.valueOf(usr.id).substring(0,14) + '-' + SAPcode + '-' + fYer.Name;    // sense guions entre els paràmetres !!!!
        // Main query to get the order's Allocation data.
        Allocation__c importResult = new Allocation__c();
        try{
            importResult = [SELECT id, NUM_Allocation_Units__c, FRML_Avalaible_Units__c, LKP_Product__c, TXT_External_ID__c 
                                FROM Allocation__c WHERE TXT_External_ID__c=: alloExtId LIMIT 1];
        } catch(QueryException e){
            importResult.NUM_Allocation_Units__c = 0;
        }
        
        
        return importResult;
    }
        
        
        // OLD ImportProductAllocation with webservice call -------------------------------------------------------------------
        
    /* NECESSARY ?¿ v v v v v v v v v v v v v v v v 
        string response='';
        string salesOrg=usr.TXT_Sales_Org__c;
        string distChannel=usr.TXT_Distribution_Channel__c;
        string division;
        if (usr.TXT_Division__c=='17') division='RC';
        else if(usr.TXT_Division__c=='15') division='CP';
        ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ */
    
    /*
    public class EsSuccess
    {
        public string plant; //{get;set;}
        public string plantDesc; //{get;set;}
        public double availableQty {get;set;}
        public string customer; //{get;set;}
        public String material; //{get; set;}
        public string unit; //{get;set;}

    }
    public class Item
    {
        
    }
    public class EtError
    {
        list<Item> item=new list<Item>();
    }
    public class productReceived
    {
        EsSuccess EsSuccess=new esSuccess();
        EtError EtError=new EtError();
    }
     global class resultRequest
    {
        public integer quantity{get;set;}
        public string description{get;set;}
        public boolean result{get;set;}
    }    */
}