import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cards"]
  connect() {
   console.log("hello")
  }

  toggle(){
    console.log("world")
  }
}
