public class OrderToCaseController {
    
    Apexpages.StandardController sc;
        Id ordid;
        public order cs;
        public delivery__c d1;
        public Invoice__c I1;
        public string AccNum{get;set;}
        public string IsConsoleValue;
        public string ControllerName{get;set;}
        public  static final String serviceCaseRecTyp = 'Service Case';
        public  static final String html1='<label for="CF00N8E000000H92J">Case Created From Order</label><span class="lookupInput"></span>';
        public  static final String html2='<label for="CF00N8E000000HaAF">Case Created From Delivery</label><span class="lookupInput"></span>';
        public  static final String html3='<label for="CF00N8E000000HaAK">Case Created From Invoice</label><span class="lookupInput"></span>';
         
        public OrderToCaseController(Apexpages.StandardController sc){
            IsConsoleValue = ApexPages.currentPage().getParameters().get('IsConsoleVal');
            ordid = ApexPages.currentPage().getParameters().get('id');
            Schema.SObjectType sobjectType = ordid.getSObjectType();
            ControllerName = sobjectType.getDescribe().getName();

            if(ordid !=null){
                if(ControllerName == System.label.ACSOrder)
                {
                    cs = [select id, AccountId from Order where Id = :ordid];
                    AccNum = cs.AccountId;
                }
                
                if(ControllerName == System.label.ACSDelivery)
                {
                    d1 = [select id, GC_Account_Integration_Key__c from Delivery__c where Id = :ordid];
                    AccNum = d1.GC_Account_Integration_Key__c;
                }
                
                if(ControllerName == System.label.ACSInvoice)
                {
                    I1 = [select id, GC_Account_Integration_Key__c from Invoice__c where Id = :ordid];
                    AccNum = I1.GC_Account_Integration_Key__c;
                }
            }   
            if(!Test.isRunningTest())
            {
                if(ControllerName == System.label.ACSOrder)
                {
                    sc.addFields(new List<String>{'OrderNumber'});
                }
                
                if((ControllerName == System.label.ACSDelivery) || (ControllerName == System.label.ACSInvoice)) 
                {
                    sc.addFields(new List<String>{'Name'});  
                }   
            }
             this.sc=sc;
        }
    
    @TestVisible private Map<String, String> createDefaultValues() {
        // Obtain the field ids
        Id caseRecid=Schema.SObjectType.case.getRecordTypeInfosByName().get(serviceCaseRecTyp).getRecordTypeId();
        PageReference p = new PageReference('/' + Case.SObjectType.getDescribe().getKeyPrefix() + '/e?RecordType='+caseRecid+'&nooverride=1');
        String html;     
        If(!Test.IsRunningTest())
        {
                 html = p.getContent().toString();
        }
        else if(ControllerName == System.label.ACSOrder)
        {
        html=html1;
        }
        else if(ControllerName == System.label.ACSDelivery)
        {
        html=html2;
        }
        else if(ControllerName == System.label.ACSInvoice)
        {
        html=html3;
        }
        /*else
        {
                html= '<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>'; 
        }*/    
        Map<String, String> labelToId = new Map<String, String>();
        Matcher m = Pattern.compile('<label for="(.*?)">(<span class="requiredMark">\\*</span>)?(.*?)</label>').matcher(html);
        while (m.find()) {
            String label = m.group(3);
            String id = m.group(1);
            labelToId.put(label, id);
        }
        // Relate the magic ids to the SObject fields
        Map<String, String> params = new Map<String, String>();
        for (SObjectField field : Case.SObjectType.getDescribe().fields.getMap().values()) {
            Object value = getDefaultValue(field);
            if (value != null) {
                DescribeFieldResult f = field.getDescribe();
                String label = f.getLabel();
                if (labelToId.containsKey(label)) {
                    // Format
                    String valueAsString;
                    if (f.getType() == DisplayType.Date) {
                        valueAsString = ((Date) value).format();
                    } else if (f.getType() == DisplayType.Datetime) {
                        valueAsString = ((Datetime) value).format();
                    } else if (f.getType() == DisplayType.Boolean) {
                        valueAsString = ((Boolean) value) ? '1' : '0';
                    } else {
                        valueAsString = String.valueOf(value);
                    }
    
                    if(ControllerName == System.label.ACSOrder)
                    {
                        if(f.getType() == DisplayType.Reference && field.getDescribe().getName() == System.label.ACSOrderField){
                            params.put(labelToId.get(label)+'_lkid', valueAsString);
                            params.put(labelToId.get(label), ((Order)sc.getRecord()).OrderNumber);
                        }else{
                        params.put(labelToId.get(label), valueAsString);
                        }
                    }
                    
                    if(ControllerName == System.label.ACSDelivery)
                    {
                        if(f.getType() == DisplayType.Reference && field.getDescribe().getName() == System.label.ACSDeliveryField){
                            params.put(labelToId.get(label)+'_lkid', valueAsString);
                            params.put(labelToId.get(label), ((Delivery__c)sc.getRecord()).Name);
                        }else{
                            params.put(labelToId.get(label), valueAsString);
                        }
                    }
                    
                    if(ControllerName == System.label.ACSInvoice)
                    {
                        if(f.getType() == DisplayType.Reference && field.getDescribe().getName() == System.label.ACSInvoiceField){
                            params.put(labelToId.get(label)+'_lkid', valueAsString);
                            params.put(labelToId.get(label), ((Invoice__c)sc.getRecord()).Name);
                        }else{
                            params.put(labelToId.get(label), valueAsString);
                        }
                    }
                }
            }
        }
        return params;
    }
    @TestVisible private Object getDefaultValue(SObjectField field) {
        if(ControllerName == System.label.ACSOrder)
        {
            if(field.getDescribe().getName() == System.label.ACSOrderField){
                return sc.getId();
            }
        }
        
        if(ControllerName == System.label.ACSDelivery)
        {
            if(field.getDescribe().getName() == System.label.ACSDeliveryField){
                return sc.getId();
            }
        }
        
        if(ControllerName == System.label.ACSInvoice)
        {
            if(field.getDescribe().getName() == System.label.ACSInvoiceField){
                return sc.getId();
            }
        }
        return null;
        
    }
    public PageReference url() {
        Id caseRecid=Schema.SObjectType.case.getRecordTypeInfosByName().get(serviceCaseRecTyp).getRecordTypeId();
        PageReference p = new PageReference('/' + Case.SObjectType.getDescribe().getKeyPrefix() + '/e?RecordType='+caseRecid+'&ent=Case&nooverride=1');
        Map<String, String> m = p.getParameters();
        m.putAll(createDefaultValues());
        m.put('cas4_lkid',AccNum);
        m.put('nooverride', '1');
        return p;
    }
    
}