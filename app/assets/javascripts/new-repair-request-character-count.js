function characterCount() {
  var descriptionText = document.getElementById("hackney_repair_request_description");
  var counter = document.getElementById("counter");
  var maxLength = counter.dataset.maximumLength;

  counter.innerText = (maxLength - descriptionText.value.length);
}
