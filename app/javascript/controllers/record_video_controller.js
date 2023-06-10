import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="record-video"
export default class extends Controller {
  static targets = ['startButton', 'stopButton', 'videoElement'];

  connect() {
    console.log('Record Video controller connected');
  }

  start() {
    navigator.mediaDevices.getUserMedia({ video: true, audio: true })
      .then((videoElement) => {
        this.videoElementTarget.srcObject = videoElement;
        this.videoElementTarget.captureStream = this.videoElementTarget.captureStream || this.videoElementTarget.mozCaptureStream;
        console.log(this.videoElementTarget)
        return new Promise((resolve) => (this.videoElementTarget.onplaying = resolve));
      })
      .then(() => this.startRecording(this.videoElementTarget.captureStream()))
      .then((recordedChunks) => {
        const recordedBlob = new Blob(recordedChunks, { type: 'video/webm' });
        //console.log(recordedBlob);
      });
  }

  startRecording(videoElement) {
    const recorder = new MediaRecorder(videoElement);
    let data = [];

    recorder.ondataavailable = (event) => data.push(event.data);
    recorder.start();

    const stopped = new Promise((resolve, reject) => {
      recorder.onstop = resolve;
      recorder.onerror = (event) => reject(event.name);
    });

    const stopRecording = () => {
      return new Promise((resolve) => this.stopButtonTarget.addEventListener('click', resolve));
    };

    const recorded = stopRecording().then(() => {
      this.stopVideo();
      if (recorder.state === 'recording') {
        recorder.stop();
      }
    });

    return Promise.all([stopped, recorded]).then(() => data);
  }

  stopVideo() {
    this.videoElementTarget.srcObject.getTracks().forEach((track) => track.stop());
  }
}
