import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="record-video"
export default class extends Controller {
  static targets = ['startButton', 'stopButton', 'videoElement'];

  connect() {
    console.log('Record Video controller connected');
  }

  start() {
    navigator.mediaDevices.getUserMedia({ video: true, audio: true })
      .then((stream) => {
        this.videoElementTarget.srcObject = stream;
      })
      .catch((error) => {
        console.error('Error starting recording:', error);
      });
  }

  stop() {
    const stream = this.videoElementTarget.srcObject;
    if (stream) {
      const tracks = stream.getTracks();
      tracks.forEach((track) => track.stop());
    }
  }
}
