function waitForElm(selector) {
  return new Promise(resolve => {
      if (document.querySelector(selector)) return resolve(document.querySelector(selector));

      const observer = new MutationObserver(mutations => {
          if (document.querySelector(selector)) {
              resolve(document.querySelector(selector));
              observer.disconnect();
          }
      });

      observer.observe(document.body, { childList: true, subtree: true });
  });
}

// move activity bar to bottom of sidebar
waitForElm('.sidebar').then((elm) => {
  elm.appendChild(document.querySelector('.activitybar'));
  console.log("hello");
});
