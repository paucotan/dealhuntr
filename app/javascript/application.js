// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
window.Turbo = Turbo;
import "controllers"
import "@popperjs/core"
import "bootstrap"

// import { Application } from "@hotwired/stimulus"
// window.Stimulus = Application.start()

// import DealController  from "./controllers/deal_controller.js"
// Stimulus.register("deal", DealController)

// Use event delegation to handle clicks on .fav-btn elements and prevent bubbling
document.addEventListener("click", async (event) => {
  const target = event.target;
  const button = target.closest(".fav-btn");
  if (!button) {
    console.log("Click event on non-fav-btn element:", target);
    return;
  }

  console.log("Favorites button clicked, stopping propagation");
  event.stopPropagation(); // Prevent the click from bubbling up to expandDetails

  const form = button.closest("form");
  if (!form) {
    console.error("Favorites button is not inside a form");
    return;
  }

  event.preventDefault(); // Prevent the form from submitting as a full page request

  const icon = button.querySelector("i");
  if (!icon) {
    console.error("Favorites button does not contain an icon");
    return;
  }

  // Optimistically toggle the UI
  const isFavorited = icon.classList.contains("fa-solid");
  if (isFavorited) {
    icon.classList.remove("fa-solid");
    icon.classList.add("fa-regular");
  } else {
    icon.classList.remove("fa-regular");
    icon.classList.add("fa-solid");
  }

  try {
    const response = await fetch(form.action, {
      method: form.method,
      body: new FormData(form),
      headers: {
        "X-Requested-With": "XMLHttpRequest",
        "Accept": "text/vnd.turbo-stream.html",
      },
    });

    if (!response.ok) {
      // Revert the UI if the server request fails
      if (isFavorited) {
        icon.classList.remove("fa-regular");
        icon.classList.add("fa-solid");
      } else {
        icon.classList.remove("fa-solid");
        icon.classList.add("fa-regular");
      }
      console.error("Failed to update favorite:", response.statusText);
      return;
    }

    // Handle the Turbo Stream response
    const turboStream = await response.text();
    console.log("Turbo Stream response:", turboStream);
    if (turboStream) {
      Turbo.renderStreamMessage(turboStream);
    }
  } catch (err) {
    // Revert the UI on network error
    if (isFavorited) {
      icon.classList.remove("fa-regular");
      icon.classList.add("fa-solid");
    } else {
      icon.classList.remove("fa-solid");
      icon.classList.add("fa-regular");
    }
    console.error("Error updating favorite:", err);
  }
});
