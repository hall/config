class InternalIframe extends HTMLElement {
  setConfig(config) {
    if (!config.path) {
      throw new Error("You must specify a path");
    }

    this.innerHTML = `<iframe onload="cleanUpIframe()" id="internal-iframe" src="${config.path}" height="100%" width="100%"></iframe>`;
  }

  cleanUpIframe() {
    document.getElementById("internal-iframe").querySelector('ha-sidebar').style.display = 'none';
  }

}

customElements.define("internal-iframe", InternalIframe);
