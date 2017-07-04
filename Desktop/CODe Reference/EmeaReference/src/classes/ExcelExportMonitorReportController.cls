public with sharing class ExcelExportMonitorReportController {

         
    public Map<ID,Map<String,Decimal>> MonitorInfo {get;set;}
    public Set<ID>getMonitorInfoSet(){return MonitorInfo.keySet();}
    
    public Map<ID,Map<String,Decimal>> MonfastInfo {get;set;}
    public Set<ID>getMonfastInfoSet(){return MonfastInfo.keySet();}
   
    public String getExcelMonitor (){return SystemSettings__c.getValues('DE_ExcelMonitor').Value__c;}   
    public String getExcelMonfast (){return SystemSettings__c.getValues('DE_ExcelMonfast').Value__c;}
    public Decimal getMON_FOC (){return Decimal.valueof(SystemSettings__c.getValues('DE_BonusMON').Value__c);}
    public String getMON_Date (){return String.valueof(SystemSettings__c.getValues('DE_MON_ExcelDate').Value__c);}
    public String getUrl (){return String.valueof(SystemSettings__c.getValues('DE_URL').Value__c);}
    
    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }

    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    public transient CampaignLineItem__c cliDate{ get;set;}
    public string xmlContent {get;set;}
    
    private ApexPages.StandardController controller;
    public ExcelExportMonitorReportController () {
        this.controller = controller;
          
            OwnerID=Util.currentUser.ID;
            AccountID=Util.currentAccount.ID;
            DivisionID=Util.currentDivision.ID;
            
            MonitorInfo= new Map<ID,Map<String,Decimal>>();
            
            MonfastInfo= new Map<ID,Map<String,Decimal>>();
            
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
           
           UserInfo=[SELECT Name, Phone FROM User WHERE ID=:OwnerID];
          // account info
           AccountInfo=[          
           SELECT DE_Ansprechpartner_ZV_CP__r.DE_MonsantoID__c , Name, Client_Code__c, DE_ZIP_PLZ__c, City__c, Street__c, DE_Ansprechpartner_ZV_CP__r.Name,
           DE_CP_AGREED_MON_CY__c, DE_Forecast_MON_CY__c, DE_CP_AGREED_MONF_CY__c, DE_Forecast_MONF_CY__c
           FROM Account
           WHERE ID=:AccountID 
         ];
         

          //A1
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_BasicUnits__c, ProductRef__r.DE_RelFactor__c, ProductRef__r.Name, Forecast__c ,POG__c, Agreed__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true)
         AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))
         AND (CampaignRef__r.Owner.ID=:OwnerID)
         AND (FarmRef__r.ID=:AccountID)
         AND (Type__c='Charged')
         AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%')
         AND (ProductRef__r.Name='MONIT,DE,144X10X0.125KG(125G)BT')]){
         
system.debug('1º query --> ' + MonitorInfo);
system.debug('1º query DivisionID--> ' + DivisionID);

            if(MonitorInfo.get(cli.ID) == null)
            {
                MonitorInfo.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' => 0,'BasicUnits'=> 0,'RelFactor'=>0});
            }
            if(AccountInfo.DE_CP_AGREED_MON_CY__c != null && AccountInfo.DE_CP_AGREED_MON_CY__c > 0){
                if(cli.Agreed__c != null)
                    MonitorInfo.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Agreed__c)).setScale(3)));
            } else {
                if(cli.Forecast__c != null)
                    MonitorInfo.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c)).setScale(3)));
            }
            if(cli.POG__c!= null)
                MonitorInfo.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c)).setScale(3)); 
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                MonitorInfo.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)).setScale(3));
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                MonitorInfo.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)).setScale(3));

         }
         
         //MONFAST
         for(CampaignLineItem__c cli : [
               
         SELECT ID, ProductRef__r.DE_BasicUnits__c, ProductRef__r.DE_RelFactor__c, ProductRef__r.Name, Forecast__c ,POG__c, Agreed__c
         FROM CampaignLineItem__c
         WHERE (CampaignRef__r.isActive=true)
         AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))
         AND (CampaignRef__r.Owner.ID=:OwnerID)
         AND (FarmRef__r.ID=:AccountID)
         AND (Type__c='Charged')
         AND (ProductRef__r.ProductVendor__r.Name LIKE '%Monsanto%')
         AND (ProductRef__r.Name='MONFAST,DE,40X4X5L AGR')]){

system.debug('2º query --> ' + MonitorInfo);
system.debug('2º query DivisionID--> ' + DivisionID);

            if(MonfastInfo.get(cli.ID) == null)
            {
                MonfastInfo.put(cli.ID,new Map<String,Decimal>{'Forecast'=> 0, 'PoG' => 0,'BasicUnits'=> 0,'RelFactor'=>0});
            }
            if(AccountInfo.DE_CP_AGREED_MONF_CY__c != null && AccountInfo.DE_CP_AGREED_MONF_CY__c > 0){
                if(cli.Agreed__c != null)
                    MonfastInfo.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Agreed__c)).setScale(3)));
            } else {
                if(cli.Forecast__c != null)
                    MonfastInfo.get(cli.ID).put('Forecast',(decimal.valueOf(string.valueOf(cli.Forecast__c)).setScale(3)));
            }
            if(cli.POG__c!= null)
                MonfastInfo.get(cli.ID).put('PoG',decimal.valueOf(string.valueOf(cli.POG__c)).setScale(3)); 
            if(cli.ProductRef__r.DE_BasicUnits__c!= null)
                MonfastInfo.get(cli.ID).put('BasicUnits',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_BasicUnits__c)).setScale(3));
            if(cli.ProductRef__r.DE_RelFactor__c!= null)
                MonfastInfo.get(cli.ID).put('RelFactor',decimal.valueOf(string.valueOf(cli.ProductRef__r.DE_RelFactor__c)).setScale(3));

         }

    }

}