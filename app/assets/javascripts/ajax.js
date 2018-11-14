function handleAjaxResponse(endpoint, ajaxTab) {
  ajax(
    endpoint,
    function (request) {
      ajaxTab.innerHTML = request.response;
    },
    function () {
      ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
    }
  )
}


function ajax(endpoint, successFn, failureFn) {
  var request = new XMLHttpRequest();

  request.open('GET', endpoint, true);
  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      if (request.status === 200) {
        successFn(request)
      } else {
        failureFn()
      }
    }
  };

  request.onerror = failureFn;
  request.send();
}
