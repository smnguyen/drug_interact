// creates a new Ajax request handler. param is the div to display
// html results to.
function AjaxRequester(responseID) {
	this.xhr = new XMLHttpRequest();
	this.responseElem = document.getElementById(responseID);
	this.xhr.onreadystatechange = this.wrap(this, "displayHTML");
}

// wrapper for assigning methods to events
AjaxRequester.prototype.wrap = function(obj, method) {
	return function(event) {
		obj[method](event);
	}
}

AjaxRequester.prototype.sendGetRequest = function(url) {
	this.xhr.open("GET", url);
	this.xhr.send();
}

AjaxRequester.prototype.requestComplete = function() {
	return this.xhr.readyState == 4;
}

AjaxRequester.prototype.abortRequest = function() {
	this.xhr.abort();
}

AjaxRequester.prototype.displayHTML = function() {
	if (!this.requestComplete()) return;
	
	if (this.xhr.status == 200) {
		this.responseElem.innerHTML = this.xhr.responseText;
	} else {
		this.responseElem.innerHTML = this.xhr.statusText;
	}
}