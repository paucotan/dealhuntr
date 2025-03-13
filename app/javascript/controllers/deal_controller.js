import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details"]

  connect() {
    this.expanded = false;
  }

  expandDetails(event) {
    event.stopPropagation();
    const container = this.detailsTarget;
    const column = this.element.closest(".deal-column");

    if (this.expanded) {
      container.innerHTML = '';
      column.classList.remove("expanded");
      this.expanded = false;
      return;
    }

    const dealId = this.element.dataset.dealId;

    fetch(`/deals/${dealId}/related`)
      .then(response => response.text())
      .then(html => {
        container.innerHTML = html;
        column.classList.add("expanded");
        this.expanded = true;
      })
      .catch(err => console.error(err));
  }
}
