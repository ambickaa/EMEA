/* JSON Object to configure Homepage component pagelayout buttons hidding policy */
var JSON_Config = { "buttons": [
		{'componentPrefix': 'a05', 'fieldValueId': '00ND0000004W6Mi_ileinner', 'action': 'enable', 'affectedValues': [{'value': 'Closed'}], 'affectedButtons': [ {'name': 'cancel_order'} ] }
		, {'componentPrefix': 'a05', 'fieldValueId': '00ND0000004W6Mi_ileinner', 'action': 'disable', 'affectedValues': [{'value': 'Cancelled'}], 'affectedButtons': [ {'name': 'edit'}, {'name': 'submit'}, {'name': 'cancel_order'}, {'name': 'piSubmit'}] }
	]};

var errorDivID = DetailElement.DEFAULT_ERROR_DIV_ID;

j$ = jQuery.noConflict();

/** function made for IE8 compatibility. Returns an array of nodes  */
function getElementsByClassName(node, classname) {
	var a = [];
	var re = new RegExp('(^| )'+classname+'( |$)');
	var els = node.getElementsByTagName("*");
	for(var i=0,j=els.length; i<j; i++)
		if(re.test(els[i].className))a.push(els[i]);
	return a;
}
/* function that generates a string from a stringArray */
function generateStringFromArray(stringArray, lastSeparator) {
	var returnString = "";
	for (i=0; i<stringArray.length; i++) {
		returnString = returnString + "'" + stringArray[i] + "'";
		if (i<stringArray.length-3) {
			returnString = returnString + ", ";
		}
		if (i==stringArray.length-2) {
			returnString = returnString + " " + lastSeparator + " ";
		}
	}
	return returnString;
}

function textInStringArray(textToSearch, stringArray) {
	var found = false;
	for (i=0; i<stringArray.length && !found; i++) {
		found = (textToSearch == stringArray[i]);
	}
	return found;
}

function createScriptNode(nodeId, scriptType, scriptSrc, scriptCode) {
	var JSnode = document.getElementById(nodeId);
	if (JSnode == null) {
		JSnode = document.createElement("script");
		JSnode.id = nodeId;
	}
	JSnode.type = scriptType;
	JSnode.src = scriptSrc;
	JSnode.text = scriptCode;
	return JSnode;
}

function showErrorInPageLayout(innerHTML_text) {
	var errorDiv = document.getElementById(errorDivID);
	errorDiv.style.display="block";
	
	errorDiv.innerHTML = innerHTML_text;
	errorDiv.text = innerHTML_text;
}

function simpleModalForm(fieldName, mandatory) {
	var insertedValue = null;
	do {
		insertedValue= window.prompt("Insert " + fieldName, "");
		if (mandatory && insertedValue== "") {
			window.alert(fieldName + " is mandatory");
		}
	} while (mandatory && insertedValue != null && insertedValue == "");
	return insertedValue;
}

function displayOverlayBackground(show) {
	var ODiv = document.getElementById("myOverlayBackground");
	if (ODiv == null) {
		ODiv = document.createElement("div");
		ODiv.id = 'myOverlayBackground';
		ODiv.className = "overlayBackground";
		ODiv.style.width = '10000px';
		ODiv.style.height = '20000px';
		document.body.appendChild(ODiv);
	}
	if (show) {
		ODiv.style.display = 'block';
	}
	else {
		ODiv.style.display = 'none';
	}
}

function emptyDialogElements(dialogId) {
	var rootNode = document.getElementById(dialogId);
	if (rootNode != null) {
		// empty activeField content if any
		var activeField = getElementsByClassName(rootNode, "activeField")[0];
		while (activeField.firstChild) {
			activeField.removeChild(activeField.firstChild);
		}
	}
}

function addElementsToDialog(dialogId, newElements) {
	var rootNode = document.getElementById(dialogId);
	if (rootNode != null) {
		emptyDialogElements(dialogId);
		var activeField = getElementsByClassName(rootNode, "activeField")[0];
		
		for (i=0; i<newElements.length; i++) {
			activeField.appendChild(newElements[i]);
		}
	}
}

function getDialogButton(dialogId, buttonName) {
	var resultButton = null;
	var rootNode = document.getElementById(dialogId);
	if (rootNode != null) {
		var buttons = getElementsByClassName(rootNode, 'zen-btn');
		var found = false;
		for (i=0; i<buttons.length && !found; i++) {
			found = (buttons[i].value == buttonName);
			if (found) {
				resultButton = buttons[i];
			}
		}
	}
	return resultButton;
}

function changeButtonEvent(dialogId, buttonName, eventName, newFunctionality) {
	var targetButton = getDialogButton(dialogId, buttonName);
	if (targetButton != null) {
		targetButton.setAttribute(eventName, newFunctionality);
	}
}

function enableButton(dialogId, buttonName, enable) {
	var targetButton = getDialogButton(dialogId, buttonName);
	if (targetButton != null) {
		if (enable) {
			targetButton.removeAttribute("disabled");
		}
		else {
			targetButton.setAttribute("disabled", "");
		}
	}
}

function createInlineEditDialog(newId, Title) {
	var IEDDiv = document.getElementById(newId);
	if (IEDDiv == null) {
		IEDDiv = document.getElementById("InlineEditDialog").cloneNode(true);
		IEDDiv.id = newId;
		document.body.appendChild(IEDDiv);
		var closeEvent = "displayInlineEditDialog('" + newId + "', false);";
		// Set the "X" button behaviour and Dialog Title
		var topRight = getElementsByClassName(IEDDiv, "topRight")[0];
		var topLeft = getElementsByClassName(topRight, "topLeft")[0];
		topLeft.getElementsByTagName("a")[0].setAttribute("onclick", closeEvent);
		topLeft.getElementsByTagName("h2")[0].innerHTML = Title;
		topLeft.getElementsByTagName("h2")[0].text = Title;
		// change zen-btn ("OK" & "Cancel") onclick event
		var inlineEditDialog_buttons = getElementsByClassName(IEDDiv, "zen-btn");
		for (i=0; i<inlineEditDialog_buttons.length; i++) {
			inlineEditDialog_buttons[i].setAttribute("onclick", closeEvent);
		}
		// Empty dialog elements
		emptyDialogElements(newId);
	}
	// return created object
	return IEDDiv;
}

function displayInlineEditDialog(Id, show) {
	var IEDDiv = document.getElementById(Id);
	if (IEDDiv != null) {
		if (show) {
			displayOverlayBackground(true);
			IEDDiv.style.display = 'block';
			IEDDiv.style.visibility = 'visible';
		}
		else {
			displayOverlayBackground(false);
			IEDDiv.style.display = 'none';
			IEDDiv.style.visibility = 'hidden';
		}
	}
}

/* Function to hide buttons on pages. A JSON_Config variable storing parametrization is mandatory */
function changeStandardButtons() {
	var currentURL = document.location;
	/* Function that ensures hiding will only be applied to allowed page */
	function pageShouldBeProcessed(componentPrefix) {
		/* Only matches for standard page layouts */
		var patternMatcher=new RegExp('(?=https:\/\/.*\\.salesforce\\.com\/' + componentPrefix + '.*)');
		return patternMatcher.test(currentURL);
	}
	/* Field (component) value retrieval function */
	function getFieldValue(fieldValueId) {
		return j$("#"+fieldValueId).text();
	}
	/* Preaction to be made to components based on actionType (hide or show) */
	function preAction(actionType, buttonName) {
		var targetDOM = j$("input[type='button'][name='" + buttonName + "']");
		if (actionType == 'show') {
			targetDOM.hide();
		}
		if (actionType == 'enable') {
			targetDOM.toggleClass('btnDisabled', true).attr('disabled', 'disabled');
		}
	}
	/* The final action to the buttons */
	function doAction(actionType, buttonName) {
		var targetDOM = j$("input[type='button'][name='" + buttonName + "']");
		// style="display: none;"
		if (actionType == 'hide') {
			targetDOM.hide();
		}
		if (actionType == 'show') {
			targetDOM.show();
		}
		if (actionType == 'disable') {
			targetDOM.toggleClass('btnDisabled', true).attr('disabled', 'disabled');
		}
		if (actionType == 'enable') {
			targetDOM.toggleClass('btnDisabled', false).attr('disabled', null);
		}
	}
	/* Main code */
	for (i=0; i<JSON_Config.buttons.length; i++) {
		if (pageShouldBeProcessed(JSON_Config.buttons[i].componentPrefix)) {
			/* Field value is checked to match JSON configured values */
			var fieldValue = getFieldValue(JSON_Config.buttons[i].fieldValueId);
			var matches = false;
			for (j=0; j<JSON_Config.buttons[i].affectedValues.length && !matches; j++) {
				matches = (JSON_Config.buttons[i].affectedValues[j].value == fieldValue);
			}
			for (j=0; j<JSON_Config.buttons[i].affectedButtons.length; j++) {
				preAction(JSON_Config.buttons[i].action, JSON_Config.buttons[i].affectedButtons[j].name);
				if (matches) {
					doAction(JSON_Config.buttons[i].action, JSON_Config.buttons[i].affectedButtons[j].name);
				}
			}
		}
	}
}
