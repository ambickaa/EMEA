public with sharing class ExcelExportRUPBonusController{

    public String font51366 {get;set;}
    public String font61366 {get;set;}
    public String font71366 {get;set;}
    public String font81366 {get;set;}
    public String font91366 {get;set;}
    public String font101366 {get;set;}
    public String font111366 {get;set;}
    public String xl631366 {get;set;}
    public String xl641366 {get;set;}
    public String xl651366 {get;set;}
    public String xl661366 {get;set;}
    public String xl671366 {get;set;}
    public String xl681366 {get;set;}
    public String xl691366 {get;set;}
    public String xl701366 {get;set;}
    public String xl711366 {get;set;}
    public String xl721366 {get;set;}
    public String xl731366 {get;set;}
    public String xl741366 {get;set;}
    public String xl751366 {get;set;}
    public String xl761366 {get;set;}
    public String xl771366 {get;set;}
    public String xl781366 {get;set;}
    public String xl791366 {get;set;}
    public String xl801366 {get;set;}
    public String xl811366 {get;set;}
    public String xl821366 {get;set;}
    public String xl831366 {get;set;}
    public String xl841366 {get;set;}
    public String xl851366 {get;set;}
    public String xl861366 {get;set;}
    public String xl871366 {get;set;}
    public String xl881366 {get;set;}
    public String xl891366 {get;set;}
    public String xl901366 {get;set;}
    public String xl911366 {get;set;}
    public String xl921366 {get;set;}
    public String xl931366 {get;set;}
    public String xl941366 {get;set;}
    public String xl951366 {get;set;}
    public String xl961366 {get;set;}
    public String xl971366 {get;set;}
    public String xl981366 {get;set;}
    public String xl991366 {get;set;}
    public String xl1001366 {get;set;}
    public String xl1011366 {get;set;}
    public String xl1021366 {get;set;}
    public String xl1031366 {get;set;}
    public String xl1041366 {get;set;}
    public String xl1051366 {get;set;}
    public String xl1061366 {get;set;}
    public String xl1071366 {get;set;}
    public String xl1081366 {get;set;}
    public String xl1091366 {get;set;}
    public String xl1101366 {get;set;}
    public String xl1111366 {get;set;}
    public String xl1121366 {get;set;}
    public String xl1131366 {get;set;}
    public String xl1141366 {get;set;}
    public String xl1151366 {get;set;}
    public String xl1161366 {get;set;}
    public String xl1171366 {get;set;}
    public String xl1181366 {get;set;}
    public String xl1191366 {get;set;}
    public String xl1201366 {get;set;}
    public String xl1211366 {get;set;}
    public String xl1221366 {get;set;}
    public String xl1231366 {get;set;}
    public String xl1241366 {get;set;}
    public String xl1251366 {get;set;}
    public String xl1261366 {get;set;}
    public String xl1271366 {get;set;}
    public String xl1281366 {get;set;}
    public String xl655351366 {get;set;}
    public String xl13128201noborder {get;set;}
    
    public Boolean pageview{get;set;}
    public String pagesheet{get;set;}
    
    public String xmlContent{get;set;}
    public String getRoundupPowerFlexLogo(){return SystemSettings__c.getValues('Roundup_PowerFlex').Value__c;}
    public String getRoundupRekordLogo(){return SystemSettings__c.getValues('Roundup_Rekord').Value__c;}
    
    public transient Id UserID{get;set;}
    public transient Id AccountID{get;set;}
    public transient Id DivisionID{get;set;}
    
    public String CurrentDate{get;set;}
    public transient Account AccountInfo{get;set;}
    public transient User UserInfo{get;set;}
    public transient VoucherCampaign__c VoucherCampaignInfo{get;set;}
    
    public Map<String,Integer> MapPoG{get;set;}
    public Map<String,Integer> MapUnits{get;set;}
    public Map<String,Integer> MapAgreed{get;set;}
    public String DiscountAgreed{get;set;}
    public String DiscountPoG{get;set;}

    private ApexPages.StandardController controller;
    public ExcelExportRUPBonusController(){
        this.controller = controller;
        
        font51366 = 'color:#262626;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;';
        font61366 = 'color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;';
        font71366 = 'color:white;font-size:12.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;';
        font81366 = 'color:windowtext;font-size:20.0pt;font-weight:700;font-style:italic;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;';
        font91366 = 'color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;mso-font-charset:0;';
        font101366 = 'color:windowtext;font-size:20.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;mso-font-charset:0;';
        font111366 = 'color:#262626;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Calibri, sans-serif;mso-font-charset:0;';
        xl631366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl641366 = 'padding:0px;mso-ignore:padding;color:#595959;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl651366 = 'padding:0px;mso-ignore:padding;color:#262626;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:normal;';
        xl661366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl671366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl681366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl691366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:left;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl701366 = 'padding:0px;mso-ignore:padding;color:#262626;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl711366 = 'padding:0px;mso-ignore:padding;color:#262626;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl721366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;border-top:none;border-right:none;border-bottom:none;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:normal;';
        xl731366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:normal;';
        xl741366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:normal;mso-rotate:90;';
        xl751366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:normal;';
        xl761366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;border-top:none;border-right:none;border-bottom:none;border-left:.5pt solid black;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl771366 = 'padding:0px;mso-ignore:padding;color:white;font-size:14.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:left;vertical-align:middle;border:.5pt solid black;background:#FF6600;mso-pattern:black none;white-space:normal;';
        xl781366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:none;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl791366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FF6600;mso-pattern:black none;white-space:nowrap;';
        xl801366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;background:white;mso-pattern:black none;white-space:nowrap;';
        xl811366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;background:white;mso-pattern:black none;white-space:normal;';
        xl821366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;background:white;mso-pattern:black none;white-space:nowrap;';
        xl831366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:none;border-right:none;border-bottom:none;border-left:none;background:white;mso-pattern:black none;white-space:nowrap;';
        xl841366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:none;border-right:none;border-bottom:none;border-left:none;background:white;mso-pattern:black none;white-space:nowrap;';
        xl851366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl861366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:general;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl871366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:left;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl881366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl891366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:12.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl901366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border:.5pt solid black;background:#FF6600;mso-pattern:black none;white-space:normal;';
        xl911366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:none;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl921366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl931366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl941366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FF6600;mso-pattern:black none;white-space:nowrap;';
        xl951366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:italic;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;border-top:none;border-right:none;border-bottom:.5pt solid black;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl961366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:20.0pt;font-weight:700;font-style:italic;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl971366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl981366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl991366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1001366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1011366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1021366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1031366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;border-top:none;border-right:none;border-bottom:.5pt solid #000000;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl1041366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;border-top:.5pt solid #000000;border-right:none;border-bottom:.5pt solid black;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl1051366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:left;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:normal;';
        xl1061366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:left;vertical-align:bottom;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl1071366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:bottom;border-top:none;border-right:none;border-bottom:.5pt solid #000000;border-left:none;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl1081366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FF6600;mso-pattern:black none;white-space:normal;';
        xl1091366 = 'padding:0px;mso-ignore:padding;color:white;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FF6600;mso-pattern:black none;white-space:normal;';
        xl1101366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:12.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:left;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl1111366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1121366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1131366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:Standard;text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1141366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1151366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1161366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1171366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1181366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1191366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:Standard;text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1201366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1211366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1221366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1231366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1241366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:none;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1251366 = 'padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:bottom;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:none;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1261366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:General;text-align:center;vertical-align:middle;border:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1271366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl1281366 = 'padding:0px;mso-ignore:padding;color:black;font-size:11.0pt;font-weight:700;font-style:normal;text-decoration:none;font-family:Arial, sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:center;vertical-align:middle;border-top:.5pt solid black;border-right:.5pt solid black;border-bottom:.5pt solid black;border-left:.5pt solid black;background:#FFFFFF;mso-pattern:black none;white-space:nowrap;';
        xl13128201noborder ='padding:0px;mso-ignore:padding;color:windowtext;font-size:11.0pt;font-weight:400;font-style:normal;text-decoration:none;font-family:Arial,sans-serif;mso-font-charset:0;mso-number-format:"\\#\\,\\#\\#0\\.00\\ \\0022€\\0022";text-align:general;vertical-align:middle;mso-background-source:auto;mso-pattern:auto;white-space:nowrap;';
        xl655351366 = '';
        
        CurrentDate = date.today().format();
    
        if(Util.currentAccount!=null && Util.currentAccount.Id != null){
        
            UserID = Util.currentUser.Id;
            AccountID = Util.currentAccount.Id;
            DivisionID = Util.currentDivision.Id;
            
            // Account Info
            AccountInfo = [SELECT Id, Name, Client_Code__c, DE_ZIP_PLZ__c, City__c, Street__c, DE_Ansprechpartner_ZV_CP__r.Name, DE_ID_Status__c,
                            DE_Forecast_RUP_CY__c, DE_CP_AGREED_RUP_CY__c
                           FROM Account WHERE Id =: AccountID];
    
            if(AccountInfo.DE_ID_Status__c == 'Wiederverkäufer Ost' || AccountInfo.DE_ID_Status__c == 'Wiederverkäufer West'){
                pageview = true;
                pagesheet = 'W-Stufe Extern';
            }
            else{
                pageview = false;
                pagesheet = 'GH_NL';
            }
            xmlContent = '<xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>'+pagesheet+'</x:Name><x:WorksheetOptions><x:FitToPage/><x:Print><x:FitWidth>1</x:FitWidth><x:FitHeight>1</x:FitHeight><x:ValidPrinterInfo/><x:Scale>100</x:Scale><x:HorizontalResolution>600</x:HorizontalResolution><x:VerticalResolution>600</x:VerticalResolution></x:Print><x:Selected/><x:Panes><x:Pane><x:General>3</x:General><x:ActiveRow>7</x:ActiveRow><x:ActiveCol>1</x:ActiveCol></x:Pane></x:Panes><x:ProtectContents>False</x:ProtectContents><x:ProtectObjects>False</x:ProtectObjects><x:ProtectScenarios>False</x:ProtectScenarios></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets><x:WindowHeight>10005</x:WindowHeight><x:WindowWidth>10005</x:WindowWidth><x:WindowTopX>120</x:WindowTopX><x:WindowTopY>135</x:WindowTopY><x:ProtectStructure>False</x:ProtectStructure><x:ProtectWindows>False</x:ProtectWindows></x:ExcelWorkbook></xml>';

            // User Info
            UserInfo = [SELECT Id, Name, Phone FROM User WHERE Id =: UserId];
            
            // Products & Action Plan
            String[] pceLabel = Label.Roundup_Bonus_2016.split(',');
            Integer SumAgreed = 0;
            Integer SumPoG = 0;
            
            Map<String, ProductCatalogEntry__c> pceMap = new Map<String, ProductCatalogEntry__c>();
            for(ProductCatalogEntry__c pce : [SELECT Id, Name, ProductRef__r.ProductSAPCode__c, ProductRef__r.NUM_UnitsPerSKU__c
                        FROM ProductCatalogEntry__c
                        WHERE ProductRef__r.ProductSAPCode__c IN : pceLabel]){
                        
                pceMap.put(pce.ProductRef__r.ProductSAPCode__c,pce);
            }
            
            Map<String, CampaignLineItem__c> cliMap = new Map<String, CampaignLineItem__c>();
            for(CampaignLineItem__c cli : [SELECT Id, Name, ProductRef__c, ProductRef__r.Name, ProductRef__r.Description, Forecast__c, Agreed__c, PoG__c,
                        ProductRef__r.NUM_UnitsPerSKU__c, ProductRef__r.ProductChemPrimPkgCont__c, ProductRef__r.ProductSAPCode__c
                        FROM CampaignLineItem__c
                        WHERE FarmRef__c =: AccountInfo.Id
                        AND year__c = '2017'
                        AND country__c = 'Germany'
                        AND division__c = 'Roundup'
                        //AND OwnerId =: UserId
                        AND ProductRef__r.ProductSAPCode__c IN : pceLabel]){
                        
                // Check if the Product is already in the Map
                if(cliMap.get(cli.ProductRef__r.ProductSAPCode__c) == null){
                
                    cliMap.put(cli.ProductRef__r.ProductSAPCode__c,cli);
                }
                else {
                    if(cli.PoG__c != null && cliMap.get(cli.ProductRef__r.ProductSAPCode__c).PoG__c != null)
                        cli.PoG__c = cli.PoG__c + cliMap.get(cli.ProductRef__r.ProductSAPCode__c).PoG__c;
                    if(cli.Agreed__c != null && cliMap.get(cli.ProductRef__r.ProductSAPCode__c).Agreed__c != null)
                        cli.Agreed__c = cli.Agreed__c + cliMap.get(cli.ProductRef__r.ProductSAPCode__c).Agreed__c;
                    if(cli.Forecast__c != null && cliMap.get(cli.ProductRef__r.ProductSAPCode__c).Forecast__c != null)
                        cli.Forecast__c = cli.Forecast__c + cliMap.get(cli.ProductRef__r.ProductSAPCode__c).Forecast__c;
                        
                    cliMap.put(cli.ProductRef__r.ProductSAPCode__c,cli);
                    
                }
                
                // If DE_CP_AGREED_RUP_CY__c > 0, take Agreed. If not, take Forecast.
                if(AccountInfo.DE_CP_AGREED_RUP_CY__c != null && AccountInfo.DE_CP_AGREED_RUP_CY__c > 0){
                    if(cli.Agreed__c != null)
                        SumAgreed = SumAgreed + (cli.Agreed__c.IntValue()*cli.ProductRef__r.NUM_UnitsPerSKU__c.IntValue());
                }
                else{
                    if(cli.Forecast__c != null)
                        SumAgreed = SumAgreed + (cli.Forecast__c.IntValue()*cli.ProductRef__r.NUM_UnitsPerSKU__c.IntValue());
                }
                if(cli.PoG__c != null)
                    SumPoG = SumPoG + (cli.PoG__c.IntValue()*cli.ProductRef__r.NUM_UnitsPerSKU__c.IntValue());
            }
            
            MapPoG = new Map<String,Integer>();
            MapUnits = new Map<String,Integer>();
            MapAgreed = new Map<String,Integer>();
            
            for(String SAP : pceMap.keyset()){
                if(cliMap.get(SAP) != null){
                    if(cliMap.get(SAP).ProductRef__r.NUM_UnitsPerSKU__c!=null)
                        MapUnits.put(SAP,cliMap.get(SAP).ProductRef__r.NUM_UnitsPerSKU__c.IntValue());
                    else
                        MapUnits.put(SAP,1);
                        
                    if(cliMap.get(SAP).PoG__c!=null && cliMap.get(SAP).PoG__c > 0)
                        MapPoG.put(SAP,cliMap.get(SAP).PoG__c.IntValue());
                    else
                        MapPoG.put(SAP,0);
                        
                    // If DE_CP_AGREED_RUP_CY__c > 0, take Agreed. If not, take Forecast.
                    if(AccountInfo.DE_CP_AGREED_RUP_CY__c != null && AccountInfo.DE_CP_AGREED_RUP_CY__c > 0){
                        if(cliMap.get(SAP).Agreed__c!=null && cliMap.get(SAP).Agreed__c > 0)
                            MapAgreed.put(SAP,cliMap.get(SAP).Agreed__c.IntValue());
                        else
                            MapAgreed.put(SAP,0);
                    } else {
                        if(cliMap.get(SAP).Forecast__c!=null && cliMap.get(SAP).Forecast__c > 0)
                            MapAgreed.put(SAP,cliMap.get(SAP).Forecast__c.IntValue());
                        else
                            MapAgreed.put(SAP,0);
                    }
    
                } else {
                    if(pceMap.get(SAP).ProductRef__r.NUM_UnitsPerSKU__c!=null)
                        MapUnits.put(SAP,pceMap.get(SAP).ProductRef__r.NUM_UnitsPerSKU__c.IntValue());
                    else
                        MapUnits.put(SAP,1);
                        
                    MapPoG.put(SAP,0);
                    MapAgreed.put(SAP,0);
    
                }
            }
    
            // Discounts & VolumenBonus
            Double DscAgreed = 0;
            Double DscPoG = 0;
            
            // VoucherCampaign Info
            VoucherCampaignInfo = [SELECT Id, Name FROM VoucherCampaign__c WHERE Name = 'Germany - Roundup - 2017'];
            
            for(Discount__c dsc : [SELECT Id, MinBags__c, MaxBags__c, DiscountInPrice__c
                                        FROM Discount__c
                                        WHERE VoucherCampaignRef__c =: VoucherCampaignInfo.Id
                                        ORDER BY MinBags__c ASC]){
                
                if(SumAgreed >= dsc.MinBags__c && SumAgreed <= dsc.MaxBags__c)
                    DscAgreed = dsc.DiscountInPrice__c;
                if(SumPoG >= dsc.MinBags__c && SumPoG <= dsc.MaxBags__c)
                    DscPoG = dsc.DiscountInPrice__c;
                    
                if(SumAgreed == 0)
                    DscAgreed = 0;
                if(SumPoG == 0)
                    DscPoG = 0;
            }
            
            DiscountAgreed = String.valueOf(DscAgreed).replace('.',',');
            DiscountPoG = String.valueOf(DscPoG).replace('.',',');
        }
    }
}