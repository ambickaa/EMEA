public with sharing class ExcelExportLatitudeReportcontroller {

    public Map<ID,Map<String,Decimal>> LatitudeInfo {get;set;}
    public Set<ID>getLatitudeInfoSet(){return LatitudeInfo.keySet();}
    
    public Map<ID,Map<String,Decimal>> LatitudeInfo20 {get;set;}
    public Set<ID>getLatitude20InfoSet(){return LatitudeInfo20.keySet();}
    
    public Map<ID,Map<String,Decimal>> LatitudeInfo200 {get;set;}
    public Set<ID>getLatitude200InfoSet(){return LatitudeInfo200.keySet();}
   
    public String getExcelLatitude (){return SystemSettings__c.getValues('DE_ExcelLatitude').Value__c;}
    //public Decimal getLAT_FOC (){return Decimal.valueof(SystemSettings__c.getValues('DE_BonusLAT').Value__c);}
    public String getLAT_Date (){return String.valueof(SystemSettings__c.getValues('DE_LAT_ExcelDate').Value__c);}
    public String getUrl (){return String.valueof(SystemSettings__c.getValues('DE_URL').Value__c);}
    
    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }

    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    public transient CampaignLineItem__c cliDate{ get;set;}
    public string xmlContent {get;set;}    
 
    private ApexPages.StandardController controller;
    public ExcelExportLatitudeReportcontroller () {
        this.controller = controller;
          
            OwnerID=Util.currentUser.ID;
            AccountID=Util.currentAccount.ID;
            DivisionID=Util.currentDivision.ID;
            
            LatitudeInfo= new Map<ID,Map<String,Decimal>>();
            LatitudeInfo20= new Map<ID,Map<String,Decimal>>();
            LatitudeInfo200= new Map<ID,Map<String,Decimal>>();

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
          
         
          //A1
          //LATITUDE,DE,40X4X5L AGF
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND(ProductRef__r.Name = 'LATITUDE,DE,40X4X5L AGF')

     
                         ])
         {
            if(LatitudeInfo.get(cli.ID) == null)
            {
                LatitudeInfo.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' => 0,'BasicUnits'=> 0});
            }
            if(cli.Forecast__c != null)
                LatitudeInfo.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                LatitudeInfo.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                LatitudeInfo.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));
         }
        
        //LATITUDE,DE,32X20L BT
        for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND(ProductRef__r.Name = 'LATITUDE,DE,32X20L BT')

     
                         ])
         {
            if(LatitudeInfo20.get(cli.ID) == null)
            {
                LatitudeInfo20.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' => 0,'BasicUnits'=> 0});
            }
            if(cli.Forecast__c != null)
                LatitudeInfo20.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                LatitudeInfo20.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                LatitudeInfo20.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));
         }

        //LATITUDE,DE,4X200L DRM
        for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_BasicUnits__c, Forecast__c ,POG__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true) AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))  AND  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND (Type__c='Charged')  AND (CampaignRef__r.DivisionRef__r.ID=:DivisionID) AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%') AND(ProductRef__r.Name = 'LATITUDE,DE,4X200L DRM')

     
                         ])
         {
            if(LatitudeInfo200.get(cli.ID) == null)
            {
                LatitudeInfo200.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' => 0,'BasicUnits'=> 0});
            }
            if(cli.Forecast__c != null)
                LatitudeInfo200.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c))));
            if(cli.POG__c!= null)
                LatitudeInfo200.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c))); 
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                LatitudeInfo200.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)));
         }


       
    }
    

}