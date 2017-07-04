//----------------------------------------------
// CMP_Controller is the Apex Class controller for the CMP Visualforce page.
// CMP (Case Management Portal) is intended for Key-Users, and they can:
// - Visualize opened tickets and read attached e-mails
// - Sort opened tickets with drag and drop actions
// - Delete opened tickets that were created by mistake
// - Answer the survey for closed tickets, rating the Support Team
//----------------------------------------------
public with sharing class CMP_Controller {
    
    //----------------------------------------------
    // All variables are defined here (some of them are also initialized)
    //----------------------------------------------
    
    private Case CaseCurrent = new Case();
    private EmailMessage EmailCurrent = new EmailMessage();
    private List<String> ListCases = new List<String>();
    private String RatingValue = '';
    private String RatingComments = '';
    
    public String actionResult {get; private set;}
    public String actionText {get; private set;}
    public String actionType {get; private set;}
    public String CountrySelected = '';
    
    public Boolean isAdmin {get; set;}
    public Boolean isPrioritized {get; set;}
    public Boolean isCountrySelected {get; set;}
    
    public Map<Id, Case> Map_Case {get; set;}
    public Map<Id, EmailMessage> Map_Email {get; set;}
    public Map<String, String> messageStatus {get; set;}
    public Map<String, String> Map_Country {get; set;}
    
    public List<String> List_Countries {get; set;}
    //----------------------------------------------
    // Current contact not needed.
    //----------------------------------------------
    //public List<Contact> List_Contact {get; set;}
    //public Contact Contact_Current {get; set;}
    public User User_Current {get; set;}
    
    //----------------------------------------------
    // Some variables are defined as transient in order to clean cache
    //----------------------------------------------
    
    public transient List<Case> List_Case {get; set;}
    public transient List<Case> List_Case_Closed {get; set;}
    public transient List<Case> List_Case_Temporal {get; set;}
    public transient List<EmailMessage> List_Messages {get; set;}
    
    public transient Map<String, String> Map_ISOCode {get; set;}
    public transient Map<String, Map<String, String>> Map_StatusColor {get; set;}
    
    //----------------------------------------------
    // The following actions/methods are called on load the Visualforce page.
    // - getUserInfo() gets the current user and corresponding contact info and determines if the profile is System Administrator
    // - getListCase() gets the whole list of opened tickets and closed tickets without rating
    //----------------------------------------------
    public CMP_Controller() {
        isCountrySelected = false;
        
        getUserInfo();
        getListCase();
        getMapCountries();
    }
    
    //----------------------------------------------
    // getUserInfo()
    // The following method executes two different actions:
    // 1. It gets the current user information and the contact that corresponds to that user
    // 2. It determines if the user profile is System Administrator
    //----------------------------------------------
    private void getUserInfo() {
        User_Current = [SELECT Id, Name, Title, Email, Country, UserRole.Name, Profile.Name, SmallPhotoUrl, FullPhotoUrl FROM User WHERE Id = :Util.currentUser.Id];
        
        //----------------------------------------------
        // Current contact not needed.
        //----------------------------------------------
        //List_Contact = new List<Contact>([SELECT Id, Name, Email, OwnerId FROM Contact WHERE Email = :checkMail(User_current.Email) LIMIT 1]);
        //Contact_Current = List_Contact.size() > 0 ? List_Contact[0] : new Contact();
        
        //----------------------------------------------
        // The view and the fields to update when sorting change depending on the current user profile.
        //----------------------------------------------
        isAdmin = (User_Current.Profile.Name == 'System Administrator' || User_Current.Profile.Name == 'Data Management') ? true : false;
    }
    
    //----------------------------------------------
    // getListCase()
    // The following method executes the following actions:
    // 1. It gets the list of cases to load and show in the page
    // 2. It populates two different lists for opened tickets and for closed tickets without rating
    // 3. It sets the boolean variable isPrioritized to true if only one of the opened tickets has been prioritized
    //----------------------------------------------
    private void getListCase() {
        
        //----------------------------------------------
        // Building the Query for the list of cases (only Standard Cases Record Type).
        //----------------------------------------------
        String Query = 'SELECT Id, CaseNumber, OwnerId, Owner.Name, CreatedDate, ClosedDate, Type, Status, Subject, Description,';
        Query += ' ContactId, Contact.Name, GC_Country_Name__c, GC_is_Close_Email_Sent__c, CHK_SURVEY_SENT__c,';
        Query += ' PICK_RATING__c, TXT_RATING_COMMENTS__c, LKP_RATING_BY__c, FRML_DaysFromCreation__c,';
        Query += ' NUM_STPriority__c, NUM_USER_PRIORITY__c, NUM_USER_SORTING__c';
        Query += ' FROM Case WHERE RecordTypeId = \'' + Util.recordType.get('Case:Standard_Cases_Record_Type') + '\'';
        Query += ' AND Status != \'Future Development\'';
        //----------------------------------------------
        // Conditions about the Status:
        // - Status is not Future Development
        // - Status is not Closed
        // - For non administrators or only for Support Team, also or Status is Closed with new email
        // - For non administrators, also or Status is Closed but the survey has not been filled
        //----------------------------------------------
        if(isAdmin && User_Current.Name != 'Support Team')
            Query += ' AND Status != \'Closed\'';
            // Mark Kirgis will only visualize Opened tickets, but not Closed tickets with new e-mail or with survey sent.
        if(!isAdmin || (isAdmin && User_Current.Name == 'Support Team'))
            Query += ' AND (Status != \'Closed\' OR (Status = \'Closed\' AND GC_is_Close_Email_Sent__c = TRUE)';
            // Mark Kirgis will not visualize Closed tickets with new email, but the others will do.
        if(isAdmin && User_Current.Name == 'Support Team')
            Query += ')';
        if(!isAdmin)
            Query += ' OR (Status = \'Closed\' AND PICK_RATING__c = NULL AND CHK_SURVEY_SENT__c = TRUE AND ClosedDate > 2015-10-12T00:00:00Z))';
        //----------------------------------------------
        // Conditions based on current user profile.
        // - System Administrator: All cases belonging to the current user or those cases in queue
        // - Any other profile: Only cases in the same country and belonging to the queue or to the eCIP Support Team (eCIP Project Manager is excluded)
        //----------------------------------------------
        if(isAdmin) {
            if(isCountrySelected)
                Query += ' AND GC_Country_Name__c = \'' + CountrySelected + '\'';
            Query += ' AND (OwnerId = \'' + User_Current.Id  + '\' OR OwnerId = \'00GD0000002Ju4CMAS\')';
            Query += ' ORDER BY';
            if(!isCountrySelected)
                Query += ' NUM_STPriority__c ASC NULLS LAST,';
            Query += ' NUM_USER_SORTING__c ASC NULLS LAST, NUM_USER_PRIORITY__c DESC NULLS LAST, CreatedDate ASC';
        } else {
            Query += ' AND GC_Country_Name__c = \'' + User_Current.Country + '\' AND OwnerId != \'005D0000002EQvbIAG\'';
            Query += ' ORDER BY NUM_USER_SORTING__c ASC NULLS LAST, NUM_USER_PRIORITY__c DESC NULLS LAST, CreatedDate ASC';
        }

        //----------------------------------------------
        // It retrieves the information from the Query and it saves it in a temporal list of cases.
        //----------------------------------------------
        List_Case_Temporal = (List<Case>)Database.query(Query);
        
        //----------------------------------------------
        // It initializes the defined maps and lists.
        //----------------------------------------------
        Map_Case = new Map<Id, Case>();
        List_Case = new List<Case>();
        List_Case_Closed = new List<Case>();
        
        List_Countries = new List<String>();
        
        isPrioritized = false;
        
        for(Case Case_Item : List_Case_Temporal) {
            //----------------------------------------------
            // Building here two separate list of cases:
            // - The ones opened or closed with new email
            // - The others closed without rating survey filled
            //----------------------------------------------
            if(Case_Item.Status != 'Closed' || (Case_Item.Status == 'Closed' && Case_Item.GC_is_Close_Email_Sent__c == true )) {
                List_Case.add(Case_Item);
                if(Case_Item.NUM_USER_PRIORITY__c != null)
                    isPrioritized = true;
            } else {
                List_Case_Closed.add(Case_Item);
            }
            
            //----------------------------------------------
            // It truncates the extra long words in case description to avoid issues in small screens, and then it populates the map.
            //----------------------------------------------
            Case_Item.Description = truncateLong(Case_Item.Description, 50);
            Map_Case.put(Case_Item.Id, Case_Item);
            
            List_Countries.add(Case_Item.GC_Country_Name__c);
        }
        //----------------------------------------------
        // Once the list of cases has been created on load the page, two further methods are called:
        // 1. A nested map for colors and icons based on the Case Status
        // 2. A simple map with the name of all different countries in the case list and their corresponding ISO codes
        //----------------------------------------------
        getMapStatusColor();
        getMapISOCode(List_Countries);
    }
    
    //----------------------------------------------
    // getMapStatusColor()
    // Getting colors and icons based on the Case Status.
    //----------------------------------------------
    private void getMapStatusColor() {
        
        //----------------------------------------------
        // It retrieves all values of the picklist Status in Case object.
        //----------------------------------------------
        Schema.DescribeFieldResult Field_Status = Case.Status.getDescribe();
        List<Schema.PicklistEntry> Field_Status_values = Field_Status.getPicklistValues();
        
        //----------------------------------------------
        // The map is initialized and populated with a default value.
        //----------------------------------------------
        Map_StatusColor = new Map<String, Map<String, String>>();
        Map_StatusColor.put(null,new Map<String, String>{'color'=>'grey', 'icon'=>'none'});
        
        for(Schema.PicklistEntry p : Field_Status_values) {
            if(p.getValue() == 'Closed') Map_StatusColor.put(p.getValue(),new Map<String, String>{'color'=>'grey', 'icon'=>'&#xe876;'});
            else if(p.getValue() == 'Scheduled') Map_StatusColor.put(p.getValue(),new Map<String, String>{'color'=>'purple lighten-2', 'icon'=>'&#xe878;'});
            else if(p.getValue() == 'New') Map_StatusColor.put(p.getValue(),new Map<String, String>{'color'=>'teal accent-4', 'icon'=>'&#xe153;'});
            else if(p.getValue() == 'In Progress') Map_StatusColor.put(p.getValue(),new Map<String, String>{'color'=>'amber accent-4', 'icon'=>'&#xe869;'});
            else if(p.getValue() == 'Pending Key-User') Map_StatusColor.put(p.getValue(),new Map<String, String>{'color'=>'deep-orange accent-2', 'icon'=>'&#xe7fd;'});
            else Map_StatusColor.put(p.getValue(),new Map<String, String>{'color'=>'blue', 'icon'=>'&#xe855;'});
        }
    }
    
    //----------------------------------------------
    // getMapISOCode()
    // This method gets a map with all countries in the list of cases and their ISO codes from a system custom label.
    //----------------------------------------------
    private void getMapISOCode(List<String> CaseCountries) {
        
        Map_ISOCode = new Map<String, String>();
        for(String c : CaseCountries)
            Map_ISOCode.put(c,'');

        List<String> List_Countries_ISO = Label.Countries_ISO.split(',');
        for(String c : List_Countries_ISO) {
            List<String> ciso = c.split('=');
            Map_ISOCode.put(ciso[0],ciso[1]);
        }
    }
    
    //----------------------------------------------
    // getMapCountries()
    // This method gets a map with all countries in the list of cases for the Admin picklist.
    //----------------------------------------------
    private void getMapCountries() {
        
        Map_Country = new Map<String, String>();
        Map_Country.put('-- All countries', '');
        for(String c : List_Countries) {
            if(c != '' && c != null)
                Map_Country.put(c,'');
            else
                Map_Country.put('-- No country', '');
        }
    }
    
    //----------------------------------------------
    // getListMessages()
    // Getting the list of all email messages attached to a given case.
    //----------------------------------------------
    private void getListMessages() {
        
        String Query = 'SELECT Id, Subject, Status, TextBody, HtmlBody, FromAddress, ParentId, CreatedDate';
        Query += ' FROM EmailMessage WHERE ParentId = \'' + CaseCurrent.Id + '\'';
        //----------------------------------------------
        // If the current user is not System Administrator, let's give it visibility only on email messages addresses to the user or sent by the user.
        //----------------------------------------------
        if(!isAdmin) {
            Query += ' AND (ToAddress LIKE \'%' + checkMail(User_current.Email) + '%\' OR FromAddress LIKE \'%' + checkMail(User_current.Email) + '%\'';
            Query += ' OR BccAddress LIKE \'%' + checkMail(User_current.Email) + '%\' OR CcAddress LIKE \'%' + checkMail(User_current.Email) + '%\')';
        }
        Query += ' ORDER BY CreatedDate DESC';
        
        //----------------------------------------------
        // It retrieves the information from the Query and it saves it in a list of email messages.
        //----------------------------------------------
        List_Messages = (List<EmailMessage>)Database.query(Query);
        
        Map_Email = new Map<Id, EmailMessage>();
        for(EmailMessage Email_Item : List_Messages)
            Map_Email.put(Email_Item.Id, Email_Item);
        
        //----------------------------------------------
        // It creates a map that traduces each numeric Status to the corresponding Status name.
        //----------------------------------------------
        messageStatus = new Map<String, String>{'0'=>'New', '1'=>'Read', '2'=>'Replied', '3'=>'Sent', '4'=>'Forwarded'};

    }
    
    //----------------------------------------------
    // Setting and getting the current case selected in the view.
    //----------------------------------------------
    public void setCaseCurrent(String Id_case) {
        CaseCurrent = Map_Case.get(Id_case);
    }
    public Case getCaseCurrent() {
        return CaseCurrent;
    }
    
    //----------------------------------------------
    // Setting and getting the current email selected in the view.
    //----------------------------------------------
    public void setEmailCurrent(String Id_email) {
        EmailCurrent = Map_Email.get(Id_email);
//----------------------------------------------
// EmailMessage from "New" to "Read". Issue: Status field is not writeable (Read Only).
//----------------------------------------------
//      if(isAdmin && EmailCurrent.Status == '0') {
//          EmailCurrent.Status = '1';
//          update EmailCurrent;
//      }
    }
    public EmailMessage getEmailCurrent() {
        return EmailCurrent;
    }
    
    //----------------------------------------------
    // Loading some methods after selecting a given case or a given email message.
    //----------------------------------------------
    public PageReference renderPanels() {
        getMapStatusColor();
        getListMessages();
        return null;
    }
    
    //----------------------------------------------
    // Loading some methods after switching country.
    //----------------------------------------------
    public void setCountrySelected(String c) {
        CountrySelected = c != '-- No country' ? c : '';
        isCountrySelected = CountrySelected != '-- All countries' ? true : false;
    }
    public String getCountrySelected() {
        return CountrySelected;
    }
    public void switcher() {
        getListCase();
        actionType = 'switcher';
        actionResult = 'success';
        actionText = CountrySelected + ' view';
    }
    
    //----------------------------------------------
    //  Setting and getting the sorted array of all cases that come from the page.
    //----------------------------------------------
    public void setListCases(String allCases) {
        ListCases = allCases.split(',');
    }
    public List<String> getListCases() {
        return ListCases;
    }
    //----------------------------------------------
    // doSort()
    // This method executes the action of saving the sorting that comes from the page.
    //----------------------------------------------
    public void doSort() {
        List<Case> List_Case_Update = new List<Case>();
        for(Integer i = 0; i < ListCases.size(); i++) {
            if(Map_Case.get(ListCases[i]) != null) {
                //----------------------------------------------
                // - A different field is updated depending on the user profile.
                // - The sorting starts with number 1, not with 0. Hence, a value i + 1 is always set.
                //----------------------------------------------
                if(isAdmin)
                    Map_Case.get(ListCases[i]).NUM_STPriority__c = i + 1;
                else
                    Map_Case.get(ListCases[i]).NUM_USER_SORTING__c = i + 1;
                List_Case_Update.add(Map_Case.get(ListCases[i]));
            }
        }
        actionType = 'sort';
        
        try {
            update List_Case_Update;
            
            actionResult = 'success';
            actionText = 'Tickets sorted successfully';
        } catch(Exception e) {
            
            actionResult = 'error';
            actionText = 'Refresh the page and try again';
        }
    }
    
    //----------------------------------------------
    //  Setting and getting the value and the comments of the rating survey.
    //----------------------------------------------
    public void setRatingValue(String txt) {
        RatingValue = txt;
    }
    public String getRatingValue() {
        return RatingValue;
    }
    public void setRatingComments(String txt) {
        RatingComments = txt;
    }
    public String getRatingComments() {
        return RatingComments;
    }
    //----------------------------------------------
    // doRate()
    // This method executes the action of saving the value and the comments of the rating survey.
    //----------------------------------------------
    public void doRate() {
        
        CaseCurrent.PICK_RATING__c = RatingValue;
        CaseCurrent.TXT_RATING_COMMENTS__c = RatingComments;
        CaseCurrent.LKP_RATING_BY__c = User_Current.Id;
        actionType = 'survey';
        
        try {
            update CaseCurrent;
            
            actionResult = 'success';
            actionText = 'Survey answered successfully';
            
        } catch(Exception e) {
            
            actionResult = 'error';
            actionText = 'Refresh the page and try again';
        }
        getListCase();
    }
    
    //----------------------------------------------
    // doDelete()
    // This method executes the action of deleting the current case.
    //----------------------------------------------
    public void doDelete() {
        
        actionType = 'delete';
        
        try {
            delete CaseCurrent;
            
            actionResult = 'success';
            actionText = 'Ticket removed successfully';

        } catch(Exception e) {
            
            actionResult = 'error';
            actionText = 'Refresh the page and try again';
        }
        getListCase();
    }
    
    //----------------------------------------------
    // doClose()
    // This method executes the action of closing the current case.
    //----------------------------------------------
    public void doClose() {
        
        actionType = 'close';
        CaseCurrent.Status = 'Closed';
        
        try {
            update CaseCurrent;
            
            actionResult = 'success';
            actionText = 'The ticket has been closed';

        } catch(Exception e) {
            
            actionResult = 'error';
            actionText = 'Refresh the page and try again';
        }
        getListCase();
    }
    
    //----------------------------------------------
    // Method to truncate extra long words to avoid issues in small screens.
    //----------------------------------------------
    public static String truncateLong(String text, Integer num_max) {
        String text_tmp = '';
        for(String word : text.split(' ')) {
            List<String> mailto = word.split('<mailto:');
            List<String> http = mailto[0].split('<http:');
            word = http[0];
            if(word.length() > num_max) {
                word = word.subString(0, num_max) + ' ' + word.subString(num_max);
            }
            text_tmp += word + ' ';
        }
        return text_tmp;
    }
    
    //----------------------------------------------
    // Method to find out if current environment is test.
    //----------------------------------------------
    public static Boolean isSandbox() {
      return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    
    //----------------------------------------------
    // Method to adapt user email address when current environment is test.
    //----------------------------------------------
    public static String checkMail(String oldEmail) {
        String EmailAddress = isSandbox() ? oldEmail.replace('@example.com','').replace('==','@').replace('=','@') : oldEmail;
        return EmailAddress;
    }
}