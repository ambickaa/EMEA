/**
 * This class is an extension class to VFP_CaseMassUpdate page.
 * 
 * @author  Accenture
 * @version  1.0, 04/21/2016
 * 
 */
public class VFC_CaseMassUpdate {

    ApexPages.StandardSetController setCon;
    public boolean enabled{get;set;}
    
    /**
     * Constructor
     * 
     * @param   controller  StandardSetController
     * @return  NA
     * @throws  NA
     * 
     */
    public VFC_CaseMassUpdate(ApexPages.StandardSetController controller) {
        setCon = controller;
        if(setCon.getSelected().size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select atleast one record'));
            enabled = false;
        } 
        else{  
            enabled = true;    
        }
    }
    
    /**
     * This method returns the count of the records selected.
     * 
     * @param   Nothing
     * @return  Integer.
     * @throws  Nothing
     * 
     */
    public integer getMySelectedSize() {
        return setCon.getSelected().size();
    }   
}