
        function OpenPrimaryTab() {
            //Open a new primary tab with the salesforce.com home page in it
            alert('tset');
            sforce.console.openPrimaryTab(null, 'https://monsantohrportal.ehr.com/default.ashx?CLASSNAME=LOGIN&RETURNURL=', true, 
                'myHR', openSuccess, 'myHR');
        }
        
        function OpenPrimaryTabContactUs() {
            //Open a new primary tab with the salesforce.com home page in it
            sforce.console.openPrimaryTab(null, 'https://test.salesforce.com/servlet/servlet.Integration?lid=00b30000001Qf50&eid=00530000009UrkQ&ic=1', true, 
                'Contact US', openSuccess, 'Contact US');
        }

        function OpenPrimaryTabFav(label, urlname) {
            //Open a new primary tab with the salesforce.com home page in it
            sforce.console.openPrimaryTab(null, urlname, true, label, openSuccess, label);
        }

        function OpenPrimaryTabKR(label, urlname) {
            //Open a new primary tab with the salesforce.com home page in it
            sforce.console.openPrimaryTab(null, urlname, true, label, openSuccess, label);
        }
        
                   
       var openSuccess = function openSuccess(result) {
       if (result.success == true) {
            
        } else {
            
        }
	};

       function OpenPrimaryTabReport(reportName, reportUrl) {
            //Open a new primary tab with the salesforce.com home page in it
            sforce.console.openPrimaryTab(null, reportUrl, true, reportName, openSuccess, reportName);
        }   

        function OpenPrimaryTabResources(reportUrl, reportName) {
            //Open a new primary tab with the salesforce.com home page in it
            sforce.console.openPrimaryTab(null, reportUrl, true, 
                reportName, openSuccess, reportName);
        }  


        function testOpenSubtab(contactId, contactName) {
            Id = contactId;
            Name = contactName;


            if (sforce.console.isInConsole()) {
                //First find the ID of the primary tab to put the new subtab in
                sforce.console.getEnclosingPrimaryTabId(openSubtab);

            } else {

                window.parent.location.replace('/' + Id);
            }
        }
        
        var openSubtab = function openSubtab(result) {
                //Now that we have the primary tab ID, we can open a new subtab in it
                var primaryTabId = result.id;
                sforce.console.openSubtab(primaryTabId, Id, true, Name, null);
            };

        function closeTab() {
            //First find the ID of the current tab to close it
            sforce.console.getEnclosingTabId(closeSubtab);
        }

        var closeSubtab = function closeSubtab(result) {
                //Now that we have the tab ID, we can close it
                var tabId = result.id;
                sforce.console.closeTab(tabId);
            };

        function testCloseTab() {
            //First find the ID of the current tab to close it
            sforce.console.getEnclosingTabId(closeSubtab);
        }

        var closeSubtab = function closeSubtab(result) {
                //Now that we have the tab ID, we can close it
                var tabId = result.id;
                sforce.console.closeTab(tabId);
            };

        function testRefreshSubtabById() {
            //Set the name of the tab by using the openSubtab method
            //This value is for example purposes only
            alert(parentId);
            //var subtabId = '{!parentId}';
            sforce.console.refreshSubtabById(subtabId, true, refreshSuccess);
        }

        var refreshSuccess = function refreshSuccess(result) {
                //Report whether refreshing the subtab was successful
                if (result.success == true) {
                    alert('Subtab refreshed successfully');
                } else {
                    alert('Subtab did not refresh');
                }
            };

function GrowerAccountOpenSubtab(AccountId,AccountName) {
            Id=AccountId;
            Name=AccountName;
            if (sforce.console.isInConsole()) {
                //First find the ID of the primary tab to put the new subtab in
                sforce.console.getEnclosingPrimaryTabId(AccountopenSubtab);

            } else {
                window.open('/' + Id);
            }
        }
        var AccountopenSubtab= function AccountopenSubtab(result) {
            //Now that we have the primary tab ID, we can open a new subtab in it
            var primaryTabId = result.id;
            sforce.console.openSubtab(primaryTabId, Id, true, Name, null);
          
        };