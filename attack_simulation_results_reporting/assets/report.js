/* Optional index filtering; evidence and detailed results remain static HTML. */
"use strict";
(() => {
  const rows = Array.from(document.querySelectorAll("[data-scenario-row]"));
  const controls = document.querySelector("[data-filters]");
  const search = document.getElementById("scenario-search");
  const coverage = document.getElementById("coverage-filter");
  const count = document.getElementById("filter-count");
  const empty = document.getElementById("filter-empty");
  if (rows.length && controls && search && coverage && count && empty) {
    const filter = () => {
      const query = search.value.trim().toLocaleLowerCase();
      let visible = 0;
      for (const row of rows) {
        const matchesText = row.textContent.toLocaleLowerCase().includes(query);
        const matchesCoverage = coverage.value === "all" || row.dataset.coverage === coverage.value;
        row.hidden = !(matchesText && matchesCoverage);
        if (!row.hidden) visible += 1;
      }
      count.textContent = visible + " of " + rows.length + " scenarios shown";
      empty.hidden = visible !== 0;
    };
    controls.hidden = false;
    search.addEventListener("input", filter);
    coverage.addEventListener("change", filter);
    filter();
  }
  let previousDetails = [];
  window.addEventListener("beforeprint", () => {
    previousDetails = Array.from(document.querySelectorAll("details")).map(item => [item, item.open]);
    for (const [item] of previousDetails) item.open = true;
  });
  window.addEventListener("afterprint", () => {
    for (const [item, wasOpen] of previousDetails) item.open = wasOpen;
    previousDetails = [];
  });
})();
