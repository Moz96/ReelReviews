import { Controller } from "@hotwired/stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = ['startButton', 'stopButton', 'videoElement'];

  connect() {
    console.log('Record Video controller connected');
  }

  start() {
    navigator.mediaDevices.getUserMedia({ video: true, audio: true })
      .then((stream) => {
        this.videoElementTarget.srcObject = stream;
        this.videoElementTarget.captureStream = this.videoElementTarget.captureStream || this.videoElementTarget.mozCaptureStream;
        console.log(this.videoElementTarget);
        return new Promise((resolve) => (this.videoElementTarget.onplaying = resolve));
      })
      .then(() => this.startRecording(this.videoElementTarget.captureStream()))
      .then((recordedChunks) => {
        const recordedBlob = new Blob(recordedChunks, { type: 'video/webm' });
        this.uploadToCloudinary(recordedBlob);
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
      this.stop();
      if (recorder.state === 'recording') {
        recorder.stop();
      }
    });

    return Promise.all([stopped, recorded]).then(() => data);
  }

  stop() {
    this.videoElementTarget.srcObject.getTracks().forEach((track) => track.stop());
  }

  uploadToCloudinary(videoBlob) {
    const formData = new FormData();
    formData.append('video[file]', videoBlob, 'my_video.mp4');

    Rails.ajax({
      url: "/videos",
      type: "post",
      data: formData
    });
  }
}
