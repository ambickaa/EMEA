public with sharing class TestCasePageController {
    
    public Integer numSemanas = 4;
    public String selectedSupporter{get; set;}
    
    private List<Change_Request__c> cases;
    private Month month;

    public void next()
    { 
        addMonth(1);
    }

    public void prev()
    { 
        addMonth(-1); 
    }

    public boolean getIsAdmin()
    {
        Boolean isAdmin=false;
        if(Util.currentUser.Profile.Name.equalsIgnoreCase('System Administrator'))
            isAdmin=true;
        return isAdmin;
    }
    
    public List<SelectOption> listSupportPeople
    { get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('*', 'All'));
            
            Schema.DescribeFieldResult fieldResult = Change_Request__c.Assigned_to__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
            for( Schema.PicklistEntry f : ple){
                options.add(new SelectOption(f.getLabel(), f.getValue()));
            }       
            
            return options;
        }
    }

    public TestCasePageController() 
    {
        selectedSupporter = null;
        Date d = system.today().toStartOfMonth();  // default  to first day of month 
        Integer mo = d.month(); 
        String w_param = System.currentPageReference().getParameters().get('we');
        // allow a month to be passed in on the url as mo=10
        if (w_param != null) 
            numSemanas = Integer.valueOf(w_param); 
        setMonth(d, numSemanas, null);
    }
    
    public void accessSupporter()
    {
        Date d = system.today().toStartOfMonth();  // default to first day of month 
        Integer mo = d.month(); 
        String w_param = System.currentPageReference().getParameters().get('we');
        // allow a month to be passed in on the url as mo=10
        if (w_param != null) 
            numSemanas = Integer.valueOf(w_param); 
        setMonth(d, numSemanas, selectedSupporter);
    }
    
    public List<Month.Week> getWeeks() 
    { 
        system.assert(month!=null,'month is null');
        return month.getWeeks();
    }

    public Month getMonth()
    {
        return month;
    } 

    private void setMonth(Date d, Integer i, String supporter)
    { 
        month = new Month(d, i); 
            
        system.assert(month != null); 

        Date[] da = month.getValidDateRange();  // gather events that fall in this month
        if(supporter==null || ''.equals(supporter) || '*'.equals(supporter) ){
            cases = [ SELECT id, StartTestDate__c, EndTestDate__c, Assigned_to__c, Name, Description__c,  Subject__c, Module__c
                    FROM Change_Request__c 
                    WHERE  (StartTestDate__c>=:da[0] AND StartTestDate__c<=:da[1]) OR (EndTestDate__c>=:da[0] AND EndTestDate__c<=:da[1])
                    ORDER BY StartTestDate__c];
                    
        }else{
            cases = [ SELECT id,  StartTestDate__c, EndTestDate__c, Assigned_to__c, Name, Description__c,  Subject__c, Module__c
                    FROM Change_Request__c 
                    WHERE  ((StartTestDate__c>=:da[0] AND StartTestDate__c<=:da[1]) OR (EndTestDate__c>=:da[0] AND EndTestDate__c<=:da[1])) AND Assigned_to__c=:supporter
                    ORDER BY StartTestDate__c];
        }
        List<Change_Request__c> modifiedCases= new List<Change_Request__c>();
        for (Change_Request__c cas: cases){
            if(cas.EndTestDate__c==cas.StartTestDate__c){
                Change_Request__c newC = new Change_Request__c( Description__c=cas.Description__c, StartTestDate__c=cas.StartTestDate__c, EndTestDate__c=cas.EndTestDate__c,
                                      id=cas.id, Assigned_to__c=cas.Assigned_to__c, Module__c=String.valueOf(cas.Name),
                                      Subject__c=cas.Subject__c);
                modifiedCases.add(newC);                                  
            }else{
                Integer counter=0;
                for(integer k=0; k<=cas.StartTestDate__c.daysBetween(cas.EndTestDate__c);k++){
                    Change_Request__c newC = new Change_Request__c( StartTestDate__c=cas.StartTestDate__c.addDays(k), Description__c=cas.Description__c, EndTestDate__c=cas.EndTestDate__c,
                                          id=cas.id, Assigned_to__c=cas.Assigned_to__c, Module__c=String.valueOf(cas.Name), Subject__c=cas.Subject__c);
                    modifiedCases.add(newC);    
                    counter++;              
                }
            }
        }
        System.Debug('TEST ENRIC '+modifiedcases);
        month.setCases(modifiedcases); 
    }

    private void addMonth(Integer val) {
        Date d = month.getFirstDate();
        d = d.addDays(val * numSemanas * 7);
        d = d.toStartOfWeek();
        setMonth(d, numSemanas, selectedSupporter);
    }

}