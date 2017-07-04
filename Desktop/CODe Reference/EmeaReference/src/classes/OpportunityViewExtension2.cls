global without sharing  class OpportunityViewExtension2 
{
    
    public string query{get;set;}
    public string orderId {get;set;}
    
    //Custom object lists for existing OPI lines and  posibles OPI lines to Add
    
    public list<cOLI> existingcOLIs{get;set;}
    public list<cOLI> existingcOLIsSize{get;set;}
    public list<cOLI> allcOLIs{get;set;}
    public Set<String> SetExistingProdNames{get;set;}
    
    public list<OpportunityLineItem> existingOLIs{ get;set;}
    
    // List of products that always must be filled in litres
    
    public list<String> List_products_litres {get {return Label.Products_litres.replace(',','_').replace(' ','_').split('#');} set;}
    
    //existing product names to choose
    
    public list<SelectOption> productNames{ get;set;}
    
    public list<PriceBookEntry> allPBEs;
    public Opportunity Ord{get; set;}
    
    public Boolean showException {get;set;}
    
    public Boolean isItaly{get;set;}
    
    //mode uses as a state for showing different page performances
    
    public string mode{get;set;}
    
    //define your custom exception
    
    public class MyException extends Exception{}
    public boolean error{get;set;}
    
    //variable to differenciate save of cancel
   
    public boolean showRequirement{get;set;}
    
    //variable assignation for search method 
   
    public list<string> s{get; set;}    
    public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    
    public list<SelectOption> fieldNames{get; set;}
    public list<SelectOption> filterPosibilities{get; set;}
    
    public string selectedField {get; set;}
    public String selectedFilter {get; set;}
    public String searchBox{get; set;}
    public string soqlQuery{get; set;}
    
    public string queryKeyWord{get; set;}
    
    public string keyWord{get; set;}
    public boolean searchState{get;set;}
    public String searchBoxConverted='';
    public string subquery; 
    public date searchBoxDate{get;set;}
    public boolean isDate{get;set;}
    public user usr{get;set;}
    public map<String, list<String>> batchsForProds{get;set;}
    public list<SelectOption> batchsForProds2{get;set;}
    public map<String, Decimal> allocationForProds{get;set;}
    public List<String> ListproductNames{get;set;}
    public map<String, User> Map_SAP_User = new Map<String, User>();
    public map<Id, User> Map_Id_User = new Map<Id, User>();

    public String batchsForProdsJSON {get{return JSON.serialize(batchsForProds);}}
    public String allocationForProdsJSON {get{return JSON.serialize(allocationForProds);}}
    public String productNamesJSON {get{return JSON.serialize(ListproductNames);}}
    
    
    
    /*-------------- Orders Transfer Partners Involveds-----------*/
    
    public string modePr{get;set;}
    public list<selectOption> soldsToC{get;set;}
    public list<selectOption> soldsToD{get;set;}
    public list<selectOption> shipsToC{get;set;}
    public list<selectOption> shipsToD{get;set;}    
    
    public map<id,account> soldsToM;
    public map<id,partner_function__c> shipsToM;
    public id soldToC{get;set;}
    public id soldToD{get;set;}
    public id shipToC{get;set;}
    public id shipToD{get;set;}
    public string modeOT{get;set;}
    public boolean availableQtyVisibility{get;set;}
    
    public boolean showTOException{get;set;}
    //public string rType{get;set;}
    
    //Mapa de allocations del usuario que se usara para inicializar los productos de los COLI
    Map<String,Allocation__c> MapallocationByProductId;
	public static Integer HIDDENLINES=10;
    public OpportunityViewExtension2( ApexPages.StandardController stdController )
    { 
        
        //usr = [SELECT UserPreferencesApexPagesDeveloperMode,SAP_Partner_Code__c , Name,Country , Division,TXT_Sales_Org__c,TXT_Division__c, CountryISOCode__c FROM User WHERE id = :UserInfo.getUserId()];
        mode='view';
        modeOT='show';
        
        modePr='Products';
        showRequirement=false;
        this.ord= (Opportunity) stdController.getRecord();
        //rType = ApexPages.currentPage().getParameters().get('RecordType');
        
        //get trnasfer order fieldset to query all fields inside this.
        query='Select ';
        string fieldsquery='id,StageName,CHK_Error_SAP_Check__c,TXTa_Sales_Org__c,TXTA_Division__c,PICK_Status__c,name,CHK_Organized__c,CHK_OE2_0_Transfer_in_approv_proc__C,Account.GC_SAP_ID__c,recordType.Name,pricebook2id,LKP_soldTo_Source_OT__c,LKP_soldTo_Source_OT__r.GC_SAP_ID__c, LKP_Partner_Function__r.Name,LKP_ShipTo_Source_OT__r.Partner_SAP_ID__c,LKP_areaManager_Credit_OT__c,LKP_soldTo_Source_OT__r.Name,Account.name,Account.CountryRef__r.Name,LKP_areaManager_Debit_OT__c,TXT_NewShipTo_ShipToName__c ,TXT_NewShipTo_Address__c,TXT_NewShipTo_ZIP_Contact__c,TXT_NewShipTo_ZIP_Phone__c,PICK_COUNTRY__c,PICK_REGION__c,TXT_NewShipTo_City__c,TXT_NewShipTo_ZIP_Code__c,LKP_shipTo_Source_OT__r.name,TXT_jsonFromSAP__c,TXT_Credit_SAP_Order_Number__c,TXT_Debit_SAP_Order_Number__c,Ownerid,LKP_Field_Agent_Credit_OT__c ,LKP_Field_Agent_Debit_OT__c from opportunity where id=:';
        orderId=ord.id;       
        fieldsquery= fieldsquery+ 'orderId'  ;
        
        List<Schema.FieldSetMember> transferFields=SObjectType.Opportunity.FieldSets.Transfer_Order_Fields.getFields();
        for(Schema.FieldSetMember f :transferFields) {
            if(!fieldsQuery.containsIgnoreCase(f.getFieldPath()) )query += f.getFieldPath() + ', ';
            
        }
        transferFields=SObjectType.Opportunity.FieldSets.Transfer_Order_Fields_Italy.getFields();
        for(Schema.FieldSetMember f :transferFields) {
            if(!fieldsQuery.containsIgnoreCase(f.getFieldPath()) && !query.containsIgnoreCase(f.getFieldPath()))query += f.getFieldPath() + ', ';
            
        }
        
        query=query +fieldsQuery;
        system.debug(query);
        ord=Database.query(query);
        
        isItaly= (ord.RecordType.Name=='Sales Order CP Italy' || ord.RecordType.Name=='Sales Italy Charged' || ord.RecordType.Name=='Sales Italy FOC') && ord.TXTA_Sales_Org__c =='IT01';
        
        MapallocationByProductId = new Map<String,Allocation__c>();
        initializeAllocationMap();
        for(User u : [SELECT UserPreferencesApexPagesDeveloperMode, SAP_Partner_Code__c , Name,Country , Division,TXT_Sales_Org__c,TXT_Division__c, CountryISOCode__c FROM User WHERE (Country = :ord.Account.CountryRef__r.Name AND TXT_Division__c = :ord.TXTA_Division__c) OR Id = :UserInfo.getUserId()])
        {
        	if(usr == null && u.Id == UserInfo.getUserId()) usr = u;
        	if(u.Id == ord.OwnerId) usr = u;
        	Map_Id_User.put(u.Id, u);
        	Map_SAP_User.put(u.SAP_Partner_Code__c, u);
        }
        //usr = [SELECT UserPreferencesApexPagesDeveloperMode, SAP_Partner_Code__c , Name,Country , Division,TXT_Sales_Org__c,TXT_Division__c, CountryISOCode__c FROM User WHERE id = :ord.ownerID];
        
        searchState=False;        
        
        soldsToC=new list<selectOption>();
        soldsToD=new list<selectOption>();
        shipsToC=new list<selectOption>();
        shipsToD=new list<selectOption>();
        
        soldsToM=new map<id,account>();
        shipsToM=new map<id,partner_function__c> ();
        
        soldToC=ord.LKP_soldTo_Source_OT__c;
        soldToD=ord.AccountId;

        shipToC=ord.LKP_shipTo_Source_OT__c;
        shipToD=ord.LKP_Partner_Function__c;
        


        /*-------Visibility for available quantity-------*/
        
        availableQtyVisibility=False;
        string ordDescr=usr.TXT_Sales_Org__c + '#'+ usr.TXT_Division__c;
        map<string,Order_Allocation_Visibility__c> vis= Order_Allocation_Visibility__c.getall();
        system.debug(vis.containsKey(ordDescr));
        
        if(vis.containsKey(ordDescr))availableQtyVisibility= vis.get(ordDescr).Visible__c;
        
        system.debug(availableQtyVisibility);

        getData();
        soldToC = soldToC == null ? ord.AccountId : soldToC;
        soldToD=ord.AccountId;      
        if(ord.LKP_areaManager_Credit_OT__c == null)ord.LKP_areaManager_Credit_OT__c= UserInfo.getUserId();     
        if(ord.LKP_areaManager_Debit_OT__c == null)ord.LKP_areaManager_Debit_OT__c= UserInfo.getUserId();       
        if(ord.LKP_Field_Agent_Credit_OT__c == null)ord.LKP_Field_Agent_Credit_OT__c= UserInfo.getUserId();     
        if(ord.LKP_Field_Agent_Debit_OT__c == null)ord.LKP_Field_Agent_Debit_OT__c= UserInfo.getUserId();               
        //ord.LKP_soldTo_Source_OT__c = ord.accountId;
        
        
        
    }
    
    
     public void initializeAllocationMap(){

        allocationForProds =new map<String, Decimal>();
         for(Allocation__c alloc : [SELECT LKP_Product__c, lkp_product__r.name, NUM_Allocation_Units__c, FRML_Avalaible_Units__c from Allocation__C WHERE LKP_User_Name__r.id =:Userinfo.getUserId() AND lkp_product__c in(select Product2Id from PricebookEntry where Pricebook2Id=:Ord.Pricebook2Id)]){
             MapallocationByProductId.put(String.valueOf(alloc.LKP_Product__c).substring(0,15), alloc);
             allocationForProds.put(alloc.lkp_product__r.name,alloc.FRML_Avalaible_Units__c);
         }         

     }
    
    public void getData()
    {
        
        error=false;
        modePr='Products';
        /*                  ----NEW CHANGE----
        * 
        ord=[Select id,PICK_Status__c,name,pricebook2id from opportunity where id=:ord.id];
        *
        */        
        ord=Database.query(query);
   
        //Related Products & PricebookEntries
        allPBEs=[select id,Pricebook2Id,Product2Id,Product2.Name,Product2.ProductSAPCode__c, Product2.ProductCode from PricebookEntry where Pricebook2Id=:Ord.Pricebook2Id and IsActive = true ]; 
        list<id> allProdIds=new list<Id>();        
        for(PriceBookEntry pBE:allPBEs)
        {
            allProdIds.add(pBE.Product2Id);
        }
        list<product2> allProds=new list<product2>();
        
        if (searchState==True){
            list <sObject> allProdaux=new list <sObject>();
            if(String.isNotBlank(keyword))
            {
                keyword+='*';
                system.debug(keyword);
                Try{
                    allProdaux=search.query('Find :keyword returning Product2(Id,name)')[0];
                }catch( SearchException e)
                {
                    
                    
                    system.debug(e.getMessage());
                    
                }
                keyword=keyword.remove('*');
                soqlQuery='Select Id,Name from Product2 where Id in :allProdaux '+subquery;
                
            }else
            { 
                if ((selectedField!='---None---')&&(selectedFilter!='---None---'))
                {
                    soqlQuery='Select Id,Name from Product2 where Id in :allProdIds '+subquery;
                }
            }   
            list<sObject> allProdaux2=new list<sObject>();
            
            if((selectedField!='---None---')&&(selectedFilter!='---None---'))
            {
                allProdaux=Database.query(soqlQuery);//             allProdaux2=Database.query(soqlQuery);
                
            }
            /* allProdaux.addAll(allProdaux2);
            allProdaux2.clear(); */
            set<Id> newAllProdIds=new set<Id>();
            for(sObject coinID:allProdaux)
            {
                for(id prodID:allProdIds)
                {
                    if(prodId==coinId.id)newAllProdIds.add(prodID);
                }
            }
            system.debug(soqlQuery);
            allProdIds.clear();
            allProdIds.addAll(newAllProdIds);
            allProdaux.clear();
            soqlQuery='';
            subQuery='';
        }
        /*     ----NEW CHANGE----          

        allProds=[Select Id,Name from Product2 where Id in :allProdIds];

        */

        allProds=[Select Id,Name,ProductSAPCode__c from Product2 where Id in :allProdIds];
        allProds.sort();
        
        /*      ----NEW CHANGE----      */
        
        string SAPshipto;
        string SAPsoldto;
        if(ord.LKP_soldTo_Source_OT__r.GC_SAP_ID__c!=null && ord.LKP_ShipTo_Source_OT__r.Partner_SAP_ID__c!=null)
        {
            SAPsoldto=ord.LKP_soldTo_Source_OT__r.GC_SAP_ID__c;
            SAPshipto=ord.LKP_ShipTo_Source_OT__r.Partner_SAP_ID__c.replaceFirst('^0+','');
        }
        system.debug('la id del ship to es'+ SAPshipto + ' y el id del sold to es ' + SAPsoldto);
        list<Delivery_Line_Item__c> allBatchs=new list<Delivery_Line_Item__c>();
        if(SAPsoldTo!=null && SAPshipTo!=null){
            allBatchs=[SELECT GC_Item_Code__c,GC_Batch_Number_Text__c from Delivery_Line_Item__c 
                       where GC_Dlvry_Integration_Key__r.GC_Account_Integration_Key__r.GC_SAP_ID__c=:SAPsoldto  ];
        }
        
         List<String> productCode = new List<String>();     
        for(Delivery_Line_Item__c dli : allBatchs)      
        {       
            productCode.add(dli.gc_item_code__c);       
        }       
        Map<String, String> batchLotMap = new Map<String, String>();            
        for( Product_Lot__c pl :[SELECT TXT_BATCH__c, name from Product_Lot__c where lkp_product__r.productsapcode__c in : productCode AND isActive__c = true])        
        {       
            batchLotMap.put(pl.txt_batch__c, pl.name);      
        }
        
        //In transfer order we show only the products that has a batch number associated for the same ship to and sold to.
        if(ord.RecordType.Name=='Transfer Order' && ord.CHK_Organized__c )   
        {
            map<Id,product2> newAllProds=new map<Id,product2>();
            
            for(product2 pr:allProds)
            {
                string SapCod=pr.ProductSAPCode__c.replaceFirst('^0+','');
                for(Delivery_Line_Item__c batch:allBatchs)
                {
                    string bthcSapCod=batch.GC_Item_Code__c.replaceFirst('^0+','');
                    if(bthcSapCod==SapCod && batch.GC_Batch_Number_Text__c!=null)
                    {
                        newAllProds.put(pr.id,pr);
                    }
                }
            }
            allProds=newAllProds.values() ;
            
            //If all products is empty we show an error message:
            
            if(allprods.size()==0 && SAPsoldTo!=null && SAPshipTo!=null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'There is no products for this Order');
                ApexPages.addMessage(myMsg);
                modePr='NoProducts';
                
            }else modePr='Products';
        }
        //fill option list with all posible products for select wich one add to the OPI && fill prodNames from allcOLIs (all possible OLIs) for multiselect of new OLIs 
        allcOLIs=new list<cOLI>();
        ListproductNames=new List<String>();
        productNames=new list<SelectOption>();
        batchsForProds =new map<String, list<String>>();
        batchsForProds2 =new list<SelectOption>();

        
        for(product2 prod:allProds)
        {
            /**
             * 
             * SE USA EL MAPA DE IDS producto  Y ALLOCATIONS para obtener el numero de allocation que pondremos en el wrapper de Custom OppotunityLineItem cOLI
             * 
             * */
            Allocation__c allocation = MapallocationByProductId.get(String.valueOf(prod.Id).substring(0,15))==null ? new Allocation__c():MapallocationByProductId.get(String.valueOf(prod.Id).substring(0,15));
            
            string nameP=String.valueOf(prod.name);
           
            ListproductNames.add(nameP);
            productNames.add(new SelectOption(nameP,nameP));
            cOLI customOLI=new cOLI();
            OpportunityLineItem OLI=new OpportunityLineItem();
            customOLI.OppLine=OLI;
            customOLI.ProdName=nameP;
            //system.debug('entra en el alloc define: '+allocation.FRML_Avalaible_Units__c);
            customOLI.allocation=allocation.FRML_Avalaible_Units__c==null ? 0:allocation.FRML_Avalaible_Units__c;

            customOLI.Selected=False;
           if(ord.RecordType.Name=='Sales Order' && ord.TXTA_Sales_Org__c !='UA01' || ord.RecordType.Name=='Sales Order CP Italy' || ord.RecordType.Name=='Sales Italy Charged' )customOLI.OppLine.type__c='Charged';
           if(ord.RecordType.Name.contains('Sales Order') && !ord.RecordType.Name.contains('CP') && (ord.TXTA_Sales_Org__c =='UA01' || ord.TXTA_Sales_Org__c =='FR24' ||ord.TXTA_Sales_Org__c =='BG01') || ord.RecordType.Name=='Sales Italy FOC')customOLI.OppLine.type__c='Free of Charge';

           //If isItaly and the product is already an opportunitylineitem do not add 
            allcOLIs.add(customOLI);
            
            //this code check the batches associated to the ship to and sold to and make a map that associate the product name of all products with their respective batches
            
            map<string,string> batchNumbers=new map<string,string>();
            list<string> batchNumbersl=new list<string>();
            customOLI.cBatchs=new list<selectOption>();

            for(Delivery_Line_Item__c batch:allBatchs)
            {
                if(prod.ProductSAPCode__c==batch.GC_Item_Code__c)
                {
                  String keyForBatchLot = batch.GC_Batch_Number_Text__c + (batchLotMap.containsKey(batch.GC_Batch_Number_Text__c)?' \\ ' + batchLotMap.get(batch.GC_Batch_Number_Text__c):'');
                  //system.debug('keyForBatchLot-->'+keyForBatchLot);
                    if(!batchNumbers.containsKey(keyForBatchLot) && batch.GC_Batch_Number_Text__c!=null)
                    {
            String batchLot = keyForBatchLot;
            batchNumbersl.add(batchLot);
            batchNumbers.put(batchLot,batch.GC_Item_Code__c);
            customOLI.cBatchs.add(new selectOption(batchLot,batchLot));     
            batchsForProds2.add(new selectOption(batchLot,batchLot));
                    }
                }
            }
            //system.debug('***batchNumbers = ' + batchNumbers.Values());
            if(batchNumbers!=null)
            {
                batchsForProds.put(prod.Name,batchNumbersL);
                //system.debug('***batchForProds = ' + batchsForProds);
            }
        }
        //fill existingcOLIs with standard OLIs
        existingOLIs= [Select id,name,NUM_Quantity_litres_CP__c,NUM_Quantity_palets_CP__c,PICK_Exceptions__c,TXT_SAP_Order_Number__c ,
                       Quantity,Product2.name,Type__c,TXT_Line_SAP_status__c,Product2.ProductSAPCode__c,opportunityId, PricebookEntryId,
                       TXTA_Comments__c,TXT_SAP_Order_line_ID__c ,TXT_PLANT_COPY__c,TXT_BatchNumber_OT__c ,NUM_QuantitySAP__c ,NUM_Discount__c 
                       from OpportunityLineItem where opportunityId=: ord.id ORDER BY Product2.name ASC, Type__c ASC];
        
        SetExistingProdNames=new Set<String>();
        existingcOLIs=new list<cOLI>();
        existingcOLIsSize=new list<cOLI>();

        for(OpportunityLineItem lineOpp: existingOLIs)
        {
         
            //usando el map de  prodId+alloc
          Allocation__c allocation = MapallocationByProductId.get(String.valueOf(lineOpp.Product2Id).substring(0,15))==null?new Allocation__c():MapallocationByProductId.get(String.valueOf(lineOpp.Product2Id).substring(0,15));
               
            cOLI customOLI=new cOLI ();
            customOLI.prodName=lineOpp.Product2.name;
            customOLI.selected=false;
            customOLI.allocation=allocation.FRML_Avalaible_Units__c==null?0:allocation.FRML_Avalaible_Units__c;
        
            customOLI.OppLine=lineOpp;
            customOLI.cBatchs=new list<selectOption>();
            


            SetExistingProdNames.add(customOLI.prodName);
            existingcOLIs.add(customOLI);
            existingcOLIsSize.add(customOLI);
        }
        
        // When adding multiple lines in Italy, only non previously selected products are displayed in the list.
        if (isItaly){
            for(Integer i = (allcOLIs.size() - 1); i >-1; i--){
                if (SetExistingProdNames.contains(allcOLIs[i].ProdName)){
                    allcOLIs.remove(i);
                }
            }
        }
                
        //////////CREATES NEW LINES ON PRODUCT LINES WHEN YOU EDIT

        for(Integer i=0; i<HIDDENLINES; i++){
          newRow();
        }
        mode = 'view';
    }
    
    public void showReq()
    {
        showRequirement=true;
        
    }
    public void edit()
    {
        showRequirement=false;
        mode='edit';
        if(ord.RecordType.Name=='Transfer Order')BatchsforProd();
    }
    public void newRow()
    {
        
        showRequirement=false;
        mode='edit';
        OpportunityLineItem oli = new OpportunityLineItem();
        cOli pOli = new cOli(); 
        pOli.Selected=true;
        
        pOli.cBatchs=new list<selectOption>();
        
        system.debug('NOO');
        pOli.OppLine=oli;
        pOli.OppLine.Type__c='';
        //--------------
        //   Specific type for specific country divisions. Sales Order in general and Italy CP want only one type .Ukraine the same but in FOC lines
        //--------------------
        if(ord.RecordType.Name=='Sales Order' && ord.TXTA_Sales_Org__c !='UA01' || ord.RecordType.Name=='Sales Order CP Italy' || ord.RecordType.Name=='Sales Italy Charged')pOli.OppLine.type__c='Charged';
        if(ord.RecordType.Name.contains('Sales Order') && !ord.RecordType.Name.contains('CP')&& (ord.TXTA_Sales_Org__c =='UA01' || ord.TXTA_Sales_Org__c =='FR24' ||ord.TXTA_Sales_Org__c =='BG01') || ord.RecordType.Name=='Sales Italy FOC')pOli.OppLine.type__c='Free of Charge';
        if(ord.StageName=='FOC ORDER')pOli.OppLine.type__c='FREE OF CHARGE ZFD1';
        existingcOLIs.add(pOli);
        // importStock();
        if(ord.RecordType.Name=='Transfer Order')BatchsforProd();
        
        
    }
    public void BatchsForProd()
    {
        
        
        for(cOli elem:existingcOlis)
        {
            if(elem.prodName!=null){
                
                list<string> btchs= batchsForProds.get(elem.prodName);
                system.debug(elem);
                if(btchs!=null)
                {
                    
                    for(string btchNumb:btchs)
                    {
                        if(btchNumb!=null)elem.cBatchs.add(new selectOption(btchNumb,btchNumb));
                    }
                }   
            }
        }
        
        
    }
    
    public void search()
    {
        System.debug('@@ Point of Search');
        filterPos();
        
        searchState=True;
        getData();
        searchState=False;
        System.debug('@@ Number of products that meet the Search criteria: '+allcOLIs.size());
    }
    public void save4()    
    {
        showException=false;
        system.debug('he entrado');
        showRequirement=true;
        error=false;
        set<OpportunityLineItem> OLIstoUpsert=new set<OpportunityLineItem>();
        
        if(mode=='addM')
        {
            for(cOli customOli:allcOLIs)
            {
                
                if(customOli.Selected == true)
                {
                    existingcOLIS.add(customOli);  
                }
            }     
        }
        Map<String, String> Map_Pricebook_Name = new Map<String, String>();
        for(integer i = 0 ; i<existingcOLIs.size();i++)
        {
            cOli customOli = existingcOLIs.get(i);
            SYSTEM.DEBUG(EXISTINGCOLIS)   ;
            for(PriceBookEntry item:allPBEs) 
            {              
                if(  (customOli.prodName==item.Product2.Name) )
                {
                    system.debug(customOli.OppLine.NUM_Quantity_palets_CP__c);
                    system.debug('la linea es ' + customOli);
                    if((customOli.OppLine.id==null) )
                    {
                        customOli.OppLine.PriceBookEntryId=item.id;
                        customOli.OppLine.OpportunityID=Ord.id;
                    }
                    if(customOli.OppLine.PriceBookEntryId != null)
                        Map_Pricebook_Name.put(customOli.OppLine.PriceBookEntryId, customOli.prodName.replace(',','_').replace(' ','_'));
                    
                    OpportunityLineItem OPL=new OpportunityLineItem();
                    OPL=customOli.OppLine;
                     
                   if(Ord.RecordType.Name=='Sales Italy Charged' || Ord.RecordType.Name=='Sales Italy FOC')
                   {
                       // Util.addWarningMessage('Debug cOLIS:'+customOli);
                    Decimal quantity = customOli.OppLine.Quantity==null?1:customOli.OppLine.Quantity;                   
                    Decimal allocation = mapAllocationByProductId.get(String.valueOf(item.product2id).substring(0,15))==null?0:mapAllocationByProductId.get(String.valueOf(item.product2id).substring(0,15)).FRML_Avalaible_Units__c;
                    if(quantity<=allocation){
                        System.debug('antes de a?adir la lista d upsert');

                    olisToUpsert.add(OPL);
                        System.debug('despues de a?adir la lista d upsert');
                    }else{
                     customOLI.validateAllocation=true;
                     existingcOLIs.set(i, customOli);
                     Util.addWarningMessage(Label.OE2_0_OppExtensionViewWarning1+' '+customOli.prodName+' '+Label.OE2_0_OppExtensionViewWarning2+customOli.OppLine.Quantity+' '+Label.OE2_0_Allocation+': '+allocation);                     
                    }                                                               
                }
                else
                {
                    olisToUpsert.add(OPL);
                }
                }
            }
            
        }
        
        set<string> Set_products_litres = new set<string>(); 
        for(String s : List_products_litres) Set_products_litres.add(s);
        
        for(OpportunityLineItem OLI:OLIstoUpsert) {
            
            
            boolean condition1 = false;
            
            
            if(ord.RecordType.name=='Sales Order CP Italy') {
                
                
                if(OLI.NUM_Discount__c!=null)condition1=oli.NUM_Quantity_litres_CP__c==null && oli.NUM_Quantity_palets_CP__c==null;
            }
            if(ord.recordType.Name=='Sales Order CP') {
                
                if(OLI.Type__c==null)
                    condition1=true;
                
                
                
                
                if(OLI.Type__c=='Free of charge')
                    condition1 = oli.NUM_Quantity_litres_CP__c==null;
                
                
                if(OLI.Type__c=='Charged')
                    condition1 = ((oli.NUM_Quantity_palets_CP__c==null && !Set_products_litres.contains(Map_Pricebook_Name.get(oli.PriceBookEntryId))) || (oli.NUM_Quantity_litres_CP__c==null && Set_products_litres.contains(Map_Pricebook_Name.get(oli.PriceBookEntryId))));
                
            } else if(ord.recordType.Name=='Sales Order' || ord.recordType.Name=='Transfer Order') {
                
                
                
                if(ord.RecordType.name.contains('Transfer Order'))
                    condition1 = OLI.Quantity==null;
                else
                    
                    condition1 = (OLI.Type__c==null || OLI.Quantity==null);
            }

            if(condition1) {
                
                
                error=true;
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Information missed');
                ApexPages.addMessage(myMsg);
                mode='edit';
                
            }


        }
        if(error==true) {
            
            
            
            // existingcOLIS.clear();
            system.debug('ERROR 1');
            
        }
        
        if(error==false) {
            system.debug(olistoupsert);
            list<OpportunityLineItem> olisToUps=new list<OpportunityLineItem>();
            olisToUps.addAll(olistoupsert);

            
            
            
            
            
            
            
            
            
                    

try {
                upsert olisToUps;





            } catch(DMLException e) { 
                
                
                
                
                system.debug('ERROR');
                
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0));
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0));
                
                ApexPages.addMessage(myMsg);
                showException = true;
                
                
                


            }
            if (showException==false) {
                              
                
                mode='view';
                OLIstoUpsert.clear();
                existingcOLIS.clear();
                allcOLIs.clear();
                getData();
                
            }
            
        }
        
        keyWord='';
        searchBox='';
        searchBoxDate=null;        
        
        

    }

    public void cancel()
    {
        showRequirement=false;
        getData();
        mode='view';
        keyWord='';
        searchBox='';
        searchBoxDate=null;
        
    }
    
    public void rejectOLIs()     // Puts the OLI's SAP status to 'Rejected by Customer' and upserts its related AllocationConsumedLog to 0 ??available?? units.
    {
        List<OpportunityLineItem> oli2Update = new List<OpportunityLineItem>();
        List<Allocation_Consume_Log__c> acl2Update = new List<Allocation_Consume_Log__c>();
        for(cOLI c: existingcOLIs){
            if(c.selected == true && c.OppLine.id!=null){
            system.debug('line: '+c.oppLine);
                // First change the OLI's status to 'rejected' (UPDATE?)
                c.OppLine.TXT_Line_SAP_status__c = 'Rejected by Customer';
                system.debug('status: ' + c.OppLine.TXT_Line_SAP_status__c);
                oli2Update.add(c.OppLine);
                // Now we modify its ConsumedAllocationLog's quantity.
                String ACLextId = usr.SAP_Partner_Code__c +'-'+   c.OppLine.TXT_SAP_Order_Number__c +'-'+ c.OppLine.Product2.ProductSAPCode__c;
                Allocation_Consume_Log__c acl = new Allocation_Consume_Log__c();
                acl.TXT_External_ID__c = ACLextId;
                acl.NUM_Qty__c = 0;
                system.debug('@@kiakaha : ' + c.OppLine.pricebookentry);
                system.debug('@@kiakaha1 : ' + c.OppLine.product2.id);
                system.debug('@@kiakaha2 : ' + c.OppLine.pricebookentry.productcode);
                System.debug('@@productcode: ' + c.OppLine.product2);
                System.debug('@@Owner ID: ' + ord.OwnerID);
                Allocation__c mdAlloc = new Allocation__c (TXT_external_id__c = String.valueOf(ord.OwnerID ).substring(0,15) +'-'+ 
                                                           String.valueOf(c.OppLine.product2id).substring(0,15) + '-'+Util.currentYear.name);
                system.debug('@@Namaste: '+ mdAlloc);
                
                acl.MD_Allocation__r = mdAlloc;
                acl2Update.add(acl);
            }
        }
        update oli2Update;
        Database.upsert(acl2Update,Allocation_Consume_Log__c.Fields.TXT_External_ID__c,false);
    }
    
    public void deleteOLIs()
    {
        
        system.debug('deleteOLIs method');
        
        list<OpportunityLineItem> oliToDel=new list<OpportunityLineItem>();
        
        for(cOli pr:existingcOLIs)
        {
            
            if(pr.selected==true && pr.OppLine.id != null)
            {  
                oliToDel.add(pr.OppLine);
            }
            
        }
        
        system.debug('***existingcOLIs: ' + existingcOLIs);
        system.debug('***oliToDel: ' + oliToDel);
        
        try{
            delete oliToDel;
        }catch(DMLException e)
        {      
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0));
            //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getDMLMessage(0));
            
            ApexPages.addMessage(myMsg);
            showException = true;
            
        } 
        getData();
        mode='view';  
    }
    public void addProducts()
    {
        getData();
        
        SelectedField='---None---';
        filterPos();
        mode='addM';
        //importStock();
        if(ord.RecordType.Name=='Transfer Order')BatchsforProd();
    }
    public void filterPos ()
    {
        
        //In order to make a search by field we need to take the description for the different fields 
        isDate=False;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ObjectSchema = schemaMap.get('product2');
        
        Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
        
        // The first step is to catch the field name and label for creating a list to filter by any field
        
        fieldNames = new List<SelectOption>();
        map<string,string> fieldNamesAux=new map<string,string> ();
        s=new list<string>();
        fieldNames.add(new SelectOption('---None---',Label.Default_pick_list_option));
        for (String fieldName: fieldMap.keySet()) 
        {
            
            string fType=string.valueOf(fieldMap.get(fieldName).getDescribe().getType());
            
            string R=fieldMap.get(fieldName).getDescribe().getLabel();
            
            if((fType=='reference'))
            {
                if(fieldName.contains('__c'))
                {
                    fieldname=fieldName.removeEndIgnoreCase('__c');
                    fieldName=fieldName+'__r';
                    
                }
                if(fieldName.contains('id')){fieldname=fieldName.removeEndIgnoreCase('id');  }
                R=R.removeEndIgnoreCase('id');
                R=R + ' Name wololo';                
                fieldName=fieldName+'.Name';
                
            }
            fieldNames.add(new SelectOption(R,R));
            fieldNamesAux.put(R,fieldName);
            s.add(fType);
        }
        fieldNames.sort();
        list<string> sFieldNames=new list<string>();
        
        //now we fill all the possibilities the filter can make
        filterPosibilities = new List<SelectOption>();
        
        /*----------------- All the possible options to filter--------------------*/
        SelectOption defaultV=new SelectOption('None',Label.Default_pick_list_option);
        SelectOption equal=new SelectOption('equals','equals');
        SelectOption noEqual=new SelectOption('not equal to','not equal to');
        SelectOption startsWith=new SelectOption('starts with','starts with');
        SelectOption contains=new SelectOption('contains','contains');
        SelectOption noContains=new SelectOption('does not contain','does not contain');
        SelectOption lessThan=new SelectOption('less than','less than');
        SelectOption greaterThan=new SelectOption('greater than','greater than');
        SelectOption lessEqual=new SelectOption('less or equal','less or equal');
        SelectOption greaterEqual=new SelectOption('greater or equal','greater or equal');
        /*----------------- -------------------------------------------------------*/
        
        if(selectedField!='---None---')
        {
            string compareNameAux=fieldNamesAux.get(selectedField);
            
            Schema.DisplayType typeField=Schema.DisplayType.String;
            
            
            if(compareNameAux.contains('.Name')){ typeField=Schema.DisplayType.STRING;}
            else { typeField=fieldMap.get(compareNameAux).getDescribe().getType();}
            
            
            if(typeField==Schema.DisplayType.DATE ||typeField==Schema.DisplayType.DATETIME) 
            {
                isDate=true;
            }
            if(typeField==Schema.DisplayType.STRING || typeField==Schema.DisplayType.TEXTAREA || typeField==Schema.DisplayType.PICKLIST  )
            {
                filterPosibilities.clear();
                filterPosibilities.add(defaultV);
                filterPosibilities.add(equal);
                filterPosibilities.add(noEqual);
                filterPosibilities.add(contains);
                filterPosibilities.add(noContains);
                filterPosibilities.add(startsWith);
                
                
                if(searchBox!=null) searchBoxConverted= ' \''+String.escapeSingleQuotes(searchBox)+'\'';
                
            }
            if(typeField==Schema.DisplayType.DOUBLE ||typeField==Schema.DisplayType.INTEGER || typeField==Schema.DisplayType.CURRENCY || 
               typeField==Schema.DisplayType.PERCENT || typeField==Schema.DisplayType.DATE ||typeField==Schema.DisplayType.DATETIME  )
            {
                
                if(typeField==Schema.DisplayType.DOUBLE){ if(searchBox!=null)searchBox =searchBox.replace(',','.');}
                filterPosibilities.clear();
                filterPosibilities.add(defaultV);
                filterPosibilities.add(equal);
                filterPosibilities.add(noEqual);
                filterPosibilities.add(lessThan);
                filterPosibilities.add(greaterThan);
                filterPosibilities.add(lessEqual);
                filterPosibilities.add(greaterEqual);
                
                if((typeField==Schema.DisplayType.DATE ||typeField==Schema.DisplayType.DATETIME) && (searchBoxDate!=null ))
                {
                    
                    
                    // searchBoxConverted=String.escapeSingleQuotes(searchBox);
                    if(searchBoxDate!=null)
                    {
                        Datetime auxSBD=datetime.newInstance(searchBoxDate.year(), searchBoxDate.month(),searchBoxDate.day());
                        searchBoxConverted=auxSBD.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                        
                        
                    }
                    
                }else 
                {
                    if(searchBox!=null) searchBoxConverted= searchBox;
                }
                
                
            }
            if(typeField==Schema.DisplayType.BOOLEAN || typeField==Schema.DisplayType.Reference || typeField==Schema.DisplayType.Id)
            {
                filterPosibilities.clear();
                filterPosibilities.add(defaultV);
                filterPosibilities.add(equal);
                filterPosibilities.add(noEqual);
                if(searchBox!=null) searchBoxConverted=String.escapeSingleQuotes(searchBox);
            }
        }
        else{
            filterPosibilities.clear();
            filterPosibilities.add(defaultV);
            filterPosibilities.add(equal);
            filterPosibilities.add(noEqual);
            filterPosibilities.add(contains);
            filterPosibilities.add(noContains);
            filterPosibilities.add(startsWith);
            filterPosibilities.add(lessThan);
            filterPosibilities.add(greaterThan);
            filterPosibilities.add(lessEqual);
            filterPosibilities.add(greaterEqual);
            
            selectedFilter=Label.Default_pick_list_option;
        }
        string fieldApiName='';
        for(String key:fieldNamesAux.keySet())
        {
            if(key==selectedField)
            {
                fieldApiName=fieldNamesAux.get(key);
                
            }
        }
        
        if(searchBox!=null ||(isDate==true && searchBoxDate!=null) )
        {
            if(selectedFilter=='$Label.Default_pick_list_option')subquery='';
            if(selectedFilter=='equals')subquery=' AND ' +fieldApiName+' = '+searchBoxConverted;
            if(selectedFilter=='not equal to')subquery=' AND ' +fieldApiName+' !=  '+searchBoxConverted;
            if(selectedFilter=='starts with')subquery=' AND ' +fieldApiName+' Like \'%'+String.escapeSingleQuotes(searchBox)+'\'';
            if(selectedFilter=='contains')subquery=' AND ' +fieldApiName+' Like \'%'+ String.escapeSingleQuotes(searchBox)+'%\'';
            if(selectedFilter=='does not contain')subquery=' AND ' +'  ( Not '+fieldApiName+' Like \'%' +String.escapeSingleQuotes(searchBox)+'%\') ';
            if(selectedFilter=='less than')subquery=' AND ' +fieldApiName+' <   '+searchBoxConverted;
            if(selectedFilter=='greater than')subquery=' AND ' +fieldApiName+' >    '+searchBoxConverted;
            if(selectedFilter=='less or equal')subquery=' AND ' +fieldApiName+' <=  '+searchBoxConverted;
            if(selectedFilter=='greater or equal')subquery=' AND ' +fieldApiName+' >=   '+searchBoxConverted;
        }
        
    }
    
    public void importStock()
    {
        if(ord.RecordType.Name=='Transfer Order')BatchsforProd();
        system.debug('He entrado en el allocation');
        system.debug(existingcOLIs);
        
        if (mode=='edit')
        {
            list<cOli> aux=new list<cOli>();
            for(cOli customOli:existingcOLIs)
            {
                
                
                for(PriceBookEntry item:allPBEs) 
                { 
                    
                    
                    if( (customOli.OppLine.id==null) && (customOli.prodName==item.Product2.Name) && (customOli.Selected==true))
                    {
                        system.debug(customOli);
                        
                        
                        customOli.OppLine.PriceBookEntryId=item.id;
                        customOli.OppLine.OpportunityID=Ord.id;
                        Allocation__c impRes= new Allocation__c();    // Canviar per Obj Allocation__c ????????

                        impRes=ImportProductAllocation.quantityfromSAP(item.product2.ProductSAPCode__c,ord.Account.GC_SAP_ID__c);
                        customOli.OppLine.NUM_quantitySAP__c=impRes.FRML_Avalaible_Units__c;    // Utilizamos campo FRML_Avalaible_Units__c ????????

                        
                        
                        
                    }
                    
                }
                
                
            }
        } 
        if (mode=='addM')
        {
            for(cOli customOli:allcOLIs)
            {
                
                for(PriceBookEntry item:allPBEs) 
                { 
                    
                    
                    if( (customOli.OppLine.id==null) && (customOli.prodName==item.Product2.Name) && (customOli.Selected==true))
                    {
                        system.debug(customOli);
                        
                        Allocation__c impRes= new Allocation__c();

                        impRes=ImportProductAllocation.quantityfromSAP(item.product2.ProductSAPCode__c,ord.Account.GC_SAP_ID__c);
                        customOli.OppLine.NUM_quantitySAP__c=impRes.FRML_Avalaible_Units__c;
                    }
                }
            }
            
            
        }
    }
    
    public void debitSoldTo()
    {
        soldsToD = selectSoldTo(ord.LKP_areaManager_Debit_OT__c);
    }
    public void creditSoldTo()
    {        
        soldsToC = selectSoldTo(ord.LKP_areaManager_Credit_OT__c);       
    }
    public void debitShipTo()
    {
        shipsToD = selectShipTo(soldToD);
    }
    public void creditShipto()
    {
        shipsToC = selectShipTo(soldToC);
    }
    public list<selectOption> selectSoldTo(ID ManagerID)
    {
        list<selectOption> soldsToNames = new list<selectOption>();
        list<Account> soldsTo = new list<Account>();
        
        //user Manager=[Select name,id,SAP_Partner_Code__c  from user where id=:ManagerId];
        if(ord.TXTA_Sales_Org__c == 'IT01' && ord.RecordTypeId == Util.recordType.get('Opportunity:Transfer_Order'))
        {
          soldsTo = [SELECT Id, Name FROM Account
          WHERE RecordTypeId = :Util.recordType.get('Account:DistRetPoS')
          AND GC_Cust_Account_Grp_Descr__c = 'Sold-to party'
          AND GC_Integration_Key__c != null
          AND GC_is_Marked_For_Del__c = false
          AND CountryRef__r.Name = 'Italy'
          AND OwnerId != '005D0000002Hslh'
          AND Owner.TXT_Division__c = '17'
          AND GC_Status_Descr__c IN ('Active', 'To be reviewed')
          ORDER BY Name ASC];
        }
        else
        {
        	if(ManagerId != null && Map_Id_User.containsKey(ManagerId))
        	{
			  soldsTo = [SELECT Id, Name FROM Account
			  WHERE RecordTypeId = :Util.recordType.get('Account:DistRetPoS')
			  AND GC_Cust_Account_Grp_Descr__c = 'Sold-to party'
			  AND GC_is_Marked_For_Del__c = false
			  AND TXT_Partners_Ids__c like : '%'  + Map_Id_User.get(ManagerId).SAP_Partner_Code__c +'%'
			  ORDER BY Name ASC];
        	}
        }
        for(Account acc:soldsTo)
        {
            SelectOption newOpt= new selectOption(acc.id,acc.name);
            soldsToNames.add(newOpt);
            soldsToM.put(acc.id,acc);
        }
        return soldsToNames;
    }
    
    public list<selectOption> selectShipTo(Id SoldToID)
    {
        list<selectOption> shipsToNames = new list<selectOption>();
        list<partner_function__c> shipsTo = new list<partner_function__c>();
        
        if(SoldToId != null)
        {
	        shipsTo = [Select id,name,Partner_SAP_ID__c,City_Name__c from partner_function__C where
	                 (( Primry_Acct_Integration_Key__r.id=:id.valueOf(SoldToID) or name like :'%'+usr.CountryISOCode__c ) And Partner_Function_Code__c='WE' and Relation_Type_Descr__c='Ship-to Party'
	                  and Sales_Area_Integration_Key__r.name like: '%'+usr.TXT_Division__c +'%' and is_Marked_For_Del__c=false and Sales_Area_Integration_Key__r.name  like: '%'+ usr.TXT_Sales_Org__c+'%')
	                ORDER BY Name ASC];
	        system.debug(shipsTo);
	        for(partner_function__c sTo:shipsTo)
	        { 
	            SelectOption newOpt;
	            if(sTo.City_Name__c!=null) newOpt= new selectOption(sTo.id,sTo.name +'  -  '+ sTo.City_Name__c);
	            else   newOpt= new selectOption(sTo.id,sTo.name);
	            shipsToNames.add(newOpt);
	            shipsToM.put(sTo.id,sTo);
	        }
        }
        return shipsToNames;
    }

    public pageReference save2()
    {
        showTOException=False;
        
        ord.LKP_soldTo_Source_OT__c=soldToC;
        ord.accountId=soldToD;
        ord.LKP_shipTo_Source_OT__c=shipToC;
        ord.LKP_Partner_Function__c=shipToD;
        
        if(usr.Country == 'Italy')
        {
	        for(Partner_Function__c pf : [SELECT Id, TXT_Partners_Ids__c FROM Partner_Function__c WHERE Id = :shipToC OR Id = :shipToD])
	        {
	        	if(pf.TXT_Partners_Ids__c != null && pf.TXT_Partners_Ids__c != '')
	        	{
		        	for(String code : pf.TXT_Partners_Ids__c.split(';'))
		        	{
		        		if(Map_SAP_User.containsKey(code) && pf.Id == shipToC)
		        		{
		        			ord.LKP_areaManager_Credit_OT__c = Map_SAP_User.get(code).Id;
		        		}
		        		if(Map_SAP_User.containsKey(code) && pf.Id == shipToD)
		        		{
		        			ord.LKP_areaManager_Debit_OT__c = Map_SAP_User.get(code).Id;
		        		}
		        	}
	        	}
	        }
        }
        
        system.debug('ord.OwnerId: ' + ord.OwnerId);
        system.debug('ord.LKP_areaManager_Credit_OT__c: ' + ord.LKP_areaManager_Credit_OT__c);
        system.debug('ord.LKP_areaManager_Debit_OT__c: ' + ord.LKP_areaManager_Debit_OT__c);

        try
        {
            update ord;
            system.debug('Guardado correcto');
        }catch(dmlException e )
        {
            system.debug('Guardado incorrecto');
            modeOT='edit';
            showTOException = true;
            
            apexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
            
        }
        getData();
        if(showTOException!=True)modeOT='show';
        system.debug('modo de visualizacion'+mode);
        return null;
    }
    
    public PageReference save(){
        
        try{
            update ord;
        }
        catch(DMLexception e)
        {
            system.debug('ERRRRRRRRRRRRRRRRRRROR');
            modeOT='edit';
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    }    
    public void edit2()
    {
        if(ord.LKP_soldTo_Source_OT__c!=null || soldToC != null) creditShipTo(); 
        if(ord.LKP_Field_Agent_Credit_OT__c!=null || ord.LKP_areaManager_Credit_OT__c!=null) creditSoldTo();
        if(ord.LKP_Field_Agent_Debit_OT__c!=null || ord.LKP_areaManager_Debit_OT__c!=null)debitSoldTo(); 
        if(ord.LKP_areaManager_Credit_OT__c == null) ord.LKP_Field_Agent_Credit_OT__c= UserInfo.getUserId();     


        if(ord.AccountId!=null) debitShipTo();
        modeOT='edit';
        system.debug('modo de visualizacion'+mode);
    }
    public void cancel2()
    {
        modeOT='show';
    }            
    
    public class cOLI
    {
        public Boolean selected {get; set;}
        // public product2 prodFromPriceBook {get; set;}
        public OpportunityLineItem OppLine {get;set;}
        public String prodName{get;set;}
        public list<selectOption> cBatchs{get;set;}
        public Decimal allocation {get;set;}
        public  String lot {get;set;}
        public boolean validateAllocation{get;set;}
        public cOLI(){
           validateAllocation=false; 
            
        }
    }
}