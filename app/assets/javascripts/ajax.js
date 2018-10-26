function loadAjaxResponse(response, tabId) {
  var ajaxTab = document.getElementById(tabId);
  ajaxTab.innerHTML = response;
};

function handleAjaxResponseApiError(tabId) {
  document.getElementById(tabId).innerHTML = 'There was a problem with an API while fetching data.'
};

function handleAjaxResponse(endpoint, tabId) {
  var xhttpAjaxResponse = new XMLHttpRequest();
  xhttpAjaxResponse.open('GET', endpoint, true);
  xhttpAjaxResponse.onreadystatechange = function() {
    if (xhttpAjaxResponse.readyState == 4) {
      if (xhttpAjaxResponse.status == 200) {
        loadAjaxResponse(xhttpAjaxResponse.response, tabId);
      } else {
        handleAjaxResponseApiError(tabId);
      }
    }
  }
  xhttpAjaxResponse.onerror = handleAjaxResponseApiError;
  xhttpAjaxResponse.send();
}
