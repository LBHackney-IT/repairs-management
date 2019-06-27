function characterCount(event) {
  var descriptionText = event.target;
  var counter = document.getElementById("counter");
  var maxLength = counter.dataset.maximumLength;

  counter.innerText = (maxLength - descriptionText.value.length);
}
