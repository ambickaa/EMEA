public with sharing class listComplaintProductController {
    
    Public listComplaintProductController(case controller){}
    Public id caseId{get;set;}
    Public List<Complaint_Products__c> listaProductos{get;set;}
    Public List<Complaint_Products__c> newlistaProductos{get;set;}
    Public List<cProduct> listcProducts{get;set;}    

    public List<SelectOption> AvailableUnits{get; set;}


    public Set<SelectOption> listAvailableProductsSet{get; set;}
    public List<SelectOption> listAvailableProducts{get; set;}
    public Map<String, Set<String>> mapBatches{get; set;}
    public list<SelectOption> batchsForProds1{get;set;}
    public list<SelectOption> batchsForProds2{get;set;}
    public list<SelectOption> batchsForProds3{get;set;}
    public list<SelectOption> batchsForProds4{get;set;}
    public List<Delivery_Line_Item__c> listDeliveryLineItem{get;set;} 
    public String mapBatchesJSON {get{return JSON.serialize(mapBatches);}}
    public string mode{get;set;}    
    
    Public listComplaintProductController(ApexPages.StandardController stdController)
    {
        caseId = ApexPages.currentPage().getParameters().get('Id');
        case ComplaintProduct = [select LKP_Direct_Customer_Name__c from case where id =: caseId];
        listDeliveryLineItem = new List<Delivery_Line_Item__c>();
        listaProductos = new List<Complaint_Products__c>();
        newlistaProductos = new list<Complaint_Products__c>();
        listcProducts=new List<cProduct>();
        for(Complaint_Products__c item :[select id, name, PICK_Complained_Qty_UOM__c, NUM_BAGS__c, LKP_Product__c, LKP_Product__r.ProductSAPCode__c,  PCK_Process__c, NUM_Number_of_units_under_complaint__c, NUM_Complaint_quantity__c, NUM_Affected_Acres_ha__c, TXT_Planting_Density__c, TXT_Quantify_problem__c, TXT_Batch_Name__c,  LKP_Product_Variety__c, NUM_Quantity_for_replacement__c from Complaint_Products__c where LKP_CASE__c=:caseId])
        {
           
            listcProducts.add(new cProduct(item));
        }
 
        Set<String> listaProdDel = new Set<String>();
        
        Integer previousYear = Integer.valueOf(Util.currentYear.name) -1;
        
        
        listDeliveryLineItem=[Select id, GC_Item_Code__c, GC_Item_Descr__c, GC_Batch_Number_Text__c, GC_Dlvry_Integration_Key__r.GC_Delivery_Date__c from Delivery_Line_Item__c where GC_Dlvry_Integration_Key__r.GC_Account_Integration_Key__c = :ComplaintProduct.LKP_Direct_Customer_Name__c AND GC_Batch_Number_Text__c !=''];
        
        
        for(Delivery_Line_Item__c item : listDeliveryLineItem)
        {
            if (item.GC_Dlvry_Integration_Key__r.GC_Delivery_Date__c.year() >= previousYear)
            {
                    listaProdDel.add(item.GC_Item_Code__c);
            }       
        }

        map<String, ID> mapProducts = new map <String, ID>();
        batchsForProds1 =new list<SelectOption>();       
        batchsForProds2 =new list<SelectOption>();       
        batchsForProds3 =new list<SelectOption>();
        batchsForProds4 =new list<SelectOption>();
        for(Product2 prod : [select id, ProductSAPCode__c from product2 where ProductSAPCode__c in :listaProdDel])
        {

                mapProducts.put(prod.ProductSAPCode__c, prod.id);

            for(Delivery_Line_Item__c batch:listDeliveryLineItem)
            {
                if(prod.ProductSAPCode__c==batch.GC_Item_Code__c)
                {
                    
                    if(batch.GC_Batch_Number_Text__c!=null)
                    {
                        if (batchsForProds1.size() < 1000)
                        {
                            batchsForProds1.add(new selectOption(batch.GC_Batch_Number_Text__c,batch.GC_Batch_Number_Text__c));        
                        }
                        else if ( batchsForProds2.size() < 1000 )
                        {
                            batchsForProds2.add(new selectOption(batch.GC_Batch_Number_Text__c,batch.GC_Batch_Number_Text__c));        
                        }
                        else if ( batchsForProds3.size() < 1000 )
                        {
                            batchsForProds3.add(new selectOption(batch.GC_Batch_Number_Text__c,batch.GC_Batch_Number_Text__c));        
                        }
                        else if ( batchsForProds4.size() < 1000 )
                        {
                            batchsForProds4.add(new selectOption(batch.GC_Batch_Number_Text__c,batch.GC_Batch_Number_Text__c));        
                        }
                    }
                }
            }
        }
        
        listAvailableProductsSet = new Set<SelectOption>();
        mapBatches = new Map <String, Set<String>>();
        
        for(Delivery_Line_Item__c dli : listDeliveryLineItem)
        {
            if(mapProducts.get(dli.GC_Item_Code__c)!=null && mapBatches.containsKey(mapProducts.get(dli.GC_Item_Code__c)))
            {
                mapBatches.get(mapProducts.get(dli.GC_Item_Code__c)).add(dli.GC_Batch_Number_Text__c);
            }
             else if (mapProducts.get(dli.GC_Item_Code__c)!=null)
            {
                listAvailableProductsSet.add(new SelectOption(mapProducts.get(dli.GC_Item_Code__c), dli.GC_Item_Descr__c));
                Set<String> listaElems = new Set<String>();
                listaElems.add(dli.GC_Batch_Number_Text__c);
                mapBatches.put(mapProducts.get(dli.GC_Item_Code__c), listaElems);
            }
        }
        
        listAvailableProducts = new List<SelectOption>();
        for(SelectOption item : listAvailableProductsSet)
        {
            listAvailableProducts.add(item);
            
            }
        
       AvailableUnits = new List<SelectOption>();       
       Schema.DescribeFieldResult Field = Complaint_Products__c.PICK_Complained_Qty_UOM__c.getDescribe();
       List<Schema.PicklistEntry> Field_values = Field.getPicklistValues();
        
       for(Schema.PicklistEntry f : Field_values)
           AvailableUnits.add(new SelectOption(f.getLabel(), f.getValue()));
        
        mode='view';
    }
    
    
    public void newRow()
    {
        mode='edit' ;
        Complaint_Products__c newPr=new Complaint_Products__c(LKP_CASE__c=caseId);
        listcProducts.add(new cProduct(newPR));
       
    }
    public void edit()
    {
        mode='edit' ;
        
    }
    public void cancel()
    {
        mode='view' ;
        listcProducts=new List<cProduct>();
        for(Complaint_Products__c item :[select id, name, PICK_Complained_Qty_UOM__c, NUM_BAGS__c, LKP_Product__c, LKP_Product__r.ProductSAPCode__c, PCK_Process__c, NUM_Number_of_units_under_complaint__c, NUM_Complaint_quantity__c, NUM_Affected_Acres_ha__c, TXT_Planting_Density__c, TXT_Quantify_problem__c, TXT_Batch_Name__c,  LKP_Product_Variety__c, NUM_Quantity_for_replacement__c from Complaint_Products__c where LKP_CASE__c=:caseId])
        {
           
            listcProducts.add(new cProduct(item));
        }
    }
    public void del()
{
    list<complaint_products__C> toDel=new list<complaint_products__C>();
    
    for(cProduct item:listcProducts)
    {
        if(item.selected)
        {
            toDel.add(item.comProd);
            
        }
            
    }
    delete toDEl;
    listcProducts=new list<cProduct>();
    for(Complaint_Products__c item :[select id, name, PICK_Complained_Qty_UOM__c, NUM_BAGS__c, LKP_Product__c, LKP_Product__r.ProductSAPCode__c, PCK_Process__c, NUM_Number_of_units_under_complaint__c, NUM_Complaint_quantity__c, NUM_Affected_Acres_ha__c, TXT_Planting_Density__c, TXT_Quantify_problem__c, TXT_Batch_Name__c,  LKP_Product_Variety__c, NUM_Quantity_for_replacement__c from Complaint_Products__c where LKP_CASE__c=:caseId])
        {

            listcProducts.add(new cProduct(item));
        }
}    
    public void save()
    {
      mode='view' ;
        
        if(listcProducts!=null || listcProducts.size()>0){
             list<complaint_products__C> toUps=new list<complaint_products__C>();
            for(cProduct i:listcProducts)
            {
                toUps.add(i.comProd);
            }
            try {
                upsert toUps;
            } catch(dmlException e )
            {
                
                apexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.ERROR,e.getDMLMessage(0)));
                
            }
            listcProducts=new list<cProduct>();
            for(Complaint_Products__c item :[select id, name, PICK_Complained_Qty_UOM__c, NUM_BAGS__c, LKP_Product__c, LKP_Product__r.ProductSAPCode__c, PCK_Process__c, NUM_Number_of_units_under_complaint__c, NUM_Complaint_quantity__c, NUM_Affected_Acres_ha__c, TXT_Planting_Density__c, TXT_Quantify_problem__c, TXT_Batch_Name__c,  LKP_Product_Variety__c, NUM_Quantity_for_replacement__c from Complaint_Products__c where LKP_CASE__c=:caseId])
            {
                
                listcProducts.add(new cProduct(item));
            }
    }
} 

    
    
    public class cProduct{
        public Complaint_Products__c comProd {get; set;}
        public Boolean selected {get; set;}
    
    public cProduct (Complaint_Products__c c){
        comProd = c;
        selected=false;        
    }}
}