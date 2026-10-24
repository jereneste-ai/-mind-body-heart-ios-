const apps = [
  {
    id: "hyvinn",
    name: "Hyvinn",
    tag: "Complete wellbeing",
    accent: "#1d6d4e",
    summary: "The main wellbeing platform for mental clarity, physical strength, and sustainable daily routines.",
    features: ["Mental wellbeing", "Physical health", "Recovery", "Progress tracking"],
    details: ["Mind", "Body", "Heart", "Everyday life"]
  },
  {
    id: "hyvinn-kirjaus",
    name: "Hyvinn Kirjaus",
    tag: "Journal & tracking",
    accent: "#d8b35d",
    summary: "Track habits, reflect on emotions, and log daily progress in a calm personal space.",
    features: ["Daily journal", "Weekly check-ins", "Progress notes", "Personal rhythms"],
    details: ["Reflection", "Habits", "Energy", "Growth"]
  },
  {
    id: "always-kindly",
    name: "Always Kindly",
    tag: "Human-centered growth",
    accent: "#111111",
    summary: "A compassionate space for emotional awareness, self-kindness, identity, and recovery support.",
    features: ["Self-awareness", "Recovery support", "Relationships", "Meaningful living"],
    details: ["Compassion", "Identity", "Support", "Transformation"]
  },
  {
    id: "always-kindly-kirjaus",
    name: "Always Kindly Kirjaus",
    tag: "Reflection & reset",
    accent: "#3f675d",
    summary: "A quiet journaling companion for emotional processing, reflection, and long-term change.",
    features: ["Emotional journaling", "Decision support", "Breathing & reflection", "Self-compassion"],
    details: ["Calm", "Clarity", "Growth", "Purpose"]
  }
];

const categories = [
  { title: "Mind", description: "Mental wellbeing, self-awareness, and emotional development." },
  { title: "Body", description: "Physical health, strength, recovery, and nutrition." },
  { title: "Heart", description: "Values, compassion, identity, and human connection." },
  { title: "Everyday Life", description: "Daily routines, focus, learning, and sustainable habits." }
];

const weeklyFocus = [
  "Notice one meaningful thing you are grateful for this week.",
  "Plan one recovery habit that supports your energy and sleep.",
  "Choose one healthy action for body, mind, and heart.",
  "Protect one daily rhythm that helps you feel grounded."
];

const heroLabels = [
  "Mental wellbeing",
  "Physical health",
  "Recovery",
  "Emotional intelligence",
  "Learning",
  "Personal growth"
];

const state = {
  selectedApp: "hyvinn",
  entries: [
    { text: "Today I choose one gentle step toward a healthier routine.", time: new Date().toISOString() },
    { text: "My wellbeing is a system: mind, body, heart, and daily life are connected.", time: new Date().toISOString() }
  ]
};

const $ = (selector) => document.querySelector(selector);

function toast(message) {
  const status = $("#status");
  status.textContent = message;
  status.style.display = "block";
  clearTimeout(toast.timeoutId);
  toast.timeoutId = setTimeout(() => {
    status.style.display = "none";
  }, 2800);
}

function saveState() {
  try {
    localStorage.setItem("hyvinn-state-v1", JSON.stringify(state));
  } catch (error) {
    console.warn("Local storage unavailable.", error);
  }
}

function loadState() {
  try {
    const saved = JSON.parse(localStorage.getItem("hyvinn-state-v1") || "null");
    if (!saved) return;
    if (saved.selectedApp) state.selectedApp = saved.selectedApp;
    if (Array.isArray(saved.entries) && saved.entries.length) state.entries = saved.entries;
  } catch (error) {
    console.warn("Could not restore saved state.", error);
  }
}

function renderHeroChips() {
  $("#heroChips").innerHTML = heroLabels.map((label) => `<span class="chip">${label}</span>`).join("");
}

function renderWeeklyFocus() {
  $("#weeklyFocus").innerHTML = weeklyFocus.map((item) => `<li>${item}</li>`).join("");
}

function renderCategories() {
  $("#categoryGrid").innerHTML = categories
    .map(
      (category) => `
        <div class="category-card">
          <strong>${category.title}</strong>
          <span>${category.description}</span>
        </div>
      `
    )
    .join("");
}

function renderSelectedApp() {
  const app = apps.find((item) => item.id === state.selectedApp) || apps[0];
  $("#selectedApp").innerHTML = `
    <h4>${app.name}</h4>
    <p>${app.summary}</p>
    <div class="detail-grid">
      ${app.details.map((detail) => `<span class="detail-pill">${detail}</span>`).join("")}
    </div>
  `;
}

function renderApps() {
  $("#appGrid").innerHTML = apps
    .map(
      (app) => `
        <button class="app-card ${app.id === state.selectedApp ? "selected" : ""}" data-app="${app.id}" type="button" style="border-color: ${app.id === state.selectedApp ? app.accent : "rgba(18, 62, 46, 0.12)"};">
          <span class="tag" style="background: ${app.accent}20; color: ${app.accent};">${app.tag}</span>
          <h4>${app.name}</h4>
          <p>${app.summary}</p>
          <ul>
            ${app.features.map((feature) => `<li>${feature}</li>`).join("")}
          </ul>
        </button>
      `
    )
    .join("");

  $("#appGrid").querySelectorAll(".app-card").forEach((button) => {
    button.addEventListener("click", () => {
      state.selectedApp = button.dataset.app;
      renderApps();
      renderSelectedApp();
      saveState();
      toast(`${apps.find((item) => item.id === state.selectedApp)?.name || "Hyvinn"} selected`);
    });
  });
}

function renderEntries() {
  $("#entryList").innerHTML = state.entries
    .slice(0, 6)
    .map(
      (entry) => `
        <li>
          ${entry.text}
          <small>${new Date(entry.time).toLocaleString([], { dateStyle: "medium", timeStyle: "short" })}</small>
        </li>
      `
    )
    .join("");
}

function addEntry() {
  const value = $("#journalEntry").value.trim();
  if (!value) {
    toast("Write a reflection first.");
    return;
  }

  state.entries.unshift({ text: value, time: new Date().toISOString() });
  $("#journalEntry").value = "";
  renderEntries();
  saveState();
  toast("Entry saved");
}

function exportData() {
  const payload = {
    ...state,
    exportedAt: new Date().toISOString()
  };

  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeExport) {
    window.webkit.messageHandlers.nativeExport.postMessage(payload);
    toast("Export started");
    return;
  }

  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "hyvinn-export.json";
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
  toast("Export created");
}

document.addEventListener("DOMContentLoaded", () => {
  loadState();
  renderHeroChips();
  renderWeeklyFocus();
  renderCategories();
  renderApps();
  renderSelectedApp();
  renderEntries();

  $("#saveButton").addEventListener("click", () => {
    saveState();
    toast("Saved locally");
  });

  $("#exportButton").addEventListener("click", exportData);
  $("#addEntry").addEventListener("click", addEntry);
});

window.state = state;
