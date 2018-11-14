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
  handleClickShowRepairsHistoryBtn();

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

function handleClickShowRepairsHistoryBtn() {
  var loadBtn = document.getElementById('load-repair-history-btn');
  var loadingText = document.createElement('p');

  document.querySelector('.repair-history-years-info').classList.add('hidden')
  loadingText.innerHTML = 'Loading repairs history'

  loadBtn.parentNode.replaceChild(loadingText, loadBtn);
  loadingText.classList.add('ajax-loading', 'govuk-caption-m');
}

function handleRepairHistoryYearsInfoText() {
  var repairHistoryYearsInfo = document.querySelectorAll('.repair-history-years-info');
  var loadRepairsDiv = document.querySelectorAll('.load-repairs-history');

  for(var i = 0; i < repairHistoryYearsInfo.length; i++) {
    repairHistoryYearsInfo[i].classList.remove('hidden');
  }

  for(var i = 0; i < repairHistoryYearsInfo.length; i++) {
    if (document.querySelector('.hackney-work-order-table')) {
      repairHistoryYearsInfo[i].innerHTML = 'Repairs history is showing jobs raised in the last <strong>5 years</strong>.'
    } else {
      repairHistoryYearsInfo[i].innerHTML = 'There are no work orders within the last <strong>5 years</strong>.'
    }
  }

  for(var i = 0; i < loadRepairsDiv.length; i++) {
    loadRepairsDiv[i].parentNode.removeChild(loadRepairsDiv[i]);
  }
}
