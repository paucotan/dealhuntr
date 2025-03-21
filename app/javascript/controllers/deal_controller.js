import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["details"]

  expandDetails(event) {
    event.stopPropagation();
    event.preventDefault();
    const container = this.element;
    const dealId = this.element.dataset.dealId;
    const parentColumn = container.closest(".deal-column");

    this.collapseOtherCards();

    if (container.classList.contains("expanded")) {
      container.classList.remove("expanded");
      parentColumn.style.width = "";
      container.innerHTML = container.dataset.originalContent || "";
      return;
    }

    // we need to save the original content in a data attribute for future
    container.dataset.originalContent = container.innerHTML;

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

  swapWithRelated(event) {
    event.stopPropagation();
    event.preventDefault();

    const container = this.element;
    const relatedDealId = event.currentTarget.dataset.dealId;

    // we collapse any other deal cards that might be open
    this.collapseOtherCards();

    // now update the element id of the deal
    this.element.dataset.dealId = relatedDealId;

    // we fetch the content of the selected related deal
    fetch(`/deals/${relatedDealId}/related`)
      .then(response => response.text())
      .then(html => {
        container.innerHTML = html;
        container.classList.add("expanded");
      })
      .catch(err => console.error(err));
  }

  collapseOtherCards() {
    const expandedCards = document.querySelectorAll(".expanded");
    expandedCards.forEach(card => {
      if (card !== this.element) {
        card.classList.remove("expanded");
        const parentColumn = card.closest(".deal-column");
        if (parentColumn) {
          parentColumn.style.width = "";
        }
        // and now we restore the original content from the data attribute
        if (card.dataset.originalContent) {
          card.innerHTML = card.dataset.originalContent;
        }
      }
    });
  }
}
