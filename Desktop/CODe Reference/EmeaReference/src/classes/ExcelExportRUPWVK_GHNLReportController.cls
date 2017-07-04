public with sharing class ExcelExportRUPWVK_GHNLReportController {

    //Roundup Rekord
    public Map<ID,Map<String,Decimal>> RUP2Info {get;set;}
    public Set<ID>getRUP2InfoSet(){return RUP2Info.keySet();}
    
    //Roundup PowerFlex 1 l
    public Map<ID,Map<String,Decimal>> RUPFLEX1Info {get;set;}
    public Set<ID>getRUPFLEX1InfoSet(){return RUPFLEX1Info.keySet();}
    
    //Roundup PowerFlex 5 l
    public Map<ID,Map<String,Decimal>> RUPFLEX5Info {get;set;}
    public Set<ID>getRUPFLEX5InfoSet(){return RUPFLEX5Info.keySet();}
    
    //Roundup PowerFlex 15 l
    public Map<ID,Map<String,Decimal>> RUPFLEX15Info {get;set;}
    public Set<ID>getRUPFLEX15InfoSet(){return RUPFLEX15Info.keySet();}
    
    //Roundup PowerFlex 640 l
    public Map<ID,Map<String,Decimal>> RUPFLEX640Info {get;set;}
    public Set<ID>getRUPFLEX640InfoSet(){return RUPFLEX640Info.keySet();}
    
    //Roundup UltraMax
    public Map<ID,Map<String,Decimal>> RUPULTRA2Info {get;set;}
    public Set<ID>getRUPULTRAInfoSet(){return RUPULTRA2Info.keySet();}
    
    //RoundupTURBOplus (10 kg)
    public Map<ID,Map<String,Decimal>> RUPTURBOInfo {get;set;}
    public Set<ID>getRUPTURBOInfoSet(){return RUPTURBOInfo.keySet();}
   
    public String getExcelRoundup (){return SystemSettings__c.getValues('DE_ExcelRoundup').Value__c;}
    public String getRUP_Date (){return String.valueof(SystemSettings__c.getValues('DE_RUP_ExcelDate').Value__c);}
    public String getUrl (){return String.valueof(SystemSettings__c.getValues('DE_URL').Value__c);}
    public String getBonusRUP (){return String.valueof(SystemSettings__c.getValues('DE_BonusRUP').Value__c);}
    
    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }

    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    public transient CampaignLineItem__c cliDate{ get;set;}
 public string xmlContent {get;set;}
 
    
    private ApexPages.StandardController controller;
    public ExcelExportRUPWVK_GHNLReportController () {
        this.controller = controller;
          
            OwnerID=Util.currentUser.ID;
            AccountID=Util.currentAccount.ID;
            DivisionID=Util.currentDivision.ID;
            
            RUP2Info= new Map<ID,Map<String,Decimal>>();
            RUPFLEX1Info= new Map<ID,Map<String,Decimal>>();
            RUPFLEX5Info= new Map<ID,Map<String,Decimal>>();
            RUPFLEX15Info= new Map<ID,Map<String,Decimal>>();
            RUPFLEX640Info= new Map<ID,Map<String,Decimal>>();
            RUPULTRA2Info= new Map<ID,Map<String,Decimal>>();
            RUPTURBOInfo= new Map<ID,Map<String,Decimal>>();
            
          
    xmlContent ='<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Sample Workbook</x:Name><x:WorksheetOptions><x:FitToPage/><x:Print><x:FitWidth>1</x:FitWidth><x:FitHeight>1</x:FitHeight><x:ValidPrinterInfo/><x:Scale>100</x:Scale><x:HorizontalResolution>600</x:HorizontalResolution><x:VerticalResolution>600</x:VerticalResolution></x:Print><x:Selected/><x:Panes><x:Pane><x:Number>3</x:Number><x:ActiveRow>22</x:ActiveRow><x:ActiveCol>9</x:ActiveCol></x:Pane></x:Panes><x:ProtectContents>False</x:ProtectContents><x:ProtectObjects>False</x:ProtectObjects><x:ProtectScenarios>False</x:ProtectScenarios></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets><x:WindowHeight>10005</x:WindowHeight><x:WindowWidth>10005</x:WindowWidth><x:WindowTopX>120</x:WindowTopX><x:WindowTopY>135</x:WindowTopY><x:ProtectStructure>False</x:ProtectStructure><x:ProtectWindows>False</x:ProtectWindows></x:ExcelWorkbook></xml>';
      
    //date
                 
          List<CampaignLineItem__c> cliDates = [
                          SELECT CampaignRef__r.StartDate, CampaignRef__r.EndDate
                          FROM CampaignLineItem__c
                          WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND ( Type__c='Charged') AND (ProductRef__r.DivisionRef__c=:DivisionID)
                          LIMIT 1
            ];  
          if(cliDates.size() > 0) cliDate = cliDates.get(0);
          else cliDate = new CampaignLineItem__c();              
          
          
            //user info
           
           UserInfo=[
                     SELECT Name, Phone
                        FROM User
                        WHERE ID=:OwnerID
          ];
          // account info
           AccountInfo=[
          
           SELECT DE_Ansprechpartner_ZV_CP__r.DE_MonsantoID__c , Name, Client_Code__c, DE_ZIP_PLZ__c, City__c, Street__c, DE_Ansprechpartner_ZV_CP__r.Name
           FROM Account
           WHERE ID=:AccountID
         ];
         
          //A1
          //REKORD PRODUCT
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Description LIKE '%RUP REKORD%')
     
                         ])
         {
            if(RUP2Info.get(cli.ID) == null)
            {
                RUP2Info.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUP2Info.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUP2Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUP2Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUP2Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
         
         //POWERFELX (1l) PRODUCT
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Name = 'RUP POWERFLEX,DE,60X12X1L FF')
     
                         ])
         {
            if(RUPFLEX1Info.get(cli.ID) == null)
            {
                RUPFLEX1Info.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUPFLEX1Info.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUPFLEX1Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUPFLEX1Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUPFLEX1Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
                 
        //POWERFELX (5l) PRODUCT
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Name = 'RUP POWERFLEX,DE,40X4X5L AGF')
     
                         ])
         {
            if(RUPFLEX5Info.get(cli.ID) == null)
            {
                RUPFLEX5Info.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUPFLEX5Info.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUPFLEX5Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUPFLEX5Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUPFLEX5Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
        
        //POWERFELX (15l) PRODUCT
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Name = 'RUP POWERFLEX,DE,48X15L BT')
     
                         ])
         {
            if(RUPFLEX15Info.get(cli.ID) == null)
            {
                RUPFLEX15Info.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUPFLEX15Info.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUPFLEX15Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUPFLEX15Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUPFLEX15Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
         
        //POWERFELX (640l) PRODUCT
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Name = 'RUP POWERFLEX,DE,640L SHZ')
     
                         ])
         {
            if(RUPFLEX640Info.get(cli.ID) == null)
            {
                RUPFLEX640Info.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUPFLEX640Info.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUPFLEX640Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUPFLEX640Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUPFLEX640Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
         
        //ULTRAMAX PRODUCT
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Description LIKE '%RUP ULTRAMAX%')
     
                         ])
         {
            if(RUPULTRA2Info.get(cli.ID) == null)
            {
                RUPULTRA2Info.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUPULTRA2Info.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUPULTRA2Info.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUPULTRA2Info.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUPULTRA2Info.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
         
         //RoundupTURBOplus (10 kg)
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_RelFactor__c, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND (ProductRef__r.Name = 'RoundupTURBOplus (10 kg)')
     
                         ])
         {
            if(RUPTURBOInfo.get(cli.ID) == null)
            {
                RUPTURBOInfo.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' =>0,'RelFactor'=> 0,'BasicUnits'=>0});
            }
            if(cli.Forecast__c != null)
                RUPTURBOInfo.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                RUPTURBOInfo.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                RUPTURBOInfo.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)));
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                RUPTURBOInfo.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));

         }
       
    }
    

}