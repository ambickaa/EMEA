public with sharing class ExcelExportOSRReportController {

    public Map<String,Map<String,String>> Asorten  { get; set; }
    public Set<String> getAsortenSet (){ return Asorten.keySet();}

    public Map<String,Map<String,String>> Bsorten{ get; set; }
    public Set<String> getBsortenSet (){ return Bsorten.keySet();}
    
    public Map<String,Map<String,String>> PYear{ get; set; }
    public Set<String> getPYearSet (){ return PYear.keySet();}
    
    public Map<String,Map<String,String>> Pyear2{ get; set; }
    public Set<String> getPYear2Set (){ return PYear2.keySet();}

    public String getExcelDekalb (){return SystemSettings__c.getValues('DE_ExcelDekalb').Value__c;}
    public String getFruehkaufBis (){return SystemSettings__c.getValues('DE_OSR_fruehkaufBis').Value__c;}
   public String getGrundMarge (){return SystemSettings__c.getValues('DE_OSR_GrundMarge').Value__c;}


    
     
    public transient ID OwnerID { get;set; }
    public transient ID AccountID { get;set; }
    public transient ID DivisionID { get;set; }


    public transient Account AccountInfo { get;set; }
    public transient User UserInfo { get;set;}
    public transient Retoure__c Retoure{ get;set;}
    
    private ApexPages.StandardController controller;
    
    public ExcelExportOSRReportController () {
        this.controller = controller;
        
          Asorten = new Map<String,Map<String,String>>();
          Bsorten = new Map<String,Map<String,String>>();
          PYear = new Map<String,Map<String,String>>();
          PYear2 = new Map<String,Map<String,String>>();

            OwnerID=Util.currentUser.ID;
            AccountID=Util.currentAccount.ID;
            DivisionID=Util.currentDivision.ID;
            
            
           //user info
           
           UserInfo=[
                     SELECT Name, Phone
                        FROM User
                        WHERE ID=:OwnerID
          ];
          // account info
          AccountInfo=[
          
           SELECT Client_Code__c, Name, DE_ZIP_PLZ__c, City__c, DE_AnsprechPartner__r.Name, DE_CustomerOSRSeeds__c, DE_POGOSRPY__c  
           FROM Account
           WHERE ID=:AccountID
         ];
         
                  // Retoure
         List<Retoure__c> retoures = [
            SELECT Account__c, Division__c, EximusRabat__c, Extrarabatt__c, FruekaufMenge__c, FruekaufRabatt__c, Id, Retoure2__c, Retoure1__c, Retoure3__c, Vorlieferant2__r.Name, Vorlieferant1__r.Name, Vorlieferant3__r.Name 
            FROM Retoure__c 
            WHERE ID=:Util.urlParameters.get('retoureId')      
              ];  
          if(retoures.size() > 0) Retoure = retoures.get(0);
          else Retoure = new Retoure__c(EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0);
       
         
         
         //date   
            datetime myDateTime = datetime.now();
          
            datetime newDate = myDateTime .addYears(-1);
            datetime newDate2 = myDateTime .addYears(-2);
   
            string PreviusYear= String.valueof(newDate.year()) + '-' + String.valueof(newDate.month()) + '-' + String.valueof(newDate.day())+ ' ' + '00' + ':' + '00' + ':' + '00';
            string PrePreviusYear= String.valueof(newDate2.year()) + '-' + String.valueof(newDate2.month()) + '-' + String.valueof(newDate2.day())+ ' ' + '00' + ':' + '00' + ':' + '00';
 
               
         
         
        for(AggregateResult a0 : [
                 SELECT  ProductRef__r.Name, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    max(Agreed__c) Agreed  , max(POG__c) PoG, max(CampaignRef__r.YearV2__r.YearStartDate__c), max(CampaignRef__r.YearV2__r.YearEndDate__c)
                FROM CampaignLineItem__c
                WHERE  (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND ( Type__c='Charged') AND (CampaignRef__r.YearV2__r.YearEndDate__c>=:date.valueOf(PreviusYear)) AND (CampaignRef__r.YearV2__r.YearStartDate__c<=:date.valueOf(PreviusYear)) AND  (ProductRef__r.DivisionRef__c=:DivisionID)
                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
                                ])
        {
            if(PYear.get(a0.get('Name') + '_' + a0.get('ID') ) == null)
            {
                PYear.put(a0.get('Name') + '_' + a0.get('ID'),new Map<String,String>{'Agreed'=> '0', 'PoG' => '0'});
            }
            
            if(integer.valueOf(a0.get('Agreed'))!= null)
            PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('Agreed',String.valueOf(integer.valueOf(a0.get('Agreed'))));
            if(integer.valueOf(a0.get('PoG'))!= null)
            PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('PoG',String.valueOf(integer.valueOf(a0.get('PoG'))));     
            PYear.get(a0.get('Name') + '_' + a0.get('ID')).put('Name',String.valueOf(a0.get('Name')));
        }

        for(AggregateResult b0 : [
        
                 SELECT  ProductRef__r.Name, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    max(Agreed__c) Agreed  , max(POG__c) PoG, max(CampaignRef__r.YearV2__r.YearStartDate__c), max(CampaignRef__r.YearV2__r.YearEndDate__c)
                FROM CampaignLineItem__c
                WHERE  (CampaignRef__r.Owner.ID=:ownerID) AND (FarmRef__r.ID=:AccountID) AND ( Type__c='Charged') AND (CampaignRef__r.YearV2__r.YearEndDate__c>:date.valueOf(PrePreviusYear)) AND (CampaignRef__r.YearV2__r.YearStartDate__c<=:date.valueOf(PrePreviusYear)) AND  (ProductRef__r.DivisionRef__c=:DivisionID)
                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 



                                ])
        {
            if(PYear2.get(b0.get('Name') + '_' + b0.get('ID') ) == null)
            {
                PYear2.put(b0.get('Name') + '_' + b0.get('ID'),new Map<String,String>{'Agreed'=> '0', 'PoG' => '0'});
            }
            
            if(integer.valueOf(b0.get('Agreed'))!= null)
            PYear2.get(b0.get('Name') + '_' + b0.get('ID')).put('Agreed',String.valueOf(integer.valueOf(b0.get('Agreed'))));
            if(integer.valueOf(b0.get('PoG'))!= null)
            PYear2.get(b0.get('Name') + '_' + b0.get('ID')).put('PoG',String.valueOf(integer.valueOf(b0.get('PoG'))));     
            PYear2.get(b0.get('Name') + '_' + b0.get('ID')).put('Name',String.valueOf(b0.get('Name')));
        }       
        
         
          
            //A1
         for(AggregateResult a1 : [
                SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    sum(Agreed__c) Agreed , sum(POG__c) POG, max(ProductRef__r.ProductBagSize__c) Size, max(ProductRef__r.DE_ZVD_Reife__c) Reife, max(ProductRef__r.DE_ZVD_Typ__c) Typ
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (ProductCatalogEntryRef__r.DE_Sorten__c ='A') 
                AND ( (ProductRef__r.Name='L DK DK EXQUISITE 1500MVK CT ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXPOWER 1500MVK CT ZZ22') 
                    OR (ProductRef__r.Name='L DK DK CAMELOT 2000MVK CT ZZ22') 
                    )
                AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))

                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
     
                         ])
         {
            if(Asorten.get(a1.get('Name') + '_' + a1.get('ID') ) == null)
            {
                Asorten.put(a1.get('Name') + '_' + a1.get('ID'),new Map<String,String>{'AgreedChinook'=> '0', 'AgreedElado' => '0','AgreedElado2'=> '0', 'PoGChinook' => '0','PoGElado' => '0','PoGElado2' => '0','Distributor'=>'','Size'=>'0','Reife'=>'0','Typ'=>'0'});
            }
            
            if(integer.valueOf(a1.get('Agreed'))!= null)
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('AgreedChinook',String.valueOf(integer.valueOf(a1.get('Agreed'))));
            if(integer.valueOf(a1.get('POG'))!= null)
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('PoGChinook',String.valueOf(integer.valueOf(a1.get('POG'))));     
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('Name',String.valueOf(a1.get('ProductDisplayName')));
            if(String.valueOf(a1.get('Distributor'))!= null)
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('Distributor',String.valueOf(a1.get('Distributor')));
            
           if(integer.valueOf(a1.get('Size'))!= null)
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('Size',String.valueOf(integer.valueOf(a1.get('Size'))));
            if(String.valueOf(a1.get('Typ'))!= null)
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('Typ',String.valueOf(a1.get('Typ')));
            if(String.valueOf(a1.get('Reife'))!= null)
            Asorten.get(a1.get('Name') + '_' + a1.get('ID')).put('Reife',String.valueOf(a1.get('Reife')));

          
            
         }
         
         
          //A2
          
         for(AggregateResult a2 : [
                SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    sum(Agreed__c) Agreed , sum(POG__c) POG, max(ProductRef__r.ProductBagSize__c) Size, max(ProductRef__r.DE_ZVD_Reife__c) Reife, max(ProductRef__r.DE_ZVD_Typ__c) Typ
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (ProductCatalogEntryRef__r.DE_Sorten__c ='A') 
                AND ( (ProductRef__r.Name='L DK DK EXPOWER 1500MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXFILE DS-KGWB X') 
                    OR (ProductRef__r.Name='L DK DK EXQUISITE 1500MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXSTORM 1500MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK CAMELOT 2000MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXIMUS 1500MVK EB ZZ22') 
                    )
                AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))
                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
     
                         ])
         {
            if(Asorten.get(a2.get('Name') + '_' + a2.get('ID') ) == null)
            {
                Asorten.put(a2.get('Name') + '_' + a2.get('ID'),new Map<String,String>{'AgreedChinook'=> '0', 'AgreedElado' => '0','AgreedElado2'=> '0', 'PoGChinook' => '0','PoGElado' => '0','PoGElado2' => '0','Distributor'=>'','Size'=>'0','Reife'=>'0','Typ'=>'0'});
            }
            if(integer.valueOf(a2.get('Agreed'))!= null)
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('AgreedElado',String.valueOf(integer.valueOf(a2.get('Agreed'))));
            if(integer.valueOf(a2.get('POG'))!= null)
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('PoGElado',String.valueOf(integer.valueOf(a2.get('POG'))));     
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('Name',String.valueOf(a2.get('ProductDisplayName')));
            if(String.valueOf(a2.get('Distributor'))!= null)
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('Distributor',String.valueOf(a2.get('Distributor')));

                  if(integer.valueOf(a2.get('Size'))!= null)
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('Size',String.valueOf(integer.valueOf(a2.get('Size'))));
            if(String.valueOf(a2.get('Typ'))!= null)
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('Typ',String.valueOf(a2.get('Typ')));
            if(String.valueOf(a2.get('Reife'))!= null)
            Asorten.get(a2.get('Name') + '_' + a2.get('ID')).put('Reife',String.valueOf(a2.get('Reife')));
            
            
         }
         
         //A3
         
                 for(AggregateResult a3 : [
                SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    sum(Agreed__c) Agreed , sum(POG__c) POG, max(ProductRef__r.ProductBagSize__c) Size, max(ProductRef__r.DE_ZVD_Reife__c) Reife, max(ProductRef__r.DE_ZVD_Typ__c) Typ
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (ProductCatalogEntryRef__r.DE_Sorten__c ='A') 
                AND ( (ProductRef__r.Name='L DK DK EXPOWER 1500MVK EA ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXQUISITE 1500MVK EA ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXSTORM 1500MVK EA ZZ22') 
                    OR (ProductRef__r.Name='LT DK DK CAMELOT 500MKGTR EA') 
                    OR (ProductRef__r.Name='LT DK DK EXQUISITE 500MKGTR EA') 
                    OR (ProductRef__r.Name='LT DK DK EXQUISITE 500MKGTR EA') 
                    OR (ProductRef__r.Name='LT DK EXCALIBUR 500MKGTR EA') 
                    OR (ProductRef__r.Name='L DK DK EXIMUS 1500MVK EA ZZ22') 
                    )
                AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))        
                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
                     
     
                         ])
         {
            if(Asorten.get(a3.get('Name') + '_' + a3.get('ID') ) == null)
            {
                Asorten.put(a3.get('Name') + '_' + a3.get('ID'),new Map<String,String>{'AgreedChinook'=> '0', 'AgreedElado' => '0','AgreedElado2'=> '0', 'PoGChinook' => '0','PoGElado' => '0','PoGElado2' => '0','Distributor'=>'','Size'=>'0','Reife'=>'0','Typ'=>'0'});
            }
            if(integer.valueOf(a3.get('Agreed'))!= null)
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('AgreedElado2',String.valueOf(integer.valueOf(a3.get('Agreed'))));
            if(integer.valueOf(a3.get('POG'))!= null)
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('PoGElado2',String.valueOf(integer.valueOf(a3.get('POG'))));     
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('Name',String.valueOf(a3.get('ProductDisplayName')));
            if(String.valueOf(a3.get('Distributor'))!= null)
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('Distributor',String.valueOf(a3.get('Distributor')));
          
          
           if(integer.valueOf(a3.get('Size'))!= null)
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('Size',String.valueOf(integer.valueOf(a3.get('Size'))));
            if(String.valueOf(a3.get('Typ'))!= null)
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('Typ',String.valueOf(a3.get('Typ')));
            if(String.valueOf(a3.get('Reife'))!= null)
            Asorten.get(a3.get('Name') + '_' + a3.get('ID')).put('Reife',String.valueOf(a3.get('Reife')));
          
          
       }
       
                 
            //b1
         for(AggregateResult b1 : [
                SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    sum(Agreed__c) Agreed , sum(POG__c) POG, max(ProductRef__r.ProductBagSize__c) Size, max(ProductRef__r.DE_ZVD_Reife__c) Reife, max(ProductRef__r.DE_ZVD_Typ__c) Typ
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (ProductCatalogEntryRef__r.DE_Sorten__c ='B') 
                AND ( (ProductRef__r.Name='L DK DK EXQUISITE 1500MVK CT ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXPOWER 1500MVK CT ZZ22') 
                    OR (ProductRef__r.Name='L DK DK CAMELOT 2000MVK CT ZZ22') 
                    )
                AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))
                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
                         ])
         {
            if(Bsorten.get(b1.get('Name') + '_' + b1.get('ID') ) == null)
            {
                Bsorten.put(b1.get('Name') + '_' + b1.get('ID'),new Map<String,String>{'AgreedChinook'=> '0', 'AgreedElado' => '0','AgreedElado2'=> '0', 'PoGChinook' => '0','PoGElado' => '0','PoGElado2' => '0','Distributor'=>'','Size'=>'0','Reife'=>'0','Typ'=>'0'});
            }
            
            if(integer.valueOf(b1.get('Agreed'))!= null)
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('AgreedChinook',String.valueOf(integer.valueOf(b1.get('Agreed'))));
            if(integer.valueOf(b1.get('POG'))!= null)       
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('PoGChinook',String.valueOf(integer.valueOf(b1.get('POG'))));     
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('Name',String.valueOf(b1.get('ProductDisplayName')));
            if(String.valueOf(b1.get('Distributor'))!= null)
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('Distributor',String.valueOf(b1.get('Distributor')));

            if(integer.valueOf(b1.get('Size'))!= null)
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('Size',String.valueOf(integer.valueOf(b1.get('Size'))));
            if(String.valueOf(b1.get('Typ'))!= null)
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('Typ',String.valueOf(b1.get('Typ')));
            if(String.valueOf(b1.get('Reife'))!= null)
            Bsorten.get(b1.get('Name') + '_' + b1.get('ID')).put('Reife',String.valueOf(b1.get('Reife')));
            
            
            
            
         }
         
         
          //b2
          
         for(AggregateResult b2 : [
                 SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    sum(Agreed__c) Agreed , sum(POG__c) POG, max(ProductRef__r.ProductBagSize__c) Size, max(ProductRef__r.DE_ZVD_Reife__c) Reife, max(ProductRef__r.DE_ZVD_Typ__c) Typ
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (ProductCatalogEntryRef__r.DE_Sorten__c ='B') 
                AND ( (ProductRef__r.Name='L DK DK EXPOWER 1500MVK EB ZZ22') 
                   OR (ProductRef__r.Name='L DK DK EXFILE DS-KGWB X') 
                    OR (ProductRef__r.Name='L DK DK EXQUISITE 1500MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXSTORM 1500MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK CAMELOT 2000MVK EB ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXIMUS 1500MVK EB ZZ22') 
                    )
                AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
                     
     
                         ])
         {
            if(Bsorten.get(b2.get('Name') + '_' + b2.get('ID') ) == null)
            {
                Bsorten.put(b2.get('Name') + '_' + b2.get('ID'),new Map<String,String>{'AgreedChinook'=> '0', 'AgreedElado' => '0','AgreedElado2'=> '0', 'PoGChinook' => '0','PoGElado' => '0','PoGElado2' => '0','Distributor'=>'','Size'=>'0','Reife'=>'0','Typ'=>'0'});
            }
            if(integer.valueOf(b2.get('Agreed'))!= null)
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('AgreedElado',String.valueOf(integer.valueOf(b2.get('Agreed'))));
            if(integer.valueOf(b2.get('POG'))!= null)
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('PoGElado',String.valueOf(integer.valueOf(b2.get('POG'))));     
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('Name',String.valueOf(b2.get('ProductDisplayName')));
            if(String.valueOf(b2.get('Distributor'))!= null)
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('Distributor',String.valueOf(b2.get('Distributor')));

            
            if(integer.valueOf(b2.get('Size'))!= null)
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('Size',String.valueOf(integer.valueOf(b2.get('Size'))));
            if(String.valueOf(b2.get('Typ'))!= null)
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('Typ',String.valueOf(b2.get('Typ')));
            if(String.valueOf(b2.get('Reife'))!= null)
            Bsorten.get(b2.get('Name') + '_' + b2.get('ID')).put('Reife',String.valueOf(b2.get('Reife')));
            
            
            
         }
         
         //b3
         
                 for(AggregateResult b3 : [
               SELECT  ProductRef__r.Name,max(ProductRef__r.ProductDisplayName__c) ProductDisplayName, DE_DistributorRef__r.ID, max(DE_DistributorRef__r.Name) Distributor,
                    sum(Agreed__c) Agreed , sum(POG__c) POG, max(ProductRef__r.ProductBagSize__c) Size, max(ProductRef__r.DE_ZVD_Reife__c) Reife, max(ProductRef__r.DE_ZVD_Typ__c) Typ
                FROM CampaignLineItem__c
                WHERE (CampaignRef__r.isActive=true) AND (CampaignRef__r.Owner.ID=:OwnerID) AND (FarmRef__r.ID=:AccountID) AND( Type__c='Charged') AND (ProductCatalogEntryRef__r.DE_Sorten__c ='B') 
                AND ( (ProductRef__r.Name='L DK DK EXPOWER 1500MVK EA ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXQUISITE 1500MVK EA ZZ22') 
                    OR (ProductRef__r.Name='L DK DK EXSTORM 1500MVK EA ZZ22') 
                    OR (ProductRef__r.Name='LT DK DK CAMELOT 500MKGTR EA') 
                    OR (ProductRef__r.Name='LT DK DK EXQUISITE 500MKGTR EA') 
                    OR (ProductRef__r.Name='LT DK DK EXQUISITE 500MKGTR EA') 
                    OR (ProductRef__r.Name='LT DK EXCALIBUR 500MKGTR EA') 
                    OR (ProductRef__r.Name='L DK DK EXIMUS 1500MVK EA ZZ22') 
                    )
                AND (ProductCatalogEntryRef__r.ProductCatalogRef__r.RecordTypeID =:Util.recordType.get('ProductCatalog__c:SalesProductCatalog'))        
                GROUP BY ProductRef__r.Name, DE_DistributorRef__r.ID 
                     
     
                         ])
         {
            if(Bsorten.get(b3.get('Name') + '_' + b3.get('ID') ) == null)
            {
                Bsorten.put(b3.get('Name') + '_' + b3.get('ID'),new Map<String,String>{'AgreedChinook'=> '0', 'AgreedElado' => '0','AgreedElado2'=> '0', 'PoGChinook' => '0','PoGElado' => '0','PoGElado2' => '0','Distributor'=>'','Size'=>'0','Reife'=>'0','Typ'=>'0'});
            }
            if(integer.valueOf(b3.get('Agreed'))!= null)
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('AgreedElado2',String.valueOf(integer.valueOf(b3.get('Agreed'))));
            if(integer.valueOf(b3.get('POG'))!= null)
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('PoGElado2',String.valueOf(integer.valueOf(b3.get('POG'))));     
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('Name',String.valueOf(b3.get('ProductDisplayName')));
            if(String.valueOf(b3.get('Distributor'))!= null)
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('Distributor',String.valueOf(b3.get('Distributor')));
            
            
            
            if(integer.valueOf(b3.get('Size'))!= null)
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('Size',String.valueOf(integer.valueOf(b3.get('Size'))));
            if(String.valueOf(b3.get('Typ'))!= null)
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('Typ',String.valueOf(b3.get('Typ')));
            if(String.valueOf(b3.get('Reife'))!= null)
            Bsorten.get(b3.get('Name') + '_' + b3.get('ID')).put('Reife',String.valueOf(b3.get('Reife'))); 
            
          
       }
       
       
       
    }
    

}//