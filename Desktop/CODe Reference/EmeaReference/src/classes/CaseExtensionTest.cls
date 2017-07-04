@isTest
private class CaseExtensionTest
{
    static
    {
        MixedDMLOps.add( Testinit.casesCom );
        MixedDMLOps.add( Testinit.attachements );
        MixedDMLOps.ins();
    }


    /*static testMethod void caseValueAccessData() {
    	apexpages.currentPage().getParameters().put('id', TestInit.cases[0].id);
        //CaseExtension controller = new caseExtension(new ApexPages.StandardController());
        controller.getCase();
        controller.getCaseComments();
        controller.getAttachment();
        controller.doSave();
    }*/
}