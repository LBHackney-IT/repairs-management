function handleAjaxResponse(endpoint, ajaxTab) {
  var request = new XMLHttpRequest();
  var errorHandler = function() {
    ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
  };

  request.open('GET', endpoint, true);
  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      if (request.status === 200) {
        ajaxTab.innerHTML = request.response;
      } else {
        errorHandler();
      }
    }
  };

  request.onerror = errorHandler;
  request.send();
}

function handleAjaxRepairsHistoryFiveYears(endpoint) {
  showLoadingMessage();

  var ajaxTab = document.getElementById('repair-history-tab');

  var request = new XMLHttpRequest();
  var errorHandler = function() {
    ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
  };

  request.open('GET', endpoint, true);
  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      if (request.status === 200) {
        ajaxTab.innerHTML = request.response;
        handleRepairHistoryYearsInfoText();
      } else {
        errorHandler();
      }
    }
  };

  request.onerror = errorHandler;
  request.send();
}

function showLoadingMessage() {
  var loadRepairsDiv = document.querySelectorAll('.load-repairs-history');
  var loadingText = document.querySelectorAll('.loading-repairs-history-text');
  var repairHistoryYearsInfo = document.querySelectorAll('.repair-history-years-info');

  for(var i = 0; i < loadRepairsDiv.length; i++) {
    repairHistoryYearsInfo[i].classList.add('hidden');
    loadingText[i].classList.remove('hidden');
    loadRepairsDiv[i].parentNode.replaceChild(loadingText[i], loadRepairsDiv[i]);
  }
}

function handleRepairHistoryYearsInfoText() {
  var repairHistoryYearsInfo = document.querySelectorAll('.repair-history-years-info');
  var loadRepairsDiv = document.querySelectorAll('.load-repairs-history');

  for(var i = 0; i < repairHistoryYearsInfo.length; i++) {
    repairHistoryYearsInfo[i].classList.remove('hidden');
    if (document.querySelector('.hackney-work-order-rows')) {
      repairHistoryYearsInfo[i].innerHTML = 'Repairs history is showing jobs raised in the <strong>last 5 years</strong>.'
    } else {
      repairHistoryYearsInfo[i].innerHTML = 'There are no work orders within the <strong>last 5 years</strong>.'
    }
  }

  for(var i = 0; i < loadRepairsDiv.length; i++) {
    loadRepairsDiv[i].parentNode.removeChild(loadRepairsDiv[i]);
  }
}
