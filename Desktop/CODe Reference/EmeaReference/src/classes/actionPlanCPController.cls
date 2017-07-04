public with sharing class actionPlanCPController
{
    public actionPlanCPController(Account controller) {}
    
    public Integer currentForecast;
    public Integer currentPOG;
    public Integer currentStock;
    public Product2 product;
    public Id productRecordType;    
    public List<cActionPlanLines> listActionPlanLines {get; set;}
    public List<cActionPlanLines> listNewAPL {get; set;}
    public Map<String, List<cActionPlanLines>> mapProductFamilyAPL {get; set;} //<ProdutFamily,List<ActionPlanLine>
    public Map<cActionPlanLines,string> aplFail {get;set;}
    public List<Apl> summaryAPL { get; set;}
    public List<cActionPlanLines> listaPintarAPL {get; set;}
    
    public Boolean enableEditInvoice {get; set;}
    
    public String periodSelected {get; set;}
    public String quarterSelected {get; set;}
    public String familySelected {get; set;}
    public String mode {get;set;}
    public Id accountId {get; set;}
    public List<SelectOption> productos {get; set;}
    public List<SelectOption> productosActive {get; set;}
    public List<Id> productsFiltered{get; set;}
    public Country__c country {get; set;}
    public User currentuser {get; set;}
    
    public Account a;
    public Boolean showException {get;set;}
    public String errorDelete {get;set;}
    public List<ID> listaCatalogosFiltrada{get; set;}
    public Boolean isAddMultipleLines {get;set;}
    
    public String selFamily {get; set;}
    
    public actionPlanCPController()
    {       
        errorDelete = 'false';
        accountId = ApexPages.currentPage().getParameters().get('Id');
        selFamily = 'none';
        isAddMultipleLines = false;
        summaryAPL = new List<apl>();
        a = [SELECT Id, Name, GC_Cust_Account_Grp_Descr__c, GC_Integration_Key__c, Influencer__c, Influencer__r.GC_Integration_Key__c FROM Account WHERE Id =: accountId LIMIT 1];
        productRecordType = Util.recordType.get('Product2:CPSalesProduct');
        //Get Units of Mesurement
        //User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        if(currentUser.Country != null) country = [SELECT Id, Units_of_Measurement__c FROM Country__c WHERE Name =: currentUser.Country ];
        
        system.debug('****currentuser: '+currentuser);
        system.debug('****country: '+country);
        
        enableEditInvoice = (a.Influencer__c != null && a.Influencer__r.GC_Integration_Key__c != null) ? true : false;
        
        cargarCombos();   
        //Get list of available products and use it in the AP summary filter
        productsFiltered = new List<Id>();
        for(SelectOption itemOption : productos)
        {
            productsFiltered.add(itemOption.getValue());
        }
        //SUMMARY
        AggregateResult[] summaryResults =[SELECT LKP_SKU__r.TXT_commercial_name__c name, MIN(LKP_SKU__r.NUM_AP_CP_Custom_Order__c), SUM(FRML_POG_Units_CFY__c) cfy, SUM(FRML_POG_Units_PFY__c) pfy, SUM(FRML_POG_Units_PFY_YTD__c) pfytd FROM Action_Plan_Line__c 
                                           WHERE ((FRML_CHK_Is_Current_FY__c = true AND FRML_POG_Units_CFY__c>0) OR (FRML_CHK_Is_Previous_FY__c = true AND FRML_POG_Units_PFY_YTD__c>0)) AND LKP_Account__c =: accountId AND LKP_SKU__r.id IN :productsFiltered
                                           GROUP BY LKP_SKU__c, LKP_SKU__r.TXT_commercial_name__c ORDER BY MIN(LKP_SKU__r.NUM_AP_CP_Custom_Order__c), LKP_SKU__r.TXT_commercial_name__c];
        
        for(AggregateResult ar : summaryResults)
        {
            summaryAPL.add(new apl(ar));
        }        
        
        if(a.GC_Cust_Account_Grp_Descr__c == 'Sold-to party') periodSelected = String.ValueOf(System.Date.today()).left(7);        
        else if(a.GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
        {
            String fy;
            Integer m = System.Date.today().month();
            String q;
            if(m >= 9 && m < 12) q = 'Q1';
            else if(m == 12 || (m >= 1 && m < 3)) q = 'Q2';
            else if(m >= 3 && m < 6) q = 'Q3';
            else if(m >= 6 && m < 9) q = 'Q4';
            
            if(m >= 9 && m <= 12) fy = String.valueOf(System.Date.today().year()+1).substring(2,4);
            else fy = String.valueOf(System.Date.today().year()).substring(2,4);
            
            quarterSelected = 'FY' + fy + ' ' + q;
        }
        familySelected = 'none';
        
        getData();      
        
        if(ApexPages.currentPage().getParameters().get('mode') == null)
        { 
            mode = 'view';
        }
        else
        {  
            mode = ApexPages.currentPage().getParameters().get('mode');    
        }
        
        //Add multiple Lines    
        if(ApexPages.currentPage().getParameters().get('products') != null)
        {
            isAddMultipleLines  = true;
            listActionPlanLines = new list<cActionPlanLines>();
            for(String s : (ApexPages.currentPage().getParameters().get('products')).split('-'))
            {
                Action_Plan_Line__c apl = new Action_Plan_Line__c();
                apl.LKP_SKU__c = s;
                if(periodSelected != null) apl.PICK_Period__c = periodSelected;
                else if(quarterSelected != null) apl.PICK_Quarter__c = quarterSelected;
                listActionPlanLines.add(new cActionPlanLines(apl));            
            }
            mapProductFamilyAPL.put('zz', listActionPlanLines);
            listaPintarAPL.addAll(listActionPlanLines);
        }          
    }
    
    public void getData()
    {               
        //Get action plan lines       
        List<Action_Plan_Line__c> actionPlanLines;
        mapProductFamilyAPL = new map<String, List<cActionPlanLines>>();
        Integer totalFor, totalForRel, totalIniStock, totalIniStockRel, totalFiStock, totalFiStockRel, totalPog,totalPogKg, totalOrd, totalOrdRel, totalDelivered, totalDeliveredRel;

        String query = 'SELECT Id, NUM_Sell_out__c , Name, PICK_Quarter__c, NUM_Forecast__c, NUM_Forecast_Rel__c, FRML_Forecast_Rel__c, FRML_POG_Unit__c, FRML_POG_Rel__c, PICK_Period__c, NUM_Initial_stock__c, NUM_Final_stock__c, NUM_Final_stock_Rel__c, FRML_Initial_stock_Rel__c, FRML_Final_stock_Rel__c, NUM_Ordered__c, FRML_Ordered_Rel__c, NUM_Delivered__c,FRML_Delivered_Rel__c, NUM_Sell_In__c, LKP_SKU__r.TXT_commercial_name__c, LKP_SKU__r.Family, LKP_SKU__r.isActive FROM Action_Plan_Line__c WHERE LKP_Account__c = \''+accountId+'\' AND LKP_SKU__c IN :productsFiltered ';
        if(a.GC_Cust_Account_Grp_Descr__c == 'Sold-to party')
        {
            if(periodSelected != 'none')
                query += ' AND PICK_Period__c =\''+periodSelected+'\' ';
        }
        else if(a.GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
        {
            if(quarterSelected != 'none')
                query += ' AND PICK_Quarter__c =\''+quarterSelected+'\' ';
        }               
        query+=' ORDER BY LKP_SKU__R.NUM_AP_CP_Custom_Order__c, LKP_SKU__r.TXT_commercial_name__c, LKP_SKU__r.Family asc';
        
        actionPlanLines = Database.query(query);
        
        if(actionPlanLines.size() > 0) 
        { 
            for(Action_Plan_Line__c apl : actionPlanLines)
            {            
                if(mapProductFamilyAPL.get(apl.LKP_SKU__r.Family) == null)
                {                                      
                    listActionPlanLines = new List<cActionPlanLines>();
                    listActionPlanLines.add(new cActionPlanLines(apl));
                    mapProductFamilyAPL.put(apl.LKP_SKU__r.Family, listActionPlanLines);
                }
                else
                {
                    mapProductFamilyAPL.get(apl.LKP_SKU__r.Family).add(new cActionPlanLines(apl));
                }
            }           
        }
        else
        {
            listActionPlanLines = new List<cActionPlanLines>();
        }
        
        //Totals category
        for(String key :mapProductFamilyAPL.keySet())
        {
            totalFor = 0;
            totalForRel = 0;
            totalIniStock = 0;
            totalIniStockRel = 0;
            totalFiStock = 0;
            totalFiStockRel = 0;
            totalPog = 0;
            totalPogKg=0;
            totalOrd = 0;
            totalOrdRel = 0;
            totalDelivered = 0;
            totalDeliveredRel = 0;
            for(cActionPlanLines item :mapProductFamilyAPL.get(key))
            {              
                if(item.actionPlanLine.NUM_Forecast__c != null) totalFor = totalFor + Integer.valueOf(item.actionPlanLine.NUM_Forecast__c);
                if(item.actionPlanLine.FRML_Forecast_Rel__c != null) totalForRel = totalForRel + Integer.valueOf(item.actionPlanLine.FRML_Forecast_Rel__c);
                if(item.actionPlanLine.NUM_Ordered__c != null) totalOrd = totalOrd + Integer.valueOf(item.actionPlanLine.NUM_Ordered__c);
                if(item.actionPlanLine.FRML_Ordered_Rel__c!= null) totalOrdRel = totalOrdRel + Integer.valueOf(item.actionPlanLine.FRML_Ordered_Rel__c);
                if(item.actionPlanLine.NUM_Delivered__c!= null) totalDelivered = totalDelivered + Integer.valueOf(item.actionPlanLine.NUM_Delivered__c);
                if(item.actionPlanLine.FRML_Delivered_Rel__c!= null) totalDeliveredRel = totalDeliveredRel + Integer.valueOf(item.actionPlanLine.FRML_Delivered_Rel__c);
                if(item.actionPlanLine.NUM_Initial_stock__c != null) totalIniStock = totalIniStock + Integer.valueOf(item.actionPlanLine.NUM_Initial_stock__c);
                if(item.actionPlanLine.FRML_Initial_stock_Rel__c != null) totalIniStockRel = totalIniStockRel + Integer.valueOf(item.actionPlanLine.FRML_Initial_stock_Rel__c);
                if(item.actionPlanLine.NUM_Final_stock__c != null) totalFiStock = totalFiStock + Integer.valueOf(item.actionPlanLine.NUM_Final_stock__c);
                if(item.actionPlanLine.FRML_Final_stock_Rel__c != null) totalFiStockRel = totalFiStockRel + Integer.valueOf(item.actionPlanLine.FRML_Final_stock_Rel__c);
                if(item.actionPlanLine.FRML_POG_Rel__c!= null) totalPog = totalPog + Integer.valueOf(item.actionPlanLine.FRML_POG_Rel__c);     
                if(item.actionPlanLine.FRML_POG_Unit__c!= null) totalPogKg = totalPogKg + Integer.valueOf(item.actionPlanLine.FRML_POG_Unit__c);  
               
            }
            Action_Plan_Line__c aplAux = new Action_Plan_Line__c();
            aplAux = (mapProductFamilyAPL.get(key)[0].actionPlanLine).clone(); 
            
            cActionPlanLines cAplAux = new cActionPlanLines(aplAux);
            cAplAux.name = 'TOTAL ' + key;
            cAplAux.total = true;
            cAplAux.totalForecast = totalFor.format();
            cAplAux.totalForecastRel = totalForRel.format();
            cAplAux.totalInitialStock = totalIniStock.format();
            cAplAux.totalInitialStockRel = totalIniStockRel.format();
            cAplAux.totalFinalStock = totalFiStock.format();
            cAplAux.totalFinalStockRel = totalFiStockRel.format();
            cAplAux.totalOrdered = totalOrd.format();
            cAplAux.totalOrderedRel = totalOrdrel.format();
            cAplAux.totalDelivered = totalDelivered.format();
            cAplAux.totalDeliveredRel = totalDeliveredRel.format();
            cAplAux.totalPOG = totalPog.format();
            cAplAux.totalPOGKg=totalPogKg.format();
            
            mapProductFamilyAPL.get(key).add(cAplAux);            
        }
        listaPintarAPL = new list<cActionPlanLines>();
        for(String s :mapProductFamilyAPL.keySet())
        {
            listaPintarAPL.addAll(mapProductFamilyAPL.get(s));
        }
        mode = 'view';        
    }        
    
    public List<SelectOption> getPeriods()
    {
        List<SelectOption> options = new List<SelectOption>();
        Integer m,y;
        y = System.Date.today().year();
        
        Date today = System.Date.today();
        Decimal startingYear = (today.month()<9)?today.year()-1:today.year();
        //TOTAL FISCAL YEAR
        for(Integer i = 0; i < 12; i++)
        {   
            m = 8 + i;     
            String formattedMonth = String.valueOf(Math.Mod(m, 12)+1).leftPad(2).replace(' ', '0');
            String formattedYear = String.valueOf(startingYear );
            if(m+1 > 12){ //Next year
                formattedYear = String.valueOf(startingYear  + 1);
            }
            options.add(new SelectOption(formattedYear  + '-' + formattedMonth, formattedYear  + '-' + formattedMonth));                                    
        }      
        options.sort();
        return options;        
    }
    
    public List<SelectOption> getQuarters()
    {
        List<SelectOption> options = new List<SelectOption>();
        String fy;
        if(System.Date.today().month() >= 9 && System.Date.today().month() <= 12) fy = String.valueOf(System.Date.today().year()+1).substring(2,4);
        else fy = String.valueOf(System.Date.today().year()).substring(2,4);        
        
        for(Integer i = 1; i <= 4; i++)
        {
            options.add(new SelectOption('FY' + fy + ' ' + 'Q' + i, 'FY' + fy + ' ' + 'Q' + i));
        }
        
        return options;
    }
    
    public void cargarCombos()
    {    
        List<ID> listaCatalogosId = new List <ID>(); 
        listaCatalogosFiltrada = new List <ID>(); 
        if (a.GC_Cust_Account_Grp_Descr__c == 'Sold-to party')
        {
            for(pricebook2 item : [select id, isActive from pricebook2 where CP_Account_Type__c =: 'Distributor'])
            {
                listaCatalogosId.add(item.id);
            }
        }
        else 
        { 
            if (a.GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
            { 
                for(pricebook2 item : [select id, isActive from pricebook2 where CP_Account_Type__c =: 'PoS'])
                {
                    listaCatalogosId.add(item.id);
                }
            }
            else
            { 
                for(pricebook2 item : [select id, isActive from pricebook2 where CountryRef__r.Name =: currentUser.Country])
                {
                    listaCatalogosId.add(item.id);
                }
            }
        }
        
        for(UserRecordAccess item : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
        {
            if(item.HasReadAccess)
            {
                listaCatalogosFiltrada.add(item.RecordId);
            }
        }
        productos = new List<SelectOption>();
        productosActive = new List<SelectOption>();
        
        /* EDIT NAME */
        for(Product2 p : [SELECT Id, Name, TXT_commercial_name__c FROM Product2 WHERE (Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) and RecordTypeId =: productRecordType) order by NUM_AP_CP_Custom_Order__c, TXT_commercial_name__c asc])
        {       
            SelectOption so = new SelectOption(p.id, p.TXT_commercial_name__c!=null?p.TXT_commercial_name__c:p.Name);
            productos.add(so);
        }   
        
        /* 27/04/2017 CR - new list for only active pricebook entries - CR-00000627 */
        for(Product2 p : [SELECT Id, Name, TXT_commercial_name__c FROM Product2 WHERE (Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada AND isActive = TRUE) and RecordTypeId =: productRecordType) order by NUM_AP_CP_Custom_Order__c, TXT_commercial_name__c asc])
        {       
            SelectOption so = new SelectOption(p.id, p.TXT_commercial_name__c!=null?p.TXT_commercial_name__c:p.Name);
            productosActive.add(so);
        }   
        /* END - 27/04/2017 CR - new list for only active pricebook entries - CR-00000627 */
    }
    
    public static List<Product2> filteredProducts(String accountCategory)
    {    
        List<ID> listaCatalogosId = new List <ID>(); 
        List<ID> listaCatalogosFiltrada = new List <ID>(); 
        if (accountCategory == 'Sold-to party')
        {
            for(pricebook2 item : [select id from pricebook2 where CP_Account_Type__c =: 'Distributor'])
            {
                listaCatalogosId.add(item.id);
            }
        }
        else 
        { 
            if (accountCategory == 'Ship-to party')
            { 
                for(pricebook2 item : [select id from pricebook2 where CP_Account_Type__c =: 'PoS'])
                {
                    listaCatalogosId.add(item.id);
                }
            }
            else
            { 
                User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
                //for(pricebook2 item : [select id from pricebook2])
                for(pricebook2 item : [select id from pricebook2 where CountryRef__r.Name =: currentUser.Country])
                {
                    listaCatalogosId.add(item.id);
                }
            }
        }
        
        for(UserRecordAccess item : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId ])
        {
            if(item.HasReadAccess)
            {
                listaCatalogosFiltrada.add(item.RecordId);
            }
        }
        Id productRecordType = Util.recordType.get('Product2:CPSalesProduct');
        return [SELECT Id, Name, TXT_commercial_name__c FROM Product2 WHERE (Id IN (SELECT Product2Id FROM PriceBookEntry where pricebook2id in :listaCatalogosFiltrada) and RecordTypeId =: productRecordType) order by NUM_AP_CP_Custom_Order__c, TXT_commercial_name__c asc];  
    }
    
    public void newRow()
    {        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        listNewAPL = new List<cActionPlanLines>();
        if(a.GC_Cust_Account_Grp_Descr__c == 'Sold-to party') apl.PICK_Period__c = periodSelected;
        else if(a.GC_Cust_Account_Grp_Descr__c == 'Ship-to party') apl.PICK_Quarter__c = quarterSelected;
        cActionPlanLines cApl = new cActionPlanLines(apl);
        listaPintarAPL.add(cApl);
        mode = 'edit';
    }
    
    public void cancelCustom()
    {              
        while(listaPintarAPL.size()-1 >= 0 && listaPintarAPL[listaPintarAPL.size()-1].actionPlanLine.Id == null && !listaPintarAPL[listaPintarAPL.size()-1].total)
        {
            listaPintarAPL.remove(listaPintarAPL.size() - 1);
        }
        mapProductFamilyAPL.remove('zz');
        
        mode = 'view';   
        isAddMultipleLines = false;
    }
    
    public void deleteActionPlanLines()
    {
        List<Action_Plan_Line__c > deleteActionPlanLine = new List<Action_Plan_Line__c>();
        
        for(cActionPlanLines apl :listaPintarAPL)
        {
            if(apl.selected)
            {
                if(a.GC_Cust_Account_Grp_Descr__c == 'Sold-to party')
                {
                    
                    if((apl.actionPlanLine.NUM_Ordered__c == 0 || apl.actionPlanLine.NUM_Ordered__c == null ||  String.valueOf(apl.actionPlanLine.NUM_Ordered__c) == '') && (apl.actionPlanLine.NUM_Delivered__c == 0 || apl.actionPlanLine.NUM_Delivered__c == null || String.valueOf(apl.actionPlanLine.NUM_Delivered__c) == '') && (apl.actionPlanLine.NUM_Initial_stock__c == 0 || apl.actionPlanLine.NUM_Initial_stock__c == null ||  String.valueOf(apl.actionPlanLine.NUM_Initial_stock__c) == '') && (apl.actionPlanLine.NUM_Final_stock__c == 0 || apl.actionPlanLine.NUM_Final_stock__c == null || String.valueOf(apl.actionPlanLine.NUM_Final_stock__c) == ''))
                    {
                        deleteActionPlanLine.add(apl.actionPlanLine); 
                    }
                    else
                    {
                        try
                        {
                            throw new MyException('something bad happened!');
                        }
                        catch(MyException e)
                        {
                            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Action plan line cannot be deleted. Action plan line data information is not empty');
                            ApexPages.addMessage(myMsg);
                            errorDelete='true';
                            showException = true; 
                        }
                    }
                }
                else if(a.GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
                {
                    if((apl.actionPlanLine.NUM_Initial_stock__c == 0 || apl.actionPlanLine.NUM_Initial_stock__c == null) && (apl.actionPlanLine.NUM_Final_stock__c == 0 || apl.actionPlanLine.NUM_Final_stock__c == null))
                    {
                        deleteActionPlanLine.add(apl.actionPlanLine);
                    }
                    else 
                    {
                        try
                        {
                            throw new MyException('something bad happened!');
                        }
                        catch(MyException e)
                        {
                            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Action plan line cannot be deleted. Action Plan Line data information is not empty');
                            ApexPages.addMessage(myMsg);
                            errorDelete='true';
                            showException = true; 
                        }
                    }
                }  
            }
        }
        try
        {
            delete deleteActionPlanLine;
            getData();
        }
        catch(DMLException e)
        {
            ApexPages.Message myMsg = new  ApexPages.Message(ApexPages.Severity.ERROR,'Action plan line cannot be deleted. Action Plan Line data is not empty');
            ApexPages.addMessage(myMsg);
            errorDelete='true';
            showException = true;
        }       
    }
    
    public void save()
    {
        List<Action_Plan_Line__c> updateActionPlanLine = new List<Action_Plan_Line__c>();
        List<Action_Plan_Line__c> insertActionPlanLine = new List<Action_Plan_Line__c>();
        
        mapProductFamilyAPL = new map<String,list<cActionPlanLines>>();
        isAddMultipleLines = false;
        
        for(cActionPlanLines item:listaPintarAPL)
        {
            if(!item.total)
            {            
                if(mapProductFamilyAPL.get(item.actionPlanLine.LKP_SKU__r.Family) == null)
                {                                      
                    listActionPlanLines = new List<cActionPlanLines>();
                    listActionPlanLines.add(new cActionPlanLines(item.actionPlanLine));
                    mapProductFamilyAPL.put(item.actionPlanLine.LKP_SKU__r.Family, listActionPlanLines);
                }
                else
                {
                    mapProductFamilyAPL.get(item.actionPlanLine.LKP_SKU__r.Family).add(new cActionPlanLines(item.actionPlanLine));
                }
            }
        }      
        
        
        for(List<cActionPlanLines> lista : mapProductFamilyAPL.values())
        {
            for(cActionPlanLines cap : lista)
            {
                if(cap.actionPlanLine.Id != null && cap.total != true) updateActionPlanLine.add(cap.actionPlanLine);
                else if(cap.actionPlanLine.Id == null && cap.total != true)
                {
                    cap.actionPlanLine.LKP_Account__c = accountId;
                    insertActionPlanLine.add(cap.actionPlanLine);                
                }
            }
        }   
        //list of inserts failed because of the existance of apls with the same product & period || quarter
        string failedP='';       
        aplFail= new Map<cActionPlanLines,string>();
        
        for(List<cActionPlanLines> lista : mapProductFamilyAPL.values())
        {                       
            for(cActionPlanLines accEx :lista)
            {
                if(accEx.actionPlanLine.id !=null)
                {
                    for(Action_Plan_line__c fail :insertActionPlanLine)
                    {                            
                        if((accEx.actionPlanLine.LKP_SKU__c==fail.LKP_SKU__c) && ((accEx.actionPlanLine.PICK_Quarter__c==fail.PICK_Quarter__c) ||
                                                                                  (accEx.actionPlanLine.PICK_Period__c==fail.PICK_Period__c)))
                        {
                            Product2 pfail=[Select name from product2 where id=: fail.LKP_SKU__c limit 1];
                            failedP=  failedP + '<br/>'+ String.valueOf(pfail.name);
                        }                            
                    }
                }
            }
        }
        
        try
        {
            update updateActionPlanLine;
            if(insertActionPlanLine.size() > 0 ) insert insertActionPlanLine;
            insertActionPlanLine.clear();
            getData();            
            mode = 'view';
        }
        catch(DMLException e)
        { 
            //La idea es que cuando salte un fallo entra en un nuevo "mode" (fallo) en el cual poder remarcar en rojo las APLs repetidas.
            //Para ello se crea un mapa con las apls y un valor booleano que haga de filtro condicional. El filtro funciona pero no se
            //ha conseguido mostrarlo en la page
            
            getData();            
            mode = 'view';            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Failed in the lines insert. The following products already have lines:'+ failedP);            
            ApexPages.addMessage(myMsg);
            showException = true;           
        }        
    }
    public void Ok()
    {
        getData();
        mode='view';        
    }
    
    public void refresh()
    {        
        if(mode=='edit') mode='view';
        else mode='edit';
    }
    
    public void editAll()
    {
        cargarcombos();
        mode = 'edit';
    }
    
    public PageReference multiLines()
    {
        getData();
        mode = 'Sales';
        String catalogsList='';
        for(String item : listaCatalogosFiltrada)
        {
            catalogslist+=item+'-';
        }
        PageReference newPage = new PageReference('/apex/ActionPlanProductPicker?id=' + accountId + '&mode=' + mode + '&division=' + Util.currentDivision.Id+'&catalogs='+catalogsList);
        newPage.setRedirect(true);
        
        return newPage;       
    }
    
    public Integer getMapSize()
    {
        if(listActionPlanLines.size() != 0)
            return mapProductFamilyAPL.size();
        else return 0;
    } 
    
    //DASHBOARDS    
    @RemoteAction
    public static dataContainer[] surveyResults(String accountId, String productFamily) 
    {
        //Record Type ActionPlanLine
        Id recordTypeAPL = Util.recordType.get('Action_Plan_Line__c:Action_Plan_Line');
        //Category__c
        Account act = [SELECT GC_Cust_Account_Grp_Descr__c FROM Account WHERE Id =: accountId LIMIT 1]; 
        List<dataContainer> surveyResultsList = new List<dataContainer>();
        List<Product2> productsToQuery = filteredProducts(act.GC_Cust_Account_Grp_Descr__c);
        dataContainer[] resultQuery;
        
        //DASHBOARD FOR "PoS"
        if (act.GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
        {
            resultQuery = new dataContainer[5];
            String myString = 'SELECT SUM(FRML_Forecast_Rel_CFY__c) fcfy,  SUM(FRML_Forecast_Rel_PFY__c) fpfy, TXT_Quarter_Group_WF__c quarter FROM Action_Plan_Line__c WHERE LKP_SKU__c IN :productsToQuery AND LKP_Account__c = \'' + accountId + '\' AND RecordTypeId =\''+recordTypeAPL+'\' ';
            if(productFamily != '-None-')
            {
                myString += ' AND LKP_SKU__r.Family= \''+productFamily+'\'';
            }    
            myString += ' GROUP BY TXT_Quarter_Group_WF__c ';
            
            AggregateResult[] ARs =  Database.query(myString);
            
            for(AggregateResult surveyResultItem : ARs)
            {
                Integer pos = Integer.valueOf((String)surveyResultItem.get('quarter'));
                resultQuery[pos] = new dataContainer('Q'+(String)surveyResultItem.get('quarter'), 0, 0, 0, 0, Integer.ValueOf(surveyResultItem.get('fcfy')),Integer.ValueOf(surveyResultItem.get('fpfy')), 0, 0);
            }
            
            if(resultQuery.size() > 1)
            {
                for(Integer i = 1; i < resultQuery.size(); i++)
                {
                    if(resultQuery[i]==null)
                        resultQuery[i] = new dataContainer();
                    
                    if(resultQuery[i].fcfy == null) resultQuery[i].fcfy = 0;   
                    if(resultQuery[i].fpfy == null) resultQuery[i].fpfy = 0;        
                    resultQuery[i].fcfy+= (resultQuery[i-1]==null||resultQuery[i-1].fcfy== null ? 0:resultQuery[i-1].fcfy);
                    resultQuery[i].fpfy+= (resultQuery[i-1]==null||resultQuery[i-1].fpfy== null ? 0:resultQuery[i-1].fpfy);
                }
            }
        }
        
        //DASHBOARD FOR "DISTRIBUTOR" OR "COOP"
        else
        {
            resultQuery = new dataContainer[12];
            String myString = 'SELECT SUM(FRML_Delivered_CFY__c) dcfy, SUM(FRML_Delivered_PFY__c) dcpy, SUM(FRML_POG_Units_CFY__c) pcfy, SUM(FRML_POG_Units_PFY__c) ppfy, SUM(FRML_Forecast_Rel_CFY__c) fcfy, TXT_Period_Month_WF__c period FROM Action_Plan_Line__c WHERE  LKP_SKU__c IN :productsToQuery AND LKP_Account__c = \'' + accountId + '\' AND RecordTypeId =\''+recordTypeAPL+'\' ';
            if(productFamily != '-None-')
            {
                myString += ' AND LKP_SKU__r.Family= \''+productFamily+'\'';
            }    
            myString += ' GROUP BY TXT_Period_Month_WF__c  ';
            
            AggregateResult[] ARs =  Database.query(myString);
            
            for(AggregateResult surveyResultItem : ARs)
            {
                Integer pos = math.mod(Integer.valueOf((String)surveyResultItem.get('period')) + 3, 12);
                resultQuery[pos] = new dataContainer((String)surveyResultItem.get('period'), Integer.ValueOf(surveyResultItem.get('dcfy')), Integer.ValueOf(surveyResultItem.get('dcpy')), Integer.ValueOf(surveyResultItem.get('pcfy')), Integer.ValueOf(surveyResultItem.get('ppfy')), Integer.ValueOf(surveyResultItem.get('fcfy')),0, Integer.ValueOf(surveyResultItem.get('dcfy')), Integer.ValueOf(surveyResultItem.get('dcpy')));
            }
            
            if(resultQuery.size() > 1)
            {
                for(Integer i = 1; i < resultQuery.size(); i++)
                {
                    if(resultQuery[i]==null)
                        resultQuery[i] = new dataContainer();
                    
                    if(resultQuery[i].dcfy == null) resultQuery[i].dcfy = 0;
                    if(resultQuery[i].dpfy== null) resultQuery[i].dpfy = 0;
                    if(resultQuery[i].pcfy == null) resultQuery[i].pcfy = 0;
                    if(resultQuery[i].ppfy == null) resultQuery[i].ppfy = 0;
                    if(resultQuery[i].fcfy == null) resultQuery[i].fcfy = 0;           
                    resultQuery[i].dcfy += (resultQuery[i-1]==null||resultQuery[i-1].dcfy == null ? 0:resultQuery[i-1].dcfy);
                    resultQuery[i].dpfy+= (resultQuery[i-1]==null||resultQuery[i-1].dpfy== null ? 0:resultQuery[i-1].dpfy);
                    resultQuery[i].pcfy += (resultQuery[i-1]==null||resultQuery[i-1].pcfy == null ? 0:resultQuery[i-1].pcfy);
                    resultQuery[i].ppfy += (resultQuery[i-1]==null||resultQuery[i-1].ppfy == null ? 0:resultQuery[i-1].ppfy);
                    resultQuery[i].fcfy+= (resultQuery[i-1]==null||resultQuery[i-1].fcfy== null ? 0:resultQuery[i-1].fcfy);
                }
            }
        }
        return resultQuery ;
    }
    
    public class dataContainer    
    {
        Integer dcfy;
        Integer dpfy;
        Integer pcfy;
        Integer ppfy;
        Integer fcfy;
        Integer fpfy;
        Integer dcfyna;
        Integer dpfyna;
        String period;    
        
        dataContainer()
        {
            
        }
        
        dataContainer(String p_period, Integer p_dcfy, Integer p_dcpy,Integer p_pcfy,Integer p_ppfy, Integer p_fcfy, Integer p_fpfy, Integer p_dcfyna, Integer p_dpfyna)
        {
            dcfy = p_dcfy;
            dpfy = p_dcpy;
            pcfy = p_pcfy;
            ppfy = p_ppfy;
            fcfy = p_fcfy;
            fpfy = p_fpfy;
            dcfyna = p_dcfyna;
            dpfyna = p_dpfyna;
            period = p_period;            
        }      
    }
    
    public class cActionPlanLines
    {
        public Boolean selected {get; set;}
        public Boolean total {get; set;}
        public String name {get; set;}
        public String totalForecast {get; set;}
        public String totalForecastRel {get; set;}
        public String totalInitialStock {get; set;}
        public String totalInitialStockRel {get; set;}
        public String totalFinalStock {get; set;}
        public String totalFinalStockRel {get; set;}
        public String totalPog {get; set;}
        public String totalPogKg {get; set;}
        public String totalOrdered {get; set;}
        public String totalOrderedRel {get; set;}
        public String totalDelivered {get; set;}
        public String totalDeliveredRel {get; set;}
        public Action_Plan_Line__c actionPlanLine {get; set;}
        
        public cActionPlanLines(Action_Plan_Line__c apl)
        {
            selected = false;
            total = false;
            name = '';
            actionPlanLine = apl;            
        }
    }
    
    public class apl
    {
        public String name { get; private set;}
        public Decimal pogCFY { get; private set;}
        public Decimal pogPFY { get; private set;}
        public Decimal pogPFYTD { get; private set;}
        
        public apl(AggregateResult ar)
        {
            name = (String)ar.get('name');
            if((Decimal)ar.get('cfy') == null) pogCFY = 0;
            else pogCFY = (Decimal)ar.get('cfy');
            
            if((Decimal)ar.get('pfy') == null) pogPFY = 0;
            else pogPFY = (Decimal)ar.get('pfy');
            
            if((Decimal)ar.get('pfytd') == null) pogPFYTD = 0;
            else pogPFYTD = (Decimal)ar.get('pfytd');
        }
    }
    
    public String getIsDevice()
    {
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        
        //& some devices use custom headers for the user-agent.
        if (userAgent==null || userAgent.length()==0){
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_OPERAMINI_PHONE_UA');
        }       
        if (userAgent==null || userAgent.length()==0){
            userAgent = ApexPages.currentPage().getHeaders().get('HTTP_X_SKYFIRE_PHONE');
        }
        
        //& replace with custom setting - using (?i) case insensitive mode.     
        String deviceReg = '(?i)(iphone|ipod|ipad|blackberry|android|palm|windows\\s+ce)';
        String desktopReg = '(?i)(windows|linux|os\\s+[x9]|solaris|bsd)';
        String botReg = '(?i)(spider|crawl|slurp|bot)';
        
        Matcher m = Pattern.compile(deviceReg).matcher(userAgent);
        
        return m.find()?'true':'false';             
    }
    
    public List<SelectOption> getFPoptions() 
    {        
        List<SelectOption> options = new List<SelectOption>();        
        List<ID> listaCatalogosId = new List <ID>(); 
        listaCatalogosFiltrada = new List <ID>();
        List<Id> listaProductosAPL = new List<Id>();
        list<Action_Plan_Line__c> listPreviousActualAPL = new List<Action_Plan_Line__c>();
        
        listPreviousActualAPL = [SELECT Id, LKP_SKU__c FROM Action_Plan_Line__c WHERE (FRML_CHK_Is_Current_FY__c = true OR FRML_CHK_Is_Previous_FY__c = true) AND LKP_Account__c =: accountId];
        for(Action_Plan_Line__c apl: listPreviousActualAPL)
        {
            listaProductosAPL.add(apl.LKP_SKU__c);
        }
        
        //Diferent code if the account is "distributor" or "PoS" 
        if (a.GC_Cust_Account_Grp_Descr__c == 'Sold-to party')
        {
            for(pricebook2 item : [select id from pricebook2 where CP_Account_Type__c =: 'Distributor'])
            {
                listaCatalogosId.add(item.id);
            }
        }
        else 
        { 
            if (a.GC_Cust_Account_Grp_Descr__c == 'Ship-to party')
            {   
                for(pricebook2 item : [select id from pricebook2 where CP_Account_Type__c =: 'PoS'])
                {
                    listaCatalogosId.add(item.id);
                }
            }
            else
            {   
                User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
                //for(pricebook2 item : [select id from pricebook2])
                for(pricebook2 item : [select id from pricebook2 where CountryRef__r.Name =: currentUser.Country])
                {
                    listaCatalogosId.add(item.id);
                }
            }
        }
        for(UserRecordAccess item : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE userid=:Userinfo.getUserId() and RecordID IN :listaCatalogosId])
        {
            if(item.HasReadAccess)
                listaCatalogosFiltrada.add(item.RecordId);
        }
        Set<String> listaDesc = new Set<String>();
        for(Product2 p : [SELECT Id, Family FROM Product2 WHERE Family !='' AND Id IN :listaProductosAPL AND Id IN (SELECT Product2Id FROM PriceBookEntry WHERE pricebook2id IN :listaCatalogosFiltrada) order by NUM_AP_CP_Custom_Order__c, TXT_commercial_name__c, Family asc])
        {
            listaDesc.add(p.Family);
        }       
        options.add(new SelectOption('-None-', '-None-'));
        for(String item : listaDesc )
        {
            options.add(new SelectOption(item, item));
        }
        return options; 
    }
    
    public PageReference filterFamily() {
        
        return null;   
    }
    
    public class MyException extends Exception{} 
    
}