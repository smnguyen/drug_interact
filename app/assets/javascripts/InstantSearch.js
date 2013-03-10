// creates a new search object, whose results immediately display on typing.
// input params: id of input box, id of div to display results in, url to
// send search query to, with empty string as the search query (.../search?q=)
function InstantSearch(inputID, resultsID, searchURL) {
	this.input = document.getElementById(inputID);
	this.input.value = "Search";
	this.input.style.color = "gray";
	this.inputSelectedOnce = false;
	this.input.onclick = this.wrap(this, "clearInitialText");
	
	this.resultsID = resultsID;
	this.url = searchURL;
	
	this.ajaxRequester = new AjaxRequester(resultsID);
	this.input.onkeyup = this.wrap(this, "search");
}

// wrapper for assigning methods to events
InstantSearch.prototype.wrap = function(obj, method) {
	return function(event) {
		obj[method](event);
	}
}

// sends a request for search
InstantSearch.prototype.search = function(event) {
	if (this.input.value == "") {
		var resultsElem = document.getElementById(this.resultsID);
		resultsElem.innerHTML = "";
		return;
	}
	
	if (!this.ajaxRequester.requestComplete()) {
		this.ajaxRequester.abortRequest();
	}
	this.ajaxRequester.sendGetRequest(this.url + encodeURIComponent(this.input.value));
}

// stylistic effect, input box has faded "Search" text that disappears
// when the user clicks inside the text box
InstantSearch.prototype.clearInitialText = function(event) {
	if (this.inputSelectedOnce) return;
	
	this.input.value = "";
	this.input.style.color = "black";
	this.inputSelectedOnce = true;
}