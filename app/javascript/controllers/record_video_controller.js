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

  switchCamera() {
    const videoTracks = this.videoElementTarget.srcObject.getVideoTracks();
    if (videoTracks.length === 0) return;

    const currentFacingMode = videoTracks[0].getSettings().facingMode;
    const newFacingMode = currentFacingMode === 'user' ? 'environment' : 'user';

    const videoConstraints = {
      video: { facingMode: { exact: newFacingMode } },
      audio: true
    };

    navigator.mediaDevices.getUserMedia(videoConstraints)
      .then((stream) => {
        this.videoElementTarget.srcObject = stream;
      })
      .catch((error) => console.error('Error switching camera:', error));
  }
  // uploadToCloudinary(videoBlob) {
  //   const formData = new FormData();
  //   formData.append('video[file]', videoBlob, 'my_video.mp4');

  //   Rails.ajax({
  //     url: "/posts/videos",
  //     type: "post",
  //     data: formData,
  //     success: () => {
  //       this.savePost();
  //     },
  //     error: (error) => {
  //       console.error("Error uploading video:", error);
  //       // Handle error response as needed
  //     }
  //   });
  // }

  uploadToCloudinary(videoBlob) {
    const formData = new FormData();
    formData.append('file', videoBlob, 'my_video');
    formData.append('upload_preset', 'rpa47g8k');

    fetch('https://api.cloudinary.com/v1_1/dwang9o22/upload', {
      method: 'POST',
      body: formData
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.secure_url) {
          // Store the video URL and the public_id in hidden fields
          document.querySelector('#hidden_video_url').value = data.secure_url;
          document.querySelector('#hidden_video_public_id').value = data.public_id;
          this.savePost();
        }
      })
      .catch((error) => console.error('Error uploading video:', error));
  }

  savePost() {
    const place_id = this.element.dataset.placeId;
    const form = this.element.querySelector("form");
    const formData = new FormData(form);

    Rails.ajax({
      url: `/places/${place_id}/posts`,
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
