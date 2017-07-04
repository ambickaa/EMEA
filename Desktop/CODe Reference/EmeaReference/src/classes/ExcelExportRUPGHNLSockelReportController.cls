public with sharing class ExcelExportRUPGHNLSockelReportController {
    public Map<ID,Map<String,Decimal>> RUP1Info {get;set;}
    public Set<ID>getRUP1InfoSet(){return RUP1Info.keySet();}
   
    public Decimal getRUP_FOC (){return Decimal.valueof(SystemSettings__c.getValues('DE_BonusRUP').Value__c);}

    
    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }

    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    
    private ApexPages.StandardController controller;
    public ExcelExportRUPGHNLSockelReportController () {
        this.controller = controller;
          
            OwnerID=Util.currentUser.ID;
            AccountID=Util.currentAccount.ID;
            DivisionID=Util.currentDivision.ID;
            
            RUP1Info= new Map<ID,Map<String,Decimal>>();

           //user info
           
           UserInfo=[
                     SELECT Name, Phone
                        FROM User
                        WHERE ID=:OwnerID
          ];
          // account info
   AccountInfo=[
          
           SELECT Client_Code__c, Name, DE_ZIP_PLZ__c, City__c, Street__c, DE_Ansprechpartner__r.Name
           FROM Account
           WHERE ID=:AccountID 
         ];
         
          //A1
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Agreed__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID)

     
                         ])
         {
            if(RUP1Info.get(cli.ID) == null)
            {
                RUP1Info.put(cli.ID,new Map<String,Decimal>{'Agreed'=> 0, 'PoG' => 0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
                
                       if(cli.Agreed__c != null)
                RUP1Info.get(cli.ID).put('Agreed',(decimal.valueOf(string.valueOf(cli.Agreed__c))));
            if(cli.POG__c!= null)
                RUP1Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUP1Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUP1Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));
     
                
                

         }
         

       
    }
    

}