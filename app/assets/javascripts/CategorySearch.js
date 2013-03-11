// creates a new search object, whose results immediately display on typing.
// input params: id of input box, id of div to display results in, url to
// send search query to, with empty string as the search query (.../search?q=)
function CategorySearch(inputID, resultsID, searchURL) {
	this.input = document.getElementById(inputID);
	
	this.resultsID = resultsID;
	this.url = searchURL;
	
	this.ajaxRequester = new AjaxRequester(resultsID);
	this.input.onchange = this.wrap(this, "search");
}

// wrapper for assigning methods to events
CategorySearch.prototype.wrap = function(obj, method) {
	return function(event) {
		obj[method](event);
	}
}

// sends a request for search
CategorySearch.prototype.search = function(event) {
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