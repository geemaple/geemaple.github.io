let currentIndex = 0;

function moveSlide(direction = 1) {
  const slides = document.querySelector('.slides');
  const totalSlides = document.querySelectorAll('.slide').length;

  currentIndex = currentIndex + direction;

  // Loop back to the first slide if reaching the end
  if (currentIndex >= totalSlides) {
    currentIndex = 0;
  }
  // Loop back to the last slide if going back from the first
  if (currentIndex < 0) {
    currentIndex = totalSlides - 1;
  }

  const slideWidth = document.querySelector('.slide').offsetWidth;
  const newTransformValue = -(currentIndex * slideWidth);
  slides.style.transform = `translateX(${newTransformValue}px)`;
}

// Auto slide every 1 second
setInterval(() => moveSlide(1), 2500);