let currentIndex = 0;
const slides = document.querySelector('.slides');
const slideWidth = document.querySelector('.slide').offsetWidth;
const totalSlides = document.querySelectorAll('.slide').length;

slides.style.transform = `translateX(-${slideWidth * currentIndex}px)`;

function moveSlide(direction) {
  currentIndex += direction;
  slides.style.transition = 'transform 1s ease-in-out';
  slides.style.transform = `translateX(-${slideWidth * currentIndex}px)`;

  // 等动画结束后（0.5s），瞬间切换位置
  setTimeout(() => {
    if (currentIndex === totalSlides - 1) {
      slides.style.transition = 'none'; // 移除动画
      currentIndex = 0; // 跳回真正的第一张
      slides.style.transform = `translateX(-${slideWidth * currentIndex}px)`;
    } 
  }, 1000); // CSS 过渡时间一致
}

// 自动滑动
function startAutoSlide() {
    autoSlideInterval = setInterval(() => moveSlide(1), 5000);
  }
  
  // 停止自动滑动
  function stopAutoSlide() {
    clearInterval(autoSlideInterval);
  }
  
  // 当标签页不可见时暂停动画
  document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
      stopAutoSlide();  // 停止自动滑动
    } else {
      startAutoSlide(); // 恢复自动滑动
    }
  });
  
  // 初始化自动滑动
  startAutoSlide();