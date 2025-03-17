import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details"]

  expandDetails(event) {
    event.stopPropagation();
    const container = this.element;
    const dealId = this.element.dataset.dealId;
    const parentColumn = container.closest(".deal-column");

    if (container.classList.contains("expanded")) {
      container.classList.remove("expanded");
      parentColumn.style.width = "";
      container.innerHTML = this.originalContent || "";
      return;
    }

    this.originalContent = container.innerHTML;

    if (window.innerWidth <= 576) {
      parentColumn.style.width = "100%";
    }

    fetch(`/deals/${dealId}/related`)
      .then(response => response.text())
      .then(html => {
        container.innerHTML = html;
        container.classList.add("expanded");
      })
      .catch(err => console.error(err));
  }
  preventExpand(event) {
    event.stopPropagation();
  }
}
