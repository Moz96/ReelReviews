// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"
import { initRecordVideo } from './components/record_video';
document.addEventListener('turbolinks:load', () => {
  if(document.querySelector("#live")) {
    initRecordVideo();
  }
});
