// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

import { Application } from "@hotwired/stimulus"
window.Stimulus = Application.start()

import DealController  from "./controllers/deal_controller.js"
Stimulus.register("deal", DealController)
