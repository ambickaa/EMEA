public with sharing class AttachmentGeneratorController{


    public String Content{get; set;}

public AttachmentGeneratorController()
{
        String signature=Util.urlParameters.get('signature');
        String name=Util.urlParameters.get('name');
        String docdate=Util.urlParameters.get('date');
        String doctype=Util.urlParameters.get('type');
    
        String stordate=Util.urlParameters.get('stordate');
        String ordernum=Util.urlParameters.get('ordernum');
        String address=Util.urlParameters.get('address');
        
        Content=Util.attachDocs.get(doctype.toUpperCase());
        
        if(signature!=null && signature != '')
            Content= Content.replace('[MON_SIGNATURE]',signature);
        if(name!=null && name != '')
            Content= Content.replace('[MON_NAME]', name );
        if(docdate!=null && docdate != '')
            Content=Content.replace('[MON_DATE]', docdate );
     
        if(stordate!=null && stordate != '')
            Content=Content.replace('[MON_STORAGE_DATE]', stordate );
        if(ordernum!=null && ordernum != '')
            Content=Content.replace('[MON_ORDER_NUM]', ordernum );
        if(address!=null && address != '')
            Content=Content.replace('[MON_ADDRESS]', address );
        
}

}