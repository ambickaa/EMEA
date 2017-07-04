/**
Controller for ExcelExportOSRReportNew page. All logic is now implemented in the controller.

Support Team
**/
public with sharing class ExcelExportOSRReportControllerNew {

    public Map<String,Map<String,String>> BOSR  { get; set; } //Map<HybridName,Map<(PoGAgreed, BagSize, etc.), values>> for CLIS B-Sorten
    public Set<String> getBOSRSet (){ return BOSR.keySet();}

    public Map<String,Map<String,String>> AOSR  { get; set; } //Map<HybridName,Map<(PoGAgreed, BagSize, etc.), values>> for CLIS A-Sorten
    public Set<String> getAOSRSet (){ return AOSR.keySet();}
    
    public Map<String,Map<String,String>> PYear{ get; set; } //Map<HybridName,Map<(PoGAgreed, BagSize, etc.), values>> for CLIS PY
    public Set<String> getPYearSet (){ return PYear.keySet();}
    
    //Added by Cognizant Team
    
    public Map<String,Map<String,String>> SOSR  { get; set; } //Map<HybridName,Map<(PoGAgreed, BagSize, etc.), values>> for CLIS Sonstige Sorten
    public Set<String> getSOSRSet (){ return SOSR.keySet();}
    
    //Added by Cognizant Team

    public List<String> discounts { get;set; } //List of parameters from the Custom Label 
     
    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }
    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    public transient Retoure__c Retoure{ get;set;}
         
    public Decimal ASorten {get;set;} 
    public Decimal BSorten {get;set;}
    public Decimal SummeRabat { get;set;}
    
    public String MalusbeiRetourePercent { get;set;}
    public Decimal MalusBeiRetoure { get;set;}
    public Decimal RetourePercentT { get;set;}
    public Decimal RetourePerCent { get;set;}
    
    public Decimal GesOSRA { get;set;}
    public Decimal GesOSRB { get;set;} 
    public Decimal GesOSRT { get;set;}
    public Decimal GesOSRS { get;set;}
        
    public Decimal AgreedOSRA { get;set;} 
    public Decimal AgreedOSRB { get;set;} 
    public Decimal AgreedOSRT { get;set;}
    public Decimal AgreedOSRS { get;set;}
    
    public Decimal PyPoGToT { get;set;}
    
    public Decimal Extrarabatt { get;set;}
    public Decimal Fruekauf { get;set;}
    public Decimal RabatMengen { get;set;}

    public Decimal MalusTotal { get;set;}
    public Integer basisziel { get;set; } 
    //public String getExcelDekalb (){return SystemSettings__c.getValues('DE_ExcelDekalb').Value__c;}
    public String getExcelDekalb (){return Label.DE_ExcelDekalb;}
    public String getFruehkaufBis (){return SystemSettings__c.getValues('DE_OSR_fruehkaufBis').Value__c;}
    public String getGrundMarge (){return SystemSettings__c.getValues('DE_OSR_GrundMarge').Value__c;}
    
    public Decimal aGesamt { get;set;}
    public Decimal bGesamt { get;set;}
    public Decimal tGesamt { get;set;}
    
    public Decimal vMargin { get;set;}
    public Decimal bMargin { get;set;}
    public Decimal zMargin { get;set;}
    public Decimal margin { get;set;}
    
    public Decimal minPercent { get;set;}
    public Decimal maxPercent { get;set;}
    public String min { get;set;}
    public String max { get;set;}
    
    public Decimal mengenstaffel { get;set;}
    
    public Boolean pickedExpansion { get; set;}
    public Decimal expansionrabatt { get;set;}
    public Decimal totalExpansion { get;set;}
    public Boolean pickedEximus { get; set;}
    public Decimal eximusrabatt { get;set;}
    public Decimal totalEximus { get;set;}
    public Boolean pickedException { get; set;}
    public Decimal Exceptionrabatt { get;set;}
    public Decimal totalException { get;set;}
    public Decimal gesamtrabatt { get;set;}
    public Decimal totalGrundMarge { get;set;}
    public Decimal totalPrice { get;set;}
    
    public string xmlContent {get;set;}

    private ApexPages.StandardController controller;
    
/* this metods initialize all atributes of the class in order to avoid null pointers*/    
    public void initialize ()
    {
        ASorten=0;
        BSorten=0;
         
        MalusbeiRetoure =0;
        discounts=new List<String>();
         
        GesOSRA =0;
        GesOSRB =0;
        GesOSRT=0;
        GesOSRS=0;
         
        AgreedOSRA =0;
        AgreedOSRB =0;
        AgreedOSRT =0;
        AgreedOSRS =0;
    
        PyPoGToT =0;
        GesOSRT =0;
        RetourePerCent =0;
        RetourePercentT =0;
        MalusBeiRetourePercent ='0';
        
        SummeRabat=0;
        MalusTotal=0;
                 
        RabatMengen=0;
        Fruekauf=0;
        Extrarabatt=0;  
        
        aGesamt=0;
        bGesamt=0;
        tGesamt=0;
        
        basisziel=0;
        vMargin=0;
        bMargin=0;
        zMargin=0;
        margin=0;
        
        mengenstaffel=0;
        
        expansionrabatt=0;
        pickedExpansion=false;
        totalExpansion=0;
        
        eximusrabatt=0;
        pickedEximus=false;
        totalEximus=0;
        
        exceptionrabatt=0;
        pickedexception=false;
        totalexception=0;
        
        gesamtrabatt=0;
        totalGrundMarge=0;
        totalPrice=0;
        
        minPercent=0;
        maxPercent=0;
        min='0';
        max='0';
    }
    
    public ExcelExportOSRReportControllerNew () {
            
        this.controller = controller;
        BOSR = new Map<String,Map<String,String>>();
        AOSR = new Map<String,Map<String,String>>();
        PYear= new Map<String,Map<String,String>>();
        SOSR = new Map<String,Map<String,String>>();
    
        OwnerID=Util.currentUser.ID;
        AccountID=Util.currentAccount.ID;
        DivisionID=Util.currentDivision.ID;
        xmlContent ='<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Sample Workbook</x:Name><x:WorksheetOptions><x:FitToPage/><x:Print><x:FitWidth>1</x:FitWidth><x:FitHeight>1</x:FitHeight><x:ValidPrinterInfo/><x:Scale>55</x:Scale><x:HorizontalResolution>600</x:HorizontalResolution><x:VerticalResolution>600</x:VerticalResolution></x:Print><x:Selected/><x:Panes><x:Pane><x:Number>3</x:Number><x:ActiveRow>22</x:ActiveRow><x:ActiveCol>9</x:ActiveCol></x:Pane></x:Panes><x:ProtectContents>False</x:ProtectContents><x:ProtectObjects>False</x:ProtectObjects><x:ProtectScenarios>False</x:ProtectScenarios></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets><x:WindowHeight>10005</x:WindowHeight><x:WindowWidth>10005</x:WindowWidth><x:WindowTopX>120</x:WindowTopX><x:WindowTopY>135</x:WindowTopY><x:ProtectStructure>False</x:ProtectStructure><x:ProtectWindows>False</x:ProtectWindows></x:ExcelWorkbook></xml>';

        //retoure
        List<Retoure__c> retoures = [
            SELECT Account__c, Division__c, NUM_ExceptionRabatt__c, NUM_ExpansionRabatt__c, TXT_Bemerkung__c, EximusRabat__c, Extrarabatt__c, FruekaufMenge__c, FruekaufRabatt__c, RabattMenge__c, NUM_MENGE_TAX__c, Id, Retoure2__c, Retoure1__c, Retoure3__c, Vorlieferant2__r.Name, Vorlieferant1__r.Name, Vorlieferant3__r.Name, TXT_year__c, NUM_Returns_Rate__c 
            FROM Retoure__c 
            WHERE ID=:Util.urlParameters.get('retoureId')]; 
             
        if(retoures.size() > 0) Retoure = retoures.get(0);
        else Retoure = new Retoure__c(EximusRabat__c = 0,RabattMenge__c=0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0);      
        if(Retoure.Retoure1__c==null) Retoure.Retoure1__c=0;
        if(Retoure.Retoure2__c==null) Retoure.Retoure2__c=0;
        if(Retoure.Retoure3__c==null) Retoure.Retoure3__c=0;        
        if(Retoure.EximusRabat__c==null) Retoure.EximusRabat__c=0; 
        if(Retoure.NUM_ExpansionRabatt__c==null) Retoure.NUM_ExpansionRabatt__c=0; 
        if(Retoure.NUM_ExceptionRabatt__c==null) Retoure.NUM_ExceptionRabatt__c=0;     
        if(Retoure.Extrarabatt__c==null) Retoure.Extrarabatt__c=0;
        if(Retoure.FruekaufMenge__c==null) Retoure.RabattMenge__c=0;        
        if(Retoure.FruekaufMenge__c==null) Retoure.FruekaufMenge__c=0;        
        if(Retoure.FruekaufRabatt__c==null) Retoure.FruekaufRabatt__c=0;
        if(Retoure.TXT_Bemerkung__c==null) Retoure.TXT_Bemerkung__c='';
        if(Retoure.NUM_Returns_Rate__c==null) Retoure.NUM_Returns_Rate__c=0;
        retoures.clear();
        retoures.add(Retoure);
        //user info
        UserInfo=[ SELECT Name, Phone,MobilePhone FROM User WHERE ID=:OwnerID];
        
        //account info 
        AccountInfo=[
            SELECT Client_Code__c, Name, DE_ZIP_PLZ__c, City__c, DE_Ansprechpartner__r.Name, DE_CustomerOSRSeeds__c, DE_POGOSRPY__c  
            FROM Account
            WHERE ID=:AccountID];
             
        initialize();
        
        //PY Summary     
        for(AggregateResult a0 : [
                SELECT ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, max(LKP_DistributorRefST__r.Name) Distributor,
                       sum(Agreed__c) Agreed , sum(POG__c) PoG, max(CampaignRef__r.YearV2__r.YearStartDate__c), max(CampaignRef__r.YearV2__r.YearEndDate__c)
                FROM CampaignLineItem__c
                WHERE (FarmRef__r.ID=:AccountID) AND ( Type__c='Charged') AND CampaignRef__r.StatusCode__c=300 AND (CampaignRef__r.DivisionRef__c=:DivisionID) //(CampaignRef__r.Owner.ID=:OwnerID)
                AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
                
            if(PYear.get(a0.get('Name') + '_' + a0.get('ID') ) == null)
                PYear.put(a0.get('Name') + '_' + a0.get('ID'),new Map<String,String>{'Agreed'=> '0', 'PoG' => '0'});
                
            if(integer.valueOf(a0.get('Agreed'))!= null)
                PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('Agreed',String.valueOf(integer.valueOf(a0.get('Agreed'))));
                
            if(integer.valueOf(a0.get('PoG'))!= null){
                PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('PoG',String.valueOf(integer.valueOf(a0.get('PoG')))); 
                PyPoGToT=PyPoGTot+integer.valueOf(a0.get('PoG')); 
            }  
            PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('Name',String.valueOf(a0.get('ProductDisplayName')));
        }
        
        //Only the products PREMIUM can appear in the ZVD  
        //B-Sorten 1: Premium: False Treatment: Thiram 
        for(AggregateResult ag : [
                SELECT  ProductRef__r.Name, max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, max(LKP_DistributorRefST__r.Name) Distributor, max(ProductRef__r.ProductBagSize__c) BagSize, max(ProductRef__r.DE_ZVD_Typ__c) Typ, max(ProductRef__r.DE_ZVD_Reife__c) Reife,
                        sum(Agreed__c) Agreed , sum(POG__c) POG
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                AND (ProductCatalogEntryRef__r.DE_isPremium__c =true) AND (ProductRef__r.ProductTreatment__c='Thiram') AND (CampaignRef__r.DivisionRef__c=:DivisionID) AND (DE_isPremium__c=False) //If is CLI Premium then is A else B//(ProductCatalogEntryRef__r.DE_Sorten__c = 'B')
                AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
                        
            if(BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID') ) == null)
                BOSR.put(ag.get('ProductDisplayName') + '_' + ag.get('ID'),new Map<String,String>{'Agreed1'=> '0', 'Agreed2' => '0','PoG1'=> '0', 'PoG2' => '0','TotalAgreed' => '0','TotalPoG' => '0','Distributor' => ''});
                                
            if(integer.valueOf(ag.get('Agreed'))!= null){
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Agreed1',String.valueOf(integer.valueOf(ag.get('Agreed'))));
                AgreedOSRB = AgreedOSRB + integer.valueOf(ag.get('Agreed'));
            }
            
            if(integer.valueOf(ag.get('PoG'))!= null){
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('PoG1',String.valueOf(integer.valueOf(ag.get('POG'))));
                GesOSRB = GesOSRB + integer.valueOf(ag.get('POG'));
            }
            
            if(integer.valueOf(ag.get('BagSize'))!= null)
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('BagSize',String.valueOf((integer.valueOf(ag.get('BagSize')))/1000.00));
            else
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('BagSize',''); 
                            
            if(String.valueOf(ag.get('Typ'))!= null)
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Typ',String.valueOf(ag.get('Typ')));
            else
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Typ',''); 
                
            if(String.valueOf(ag.get('Reife'))!= null)
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Reife',String.valueOf(ag.get('Reife')));
            else
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Reife','');                
            
            BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Name',String.valueOf(ag.get('ProductDisplayName')));
            
            if(String.valueOf(ag.get('Distributor'))!= null)
                BOSR.get(ag.get('ProductDisplayName') + '_' + ag.get('ID')).put('Distributor',String.valueOf(ag.get('Distributor')));
        }
        
        //B-Sorten 2 Premium: False Treatment: Thiram+DMM 
        for(AggregateResult ag1 : [
                SELECT ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, max(LKP_DistributorRefST__r.Name) Distributor,  max(ProductRef__r.ProductBagSize__c) BagSize, max(ProductRef__r.DE_ZVD_Typ__c) Typ, max(ProductRef__r.DE_ZVD_Reife__c) Reife,
                    sum(Agreed__c) Agreed , sum(POG__c) POG
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                AND (ProductCatalogEntryRef__r.DE_isPremium__c =true) AND (ProductRef__r.ProductTreatment__c='Thiram+DMM') AND (CampaignRef__r.DivisionRef__c=:DivisionID) AND (DE_isPremium__c=False) //If is CLI Premium then is A else B//(ProductCatalogEntryRef__r.DE_Sorten__c = 'B')
                AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
                    
            if(BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID') ) == null)
                BOSR.put(ag1.get('ProductDisplayName') + '_' + ag1.get('ID'),new Map<String,String>{'Agreed1'=> '0', 'Agreed2' => '0','PoG1'=> '0', 'PoG2' => '0','TotalAgreed' => '0','TotalPoG' => '0','Distributor' => ''});
     
            if(integer.valueOf(ag1.get('Agreed'))!= null){
                    BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Agreed2',String.valueOf(integer.valueOf(ag1.get('Agreed'))));
                    AgreedOSRB = AgreedOSRB + integer.valueOf(ag1.get('Agreed'));
            }
            
            if(integer.valueOf(ag1.get('PoG'))!= null){
                    BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('PoG2',String.valueOf(integer.valueOf(ag1.get('POG'))));
                    GesOSRB = GesOSRB + integer.valueOf(ag1.get('POG'));              
            }
            
            if(integer.valueOf(ag1.get('BagSize'))!= null)
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('BagSize',String.valueOf((integer.valueOf(ag1.get('BagSize')))/1000.00));
            else
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('BagSize',''); 
                            
            if(String.valueOf(ag1.get('Typ'))!= null)
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Typ',String.valueOf(ag1.get('Typ')));
            else
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Typ',''); 
                
            if(String.valueOf(ag1.get('Reife'))!= null)
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Reife',String.valueOf(ag1.get('Reife')));
            else
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Reife','');                
            
            BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Name',String.valueOf(ag1.get('ProductDisplayName')));
             
            if(String.valueOf(ag1.get('Distributor'))!= null)
                BOSR.get(ag1.get('ProductDisplayName') + '_' + ag1.get('ID')).put('Distributor',String.valueOf(ag1.get('Distributor')));
        }
        
        //A-Sorten 1 Premium: True Treatment: Thiram
        for(AggregateResult ag2 : [
                SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, max(LKP_DistributorRefST__r.Name) Distributor,  max(ProductRef__r.ProductBagSize__c) BagSize, max(ProductRef__r.DE_ZVD_Typ__c) Typ, max(ProductRef__r.DE_ZVD_Reife__c) Reife,
                    sum(Agreed__c) Agreed , sum(POG__c) POG
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                AND (ProductCatalogEntryRef__r.DE_isPremium__c =true) AND (ProductRef__r.ProductTreatment__c='Thiram') AND (CampaignRef__r.DivisionRef__c=:DivisionID) AND (DE_isPremium__c=true) AND (ProductCatalogEntryRef__r.DE_Sorten__c = 'A')//If is CLI Premium && PCE. Sorten=A then is A else B// AND (ProductCatalogEntryRef__r.DE_Sorten__c = 'A')
                AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
            if(AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID') ) == null)
                    AOSR.put(ag2.get('ProductDisplayName') + '_' + ag2.get('ID'),new Map<String,String>{'Agreed1'=> '0', 'Agreed2' => '0','PoG1'=> '0', 'PoG2' => '0','TotalAgreed' => '0','TotalPoG' => '0','Distributor' => ''});
                
            if(integer.valueOf(ag2.get('Agreed'))!= null){
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Agreed1',String.valueOf(integer.valueOf(ag2.get('Agreed'))));
                AgreedOSRA= AgreedOSRA + integer.valueOf(ag2.get('Agreed'));
            }
            if(integer.valueOf(ag2.get('PoG'))!= null){
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('PoG1',String.valueOf(integer.valueOf(ag2.get('POG'))));
                GesOSRA= GesOSRA +integer.valueOf(ag2.get('POG'));
            }
            if(integer.valueOf(ag2.get('BagSize'))!= null)
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('BagSize',String.valueOf((integer.valueOf(ag2.get('BagSize')))/1000.00));
            else
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('BagSize',''); 
                            
            if(String.valueOf(ag2.get('Typ'))!= null)
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Typ',String.valueOf(ag2.get('Typ')));
            else
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Typ',''); 
                
            if(String.valueOf(ag2.get('Reife'))!= null)
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Reife',String.valueOf(ag2.get('Reife')));
            else
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Reife','');              
                               
            AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Name',String.valueOf(ag2.get('ProductDisplayName')));
            
            if(String.valueOf(ag2.get('Distributor'))!= null)
                AOSR.get(ag2.get('ProductDisplayName') + '_' + ag2.get('ID')).put('Distributor',String.valueOf(ag2.get('Distributor')));
        }
        
        //A-Sorten 2  Premium: true Treatment: Thiram+DMM 
        for(AggregateResult ag3 : [
                    SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, max(LKP_DistributorRefST__r.Name) Distributor,  max(ProductRef__r.ProductBagSize__c) BagSize, max(ProductRef__r.DE_ZVD_Typ__c) Typ, max(ProductRef__r.DE_ZVD_Reife__c) Reife,
                        sum(Agreed__c) Agreed , sum(POG__c) POG
                    FROM CampaignLineItem__c
                    WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                    AND (ProductCatalogEntryRef__r.DE_isPremium__c =true) AND (ProductRef__r.ProductTreatment__c='Thiram+DMM') AND (CampaignRef__r.DivisionRef__c=:DivisionID) AND (DE_isPremium__c=true) AND (ProductCatalogEntryRef__r.DE_Sorten__c = 'A')//If is CLI Premium && PCE. Sorten=A then is A else B// 
                    AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                    GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
            if(AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID') ) == null)
                AOSR.put(ag3.get('ProductDisplayName') + '_' + ag3.get('ID'),new Map<String,String>{'Agreed1'=> '0', 'Agreed2' => '0','PoG1'=> '0', 'PoG2' => '0','TotalAgreed' => '0','TotalPoG' => '0','Distributor' => ''});
    
            if(integer.valueOf(ag3.get('Agreed'))!= null){
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Agreed2',String.valueOf(integer.valueOf(ag3.get('Agreed'))));
                AgreedOSRA= AgreedOSRA + integer.valueOf(ag3.get('Agreed'));              
            }
            if(integer.valueOf(ag3.get('PoG'))!= null){
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('PoG2',String.valueOf(integer.valueOf(ag3.get('POG'))));
                GesOSRA= GesOSRA +integer.valueOf(ag3.get('POG'));                
            }
                
            if(integer.valueOf(ag3.get('BagSize'))!= null)
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('BagSize',String.valueOf((integer.valueOf(ag3.get('BagSize')))/1000.00));
            else
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('BagSize',''); 
                            
            if(String.valueOf(ag3.get('Typ'))!= null)
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Typ',String.valueOf(ag3.get('Typ')));
            else
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Typ',''); 
                
            if(String.valueOf(ag3.get('Reife'))!= null)
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Reife',String.valueOf(ag3.get('Reife')));
            else
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Reife','');               
            
            AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Name',String.valueOf(ag3.get('ProductDisplayName')));
                
            if(String.valueOf(ag3.get('Distributor'))!= null)   
                AOSR.get(ag3.get('ProductDisplayName') + '_' + ag3.get('ID')).put('Distributor',String.valueOf(ag3.get('Distributor')));
         }
        
        // Added by Cognizant - CLIS Sonstige Sorten -  CLIs which are not A-sorten and B-sorten & isPremium = False & isZVD = False
        for(AggregateResult ag4 : [
                SELECT  ProductRef__r.Name, max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, LKP_DistributorRefST__r.ID, max(LKP_DistributorRefST__r.Name) Distributor, max(ProductRef__r.ProductBagSize__c) BagSize, max(ProductRef__r.DE_ZVD_Typ__c) Typ, max(ProductRef__r.DE_ZVD_Reife__c) Reife,
                        sum(Agreed__c) Agreed , sum(POG__c) POG
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') //(CampaignRef__r.Owner.ID=:OwnerID)
                AND (ProductCatalogEntryRef__r.DE_isPremium__c =false) AND (ProductRef__r.ProductTreatment__c='Thiram' OR ProductRef__r.ProductTreatment__c='Thiram+DMM') AND (CampaignRef__r.DivisionRef__c=:DivisionID) AND (DE_isPremium__c=False) //If is CLI Premium then is A else B//(ProductCatalogEntryRef__r.DE_Sorten__c = 'B')
                AND (ProductCatalogEntryRef__r.DE_Sorten__c != 'A' OR ProductCatalogEntryRef__r.DE_Sorten__c != 'B') AND ((Agreed__c!=0 AND Agreed__c!=null) OR (POG__c!=0 AND POG__c!=null))
                GROUP BY ProductRef__r.Name, LKP_DistributorRefST__r.ID]){
            System.debug('ProductDisplayName'+ag4.get('ProductDisplayName'));
            System.debug('ID'+ag4.get('ID'));
			System.debug('Agreed'+ag4.get('Agreed'));
			System.debug('PoG'+ag4.get('PoG'));
			System.debug('BagSize'+ag4.get('BagSize'));
			System.debug('Typ'+ag4.get('Typ'));
			System.debug('Reife'+ag4.get('Reife'));
			System.debug('Distributor'+ag4.get('Distributor'));
            if(SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID') ) == null)
                SOSR.put(ag4.get('ProductDisplayName') + '_' + ag4.get('ID'),new Map<String,String>{'Agreed1'=> '0', 'Agreed2' => '0','PoG1'=> '0', 'PoG2' => '0','TotalAgreed' => '0','TotalPoG' => '0','Distributor' => ''});
                                
            if(integer.valueOf(ag4.get('Agreed'))!= null){
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Agreed1',String.valueOf(integer.valueOf(ag4.get('Agreed'))));
                AgreedOSRS = AgreedOSRS + integer.valueOf(ag4.get('Agreed'));
            }
            
            if(integer.valueOf(ag4.get('PoG'))!= null){
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('PoG1',String.valueOf(integer.valueOf(ag4.get('POG'))));
                GesOSRS = GesOSRS + integer.valueOf(ag4.get('POG'));
            }
            
            if(integer.valueOf(ag4.get('BagSize'))!= null)
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('BagSize',String.valueOf((integer.valueOf(ag4.get('BagSize')))/1000.00));
            else
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('BagSize',''); 
                            
            if(String.valueOf(ag4.get('Typ'))!= null)
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Typ',String.valueOf(ag4.get('Typ')));
            else
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Typ',''); 
                
            if(String.valueOf(ag4.get('Reife'))!= null)
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Reife',String.valueOf(ag4.get('Reife')));
            else
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Reife','');                
            
            SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Name',String.valueOf(ag4.get('ProductDisplayName')));
            
            if(String.valueOf(ag4.get('Distributor'))!= null)
                SOSR.get(ag4.get('ProductDisplayName') + '_' + ag4.get('ID')).put('Distributor',String.valueOf(ag4.get('Distributor')));
        }
        System.debug('SOSR Map'+SOSR);
         /* Total Agreed and Total PoG per Hybrid and Sorten*/
         for(String key: AOSR.keySet()){
            Integer totAg = Integer.valueOf((AOSR.get(key)).get('Agreed1'))+Integer.valueOf((AOSR.get(key)).get('Agreed2'));
            Integer totPoG = Integer.valueOf((AOSR.get(key)).get('PoG1'))+Integer.valueOf((AOSR.get(key)).get('PoG2'));
            (AOSR.get(key)).put('TotalAgreed',String.valueOf(totAg));
            (AOSR.get(key)).put('TotalPoG',String.valueOf(totPoG));
         }
         for(String key: BOSR.keySet()){
            Integer totAg = Integer.valueOf((BOSR.get(key)).get('Agreed1'))+Integer.valueOf((BOSR.get(key)).get('Agreed2'));
            Integer totPoG = Integer.valueOf((BOSR.get(key)).get('PoG1'))+Integer.valueOf((BOSR.get(key)).get('PoG2'));
            (BOSR.get(key)).put('TotalAgreed',String.valueOf(totAg));
            (BOSR.get(key)).put('TotalPoG',String.valueOf(totPoG));
         }
        
        /* Added by Cognizant Team*/
        if(!SOSR.isEmpty())
        {
			for(String key: SOSR.keySet()){
            	Integer totAg = Integer.valueOf((SOSR.get(key)).get('Agreed1'))+Integer.valueOf((SOSR.get(key)).get('Agreed2'));
            	Integer totPoG = Integer.valueOf((SOSR.get(key)).get('PoG1'))+Integer.valueOf((SOSR.get(key)).get('PoG2'));
            	(SOSR.get(key)).put('TotalAgreed',String.valueOf(totAg));
            	(SOSR.get(key)).put('TotalPoG',String.valueOf(totPoG));
         	}             
        }
        
         /* Total Agreed and Total PoG*/
        GesOSRT=GesOSRA+GesOSRB;
        AgreedOSRT=AgreedOSRA+AgreedOSRB;
         
         /* Obtaining all parameters from the Custom label DE_RAPS2014_DISCOUNTS */
        List<String> discounts = (label.DE_RAPS2014_DISCOUNTS.replaceAll('(\\s+)', '')).split('#',0);   
        if (AccountInfo.DE_CustomerOSRSeeds__c=='A'){   
            ASorten=Decimal.valueOf(discounts.get(1));
            BSorten=Decimal.valueOf(discounts.get(7));
            zMargin=Decimal.valueOf(discounts.get(13));
            bMargin=Decimal.valueOf(discounts.get(17));
            vMargin=Decimal.valueOf(discounts.get(21));            
        }else if (AccountInfo.DE_CustomerOSRSeeds__c=='B'){
            ASorten=Decimal.valueOf(discounts.get(3));
            BSorten=Decimal.valueOf(discounts.get(9));
            zMargin=Decimal.valueOf(discounts.get(15));
            bMargin=Decimal.valueOf(discounts.get(19));
            vMargin=Decimal.valueOf(discounts.get(23));             
        }else if (AccountInfo.DE_CustomerOSRSeeds__c=='C'){
            ASorten=Decimal.valueOf(discounts.get(5));
            BSorten=Decimal.valueOf(discounts.get(11));
            zMargin=Decimal.valueOf(discounts.get(33));
			bMargin=Decimal.valueOf(discounts.get(35));
        }
         /* Obtaining all Retoure info, extrarabatt and fruhkauf total discount */
        for(Retoure__c rtr : retoures){
            MalusbeiRetoure=MalusbeiRetoure + (rtr.Retoure1__c);    
            MalusBeiRetoure=MalusBeiRetoure + (rtr.Retoure2__c);    
            MalusBeiRetoure=MalusBeiRetoure + (rtr.Retoure3__c); 
            if(rtr.RabattMenge__c !=null && rtr.Extrarabatt__c!=null)
                Extrarabatt=rtr.Extrarabatt__c*rtr.RabattMenge__c;
            if(rtr.FruekaufMenge__c!=null && rtr.FruekaufRabatt__c!=null)
                Fruekauf=rtr.FruekaufMenge__c*rtr.FruekaufRabatt__c;
            break;
        }
         /* Obtaining all Gesamt discounts */
        aGesamt=ASorten*GesOSRA;
        bGesamt=BSorten*GesOSRB;
        tGesamt= aGesamt+bGesamt; 
                    
        if((GesOSRT+MalusbeiRetoure)>0)
            RetourePerCent= MalusbeiRetoure/(GesOSRT+MalusbeiRetoure);
        else 
            RetourePerCent=0;
         /* Obtaining malus per retoure */
        RetourePerCentT=100.00*RetourePerCent;
        min=discounts.get(25);
        max=discounts.get(27);
        minPercent=Decimal.valueOf(discounts.get(29));
        maxPercent=Decimal.valueOf(discounts.get(31));
        if(RetourePerCent*100<=minPercent)
            MalusBeiRetourePercent='0';
        else if(RetourePerCent*100>minPercent && RetourePerCent*100<=maxPercent)
            MalusBeiRetourePercent=min;
        else
            MalusBeiRetourePercent=max;
        MalusTotal=MalusbeiRetoure*Decimal.valueof(MalusBeiRetourePercent)*-1; 
        
         /* Obtaining the Basisziel value */
        if(AccountInfo.DE_POGOSRPY__c > AgreedOSRT) basisziel= Integer.valueOf(AgreedOSRT);
        else basisziel=Integer.valueOf(((AccountInfo.DE_POGOSRPY__c+AgreedOSRT)/2).round(System.RoundingMode.UP));
        
         /* Obtaining the correct margin and value for mengenstaffel discount*/
        if(GesOSRT>=AgreedOSRT)
            margin=zMargin;
        else if(GesOSRT>=basisziel) 
            margin=bMargin;
        else if(GesOSRT>=AccountInfo.DE_POGOSRPY__c)
            margin=vMargin; 
        mengenstaffel=margin*GesOSRT;
        
        set<String> auxList = new set<String>();
        auxList.addAll(AOSR.keyset());
        auxList.addAll(BOSR.keyset());
        
         /* Checking whether Expansion products have been chosen and obtaining the whole quantity for A&B Sorten*/
        for(String iter : auxList){
            if (iter.containsIgnoreCase('Expansion')){
                pickedExpansion=true;
                if(AOSR.keyset().contains(iter)){
                    expansionrabatt+=Decimal.valueOf((AOSR.get(iter)).get('PoG1'));
                    expansionrabatt+=Decimal.valueOf((AOSR.get(iter)).get('PoG2'));
                    
                }   
                if(BOSR.keyset().contains(iter)){
                    expansionrabatt+=Decimal.valueOf((BOSR.get(iter)).get('PoG1'));
                    expansionrabatt+=Decimal.valueOf((BOSR.get(iter)).get('PoG2'));
                    
                }               
            }   
        }
        totalExpansion=expansionrabatt*Retoure.NUM_ExpansionRabatt__c;
        
         /* Checking whether Eximus products have been chosen and obtaining the whole quantity for A&B Sorten*/
        for(String iter : auxList){
            if (iter.containsIgnoreCase('Eximus')){
                pickedEximus=true;
                if(AOSR.keyset().contains(iter)){
                    eximusrabatt+=Decimal.valueOf((AOSR.get(iter)).get('PoG1'));
                    eximusrabatt+=Decimal.valueOf((AOSR.get(iter)).get('PoG2'));
                    
                }   
                if(BOSR.keyset().contains(iter)){
                    eximusrabatt+=Decimal.valueOf((BOSR.get(iter)).get('PoG1'));
                    eximusrabatt+=Decimal.valueOf((BOSR.get(iter)).get('PoG2'));
                    
                }               
            }   
        }
        totalEximus=eximusrabatt*Retoure.EximusRabat__c;
         /* Checking whether Exception products have been chosen and obtaining the whole quantity for A&B Sorten*/
        for(String iter : auxList){
            if (iter.containsIgnoreCase('Exception')){
                pickedException=true;
                if(AOSR.keyset().contains(iter)){
                    Exceptionrabatt+=Decimal.valueOf((AOSR.get(iter)).get('PoG1'));
                    Exceptionrabatt+=Decimal.valueOf((AOSR.get(iter)).get('PoG2'));
                    
                }   
                if(BOSR.keyset().contains(iter)){
                    Exceptionrabatt+=Decimal.valueOf((BOSR.get(iter)).get('PoG1'));
                    Exceptionrabatt+=Decimal.valueOf((BOSR.get(iter)).get('PoG2'));
                    
                }               
            }   
        }
        totalException=Exceptionrabatt*Retoure.NUM_ExceptionRabatt__c;
         /* Obtaining the final price*/
        gesamtrabatt= totalExpansion + totalEximus + mengenstaffel + Extrarabatt + Fruekauf + MalusTotal + tGesamt + totalException;
        Decimal auxGM=0;
        if(getGrundMarge()!= null)
         auxGM=Decimal.valueOf(getGrundMarge());
        totalGrundMarge= auxGM*GesOSRT;
        totalPrice= totalGrundMarge + gesamtrabatt;
    }
}