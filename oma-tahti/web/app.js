const moodOptions = [
  { label: "Rauhallinen", value: "calm" },
  { label: "Virkeä", value: "energized" },
  { label: "Väsynyt", value: "tired" },
  { label: "Stressaantunut", value: "stressed" },
  { label: "Toiveikas", value: "hopeful" }
];

const prompts = [
  "Mitä yksi pieni asia teki minulle hyvää tänään?",
  "Millainen minun tuli olla itseni kanssa tänään?",
  "Mikä antoi minulle energiaa ja mikä vei sitä pois?",
  "Mitä voisin tehdä huomenna, jotta arki tuntuu helpommalta?"
];

const state = {
  selectedMood: "calm",
  energy: 7,
  sleep: 6,
  reflection: "",
  support: "",
  nextStep: "",
  entries: []
};

const $ = (selector) => document.querySelector(selector);

function toast(message) {
  const status = $("#status");
  status.textContent = message;
  status.style.display = "block";
  clearTimeout(toast.timeoutId);
  toast.timeoutId = setTimeout(() => {
    status.style.display = "none";
  }, 2600);
}

function formatDate(date = new Date()) {
  return new Intl.DateTimeFormat("fi-FI", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric"
  }).format(date);
}

function loadState() {
  try {
    const saved = JSON.parse(localStorage.getItem("always-kindly-hyvinn-state") || "null");
    if (!saved) return;
    Object.assign(state, saved);
  } catch (error) {
    console.warn("State restore failed", error);
  }
}

function saveState() {
  try {
    localStorage.setItem("always-kindly-hyvinn-state", JSON.stringify(state));
  } catch (error) {
    console.warn("Local storage unavailable", error);
  }
}

function renderDate() {
  $("#todayDate").textContent = formatDate();
}

function renderMetrics() {
  $("#heroMetrics").innerHTML = `
    <div class="metric">Energia: ${state.energy}/10</div>
    <div class="metric">Uni: ${state.sleep}/10</div>
    <div class="metric">Tila: ${moodOptions.find((item) => item.value === state.selectedMood)?.label || "Rauhallinen"}</div>
  `;
}

function renderMoodButtons() {
  $("#moodRow").innerHTML = moodOptions
    .map((mood) => `
      <button class="mood-btn ${state.selectedMood === mood.value ? "active" : ""}" data-mood="${mood.value}" type="button">
        ${mood.label}
      </button>
    `)
    .join("");

  $("#moodRow").querySelectorAll(".mood-btn").forEach((button) => {
    button.addEventListener("click", () => {
      state.selectedMood = button.dataset.mood;
      renderMoodButtons();
      renderMetrics();
    });
  });
}

function renderPrompts() {
  $("#promptList").innerHTML = prompts
    .map((prompt) => `<div class="prompt-card">${prompt}</div>`)
    .join("");
}

function renderSummary() {
  const averageEnergy = state.entries.length ? Math.round(state.entries.reduce((sum, item) => sum + item.energy, 0) / state.entries.length) : state.energy;
  const averageSleep = state.entries.length ? Math.round(state.entries.reduce((sum, item) => sum + item.sleep, 0) / state.entries.length) : state.sleep;

  $("#summaryGrid").innerHTML = `
    <div class="summary-box">
      <span class="label">Merkinnät</span>
      <span class="value">${state.entries.length}</span>
    </div>
    <div class="summary-box">
      <span class="label">Energia</span>
      <span class="value">${averageEnergy}/10</span>
    </div>
    <div class="summary-box">
      <span class="label">Uni</span>
      <span class="value">${averageSleep}/10</span>
    </div>
  `;
}

function renderEntries() {
  const list = $("#entriesList");
  if (!state.entries.length) {
    list.innerHTML = '<div class="entry-card"><p>Ei vielä merkintöjä. Aloita ensimmäinen kirjaus.</p></div>';
    return;
  }

  list.innerHTML = state.entries
    .slice(0, 12)
    .map((entry) => `
      <article class="entry-card">
        <h4>${entry.moodLabel} · ${entry.date}</h4>
        <p><strong>Mitä koen:</strong> ${entry.reflection || "—"}</p>
        <p><strong>Mitä tukee:</strong> ${entry.support || "—"}</p>
        <p><strong>Seuraava askel:</strong> ${entry.nextStep || "—"}</p>
        <div class="entry-meta">
          <span>Energia ${entry.energy}/10</span>
          <span>Uni ${entry.sleep}/10</span>
        </div>
      </article>
    `)
    .join("");
}

function syncInputs() {
  $("#energy").value = state.energy;
  $("#sleep").value = state.sleep;
  $("#energyValue").textContent = `${state.energy}/10`;
  $("#sleepValue").textContent = `${state.sleep}/10`;
  $("#reflection").value = state.reflection;
  $("#support").value = state.support;
  $("#nextStep").value = state.nextStep;
}

function saveEntry() {
  const reflection = $("#reflection").value.trim();
  if (!reflection) {
    toast("Kirjoita ensin päivän tunnelma.");
    return;
  }

  const moodLabel = moodOptions.find((item) => item.value === state.selectedMood)?.label || "Rauhallinen";

  state.entries.unshift({
    date: formatDate(),
    moodLabel,
    energy: Number($("#energy").value),
    sleep: Number($("#sleep").value),
    reflection,
    support: $("#support").value.trim(),
    nextStep: $("#nextStep").value.trim()
  });

  state.reflection = "";
  state.support = "";
  state.nextStep = "";
  state.energy = 7;
  state.sleep = 6;
  state.selectedMood = "calm";

  syncInputs();
  renderMoodButtons();
  renderMetrics();
  renderSummary();
  renderEntries();
  saveState();
  toast("Merkintä tallennettu");
}

function exportData() {
  const payload = {
    app: "Always Kindly × Hyvinn",
    savedAt: new Date().toISOString(),
    entries: state.entries
  };

  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.nativeExport) {
    window.webkit.messageHandlers.nativeExport.postMessage(payload);
    toast("Vienti aloitettu");
    return;
  }

  const blob = new Blob([JSON.stringify(payload, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = "always-kindly-hyvinn.json";
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
  toast("Vienti valmis");
}

function clearEntries() {
  state.entries = [];
  renderSummary();
  renderEntries();
  saveState();
  toast("Merkinnät tyhjennetty");
}

document.addEventListener("DOMContentLoaded", () => {
  loadState();
  renderDate();
  renderPrompts();
  renderMoodButtons();
  renderMetrics();
  renderSummary();
  syncInputs();
  renderEntries();

  $("#energy").addEventListener("input", (event) => {
    state.energy = Number(event.target.value);
    $("#energyValue").textContent = `${state.energy}/10`;
    renderMetrics();
  });

  $("#sleep").addEventListener("input", (event) => {
    state.sleep = Number(event.target.value);
    $("#sleepValue").textContent = `${state.sleep}/10`;
    renderMetrics();
  });

  $("#reflection").addEventListener("input", (event) => {
    state.reflection = event.target.value;
  });

  $("#support").addEventListener("input", (event) => {
    state.support = event.target.value;
  });

  $("#nextStep").addEventListener("input", (event) => {
    state.nextStep = event.target.value;
  });

  $("#saveEntryBtn").addEventListener("click", saveEntry);
  $("#saveBtn").addEventListener("click", () => {
    saveState();
    toast("Tallennettu paikallisesti");
  });
  $("#exportBtn").addEventListener("click", exportData);
  $("#clearBtn").addEventListener("click", clearEntries);
});

window.state = state;
