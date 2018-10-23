function handleToggleTrade() {
  var filterCheckBoxes = document.querySelectorAll('.trade-filter-checkbox:checked');
  var workOrders = document.querySelectorAll('.hackney-work-order-rows.repairs-history');

  var showTheseTrades = [];

  for(var i = 0; i < filterCheckBoxes.length; i++) {
    showTheseTrades.push(filterCheckBoxes[i].id);
  }

  if (showTheseTrades.length == 0) {
    for(var i = 0; i < workOrders.length; i++) {
      workOrders[i].classList.remove('hidden');
    }
  } else {

    for(var i = 0; i < workOrders.length; i++) {
      workOrders[i].classList.add('hidden');
      if (showTheseTrades.indexOf(workOrders[i].getAttribute("data-trade")) >= 0) {
        workOrders[i].classList.remove('hidden');
      }
    }
  }
}

function handleClearAllFilters() {
  var filterCheckBoxes = document.querySelectorAll('.trade-filter-checkbox:checked');
  var workOrders = document.querySelectorAll('.hackney-work-order-rows.repairs-history');

  for(var i = 0; i < filterCheckBoxes.length; i++) {
    filterCheckBoxes[i].checked = false;
  }
  for(var i = 0; i < workOrders.length; i++) {
    workOrders[i].classList.remove('hidden');
  }
}

function collapsibleFilter(hierarchyOrTrade) {
  var collapsible = document.querySelector(hierarchyOrTrade + '-filter-collapsible');
  var content = document.querySelector(hierarchyOrTrade + '-hackney-checkbox');

  if (content.style.display === "none") {
    content.style.display = "block";
    collapsible.classList.remove('up-arrow');
    collapsible.classList.add('up-arrow');
  } else {
    content.style.display = "none";
    collapsible.classList.remove('up-arrow');
    collapsible.classList.add('down-arrow');
  }
}
