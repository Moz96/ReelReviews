import { Controller } from "@hotwired/stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = ['recordButton', 'videoElement', 'form'];

  static isFrontFacing = true;
  static form = document.getElementById('form');

  isRecording = false;
  recorder = null;
  stream = null;

  connect() {
    console.log('Record Video controller connected');

    navigator.mediaDevices.getUserMedia({ video: true, audio: true })
      .then(() => {
        console.log('Camera access permission granted');
        this.start();
      })
      .catch((error) => {
        console.error('Error accessing camera:', error);
      });
  }

  toggleRecording() {
    if (this.isRecording) {
      this.stop();
    } else {
      this.startRecording();
    }
  }

  start() {
    let cameraMode = this.isFrontFacing ? 'environment' : 'user';
    console.log("Start called with camera mode: " + cameraMode);
    return navigator.mediaDevices.getUserMedia({
      video: {
        facingMode: {
          ideal: cameraMode
        }
      },
      audio: true
    })
      .then((stream) => {
        this.stream = stream;
        this.videoElementTarget.srcObject = stream;
        this.videoElementTarget.captureStream = this.videoElementTarget.captureStream || this.videoElementTarget.mozCaptureStream;
        return new Promise((resolve) => (this.videoElementTarget.onplaying = resolve));
      })
      .catch((error) => {
        console.error("Error starting camera:", error);
      });
  }

  stop() {
    this.recorder.stop();
    this.stream.getTracks().forEach((track) => track.stop());
    this.isRecording = false;
    this.recorder = null;
    this.stream = null;
  }

  startRecording() {
    this.isRecording = true;
    this.recorder = this.startMediaRecorder(this.stream);
  }

  startMediaRecorder(stream) {
    const recorder = new MediaRecorder(stream);
    let data = [];

    recorder.ondataavailable = (event) => data.push(event.data);
    recorder.start();
    recorder.recordedChunks = data;

    recorder.onstop = () => {
      let recordedChunks = recorder.recordedChunks;
      let recordedBlob = new Blob(recordedChunks, { type: "video/webm" });

      if (recordedBlob.size === 0) {
        console.error("Recorded Blob is empty. Recording failed.");
        return;
      }
      this.enableForm();
      this.uploadToCloudinary(recordedBlob);
    };

    return recorder;
  }

  enableForm() {
    this.formTarget.style.opacity = '1';
    this.submit_button = document.getElementById('submit_button');
  }

  uploadToCloudinary(videoBlob) {
    const formData = new FormData();
    formData.append('file', videoBlob, 'my_video');
    formData.append('upload_preset', 'm2tzhcc6');

    fetch('https://api.cloudinary.com/v1_1/dfmuyxggs/upload', {
      method: 'POST',
      body: formData
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.secure_url) {
          // Store the video URL and the public_id in hidden fields
          document.querySelector('#hidden_video_url').value = data.secure_url;
          document.querySelector('#hidden_video_public_id').value = data.public_id;
          this.submit_button.value = 'Post Reel Review';
          this.submit_button.disabled = false;
        }
      })
      .catch((error) => console.error('Error uploading video:', error));
  }

  savePost() {
    const formData = new FormData(this.form);
    console.log(formData);
    Rails.ajax({
      url: '/posts',
      type: "post",
      data: formData,
      success: (response) => {
        console.log("Post saved successfully:", response);
        // Handle success response as needed
      },
      error: (error) => {
        console.error("Error saving post:", error);
        // Handle error response as needed
      }
    });
  }
}
