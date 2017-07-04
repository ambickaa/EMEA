public class VFC_Delivery {
    public Id casId;
    public case cs;
    public string selectedOption {Get; set;}
    public account acc;
    public String searchStr {get;set;}
    public Boolean pagin{get;set;}
    public Boolean HidePanel{get;set;}

    public Boolean pagindel{get;set;}
    public Boolean pagininv{get;set;}
    public string accntnum{get;set;}
    public string srchStr{get;set;}
    public string srchStrDel{get;set;}
    public string srchStrInv{get;set;}
    public string casenum{get;set;}
    public List<wrapDelivery> deliveryWrapperList {get;set;}
    public List<wrapDelivery> deliveryWrapperListsearch { get; set; }
    public List<Delivery__c> dellst;
   // CustomIterableDel obj1;
    Map<Id, Delivery__c> DeliveryMap = new Map<Id, Delivery__c>();
    // Map<Id, Delivery__c> DelMap1 ;
    public Map<Id, List<DeliveryLineItemWrapper>> DelIdDelItmListMap { get; set; }
    public list<Delivery__c> deliverylist{get;set;}
    public List<Delivery_Line_Item__c> DelItmList { get; set; }
    public static list<DeliveryLineItemWrapper> SelectedDelitem {get;set;}
    public static List<DeliveryLineItemWrapper> DelItemList{get;set;}
    public Set<Id> DeliveryIds = new Set<Id>(); 
    public list<OrderSelection__c> DeliveryCSList{get;set;}
    public List<OrderSelection__c> DeliveryCSListupdate;
    public List<OrderSelection__c> DeliveryCSListupdatePdts;
    public Map<Id,OrderSelection__c> DeliveryCSListDup;
    public list<OrderSelection__c> delvlist= new List<OrderSelection__c>();
    public list<OrderSelection__c> OCSdeliverylist;
    public List<wrapDelivery> deliveryWrapperList1 { get; set; }
    //orders
    public List<Order> orderList;
    public List<OrderItem> OrdItmList;
    public Map<Id, List<OrderPrdtWrapper>> OrdIdOrdItmListMap ;
    public Set<Id> orderIds = new Set<Id>();
    Map<Id, Order> orderMap = new Map<Id, Order>();
    public list<OrderPrdtWrapper> SelectedOrderitem ;
    public static List<OrderPrdtWrapper> ordPdtList;
    //Map<Id, Order> orderMap1 ;
    public List<OrderWrapper> orderWrapperList { get; set; }
    public List<OrderWrapper> orderWrapperListsearch { get; set; }
    public List<Order> ordlst;
    public static List<OrderSelection__c> newLst = new List<OrderSelection__c>();
    public list<OrderSelection__c> OrderCSList;
    public List<OrderSelection__c> OrderCSListupdate;
    public List<OrderSelection__c> OrderCSListupdatePdts;
    public Map<Id,OrderSelection__c> OrderCSListDup;
    public list<OrderSelection__c> OCSlist;
    //CustomIterable obj; 
    public List<OrderWrapper> orderWrapperList1 { get; set; }
    //Invoice
    public list<OrderSelection__c> invlist= new List<OrderSelection__c>();
    public list<OrderSelection__c> InvoiceCSList;
    public List<OrderSelection__c> InvoiceCSListupdate;
    public List<OrderSelection__c> InvoiceCSListupdatePdts;
    public Map<Id,OrderSelection__c> InvoiceCSListDup;
    Map<Id, Invoice__c> InvoiceMap = new Map<Id, Invoice__c>();
    //public Map<Id, Invoice__c> InvMap1 ;
    public Map<Id, List<InvoiceLineItemWrapper>> InvIdInvItmListMap ;
    public static list<invoice__c> invoicelist;
    public List<Invoice_Line_Item__c> InvItmList;
    public static list<InvoiceLineItemWrapper> SelectedInvitem ;
    public static List<InvoiceLineItemWrapper> InvItemList;
    public Set<Id> InvoiceIds = new Set<Id>();
    public List<wrapInvoice> invoiceWrapperList {get;set;}
    public List<wrapInvoice> invoiceWrapperListSearch {get;set;}
    public List<Invoice__c> Invlst;
    public list<OrderSelection__c> OCSInvoicelist;
   // CustomIterableInv obj2;
    public List<wrapInvoice> invoiceWrapperList1{ get; set; }
    //Remove Functionality
    public string conid{get;set;}
    public integer removepos{get;set;}
    public string Ivid{get;set;}
    public integer removeposinv{get;set;}
    public string dlid{get;set;}
    public integer removeposdel{get;set;}
    public string IsConsoleValue;   //Check for Console
    public boolean attachSuccess {get; set;}   //Check for Attachment Sucess
        public VFC_Delivery(ApexPages.StandardController controller) {
            IsConsoleValue = ApexPages.currentPage().getParameters().get('IsConsoleVal');
            casId = ApexPages.currentPage().getParameters().get('id');
            pagin= true;
            pagindel= true;
            pagininv= true;
            if(casId !=null){
                cs = [select id, casenumber, AccountId from Case where Id = :casId];
                casenum= cs.casenumber;
                if(cs.accountid!=null){
                    acc=[select id, AccountNumber,Name from account where Id=:cs.accountid];
                    accntnum=acc.Name ;
                }
            } 
            attachSuccess = false;
            
            system.debug('is consol value------'+IsConsoleValue+'--attachSuccess --'+attachSuccess );
        }
        public void getdelivery(){
           // pagindel = true;
            //srchstrdel='';
            
            /*if(deliveryWrapperListSearch != null){
                deliveryWrapperListSearch.clear();
            }*/
            if(srchStrDel!='' && srchStrDel.length()>5 && srchStrDel.length()<11)
            {
            srchStrDel = '%' + srchStrDel + '%'; 
            if(cs.AccountId!=null){
            
                deliverylist = [SELECT Id,name,GC_Account_Integration_Key__c,ShipTo_Acc_Integration_Key__c,ShipTo_Acc_Integration_Key__r.name,GC_Delivery_Creation_Date__c,GC_Delivery_Date__c,GC_Proposed_GI_Date__c,GC_Actual_GI_Date__c,GC_Order_Number__c,LastModifiedDate,(select id,name,GC_Plant_Desc__c,GC_Dlvry_Integration_Key__c,GC_Item_Code__c,GC_Item_Descr__c,GC_Batch_Number_Text__c,GC_SKULineItem_Quantity__c,GC_Shipping_Point_Descr__c from Delivery_Line_Items2__r) FROM Delivery__c where GC_Account_Integration_Key__c = :cs.AccountId AND name LIKE :srchStrdel Order By LastModifiedDate DESC Limit 500];
                system.debug('+++deliverylist+++'+deliverylist );
                //pagination 
                DelIdDelItmListMap = new Map<Id, List<DeliveryLineItemWrapper>>();
                deliveryWrapperList = new List<wrapDelivery>();
                DelItemList = new List<DeliveryLineItemWrapper>();
                DeliveryLineItemWrapper wrpDel ;
                  if(deliverylist.size()==0)
                {
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found, Please modify or expand your search string'));
                }
                if(deliverylist.size() > 0) {
                    for(Delivery__c mem : deliverylist ){
                        DeliveryIds.add(mem.Id);
                        DeliveryMap.put(mem.Id, mem);
                        if(mem.Delivery_Line_Items2__r.size()== 0){
                            deliveryWrapperList.add(new wrapDelivery(mem, null) ); 
                        }
                    }
                    system.debug('*DeliveryMap*'+DeliveryMap);
                    DelItmList = [SELECT id,name,GC_Plant_Desc__c,GC_Dlvry_Integration_Key__c,GC_Item_Code__c,GC_Item_Descr__c,GC_Batch_Number_Text__c,GC_SKULineItem_Quantity__c,GC_Shipping_Point_Descr__c,GC_Dlvry_Integration_Key__r.name,GC_Dlvry_Integration_Key__r.ShipTo_Acc_Integration_Key__r.name,GC_Dlvry_Integration_Key__r.GC_Delivery_Creation_Date__c, GC_Dlvry_Integration_Key__r.GC_Delivery_Date__c, GC_Dlvry_Integration_Key__r.GC_Proposed_GI_Date__c,GC_Dlvry_Integration_Key__r.GC_Actual_GI_Date__c,GC_Dlvry_Integration_Key__r.GC_Order_Number__c,GC_Dlvry_Integration_Key__r.LastModifiedDate FROM Delivery_Line_Item__c WHERE GC_Dlvry_Integration_Key__c IN : DeliveryIds];
                    system.debug('*DelItmList*'+DelItmList);
                    if(DelItmList!= null){
                        for(Delivery_Line_Item__c delitm : DelItmList ) {
                            if(!DelIdDelItmListMap.containsKey(delitm.GC_Dlvry_Integration_Key__c)){
                                DelIdDelItmListMap.put(delitm.GC_Dlvry_Integration_Key__c, new List<DeliveryLineItemWrapper>());
                            }
                            system.debug('*DelIdDelItmListMap*'+DelIdDelItmListMap);
                            wrpDel = new DeliveryLineItemWrapper(new Delivery_Line_Item__c() );
                            wrpDel.delLineItm = delitm;
                            DelIdDelItmListMap.get(delitm.GC_Dlvry_Integration_Key__c).add(wrpDel);
                            // DeliveryLineItemWrapper wrpDel1 = new DeliveryLineItemWrapper(new Delivery_Line_Item__c() );
                        }
                       /* for(Id DelId : DelIdDelItmListMap.keySet()) {
                            deliveryWrapperList.add(new wrapDelivery(DeliveryMap.get(DelId), DelIdDelItmListMap.get(DelId)));
                        }
                        deliveryWrapperList1= new list<wrapDelivery>();
                        system.debug('****'+deliveryWrapperList);
                       // obj1 = new CustomIterableDel(deliveryWrapperList);
                        next_del(); 
                        system.debug('****'+deliveryWrapperList);*/
                        searchdel();
                        } 
                    } 
                }   
            }
           else
            {
             system.debug('Show Error');
             deliveryWrapperListSearch=null;
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least 6 and maximum 10 digit Delivery number'));
            }
            srchStrDel='';     
    //return null;
        }
        public List<OrderSelection__c > selecteddeliverylineitem(){
            SelectedDelitem= new list<DeliveryLineItemWrapper>();
            // List<Delivery_Line_Item__c> delItmList = new List<Delivery_Line_Item__c>();
            DeliveryCSList= new list <OrderSelection__c>();
            DeliveryCSListDup= new Map<Id,OrderSelection__c>();
            DeliveryCSListupdate= new List<OrderSelection__c>();
            DeliveryCSListupdatePdts = new List<OrderSelection__c>();
            // OrderSelection__c OCS= new OrderSelection__c();
            List<OrderSelection__c> deliveryselection = new List<OrderSelection__c>([select id,name, CaseId_Text__c ,Delivery_Id_Text__c,Delivery_Status_Descr__c,DeliveryItem_Id_Text__c,Delivery_Number_Text__c,Plant_Description_Text__c,SKULine_Item_Nbr__c,OrderRecordId__c,DeliveryRecordId__c,InvoiceRecordId__c, Ship_To_Name_Text__c,Delivery_Creation_Date_header__c,Delivery_Date__c,Proposed_GI_Date__c,Actual_GI_Date__c,Delivery_Order_Number__c,Delivery_Material_Code_text__C,Delivery_Material_Descr__c,Batch_Number_Text__c,SKULineItem_Quantity__c,Shipping_Point_Descr__c,Last_Modified_Del_Date__c from OrderSelection__c where CaseId_Text__c=:casId Order By Last_Modified_Del_Date__c DESC ]);
            system.debug('mmmm'+deliveryselection);
            Map<Id,OrderSelection__c> Delorderselectionmap = new Map<Id,OrderSelection__c>();
            Map<Id,OrderSelection__c> Delorderselectionmap2 = new Map<Id,OrderSelection__c>();
            for(OrderSelection__c o: deliveryselection){
            if(o.Delivery_Id_Text__c!= null && o.Delivery_Id_Text__c !=''){
                Delorderselectionmap.put(o.Delivery_Id_Text__c,o);
                }
                Delorderselectionmap2.put(o.DeliveryItem_Id_Text__c,o);
            }
            system.debug('gggg'+Delorderselectionmap.keyset());
            system.debug('++deliveryWrapperList++'+deliveryWrapperList);
            if(Delorderselectionmap.isEmpty()){
                if(deliveryWrapperListsearch != null){
                    for(wrapDelivery ow: deliveryWrapperListsearch){
                        if(ow.isSelected==true){ 
                            system.debug('++++'+deliveryWrapperListsearch);
                            OrderSelection__c OCS= new OrderSelection__c();
                            //OCS.Delivery_Number_Text__c = OW.del.GC_Delivery_Number_Text__c;
                            OCS.Delivery_Number_Text__c = OW.del.name;
                            OCS.Delivery_Id_Text__c= OW.del.id;
                            OCS.CaseId_Text__c = casId ;
                            // OCS.Delivery_Comments_Text__c= OW.del.Comments_Text__c;
                            //OCS.Tracking_Number__c = OW.del.GC_Tracking_Number__c;
                            //OCS.Delivery_Status_Descr__c= OW.del.GC_Delivery_Status_Descr__c;
                            OCS.DeliveryRecordId__c = OW.del.Id;
                            OCS.Ship_To_Name_Text__c = OW.del.ShipTo_Acc_Integration_Key__r.name;
                            OCS.Delivery_Creation_Date_header__c = OW.del.GC_Delivery_Creation_Date__c;
                            OCS.Delivery_Date__c = OW.del.GC_Delivery_Date__c;
                            OCS.Proposed_GI_Date__c = OW.del.GC_Proposed_GI_Date__c;
                            OCS.Actual_GI_Date__c = OW.del.GC_Actual_GI_Date__c;
                            OCS.Delivery_Order_Number__c = OW.del.GC_Order_Number__c;
                            OCS.Last_Modified_Del_Date__c = OW.del.LastModifiedDate;
                            DeliveryCSList.add(OCS);
                        } 
                        if( ow.DelItemList != null){ 
                            for(DeliveryLineItemWrapper OI: ow.DelItemList ){
                                if(OI.flg==true){
                                    OrderSelection__c OCS2= new OrderSelection__c();
                                    //OCS2.Delivery_Number_Text__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Number_Text__c;
                                    OCS2.Delivery_Number_Text__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.name;
                                    OCS2.SKULine_Item_Nbr__c= OI.delLineItm.name;
                                    OCS2.DeliveryItem_Id_Text__c= OI.delLineItm.id;
                                    // OCS2.Delivery_Item_Comments_Text__c = OI.delLineItm.Comments_Text__c ;
                                    OCS2.CaseId_Text__c = casId;
                                    OCS2.Plant_Description_Text__c= OI.delLineItm.GC_Plant_Desc__c;
                                    OCS2.Delivery_Material_Code_text__c= OI.delLineItm.GC_Item_Code__c;
                                    OCS2.Delivery_Material_Descr__c= OI.delLineItm.GC_Item_Descr__c;
                                    OCS2.Batch_Number_Text__c= OI.delLineItm.GC_Batch_Number_Text__c;
                                    OCS2.SKULineItem_Quantity__c= OI.delLineItm.GC_SKULineItem_Quantity__c;
                                    OCS2.Shipping_Point_Descr__c= OI.delLineItm.GC_Shipping_Point_Descr__c;
                                    OCS2.DeliveryRecordId__c = OI.delLineItm.GC_Dlvry_Integration_Key__c;
                                    //OCS2.Tracking_Number__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Tracking_Number__c;
                                    //OCS2.Delivery_Status_Descr__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Status_Descr__c;
                                    OCS2.Ship_To_Name_Text__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.ShipTo_Acc_Integration_Key__r.name;
                                    OCS2.Delivery_Creation_Date_header__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Creation_Date__c;
                                    OCS2.Delivery_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Date__c;
                                    OCS2.Proposed_GI_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Proposed_GI_Date__c;
                                    OCS2.Actual_GI_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Actual_GI_Date__c;
                                    OCS2.Delivery_Order_Number__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Order_Number__c;
                                    OCS2.Last_Modified_Del_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.LastModifiedDate;
                                    DeliveryCSList.add(OCS2);
                                    SelectedDelitem.add(OI); 
                                }
                            } 
                        } 
                    }
                }
            }
            else if(!Delorderselectionmap.isEmpty()){
                if(deliveryWrapperListSearch != null ){
                    for(wrapDelivery ow: deliveryWrapperListSearch){
                        if(ow.isSelected==true){ 
                            /* if(Delorderselectionmap.containsKey(OW.del.id) ){
                            system.debug('hi2');
                            Delorderselectionmap.get(OW.del.id).Delivery_Comments_Text__c= OW.del.Comments_Text__c;
                            DeliveryCSListupdate.add(Delorderselectionmap.get(OW.del.id));
                            }*/
                            if(Delorderselectionmap.containsKey(OW.del.id))
                            {
                                //OCS1.Delivery_Number_Text__c = OW.del.GC_Delivery_Number_Text__c;
                                Delorderselectionmap.get(OW.del.id).Delivery_Number_Text__c = OW.del.name;
                                Delorderselectionmap.get(OW.del.id).Delivery_Id_Text__c= OW.del.id;
                                Delorderselectionmap.get(OW.del.id).CaseId_Text__c = casId ;
                                Delorderselectionmap.get(OW.del.id).DeliveryRecordId__c = OW.del.Id;
                                Delorderselectionmap.get(OW.del.id).Ship_To_Name_Text__c = OW.del.ShipTo_Acc_Integration_Key__r.name;
                                Delorderselectionmap.get(OW.del.id).Delivery_Creation_Date_header__c = OW.del.GC_Delivery_Creation_Date__c;
                                Delorderselectionmap.get(OW.del.id).Delivery_Date__c = OW.del.GC_Delivery_Date__c;
                                Delorderselectionmap.get(OW.del.id).Proposed_GI_Date__c = OW.del.GC_Proposed_GI_Date__c;
                                Delorderselectionmap.get(OW.del.id).Actual_GI_Date__c = OW.del.GC_Actual_GI_Date__c;
                                Delorderselectionmap.get(OW.del.id).Delivery_Order_Number__c = OW.del.GC_Order_Number__c;
                                Delorderselectionmap.get(OW.del.id).Last_Modified_Del_Date__c = OW.del.LastModifiedDate;
                                DeliveryCSListupdate.add(Delorderselectionmap.get(OW.del.id));
                                
                            }
                            // else if(!Delorderselectionmap.containsKey(OW.del.id) )
                            else if(!Delorderselectionmap.containsKey(OW.del.id) ){
                                OrderSelection__c OCS1= new OrderSelection__c();
                                //OCS1.Delivery_Number_Text__c = OW.del.GC_Delivery_Number_Text__c;
                                OCS1.Delivery_Number_Text__c = OW.del.name;
                                OCS1.Delivery_Id_Text__c= OW.del.id;
                                OCS1.CaseId_Text__c = casId ;
                                // OCS1.Delivery_Comments_Text__c= OW.del.Comments_Text__c;
                                //OCS1.Tracking_Number__c = OW.del.GC_Tracking_Number__c;
                                //OCS1.Delivery_Status_Descr__c= OW.del.GC_Delivery_Status_Descr__c;
                                OCS1.DeliveryRecordId__c = OW.del.Id;
                                OCS1.Ship_To_Name_Text__c = OW.del.ShipTo_Acc_Integration_Key__r.name;
                                OCS1.Delivery_Creation_Date_header__c = OW.del.GC_Delivery_Creation_Date__c;
                                OCS1.Delivery_Date__c = OW.del.GC_Delivery_Date__c;
                                OCS1.Proposed_GI_Date__c = OW.del.GC_Proposed_GI_Date__c;
                                OCS1.Actual_GI_Date__c = OW.del.GC_Actual_GI_Date__c;
                                OCS1.Delivery_Order_Number__c = OW.del.GC_Order_Number__c;
                                OCS1.Last_Modified_Del_Date__c = OW.del.LastModifiedDate;
                                DeliveryCSList.add(OCS1);
                            }
                        }
                        if(ow.DelItemList!= null){
                            for(DeliveryLineItemWrapper OI: ow.DelItemList ){
                                if(OI.flg==true){
                                    if(Delorderselectionmap2.containsKey(OI.delLineItm.id) ){
                                        //Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Item_Comments_Text__c= OI.delLineItm.Comments_Text__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Number_Text__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.name;
                                        Delorderselectionmap2.get(OI.delLineItm.id).SKULine_Item_Nbr__c= OI.delLineItm .name;
                                        Delorderselectionmap2.get(OI.delLineItm.id).DeliveryItem_Id_Text__c= OI.delLineItm.id;
                                        // OCS2.Delivery_Item_Comments_Text__c = OI.delLineItm.Comments_Text__c ;
                                        Delorderselectionmap2.get(OI.delLineItm.id).DeliveryRecordId__c = OI.delLineItm.GC_Dlvry_Integration_Key__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).CaseId_Text__c = casId;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Plant_Description_Text__c= OI.delLineItm.GC_Plant_Desc__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Material_Code_text__c= OI.delLineItm.GC_Item_Code__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Material_Descr__c= OI.delLineItm.GC_Item_Descr__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Batch_Number_Text__c= OI.delLineItm.GC_Batch_Number_Text__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).SKULineItem_Quantity__c= OI.delLineItm.GC_SKULineItem_Quantity__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Shipping_Point_Descr__c= OI.delLineItm.GC_Shipping_Point_Descr__c;
                                        //OCS2.Tracking_Number__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Tracking_Number__c;
                                        //OCS2.Delivery_Status_Descr__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Status_Descr__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Ship_To_Name_Text__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.ShipTo_Acc_Integration_Key__r.name;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Creation_Date_header__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Creation_Date__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Date__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Proposed_GI_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Proposed_GI_Date__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Actual_GI_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Actual_GI_Date__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Delivery_Order_Number__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Order_Number__c;
                                        Delorderselectionmap2.get(OI.delLineItm.id).Last_Modified_Del_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.LastModifiedDate;
                                        DeliveryCSListupdatePdts.add(Delorderselectionmap2.get(OI.delLineItm.id));
                                        //system.debug('***DeliveryCSListupdatePdts'+DeliveryCSListupdatePdts);
                                    }
                                    else if(!Delorderselectionmap2.containsKey(OI.delLineItm.id) ){
                                        OrderSelection__c OCS2= new OrderSelection__c();
                                        //OCS2.Delivery_Number_Text__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Number_Text__c;
                                        OCS2.Delivery_Number_Text__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.name;
                                        OCS2.SKULine_Item_Nbr__c= OI.delLineItm .name;
                                        OCS2.DeliveryItem_Id_Text__c= OI.delLineItm.id;
                                        // OCS2.Delivery_Item_Comments_Text__c = OI.delLineItm.Comments_Text__c ;
                                        OCS2.DeliveryRecordId__c = OI.delLineItm.GC_Dlvry_Integration_Key__c;
                                        OCS2.CaseId_Text__c = casId;
                                        OCS2.Plant_Description_Text__c= OI.delLineItm.GC_Plant_Desc__c;
                                        OCS2.Delivery_Material_Code_text__c= OI.delLineItm.GC_Item_Code__c;
                                        OCS2.Delivery_Material_Descr__c= OI.delLineItm.GC_Item_Descr__c;
                                        OCS2.Batch_Number_Text__c= OI.delLineItm.GC_Batch_Number_Text__c;
                                        OCS2.SKULineItem_Quantity__c= OI.delLineItm.GC_SKULineItem_Quantity__c;
                                        OCS2.Shipping_Point_Descr__c= OI.delLineItm.GC_Shipping_Point_Descr__c;
                                        //OCS2.Tracking_Number__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Tracking_Number__c;
                                        //OCS2.Delivery_Status_Descr__c= OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Status_Descr__c;
                                        OCS2.Ship_To_Name_Text__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.ShipTo_Acc_Integration_Key__r.name;
                                        OCS2.Delivery_Creation_Date_header__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Creation_Date__c;
                                        OCS2.Delivery_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Delivery_Date__c;
                                        OCS2.Proposed_GI_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Proposed_GI_Date__c;
                                        OCS2.Actual_GI_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Actual_GI_Date__c;
                                        OCS2.Delivery_Order_Number__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.GC_Order_Number__c;
                                        OCS2.Last_Modified_Del_Date__c = OI.delLineItm.GC_Dlvry_Integration_Key__r.LastModifiedDate;
                                        DeliveryCSList.add(OCS2);
                                        SelectedDelitem.add(OI);
                                    } 
                                } 
                            }
                        }
                    }
                }
            }
            insert DeliveryCSList;
            update DeliveryCSListupdate;
            update DeliveryCSListupdatePdts;
            DeliveryCSListupdate.addAll(DeliveryCSListupdatePdts);     
            DeliveryCSList.addAll(DeliveryCSListupdate);
            return DeliveryCSList;
        }
       /* public Boolean hasNext_del {
            get 
            { 
                return obj1.hasNext(); 
            }
            set;
        }
        public Boolean hasPrevious_del{
            get 
            {
                return obj1.hasPrevious();
            }
            set;
        } 
        public void next_del() 
        { 
            deliveryWrapperList1 = obj1.next();
        }
        public void previous_del() 
        {
            deliveryWrapperList1 = obj1.previous();
        } */
        
        public void search(){
            system.debug('ordlst .....' );
            orderWrapperListsearch = new List<OrderWrapper>();
            //pagin = false;
            srchStr = '%' + srchStr + '%'; 
            ordlst = [SELECT Id, OrderNumber,GC_Integration_Key__c,TotalAmount,fGC_Total_Amount__c,GC_Ship_To_Party_Text__c,GC_Ship_To_Party_Descr__c,PONumber,GC_Document_Type_Descr__c,GC_Currency_Description__c,LastModifiedDate,
            (select Id,GC_Quantity__c,orderid,Description,UnitPrice,fGC_Unit_Price__c,PricebookEntry.ProductCode,GC_Sales_UoM_Text__c,OrderItemNumber,GC_SalesOrder_Item_Nbr__c from OrderItems) FROM Order where  AccountId = :cs.AccountId And GC_Integration_Key__c LIKE :srchStr Order By LastModifiedDate Desc Limit 500];
            system.debug('ordlst .....'+ordlst );
            if( ordlst.size()>0){
                for(Order o: ordlst ){ 
                    orderWrapperListsearch.add(new orderWrapper(o,OrdIdOrdItmListMap.get(o.Id)));
                }          
                
               // orderWrapperList1.clear();
                system.debug('orderWrapperListsearch ...'+orderWrapperListsearch );
                system.debug('orderWrapperList1...'+orderWrapperList1);
            }
         
        } 
        public void searchdel(){ 
            deliveryWrapperListSearch = new List<wrapdelivery>();
            //pagindel = false;
            srchStrdel = '%' + srchStrdel + '%'; 
            dellst =[ select Id,name,GC_Account_Integration_Key__c, ShipTo_Acc_Integration_Key__c,ShipTo_Acc_Integration_Key__r.name,GC_Delivery_Creation_Date__c,GC_Delivery_Date__c,GC_Proposed_GI_Date__c,GC_Actual_GI_Date__c,GC_Order_Number__c,LastModifiedDate,(select id,name,GC_Plant_Desc__c,GC_Dlvry_Integration_Key__c,GC_Item_Code__c,GC_Item_Descr__c,GC_Batch_Number_Text__c,GC_SKULineItem_Quantity__c,GC_Shipping_Point_Descr__c from Delivery_Line_Items2__r) FROM Delivery__c where name LIKE :srchStrdel AND GC_Account_Integration_Key__c = :cs.AccountId Order By LastModifiedDate DESC Limit 500];
            system.debug('dellst .....'+dellst );
            if( dellst.size()>0){
                for(Delivery__c d: dellst ){ 
                    deliveryWrapperListSearch.add(new wrapdelivery(d,DelIdDelItmListMap.get(d.Id)));
                }
               // deliveryWrapperList1.clear();
                system.debug('deliveryWrapperListSearch...'+deliveryWrapperListSearch);
            }
        } 
        public void searchinv(){ 
            invoiceWrapperListSearch = new List<wrapInvoice>();
           // pagininv = false;
            srchStrinv = '%' + srchStrinv + '%'; 
            invlst =[ SELECT id,Name,GC_Invoice_Status_descr__c ,GC_Invoice_Due_Date__c,GC_Total_Inv_Amount_Nbr__c,GC_Invoice_Creation_Date__c ,GC_Currency_Desc__c,LastModifiedDate,(select id,Name,GC_Item_Descr__c,GC_Quantity__c,GC_Net_Value_Amount__c ,GC_Invoice_Integration_Key__c,GC_UOM_Line_Item_Descr__c,GC_Item_Code__c from Invoice_Line_Items2__r ) FROM Invoice__c where name LIKE :srchStrinv and GC_Account_Integration_Key__c =:cs.AccountId Order BY LastModifiedDate DESC Limit 500];
            system.debug('invlst .....'+invlst );
            if( invlst.size()>0){
            for(Invoice__c i: invlst ){ 
                invoiceWrapperListSearch.add(new wrapinvoice(i,InvIdInvItmListMap.get(i.Id)));
            }
           // invoiceWrapperList1.clear();
            system.debug('invoiceWrapperListSearch...'+invoiceWrapperListSearch);
            }
        } 
        public PageReference Attach() { 
            
            if(orderWrapperListsearch!=null)
            { 
                newLst = selectedorderlineitem();
            }
            if(deliveryWrapperListSearch!=null)
            {
                delvlist=selecteddeliverylineitem();
            } 
            if(invoiceWrapperListSearch!=null)
            { 
                invlist=selectedInvoicelineitem();
            }
            /* if( delvlist.size() >10 || invlist.size() >10 || newLst.size() >10){
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Number of selected records are more than 10'));
            }
            else{ */
             attachSuccess = true; 
        PageReference pageRef = new PageReference('/'+casId);
        pageRef.setRedirect(false);
         
         if(IsConsoleValue=='1')
        return null; 
        else
        return pageref; 
        //} 
        // return null;
        }   
        public PageReference getorders(){
            /*pagin = true;
           // srchstr='';
            
            if(OrderWrapperListsearch!= null){
                OrderWrapperListsearch.clear();
            }*/
            
            System.debug('SearchStringnew' + srchStr.length());
            if(srchStr!='' && srchStr.length()>5 && srchStr.length()<11)
            {
            srchStr = '%' + srchStr + '%'; 
            System.debug('SearchString' + srchStr + srchStr.length());
                if(cs.AccountId!=null){
                    orderList = [SELECT Id, OrderNumber,GC_Integration_Key__c,PoNumber,GC_Document_Type_Descr__c,TotalAmount,fGC_Total_Amount__c,GC_Ship_To_Party_Text__c,GC_Ship_To_Party_Descr__c,GC_Currency_Description__c,LastModifiedDate,(select id from OrderItems) FROM Order where AccountId = :cs.AccountId and GC_Integration_Key__c LIKE :srchStr Order By LastModifiedDate Limit 500];
                    system.debug('+++orderList+++'+orderList );
                    //orderMap1 = new Map<Id, Order>([SELECT Id, OrderNumber,GC_Integration_Key__c,TotalAmount,GC_Ship_To_Party_Text__c,GC_Ship_To_Party_Descr__c,PoNumber,GC_Document_Type_Descr__c FROM Order ]);
                    //pagination 
                    OrdIdOrdItmListMap = new Map<Id, List<OrderPrdtWrapper>>();
                    OrderWrapperList = new List<OrderWrapper>();
                    ordPdtList = new List<OrderPrdtWrapper>();
                    OrderPrdtWrapper wrpObj ;
                    if(orderList.size()==0)
                {
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found, Please modify or expand your search string'));
                }
                    
                    if(orderList.size() > 0) {
                        for(Order mem : orderList ){
                            orderIds.add(mem.Id);
                            orderMap.put(mem.Id, mem);
                            if(mem.OrderItems.size()== 0){
                                orderWrapperList.add(new orderWrapper(mem, null) );
                            }
                        }
                        system.debug('*orderMap*'+orderMap);
                        OrdItmList = [SELECT Id,GC_Quantity__c,orderid,PricebookEntry.ProductCode,Description,UnitPrice,fGC_Unit_Price__c,GC_Sales_UoM_Text__c,OrderItemNumber,GC_SalesOrder_Item_Nbr__c,Order.OrderNumber,Order.GC_Ship_To_Party_Text__c,Order.GC_Ship_To_Party_Descr__c,Order.fGC_Total_Amount__c,Order.PoNumber,Order.GC_Document_Type_Descr__c,order.GC_Integration_Key__c,order.GC_Currency_Description__c,Order.LastModifiedDate FROM OrderItem WHERE OrderId IN : orderIds ORDER BY GC_SalesOrder_Item_Nbr__c ASC];
                        system.debug('*OrdItmList*'+OrdItmList);
                        if(OrdItmList!= null){
                            for(OrderItem orditm : OrdItmList ) {
                                if(!OrdIdOrdItmListMap.containsKey(orditm.orderid)){
                                    OrdIdOrdItmListMap.put(orditm.orderid, new List<OrderPrdtWrapper>());
                                }
                                system.debug('*OrdIdOrdItmListMap*'+OrdIdOrdItmListMap);
                                wrpObj = new OrderPrdtWrapper(new OrderItem() );
                                wrpObj.ordLineItm = orditm;
                                OrdIdOrdItmListMap.get(orditm.orderid).add(wrpObj);
                                system.debug('*OrdIdOrdItmListMap1*'+OrdIdOrdItmListMap);
                                // OrderPrdtWrapper wrpObj1 = new OrderPrdtWrapper(new OrderItem() );
                                system.debug('*OrdIdOrdItmListMap.keySet*'+OrdIdOrdItmListMap.keySet()); 
                            }
                            /*for(Id ordId : OrdIdOrdItmListMap.keySet()) {
                                system.debug('*OrdIdOrdItmListMap.keySet1*'+OrdIdOrdItmListMap.keySet());
                                system.debug('****'+OrdIdOrdItmListMap.get(ordId));
                                orderWrapperList.add( new orderwrapper (orderMap.get(ordId), OrdIdOrdItmListMap.get(ordId)));
                                system.debug('orderWrapperList123 ..'+orderWrapperList );
                            }
                            orderWrapperList1 = new List<OrderWrapper>();
                            system.debug('orderWrapperList1 ..'+orderWrapperList );
                           // obj = new CustomIterable (orderWrapperList);
                            system.debug('orderWrapperList2 ..'+orderWrapperList );
                            next(); 
                            system.debug('orderWrapperList3 ..'+orderWrapperList );*/
                            search();
                            //HidePanel=false;
                        }
                    }
                }
                    
            }
            else
            {
           // HidePanel=true;
             system.debug('Show Error');
             orderWrapperListsearch=null;
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least 6 and maximum 10 digit order number'));
            }
            srchStr='';
                    system.debug('orderWrapperListsearch.'+orderWrapperListsearch);

            system.debug('HidePanelHidePanel'+HidePanel);
            return null;
           
        }
       /* public Boolean hasNext {
        get 
        { 
            return obj.hasNext();
        }
        set;
        }
        public Boolean hasPrevious {
        get 
        {
            return obj.hasPrevious();
        }
        set;
        }
        public void next() 
        { 
            orderWrapperList1 = obj.next();
            system.debug('orderWrapperList4 ..'+orderWrapperList );
        }
        public void previous() 
        {
            orderWrapperList1 = obj.previous();
        } */
        public List<OrderSelection__c > selectedorderlineitem(){
            system.debug('orderWrapperList******* ..'+orderWrapperList );
            SelectedOrderitem= new list<OrderPrdtWrapper>();
            //List<OrderItem> ordItmList = new List<OrderItem>();
            OrderCSList= new list <OrderSelection__c>();
            OrderCSListDup= new Map<Id,OrderSelection__c>();
            OrderCSListupdate= new List<OrderSelection__c>();
            OrderCSListupdatePdts = new List<OrderSelection__c>();
            // OrderSelection__c OCS= new OrderSelection__c();
            List<OrderSelection__c> orderselection = new List<OrderSelection__c>([select Order_Number_Text__c,OrderId_Text__c,name,PO_Number_Text__c,   Document_Type_Text__c,OrderLine_Item_Id_Text__c,Ship_To_Party_Descr_Text__c,Sales_UoM_Text__c,Ship_To_Party_Text__c,Material_Description_Text__c,Net_Unit_Price_Curncy__c,OrderRecordId__c,DeliveryRecordId__c,InvoiceRecordId__c,Net_Value_Curncy__c,CaseId_Text__c,Order_Currency_Descr__c ,SAP_Item_Line__c,Last_Modified_Date__c from OrderSelection__c where CaseId_Text__c=:casId Order By Last_Modified_Date__c DESC]);
            Map<Id,OrderSelection__c> orderselectionmap = new Map<Id,OrderSelection__c>();
            Map<Id,OrderSelection__c> orderselectionmap2 = new Map<Id,OrderSelection__c>();
            for(OrderSelection__c o: orderselection){
                if(o.OrderId_Text__c!=null && o.OrderId_Text__c!=''){
                orderselectionmap.put(o.OrderId_Text__c,o);
                }
                orderselectionmap2.put(o.OrderLine_Item_Id_Text__c,o);
            }
            system.debug('gggg'+orderselectionmap.keyset());
            if(orderselectionmap.isEmpty()){
                if(orderWrapperListsearch != null){
                    for(orderWrapper ow: orderWrapperListSearch){
                        system.debug('ggggeeeee'+orderWrapperListSearch);
                        if(ow.flg1==true){ 
                            OrderSelection__c OCS= new OrderSelection__c();
                            //OCS.Order_Number_Text__c = OW.ord.ordernumber;
                            OCS.Order_Number_Text__c = OW.ord.GC_Integration_Key__c;
                            OCS.OrderId_Text__c= OW.ord.id;
                            OCS.CaseId_Text__c = casId ;
                            // OCS.Order_Comments_Text__c= OW.ord.Comments_Text__c;
                            OCS.Ship_To_Party_Text__c = OW.ord.GC_Ship_To_Party_Text__c;
                            OCS.Ship_To_Party_Descr_Text__c= OW.ord.GC_Ship_To_Party_Descr__c;
                            OCS.Net_Value_Curncy__c= OW.ord.fGC_Total_Amount__c;
                            OCS.OrderRecordId__c = OW.ord.Id;
                            OCS.PO_Number_Text__c = OW.ord.PoNumber;
                            OCS.Document_Type_Text__c = OW.ord.GC_Document_Type_Descr__c;
                            OCS.Order_Currency_Descr__c = OW.ord.GC_Currency_Description__c;
                            OCS.Last_Modified_Date__c = OW.ord.LastModifiedDate;
                            
                            OrderCSList.add(OCS); 
                        }
                        system.debug('ow.orderItemList ...'+ow.orderItemList );
                        if( ow.orderItemList != null){ 
                            for(OrderPrdtWrapper OI: ow.orderItemList ){
                                if(OI.flg==true){
                                    OrderSelection__c OCS2= new OrderSelection__c(); 
                                    //OCS2.OrderLineItem_Number_Text__c= OI.ordLineItm.OrderItemNumber;
                                    OCS2.OrderLineItem_Number_Text__c= OI.ordLineItm.PricebookEntry.ProductCode;
                                    OCS2.OrderLine_Item_Id_Text__c= OI.ordLineItm.id;
                                    // OCS2.Order_Product_Comments_Text__c= OI.ordLineItm.Comments_Text__c ;
                                    //OCS2.Order_Number_Text__c= OI.ordLineItm.Order.OrderNumber;
                                    OCS2.Order_Number_Text__c= OI.ordLineItm.Order.GC_Integration_Key__c;
                                    OCS2.OrderId_Text__c= OI.ordLineItm.orderid;
                                    OCS2.Quantity_Nbr__c= OI.ordLineItm.GC_Quantity__c;
                                    OCS2.CaseId_Text__c = casId;
                                    OCS2.Material_Description_Text__c= OI.ordLineItm.Description;
                                    OCS2.Net_Unit_Price_Curncy__c= OI.ordLineItm.fGC_Unit_Price__c; 
                                    OCS2.Sales_UoM_Text__c= OI.ordLineItm.GC_Sales_UoM_Text__c ;
                                    OCS2.OrderRecordId__c = OI.ordLineItm.OrderId;
                                    OCS2.SAP_Item_Line__c= OI.ordLineItm.GC_SalesOrder_Item_Nbr__c;
                                    OCS2.Ship_To_Party_Text__c = OI.ordLineItm.Order.GC_Ship_To_Party_Text__c;
                                    OCS2.Ship_To_Party_Descr_Text__c= OI.ordLineItm.Order.GC_Ship_To_Party_Descr__c;
                                    OCS2.Net_Value_Curncy__c= OI.ordLineItm.Order.fGC_Total_Amount__c;
                                    OCS2.PO_Number_Text__c= OI.ordLineItm.Order.PoNumber;
                                    OCS2.Document_Type_Text__c= OI.ordLineItm.Order.GC_Document_Type_Descr__c;
                                    OCS2.Order_Currency_Descr__c = OI.ordLineItm.Order.GC_Currency_Description__c;
                                    OCS2.Last_Modified_Date__c = OI.ordLineItm.Order.LastModifiedDate;
                                    OrderCSList.add(OCS2);
                                    SelectedOrderitem.add(OI); 
                                }
                            } 
                        } 
                    }
                }
            }
            else if(!orderselectionmap.isEmpty()){
                if(orderWrapperListsearch != null){
                
                    for(orderWrapper ow: orderWrapperListsearch){   
                        system.debug('*****'+ow);
                        system.debug('*****'+ow.orderItemList);
                        if(ow.flg1==true){ 
                            if(orderselectionmap.containsKey(OW.ord.id) ){
                                orderselectionmap.get(OW.ord.id).Order_Number_Text__c = OW.ord.GC_Integration_Key__c;
                                orderselectionmap.get(OW.ord.id).OrderId_Text__c= OW.ord.id;
                                orderselectionmap.get(OW.ord.id).CaseId_Text__c = casId ;
                                orderselectionmap.get(OW.ord.id).Ship_To_Party_Text__c = OW.ord.GC_Ship_To_Party_Text__c;
                                orderselectionmap.get(OW.ord.id).Ship_To_Party_Descr_Text__c= OW.ord.GC_Ship_To_Party_Descr__c;
                                orderselectionmap.get(OW.ord.id).Net_Value_Curncy__c= OW.ord.fGC_Total_Amount__c;
                                orderselectionmap.get(OW.ord.id).OrderRecordId__c = OW.ord.Id;
                                orderselectionmap.get(OW.ord.id).PO_Number_Text__c = OW.ord.PoNumber;
                                orderselectionmap.get(OW.ord.id).Document_Type_Text__c = OW.ord.GC_Document_Type_Descr__c;
                                orderselectionmap.get(OW.ord.id).Order_Currency_Descr__c = OW.ord.GC_Currency_Description__c;
                                orderselectionmap.get(OW.ord.id).Last_Modified_Date__c = OW.ord.LastModifiedDate;
                                OrderCSListupdate.add(orderselectionmap.get(OW.ord.id));
                            }
                            // else if(!orderselectionmap.containsKey(OW.ord.id) )
                            else if(!orderselectionmap.containsKey(OW.ord.id) ){
                                OrderSelection__c OCS1= new OrderSelection__c();
                                //OCS1.Order_Number_Text__c = OW.ord.ordernumber;
                                OCS1.Order_Number_Text__c = OW.ord.GC_Integration_Key__c;
                                OCS1.OrderId_Text__c= OW.ord.id;
                                OCS1.CaseId_Text__c = casId ;
                                // OCS1.Order_Comments_Text__c= OW.ord.Comments_Text__c;
                                OCS1.Ship_To_Party_Text__c = OW.ord.GC_Ship_To_Party_Text__c;
                                OCS1.Ship_To_Party_Descr_Text__c= OW.ord.GC_Ship_To_Party_Descr__c;
                                OCS1.Net_Value_Curncy__c= OW.ord.fGC_Total_Amount__c;
                                OCS1.OrderRecordId__c = OW.ord.Id;
                                OCS1.PO_Number_Text__c = OW.ord.PoNumber;
                                OCS1.Document_Type_Text__c = OW.ord.GC_Document_Type_Descr__c;
                                OCS1.Order_Currency_Descr__c = OW.ord.GC_Currency_Description__c;
                                OCS1.Last_Modified_Date__c = OW.ord.LastModifiedDate;
                                OrderCSList.add(OCS1);
                            }
                        }
                        if( ow.orderItemList!= null){
                            for(OrderPrdtWrapper OI: ow.orderItemList){
                                if(OI.flg==true){
                                if(orderselectionmap2.containsKey(OI.ordLineItm.id) ){
                                //orderselectionmap2.get(OI.ordLineItm.id).Order_Product_Comments_Text__c= OI.ordLineItm.Comments_Text__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).OrderLineItem_Number_Text__c= OI.ordLineItm.PricebookEntry.ProductCode;
                                    orderselectionmap2.get(OI.ordLineItm.id).OrderLine_Item_Id_Text__c= OI.ordLineItm.id;
                                    orderselectionmap2.get(OI.ordLineItm.id).Order_Number_Text__c= OI.ordLineItm.Order.GC_Integration_Key__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).OrderId_Text__c= OI.ordLineItm.orderid;
                                    orderselectionmap2.get(OI.ordLineItm.id).Quantity_Nbr__c= OI.ordLineItm.GC_Quantity__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Material_Description_Text__c= OI.ordLineItm.Description;
                                    orderselectionmap2.get(OI.ordLineItm.id).Net_Unit_Price_Curncy__c= OI.ordLineItm.fGC_Unit_Price__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Sales_UoM_Text__c= OI.ordLineItm.GC_Sales_UoM_Text__c ;
                                    orderselectionmap2.get(OI.ordLineItm.id).OrderRecordId__c = OI.ordLineItm.OrderId;
                                    orderselectionmap2.get(OI.ordLineItm.id).CaseId_Text__c = casId ;
                                    orderselectionmap2.get(OI.ordLineItm.id).SAP_Item_Line__c= OI.ordLineItm.GC_SalesOrder_Item_Nbr__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Ship_To_Party_Text__c = OI.ordLineItm.Order.GC_Ship_To_Party_Text__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Ship_To_Party_Descr_Text__c= OI.ordLineItm.Order.GC_Ship_To_Party_Descr__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Net_Value_Curncy__c= OI.ordLineItm.Order.fGC_Total_Amount__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).PO_Number_Text__c= OI.ordLineItm.Order.PoNumber;
                                    orderselectionmap2.get(OI.ordLineItm.id).Document_Type_Text__c= OI.ordLineItm.Order.GC_Document_Type_Descr__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Order_Currency_Descr__c = OI.ordLineItm.Order.GC_Currency_Description__c;
                                    orderselectionmap2.get(OI.ordLineItm.id).Last_Modified_Date__c = OI.ordLineItm.Order.LastModifiedDate;
                                    OrderCSListupdatePdts.add(orderselectionmap2.get(OI.ordLineItm.id));
                                }
                                // else if(!orderselectionmap2.containsKey(OI.ordLineItm.id) )
                                else if(!orderselectionmap2.containsKey(OI.ordLineItm.id) ){
                                    OrderSelection__c OCS2= new OrderSelection__c(); 
                                    //OCS2.OrderLineItem_Number_Text__c= OI.ordLineItm.OrderItemNumber;
                                    OCS2.OrderLineItem_Number_Text__c= OI.ordLineItm.PricebookEntry.ProductCode;
                                    OCS2.OrderLine_Item_Id_Text__c= OI.ordLineItm.id;
                                    // OCS2.Order_Product_Comments_Text__c= OI.ordLineItm.Comments_Text__c ;
                                    //OCS2.Order_Number_Text__c= OI.ordLineItm.Order.OrderNumber;
                                    OCS2.Order_Number_Text__c= OI.ordLineItm.Order.GC_Integration_Key__c;
                                    OCS2.OrderId_Text__c= OI.ordLineItm.orderid;
                                    OCS2.Quantity_Nbr__c= OI.ordLineItm.GC_Quantity__c;
                                    OCS2.Material_Description_Text__c= OI.ordLineItm.Description;
                                    OCS2.Net_Unit_Price_Curncy__c= OI.ordLineItm.fGC_Unit_Price__c;
                                    OCS2.Sales_UoM_Text__c= OI.ordLineItm.GC_Sales_UoM_Text__c ;
                                    OCS2.OrderRecordId__c = OI.ordLineItm.OrderId;
                                    OCS2.CaseId_Text__c = casId ;
                                    OCS2.SAP_Item_Line__c= OI.ordLineItm.GC_SalesOrder_Item_Nbr__c;
                                    OCS2.Ship_To_Party_Text__c = OI.ordLineItm.Order.GC_Ship_To_Party_Text__c;
                                    OCS2.Ship_To_Party_Descr_Text__c= OI.ordLineItm.Order.GC_Ship_To_Party_Descr__c;
                                    OCS2.Net_Value_Curncy__c= OI.ordLineItm.Order.fGC_Total_Amount__c;
                                    OCS2.PO_Number_Text__c= OI.ordLineItm.Order.PoNumber;
                                    OCS2.Document_Type_Text__c= OI.ordLineItm.Order.GC_Document_Type_Descr__c;
                                    OCS2.Order_Currency_Descr__c = OI.ordLineItm.Order.GC_Currency_Description__c;
                                    OCS2.Last_Modified_Date__c = OI.ordLineItm.Order.LastModifiedDate;
                                    OrderCSList.add(OCS2);
                                    SelectedOrderitem.add(OI); 
                                }
                                }    
                            }
                        }
                    }
                }
            }
        
            insert OrderCSList;
            update OrderCSListupdate;
            update OrderCSListupdatePdts;
            OrderCSListupdate.addAll(OrderCSListupdatePdts);            
            OrderCSList.addAll(OrderCSListupdate);
            return OrderCSList;
        }
        public PageReference getInvoices(){
           /* pagininv = true;
            srchstrinv='';
            if(invoiceWrapperListSearch != null){
                invoiceWrapperListSearch.clear();
            }*/
            if(srchStrinv!='' && srchStrinv.length()>5 && srchStrinv.length()<11)
            {
            srchStrinv = '%' + srchStrinv + '%';
            if(cs.AccountId!=null){
                invoicelist= [SELECT id,Name,GC_Invoice_Status_descr__c ,GC_Invoice_Due_Date__c,GC_Total_Inv_Amount_Nbr__c,GC_Invoice_Creation_Date__c ,GC_Currency_Desc__c,LastModifiedDate,(select id,Name,GC_Item_Descr__c,GC_Quantity__c,GC_Net_Value_Amount__c ,GC_Invoice_Integration_Key__c,GC_UOM_Line_Item_Descr__c,GC_Item_Code__c from Invoice_Line_Items2__r) FROM Invoice__c where Invoice__c.GC_Account_Integration_Key__c =:cs.AccountId AND name LIKE :srchStrinv Order By LastModifiedDate Limit 500];
                system.debug('+++invoicelist+++'+invoicelist );
                //InvMap1= new map<id,Invoice__c>([SELECT Name,GC_Invoice_Status_descr__c,GC_Total_Inv_Amount_Nbr__c,GC_Invoice_Creation_Date__c,GC_Invoice_Due_Date__c FROM Invoice__c]); 
                InvIdInvItmListMap= new map<Id, List<InvoiceLineItemWrapper>>();
                invoiceWrapperList = new List<wrapInvoice>();
                InvItemList = new list<InvoiceLineItemWrapper>();
                InvoiceLineItemWrapper InvWrapObj;
                
                if(invoicelist.size()==0)
                {
                apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No records found, Please modify or expand your search string'));
                }
                
                if(invoicelist.size() > 0) {
                    for(Invoice__c mem : invoicelist ){
                        InvoiceIds.add(mem.Id);
                        InvoiceMap.put(mem.Id, mem);
                        if(mem.Invoice_Line_Items2__r.size()== 0){
                            invoiceWrapperList.add(new wrapInvoice(mem, null));
                        }
                    }
                    system.debug('*InvoiceMap*'+InvoiceMap);
                    InvItmList = [SELECT id,Name,GC_Item_Descr__c,GC_Quantity__c,GC_UOM_Line_Item_Descr__c,GC_Net_Value_Amount__c,GC_Item_Code__c,GC_Invoice_Integration_Key__r.name,GC_Invoice_Integration_Key__c,GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c,GC_Invoice_Integration_Key__r.GC_Total_Inv_Amount_Nbr__c,GC_Invoice_Integration_Key__r.GC_Invoice_Status_Descr__c,GC_Invoice_Integration_Key__r.GC_Invoice_Due_Date__c ,GC_Invoice_Integration_Key__r.GC_Currency_Desc__c,GC_Invoice_Integration_Key__r.LastModifiedDate FROM Invoice_Line_Item__c WHERE GC_Invoice_Integration_Key__c IN : InvoiceIds];
                    system.debug('*InvItmList*'+InvItmList);
                    if(InvItmList != null){
                        for(Invoice_Line_Item__c itm : InvItmList ) {
                            if(!InvIdInvItmListMap.containsKey(itm.GC_Invoice_Integration_Key__c)){
                                InvIdInvItmListMap.put(itm.GC_Invoice_Integration_Key__c, new List<InvoiceLineItemWrapper>());
                            }
                            system.debug('*InvIdInvItmListMap*'+InvIdInvItmListMap);
                            InvWrapObj = new InvoiceLineItemWrapper(new Invoice_Line_Item__c() );
                            InvWrapObj.InvLineItm = itm;
                            InvIdInvItmListMap.get(itm.GC_Invoice_Integration_Key__c).add(InvWrapObj);
                            // InvoiceLineItemWrapper InvWrapObj1 = new InvoiceLineItemWrapper(new Invoice_Line_Item__c() );
                        }
                        /*for(Id InvId : InvIdInvItmListMap.keySet()) {
                            invoiceWrapperList.add(new wrapInvoice(InvoiceMap.get(InvId), InvIdInvItmListMap.get(InvId)));
                        }
                        system.debug('****'+invoiceWrapperList);
                        invoiceWrapperList1 = new List<wrapInvoice>();
                        //obj2 = new CustomIterableInv (invoiceWrapperList);
                        system.debug('invoiceWrapperList...'+invoiceWrapperList);
                        next_inv(); */
                        searchinv();
                        } 
                    }
            
                }
            }
            else
            {
            system.debug('Show Error');
            invoiceWrapperListSearch=null;
            apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter at least 6 and maximum 10 digit Invoice number'));
            
            }
            srchStrinv='';
            return null;
        } 
       /* public Boolean hasNext_inv {
        get 
        { 
            return obj2.hasNext();
        }
        set;
        }
        public Boolean hasPrevious_inv{
        get 
        {
            return obj2.hasPrevious();
        }
        set;
        }
        public void next_inv() 
        { 
            invoiceWrapperList1 = obj2.next();
        }
        public void previous_inv() 
        {
            invoiceWrapperList1 = obj2.previous();
        } */
        public List<OrderSelection__c> selectedInvoicelineitem(){
            system.debug('$$$$');
            SelectedInvitem= new list<InvoiceLineItemWrapper>();
            // List<Invoice_Line_Item__c> InvItmList = new List<Invoice_Line_Item__c>();
            InvoiceCSList= new list <OrderSelection__c>();
            InvoiceCSListDup= new Map<Id,OrderSelection__c>();
            InvoiceCSListupdate= new List<OrderSelection__c>();
            InvoiceCSListupdatePdts = new List<OrderSelection__c>();
            List<OrderSelection__c> orderselectionInv = new List<OrderSelection__c>([select Total_Inv_Amount_Nbr__c,Invoice_Net_Value_Amount__c,Invoice_Creation_Date__c,Invoice_Number_Text__c,Invoice_Status_Descr__c,Invoice_Item_Number__c,InvoiceLineItemId_Text__c,OrderRecordId__c,DeliveryRecordId__c,InvoiceRecordId__c,InvoiceId_Text__c ,Invoice_Due_Date__c,Invoice_Line_Item_Name_Text__c,Invoice_Line_Item_QTY__c,Invoice_Line_Item_Descr__c,UOM_line_item_Text__c,Invoice_Material_Code__c,Last_Modified_Inv_Date__c from OrderSelection__c where CaseId_Text__c=:casId ORDER BY Last_Modified_Inv_Date__c DESC]);
            Map<Id,OrderSelection__c> orderselectionmapInv = new Map<Id,OrderSelection__c>();
            Map<Id,OrderSelection__c> orderselectionmap2Inv = new Map<Id,OrderSelection__c>();
            for(OrderSelection__c o: orderselectionInv){
                //orderselectionmapInv.put(o.InvoiceId_Text__c,o);
                if(o.InvoiceId_Text__c!=null && o.InvoiceId_Text__c!='')
                {
                    orderselectionmapInv.put(o.InvoiceId_Text__c,o);
                }
                orderselectionmap2Inv.put(o.InvoiceLineItemId_Text__c,o);
            }
            system.debug('gggg'+orderselectionmapInv.keyset());
            system.debug('aaaag'+orderselectionmapInv);
            if(orderselectionmapInv.isEmpty()){
                if(invoiceWrapperListsearch != null){
                    for(wrapInvoice ow: invoiceWrapperListsearch){
                        if(ow.isSelected ==true){ 
                            OrderSelection__c OCS= new OrderSelection__c();
                            //OCS.Invoice_Number_Text__c = OW.Inv.GC_Invoice_Number_Text__c;
                            OCS.Invoice_Number_Text__c = OW.Inv.name;
                            OCS.InvoiceId_Text__c= OW.Inv.id;
                            OCS.CaseId_Text__c = casId ;
                            // OCS.Invoice_Comments_Text__c= OW.Inv.Comments_Text__c;
                            OCS.Invoice_Creation_Date__c = OW.Inv.GC_Invoice_Creation_Date__c;
                            OCS.Total_Inv_Amount_Nbr__c= OW.Inv.GC_Total_Inv_Amount_Nbr__c;
                            OCS.Invoice_Status_Descr__c=OW.Inv.GC_Invoice_Status_Descr__c;
                            OCS.InvoiceRecordId__c = OW.Inv.Id;
                            OCS.Invoice_Due_Date__c = OW.Inv.GC_Invoice_Due_Date__c;
                            OCS.Invoice_Currency_Descr__c = OW.Inv.GC_Currency_Desc__c;
                            OCS.Last_Modified_Inv_Date__c = OW.Inv.LastModifiedDate;
                            system.debug('OCS.InvoiceRecordId__c'+OCS.InvoiceRecordId__c);
                            InvoiceCSList.add(OCS); 
                        }
                        system.debug('ow.InvoiceItemList ...'+ow.InvoiceItemList );
                        if( ow.InvoiceItemList != null){ 
                            for(InvoiceLineItemWrapper OI: ow.InvoiceItemList ){
                                if(OI.flg==true){
                                    OrderSelection__c OCS2= new OrderSelection__c(); 
                                    //OCS2.Invoice_Number_Text__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Number_Text__c;
                                    OCS2.Invoice_Number_Text__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.name;
                                    // OCS2.Invoice_Item_Number__c= OI.InvLineItm.GC_Item_Number__c;
                                    OCS2.InvoiceLineItemId_Text__c= OI.InvLineItm.id;
                                    //OCS2.Invoice_LineItem_Comments_Text__c= OI.InvLineItm .Comments_Text__c ;
                                    OCS2.Invoice_Net_Value_Amount__c= OI.InvLineItm.GC_Net_Value_Amount__c;
                                    OCS2.InvoiceRecordId__c = OI.InvLineItm.GC_Invoice_Integration_Key__c;
                                    system.debug('OCS2.InvoiceRecordId__c'+OCS2.InvoiceRecordId__c);
                                    OCS2.CaseId_Text__c = casId;
                                    OCS2.Invoice_Creation_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c;
                                    OCS2.Total_Inv_Amount_Nbr__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Total_Inv_Amount_Nbr__c; 
                                    OCS2.Invoice_Status_Descr__c=OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Status_Descr__c;
                                    OCS2.Invoice_Due_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Due_Date__c;
                                    OCS2.Invoice_Currency_Descr__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Currency_Desc__c;
                                    OCS2.Invoice_Line_Item_Name_Text__c = OI.InvLineItm.Name;
                                    OCS2.Invoice_Line_Item_Descr__c = OI.InvLineItm.GC_Item_Descr__c;
                                    OCS2.Invoice_Line_Item_QTY__c = OI.InvLineItm.GC_Quantity__c;
                                    OCS2.UOM_line_item_Text__c = OI.InvLineItm.GC_UOM_Line_Item_Descr__c;
                                    OCS2.Invoice_Material_Code__c= OI.InvLineItm.GC_Item_Code__c;
                                    OCS2.Last_Modified_Inv_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.LastModifiedDate;
                                    InvoiceCSList.add(OCS2);
                                    SelectedInvitem.add(OI); 
                                }
                            } 
                        } 
                    }
                }
            }
            else if(!orderselectionmapInv.isEmpty()){
                if(invoiceWrapperListsearch != null){ 
                    for(wrapInvoice ow: invoiceWrapperListsearch){
                        if(ow.isSelected==true){ 
                            if(orderselectionmapInv.containsKey(OW.Inv.id) ){
                            //orderselectionmapInv.get(OW.Inv.id).Invoice_Comments_Text__c= OW.Inv.Comments_Text__c;
                            orderselectionmapInv.get(OW.Inv.id).Invoice_Number_Text__c = OW.Inv.name;
                            orderselectionmapInv.get(OW.Inv.id).InvoiceId_Text__c= OW.Inv.id;
                            orderselectionmapInv.get(OW.Inv.id).CaseId_Text__c = casId ;
                            orderselectionmapInv.get(OW.Inv.id).Invoice_Creation_Date__c = OW.Inv.GC_Invoice_Creation_Date__c;
                            orderselectionmapInv.get(OW.Inv.id).Total_Inv_Amount_Nbr__c= OW.Inv.GC_Total_Inv_Amount_Nbr__c;
                            orderselectionmapInv.get(OW.Inv.id).Invoice_Status_Descr__c=OW.Inv.GC_Invoice_Status_Descr__c;
                            orderselectionmapInv.get(OW.Inv.id).InvoiceRecordId__c = OW.Inv.Id;
                            orderselectionmapInv.get(OW.Inv.id).Invoice_Due_Date__c = OW.Inv.GC_Invoice_Due_Date__c;
                            orderselectionmapInv.get(OW.Inv.id).Invoice_Currency_Descr__c = OW.Inv.GC_Currency_Desc__c;
                            orderselectionmapInv.get(OW.Inv.id).Last_Modified_Inv_Date__c = OW.Inv.LastModifiedDate;
                            InvoiceCSListupdate.add(orderselectionmapInv.get(OW.Inv.id));
                            }
                            // else if(!orderselectionmapInv.containsKey(OW.Inv.id) )
                            else if(!orderselectionmapInv.containsKey(OW.Inv.id) ){
                                OrderSelection__c OCS1= new OrderSelection__c();
                                OCS1.Invoice_Number_Text__c = OW.Inv.name;
                                OCS1.InvoiceId_Text__c= OW.Inv.id;
                                OCS1.CaseId_Text__c = casId ;
                                OCS1.Invoice_Creation_Date__c = OW.Inv.GC_Invoice_Creation_Date__c;
                                OCS1.Total_Inv_Amount_Nbr__c= OW.Inv.GC_Total_Inv_Amount_Nbr__c;
                                OCS1.Invoice_Status_Descr__c=OW.Inv.GC_Invoice_Status_Descr__c;
                                OCS1.InvoiceRecordId__c = OW.Inv.Id;
                                OCS1.Invoice_Due_Date__c = OW.Inv.GC_Invoice_Due_Date__c;
                                OCS1.Invoice_Currency_Descr__c = OW.Inv.GC_Currency_Desc__c;
                                OCS1.Last_Modified_Inv_Date__c = OW.Inv.LastModifiedDate;
                                InvoiceCSList.add(OCS1);
                            }
                        }
                        if( ow.InvoiceItemList!= null){
                            for(InvoiceLineItemWrapper OI: ow.InvoiceItemList ){
                                if(OI.flg==true){
                                    if(orderselectionmap2Inv.containsKey(OI.InvLineItm.id) ){
                                    //orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_LineItem_Comments_Text__c= OI.InvLineItm.Comments_Text__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Number_Text__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.name;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).InvoiceLineItemId_Text__c= OI.InvLineItm .id;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Net_Value_Amount__c= OI.InvLineItm .GC_Net_Value_Amount__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).InvoiceRecordId__c = OI.InvLineItm.GC_Invoice_Integration_Key__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).CaseId_Text__c = casId;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Creation_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Total_Inv_Amount_Nbr__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Total_Inv_Amount_Nbr__c;                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Status_Descr__c=OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Status_Descr__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Due_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Due_Date__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Currency_Descr__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Currency_Desc__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Line_Item_Name_Text__c = OI.InvLineItm.Name;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Line_Item_Descr__c = OI.InvLineItm.GC_Item_Descr__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Line_Item_QTY__c = OI.InvLineItm.GC_Quantity__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).UOM_line_item_Text__c = OI.InvLineItm.GC_UOM_Line_Item_Descr__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Invoice_Material_Code__c= OI.InvLineItm.GC_Item_Code__c;
                                        orderselectionmap2Inv.get(OI.InvLineItm.id).Last_Modified_Inv_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.LastModifiedDate;
                                        InvoiceCSListupdatePdts.add(orderselectionmap2Inv.get(OI.InvLineItm .id));
                                        system.debug('***InvoiceCSListupdatePdts'+InvoiceCSListupdatePdts);
                                    }
                                    // else if(!orderselectionmap2Inv.containsKey(OI.InvLineItm.id) )
                                    else if(!orderselectionmap2Inv.containsKey(OI.InvLineItm.id) ){
                                        OrderSelection__c OCS2= new OrderSelection__c(); 
                                        //OCS2.Invoice_Number_Text__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Number_Text__c;
                                        OCS2.Invoice_Number_Text__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.name;
                                        //OCS2.Invoice_Item_Number__c= OI.InvLineItm.GC_Item_Number__c;
                                        OCS2.InvoiceLineItemId_Text__c= OI.InvLineItm .id;
                                        // OCS2.Invoice_LineItem_Comments_Text__c= OI.InvLineItm .Comments_Text__c ;
                                        OCS2.Invoice_Net_Value_Amount__c= OI.InvLineItm .GC_Net_Value_Amount__c;
                                        OCS2.InvoiceRecordId__c = OI.InvLineItm.GC_Invoice_Integration_Key__c;
                                        OCS2.CaseId_Text__c = casId;
                                        OCS2.Invoice_Creation_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Creation_Date__c;
                                        OCS2.Total_Inv_Amount_Nbr__c= OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Total_Inv_Amount_Nbr__c; 
                                        OCS2.Invoice_Status_Descr__c=OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Status_Descr__c;
                                        OCS2.Invoice_Due_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Invoice_Due_Date__c;
                                        OCS2.Invoice_Currency_Descr__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.GC_Currency_Desc__c;
                                        OCS2.Invoice_Line_Item_Name_Text__c = OI.InvLineItm.Name;
                                        OCS2.Invoice_Line_Item_Descr__c = OI.InvLineItm.GC_Item_Descr__c;
                                        OCS2.Invoice_Line_Item_QTY__c = OI.InvLineItm.GC_Quantity__c;
                                        OCS2.UOM_line_item_Text__c = OI.InvLineItm.GC_UOM_Line_Item_Descr__c;
                                        OCS2.Invoice_Material_Code__c= OI.InvLineItm.GC_Item_Code__c;
                                        OCS2.Last_Modified_Inv_Date__c = OI.InvLineItm.GC_Invoice_Integration_Key__r.LastModifiedDate;
                                        InvoiceCSList.add(OCS2);
                                        SelectedInvitem.add(OI); 
                                    }
                                } 
                            }
                        }
                    }
                }
            }
            insert InvoiceCSList;
            update InvoiceCSListupdate;
            update InvoiceCSListupdatePdts;
            InvoiceCSListupdate.addAll(InvoiceCSListupdatePdts);            
            InvoiceCSList.addAll(InvoiceCSListupdate);
            return InvoiceCSList;
        }
        //For VFP_displayorderlineitems 
        public list<OrderSelection__c> getorderselection(){
            if(casId!=null){
                OCSlist=[select Name,Order_Number_Text__c,Ship_To_Party_Descr_Text__c,Ship_To_Party_Text__c,Sales_UoM_Text__c,OrderLine_Item_Id_Text__c,Order_Currency_Descr__c,Material_Description_Text__c,Net_Unit_Price_Curncy__c,Net_Value_Curncy__c,Quantity_Nbr__c,OrderId_Text__c,OrderLineItem_Number_Text__c,OrderRecordId__c,DeliveryRecordId__c,InvoiceRecordId__c,Document_Type_Text__c,PO_Number_Text__c,SAP_Item_Line__c,Last_Modified_Date__c from OrderSelection__c where CaseId_Text__c=: casId and Delivery_Id_Text__c= null and DeliveryItem_Id_Text__c = null and InvoiceId_Text__c=null and InvoiceLineItemId_Text__c= null ORDER BY Last_Modified_Date__c DESC];
            }
            return OCSlist;
        } 
        public list<OrderSelection__c> getdeliveryselection(){
            if(casId!=null){
            OCSdeliverylist=[select Name,Delivery_Number_Text__c,Delivery_Id_Text__c,CaseId_Text__c,Delivery_Status_Descr__c,SKULine_Item_Nbr__c,DeliveryItem_Id_Text__c,Plant_Description_Text__c,OrderRecordId__c,DeliveryRecordId__c,InvoiceRecordId__c,Ship_To_Name_Text__c,Delivery_Creation_Date_header__c,Delivery_Date__c,Proposed_GI_Date__c,Actual_GI_Date__c,Delivery_Order_Number__c,Delivery_Material_Code_text__C,Delivery_Material_Descr__c,Batch_Number_Text__c,SKULineItem_Quantity__c,Shipping_Point_Descr__c,Last_Modified_Del_Date__c from OrderSelection__c where CaseId_Text__c=: casId and OrderId_Text__c= null and OrderLine_Item_Id_Text__c= null and InvoiceId_Text__c=null and InvoiceLineItemId_Text__c= null ORDER BY Last_Modified_Del_Date__c DESC];
            }
            return OCSdeliverylist;
        } 
        public list<OrderSelection__c> getinvoiceselection(){
            if(casId!=null){
            OCSInvoicelist=[select Name,Total_Inv_Amount_Nbr__c,Invoice_Creation_Date__c,UOM_line_item_Text__c,InvoiceId_Text__c,Invoice_Currency_Descr__c,InvoiceLineItemId_Text__c,Invoice_Status_Descr__c,Invoice_Net_Value_Amount__c,Invoice_Number_Text__c,OrderRecordId__c,DeliveryRecordId__c,InvoiceRecordId__c,Invoice_Item_Number__c,Invoice_Due_Date__c,Invoice_Line_Item_Name_Text__c,Invoice_Line_Item_QTY__c,Invoice_Line_Item_Descr__c ,Invoice_Material_Code__c,Last_Modified_Inv_Date__c from OrderSelection__c where CaseId_Text__c=: casId and OrderId_Text__c= null and OrderLine_Item_Id_Text__c= null and Delivery_Id_Text__c=null and DeliveryItem_Id_Text__c= null ORDER BY Last_Modified_Inv_Date__c DESC];
            }
            return OCSInvoicelist;
        }
        public void removecon()
        {
            list<OrderSelection__c> deleteorderlist= new list<OrderSelection__c>();
            if(OCSlist.size()>0)
            {
                for(Integer i=0;i<OCSlist.size();i++)
                {
                    if(OCSlist[i].id==conid)
                    {
                        removepos=i;
                        deleteorderlist.add(OCSlist[i]);
                    }
                }
                OCSlist.remove(removepos);
                delete deleteorderlist;
            }
        }
        public void removeinv()
        {
            list<OrderSelection__c> deleteorderlistinv= new list<OrderSelection__c>();
            if(OCSInvoicelist.size()>0)
            {
                for(Integer i=0;i<OCSInvoicelist.size();i++)
                {
                    if(OCSInvoicelist[i].id==Ivid)
                    {
                        removeposinv=i;
                        deleteorderlistinv.add(OCSInvoicelist[i]);
                    }
                }
                OCSInvoicelist.remove(removeposinv);
                delete deleteorderlistinv;
            }
        }
        public void removedel()
        {
            list<OrderSelection__c> deleteorderlistdel= new list<OrderSelection__c>();
            if(OCSdeliverylist.size()>0)
            {
                for(Integer i=0;i<OCSdeliverylist.size();i++)
                {
                    if(OCSdeliverylist[i].id==dlid)
                    {
                        removeposdel=i;
                        deleteorderlistdel.add(OCSdeliverylist[i]);
                    }
                }
                OCSdeliverylist.remove(removeposdel);
                delete deleteorderlistdel;
            }
        }
       public void buttonvalue()
        {
            HidePanel=true;
        } 
    }