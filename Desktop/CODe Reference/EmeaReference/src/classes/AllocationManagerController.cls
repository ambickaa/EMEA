public class AllocationManagerController {
    
    public integer total   {get;set;}
    public integer avalaibleTotal   {get;set;}
    public integer consumedTotal {get;set;}
    public integer allocationTotal {get;set;}
    public List<Allocation__c> allocationList {get;set;}
    public List<PricebookEntry> productList{get;set;}
    public List<AllocationWrapper> allocationWrapperList {get;set;}
    public String productIdentifier{get;set;}
    public List<SelectOption> items {get; set;}
    public boolean renderedBool {get;set;}
    public boolean regionalManagerBool {get;set;}
    private User loggedUser;
   public AllocationManagerController(){

        loggedUser = [select Id, Name,profile.name ,country, TXT_Sales_Org__c, TXT_Division__c from user where id=:Userinfo.getUserId()];
        regionalManagerBool = isRegionalManager();
        
        renderedBool = false;
        allocationList = new List<Allocation__c>();
        allocationWrapperList = new List<AllocationWrapper>();
        productList = new List<PricebookEntry>();
        initializeItems();

        
        
    }
    //comrpobamos si es regionalManager
    private Boolean isRegionalManager(){
        
        String profileName= loggedUser.profile.name;
        profileName = profileName.toLowerCase();
        return profileName.contains('regional manager');
        
    }
    
    
    //cargamos la lista inicial para la tabla 
    public void loadList(){
        initializeAllocationWrapper();
        if(allocationWrapperList.size()>0){
            renderedBool  = true;
            calculateTotals();
        }else {
            renderedBool = false;
        }
    }
    //calcula los totales de cada columna
    public void calculateTotals(){
        avalaibleTotal = avalaibleTotalizer();
        consumedTotal = consumedTotalizer();
        allocationTotal = allocationUnitsTotalizer();
        
    }
    
    
    

    public Allocation__c ApplyValueChanges(AllocationWrapper allocationWrapper){
        Allocation__c allocation =allocationWrapper.allocation;
        //evitamos los nulos en el objeto allocation
        //si un campo es nulo lo ponemos a 0
        Decimal change = allocationWrapper.allocationUnitsChange;
        Decimal allocationunits= allocation.NUM_Allocation_Units__c==null?0:allocation.NUM_Allocation_Units__c;
        Decimal allocationFRMLAvailable = allocation.FRML_Avalaible_Units__c==null?0:allocation.FRML_Avalaible_Units__c;
        ////
        Decimal allocationchanged = allocationunits + change;
        
        if((change+allocationFRMLAvailable)>=0){
            allocation.NUM_Allocation_Units__c =allocationchanged;
        }else{
            Util.addWarningMessage(allocation.LKP_User_Name__r.name + System.Label.OE2_0_AllocationAvailableUnits
                                   +allocation.FRML_Avalaible_Units__c+ ' change+avalaible: '+(change+allocation.FRML_Avalaible_Units__c));
        }
        
        
        
        return allocation;
    }
    
    //Guarda los datos que tenemos en la tabla  , si un allocation no existe 
    //lo crea (upsert).
    //Para determinar si un  allocation no existe se mira si el campo available units es nulo (quiere decir que es un allocation fantasma)
    public void saveAllocationChanges(){
        for(AllocationWrapper allocationWrapper: allocationWrapperList){
            Allocation__c allocation;
            if(allocationWrapper.allocationUnitsChange!=0 ){
                allocation = ApplyValueChanges(allocationWrapper);
            }
            allocationList.add(allocationWrapper.allocation);
        }
        List<Database.UpsertResult> results = Database.upsert(allocationList, Allocation__c.Fields.txt_external_id__c, true);
        boolean saved = true;
        Integer i = 0;
        while(saved && i<results.size())
        {
            saved = results[i].isSuccess(); 
            i++;            
        }
        if(saved)
        {
            //recalculamos los totales despues d actualizar los datos
            calculateTotals();
            //vaciamos la lista de allocation anterior
            allocationList.clear(); 
            //recargamos datos para la tabla
            initializeAllocationWrapper(); 
        }
    }
    
    private integer  allocationUnitsTotalizer(){
        integer localTotal = 0;
        for(AllocationWrapper allocationWrapper: allocationWrapperList){
            if(allocationWrapper.allocation.NUM_Allocation_Units__c!=null){
                localTotal =localTotal+(integer)allocationWrapper.allocation.NUM_Allocation_Units__c;
            }
        }
        return localTotal;
    }
    
    private integer consumedTotalizer(){
        integer localTotal = 0;
        for(AllocationWrapper allocationWrapper: allocationWrapperList){
            if(allocationWrapper.allocation.NUM_Consumed_ROLL__c !=null){
                localTotal =localTotal+(integer)allocationWrapper.allocation.NUM_Consumed_ROLL__c;
            }
        }
        return localTotal;
    }
    
    private integer avalaibleTotalizer(){
        integer localTotal = 0;
        for(AllocationWrapper allocationWrapper: allocationWrapperList){
            if(allocationWrapper.allocation.FRML_Avalaible_Units__c != null){
                localTotal =localTotal+(integer)allocationWrapper.allocation.FRML_Avalaible_Units__c;
            }
        }
        return localTotal;
    }
    
    
    public void initializeItems() {
    
        items = new List<SelectOption>();
        ID pricebookId;
       
       Map<String, String> pricebookMap = new Map<String, String>();
        for(SystemSettings__c item : [Select name, value__c from systemSettings__c where name like 'Pricebook%'])
        {
            pricebookMap.put(item.name, item.value__c);
        }

        if(pricebookMap!=null && pricebookMap.get('Pricebook_'+loggedUser.TXT_Sales_Org__c+'_'+loggedUser.TXT_Division__c)!=null)
        {
            pricebookId = pricebookMap.get('Pricebook_'+loggedUser.TXT_Sales_Org__c+'_'+loggedUser.TXT_Division__c);
        }
       
       
        productList = [select product2.id,product2.name from PricebookEntry where pricebook2id = :pricebookId and isactive=true limit 1000];
        Set<SelectOption> itemsWithNoDuplicate= new Set<SelectOption>();
        for(PricebookEntry pricebookEntr: productList){
            try{
                items.add(new SelectOption(pricebookEntr.product2.Id,pricebookEntr.product2.Name));
            }catch(Exception e){
            }
        }
        itemsWithNoDuplicate.addAll(items);
        items.clear();
        items.addAll(itemsWithNoDuplicate);
        
    }
    
    //En este metodo se inicializa la lista de allocation que se mostrara en la tabla  
    //Ademas de crear las allocation "fantasma" que no existen.
    public void initializeAllocationWrapper(){
        Map<Id, AllocationWrapper> ghostAllocationMap =new Map<Id,AllocationWrapper>();
        //usuarios que estan por debajo del usuario que mira la pantalla
        List<User> usersbelowList = [select Id, Name from user  where user.managerId=:UserInfo.getUserId()  or user.manager.managerId=:UserInfo.getUserId()]; 
        allocationWrapperList = new List<AllocationWrapper>();
        for (Allocation__c allocation : [select Id, NUM_Allocation_Units__c,FRML_Avalaible_Units__c,NUM_Consumed_units__c,NUM_Consumed_ROLL__c,
                                         TXT_External_ID__c,LKP_Fiscal_Year__c,LKP_Product__c,LKP_Product__r.Name, LKP_Product__r.Id,
                                         LKP_User_Name__c,LKP_User_Name__r.name,LKP_User_Name__r.Id from Allocation__c  where LKP_Product__r.Id=:productIdentifier and LKP_Fiscal_Year__c = :Util.currentYear.Id and (lkp_user_name__r.managerId=:Userinfo.getUserId() or lkp_user_name__r.manager.managerid=:Userinfo.getUserId()) order by lkp_user_name__r.name])
            
        {
            ghostAllocationMap.put(allocation.LKP_User_Name__r.Id, new AllocationWrapper(0,allocation,allocation.LKP_User_Name__r.Name)); 
        }
        
        
        
        for(User lessPrivilegedUser: usersbelowList){
            if(!ghostAllocationMap.containsKey(lessPrivilegedUser.Id) ){
                String externalId = string.valueOf(lessPrivilegedUser.Id).substring(0,15)+ '-' + productIdentifier.substring(0,15) + '-' + Util.currentYear.name; 
                ghostAllocationMap.put(lessPrivilegedUser.Id,new AllocationWrapper(0,createNewGhostAllocation(externalId,lessPrivilegedUser),lessPrivilegedUser.Name));
                
            }
            
        } 
        allocationWrapperList.addAll(ghostAllocationMap.values());
      allocationWrapperList.sort();
    }
    private Allocation__c createNewGhostAllocation(String externalId,User neededUser){
        
        Allocation__c alloc= new Allocation__c();
        alloc.TXT_External_ID__c = externalId;
        alloc.LKP_User_Name__c = neededUser.Id;
        alloc.ownerId = neededUser.Id; 
        alloc.LKP_Product__c = productIdentifier;
        alloc.NUM_Allocation_Units__c= 0;
        alloc.LKP_Fiscal_Year__c = Util.currentYear.Id;
        
        return alloc;
    }
    
    
    public class AllocationWrapper implements Comparable{
        public Decimal allocationUnitsChange {get;set;}
        public Allocation__c allocation {get;set;}
        public String username{get; set;}
        public AllocationWrapper(integer changevalue, Allocation__c alloc, String user){
            allocationUnitsChange=changeValue;
            allocation=alloc;            
            username = user;
        }
        
        // Compare opportunities based on the opportunity amount.
        public Integer compareTo(Object compareTo) 
        {
            // Cast argument to AllocationWrapper
            AllocationWrapper compareToAlloc = (AllocationWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (username > compareToAlloc.username) 
            {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (username < compareToAlloc.username) 
            {
                // Set return value to a negative value.
                returnValue = -1;
            }           
            return returnValue;       
        }
    }
    
}