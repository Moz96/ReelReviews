import { Application } from "@hotwired/stimulus"
import PlacesController from "./places";

const application = Application.start()
application.register("places", PlacesController);


// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
