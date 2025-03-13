import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details"]

  expandDetails(event) {
    event.stopPropagation();
    const container = this.detailsTarget;
    const column = this.element.closest(".deal-column");

    if (container.innerHTML.trim() !== '') {
      container.innerHTML = '';
      column.classList.remove("expanded");
      return;
    }

    const dealId = this.element.dataset.dealId;

    fetch(`/deals/${dealId}/related`)
      .then(response => response.text())
      .then(html => {
        container.innerHTML = html;
        column.classList.add("expanded");
      })
      .catch(err => console.error(err));
  }
}
