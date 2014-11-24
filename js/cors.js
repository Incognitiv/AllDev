var createCORSRequest, getTitle, makeCorsRequest;

function createCORSRequest(method, url) {
  var xhr;
  xhr = new XMLHttpRequest();
  if ("withCredentials" in xhr) {
    xhr.open(method, url, true);
  } else if (typeof XDomainRequest !== "undefined") {
    xhr = new XDomainRequest();
    xhr.open(method, url);
  } else {
    xhr = null;
  }
  return xhr;
};

function getTitle(text) {
  return text.match("<title>(.*)?</title")[1];
};

function makeCorsRequest(url) {
  var xhr;
  xhr = createCORSRequest("GET", url);
  if (!xhr) {
    console.log("CORS is not supported!");
    return;
  }
  xhr.onload = function() {
    var text, title;
    text = xhr.responseText;
    title = getTitle(text);
    console.log("Response from CORS request to " + url + ": " + title);
  };
  xhr.onerror = function() {
    console.log("Request error!");
  };
  xhr.send();
};