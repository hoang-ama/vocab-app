(() => {
  const ROOT_ID = "h2m-vocab-overlay-root";
  const LOAD_TIMEOUT_MS = 5000;

  const getRoot = () => document.getElementById(ROOT_ID);

  const removePanel = () => {
    const root = getRoot();
    if (root) root.remove();
  };

  const createFallback = (appUrl) => {
    const fallback = document.createElement("div");
    fallback.className = "h2m-fallback hidden";
    fallback.innerHTML = `
      <p>Cannot display the app inside this website.</p>
      <p class="h2m-fallback-hint">This page is likely blocking embedded iframes (CSP/X-Frame).</p>
      <button id="h2m-open-fallback-tab" type="button">Open App in New Tab</button>
    `;
    const openFallbackBtn = fallback.querySelector("#h2m-open-fallback-tab");
    openFallbackBtn?.addEventListener("click", () => window.open(appUrl, "_blank"));
    return fallback;
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
    const fallback = createFallback(appUrl);
    let isLoaded = false;

    const showFallback = () => {
      if (isLoaded) return;
      fallback.classList.remove("hidden");
      iframe.classList.add("hidden");
    };

    const hideFallback = () => {
      isLoaded = true;
      fallback.classList.add("hidden");
      iframe.classList.remove("hidden");
    };

    iframe.addEventListener("load", hideFallback, { once: true });
    iframe.addEventListener("error", showFallback, { once: true });
    window.setTimeout(showFallback, LOAD_TIMEOUT_MS);

    panel.appendChild(header);
    panel.appendChild(iframe);
    panel.appendChild(fallback);
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
