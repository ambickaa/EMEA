public class VFC_CustConsoleLinks {

    public list<Links__c> lstfav {get; set;}
       
    public VFC_CustConsoleLinks(){
       lstfav= Links__c.getAll().values();
        lstfav.sort();      
    }
}