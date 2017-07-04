public with sharing class VoucherGeneratorController
{
    // distributors
    
    AccountxFactory factory = new AccountxFactory();
    
    
    public List<SelectOption>distributors{get
        {
            if(distributors == null)
            {
                distributors = new List<SelectOption>();
                for(Accountx distributor : factory.ceateListOfDistributorsForTheCurrentAccount())
                {
                    distributors.add( new SelectOption(distributor.record.id, distributor.record.name));
                }
            }
            return distributors;
        } set;}
    
    public ID selectedDistributor
    {
        get
        {
            if(selectedDistributor == null && distributors.size()>0)
            {
                if(Util.urlparameters.containsKey('distributor'))
                {
                    selectedDistributor  = Util.urlparameters.get('distributor');
                }
                else
                {
                    selectedDistributor = distributors.get(0).getValue();
                }
            }
            return selectedDistributor;
        }
        set;
    }
    
    public List<SelectOption>templates
    {
        get
        {
            return (new CountryAdapter()).getVoucherTemplates();
        }
        set;
    }
    
    public boolean getIsTemplate()
    {
        return templates.size()>0 && distributors.size()>0;
    }
    
    public String templateUrl{
        get{
            if(selectedTemplate == null || selectedTemplate == '')
            {
                return null;
            }
            else
            {
                templateUrl = '/apex/'+selectedTemplate+'?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId+'&distributor='+selectedDistributor;
            }
            
            return templateUrl;
        }
        set;
    }
    
    public String selectedTemplate{get
        {
            if(selectedTemplate == null)
            {
                if(Util.urlParameters.containsKey('template'))
                {
                    selectedTemplate = Util.urlParameters.get('template');
                }
            }
            return selectedTemplate;
        } set;}
    
    
    public PageReference goToVoucherPage()
    {
        return URLx.setURL('/apex/VoucherGenerator?id=' + Util.currentAccount.Id + '&division=' + Util.divisionId+'&template='+selectedTemplate+'&distributor='+selectedDistributor);
    }
    
    public PageReference goToAccount()
    {
        return URLx.setURL('/'+Util.currentAccount.Id);
    }
    
    
    public String attachmentId {get; set;}
    
    public PageReference saveAsAttachement()
    {
        Attachment anAttachment = new Attachment();
        anAttachment.Body = new PageReference(templateUrl).getContent();
        anAttachment.ContentType = 'application/pdf';
        anAttachment.Name = Date.today().format();
        anAttachment.ParentId = Util.currentAccount.id;
        insert anAttachment;
        
        attachmentId = anAttachment.Id;
        return new PageReference('/servlet/servlet.FileDownload?file='+attachmentId);
    }
}