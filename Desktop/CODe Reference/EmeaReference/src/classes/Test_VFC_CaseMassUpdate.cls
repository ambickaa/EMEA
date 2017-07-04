/**
 * This class is an Test class to VFC_CaseMassUpdate Class.
 * 
 * @author  Accenture
 * @version  1.0, 04/21/2016
 * 
 */
 
@isTest
public class Test_VFC_CaseMassUpdate {

    private static testmethod void testcase1() {
    
        //Test Data
        Account acc = new Account(Name='Test');
        insert acc;
        
        Case c = new Case(AccountId=acc.Id,Origin='Phone',Priority='Low');
        insert c;
        
        List<Case> lstCase = new List<Case>();
        lstCase.add(c);
        
        
        PageReference pageRef = Page.VFP_CaseMassUpdate;      
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lstCase);
        
        VFC_CaseMassUpdate ins = new VFC_CaseMassUpdate(setCon);
        
        Integer a = ins.getMySelectedSize();
        
    
    }
    private static testmethod void testcase2() {
        List<Case> lstCase = new List<Case>();
        PageReference pageRef = Page.VFP_CaseMassUpdate;      
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lstCase);
        
        VFC_CaseMassUpdate ins = new VFC_CaseMassUpdate(setCon);
         Integer a = ins.getMySelectedSize();
    }
}