(() => {
  const ROOT_ID = "h2m-vocab-overlay-root";

  const getRoot = () => document.getElementById(ROOT_ID);

  const removePanel = () => {
    const root = getRoot();
    if (root) root.remove();
  };

  const createPanel = (appUrl) => {
    removePanel();

    const root = document.createElement("div");
    root.id = ROOT_ID;

    const panel = document.createElement("div");
    panel.className = "h2m-panel";

    const header = document.createElement("div");
    header.className = "h2m-header";
    header.innerHTML = `
      <span>H2M Vocabulary Panel</span>
      <div class="h2m-actions">
        <button id="h2m-open-new-tab" title="Open in new tab">Open</button>
        <button id="h2m-close-panel" title="Close">Close</button>
      </div>
    `;

    const iframe = document.createElement("iframe");
    iframe.src = appUrl;
    iframe.referrerPolicy = "no-referrer";
    iframe.setAttribute("title", "H2M Vocabulary App");

    panel.appendChild(header);
    panel.appendChild(iframe);
    root.appendChild(panel);
    document.documentElement.appendChild(root);

    const closeBtn = root.querySelector("#h2m-close-panel");
    const openBtn = root.querySelector("#h2m-open-new-tab");
    closeBtn?.addEventListener("click", removePanel);
    openBtn?.addEventListener("click", () => window.open(appUrl, "_blank"));
  };

  chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
    if (!message || message.type !== "H2M_TOGGLE_PANEL") return;

    if (getRoot()) {
      removePanel();
      sendResponse({ ok: true, visible: false });
      return;
    }

    createPanel(message.appUrl);
    sendResponse({ ok: true, visible: true });
  });
})();
