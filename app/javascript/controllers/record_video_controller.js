import { Controller } from "@hotwired/stimulus";
import Rails from "@rails/ujs";

export default class extends Controller {
  static targets = ['recordButton', 'videoElement', 'form'];

  static isFrontFacing = true;
  static form = document.getElementById('form');
  // static recordingTimeMS = 5000;

  isRecording = false;

  connect() {
    console.log('Record Video controller connected');
    // this.constructor.form = document.getElementById('form');
    // this.constructor.form.addEventListener("submit", this.handleFormSubmission.bind(this));
  }

  toggleRecording() {
    if (this.isRecording) {
      this.stop();
    } else {
      this.start();
      }
    }

  start() {
    let cameraMode = this.isFrontFacing ? 'environment' : 'user';
    console.log("Start called with camera mode: " + cameraMode);
    return navigator.mediaDevices.getUserMedia({
      video: {
        facingMode: {
          // Using ideal instead of exact so we can test on devices other than mobile
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
    .then(() => {
      this.isRecording = true;
      this.recorder = this.startRecording(this.videoElementTarget.captureStream());
      this.recorder.onstop = () => {
        let recordedChunks = this.recorder.recordedChunks;
        let recordedBlob = new Blob(recordedChunks, { type: "video/webm" });

        if (recordedBlob.size === 0) {
          console.error("Recorded Blob is empty. Recording failed.");
          return;
        }
        this.enableForm();
        this.uploadToCloudinary(recordedBlob);
      };
    })
    .catch((error) => {
      console.error("Error starting recording:", error);
    });
  }

  enableForm () {
    this.formTarget.style.display = 'block';
    this.submit_button = document.getElementById('submit_button');
  }

  stop() {
    this.recorder.stop();
    this.stream.getTracks().forEach((track) => track.stop());
    this.isRecording = false;
  };

  toggleFlag() {
    console.log("isFrontFacing before toggle: " + this.isFrontFacing);
    this.isFrontFacing = !this.isFrontFacing;
    console.log("isFrontFacing after toggle: " + this.isFrontFacing);
    this.start();
  }

  startRecording(stream) {
    const recorder = new MediaRecorder(stream);
    let data = [];

    recorder.ondataavailable = (event) => data.push(event.data);
    recorder.start();
    recorder.recordedChunks = data;

    return recorder;
  }

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
          this.submit_button.value = 'Post Reel Review';
          this.submit_button.disabled = false;
        }
      })
      .catch((error) => console.error('Error uploading video:', error));
  }

  savePost() {
  const formData = new FormData(this.form);
   console.log(formData)
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


 // switchCamera() {
  //   const constraints = {
  //     video: {
  //       facingMode: {
  //         exact: 'environment'
  //       }
  //     },
  //     audio: true
  //   };

  //   const currentStream = this.videoElementTarget.srcObject;

  //   navigator.mediaDevices.getUserMedia(constraints)
  //     .then((stream) => {
  //       const videoTracks = stream.getVideoTracks();
  //       currentStream.getVideoTracks().forEach((track) => track.stop());
  //       videoTracks.forEach((track) => currentStream.addTrack(track));
  //       this.videoElementTarget.srcObject = currentStream;
  //     })
  //     .catch((error) => {
  //       console.error('Error switching camera:', error);
  //       this.videoElementTarget.srcObject = currentStream;
  //     });
  // }

 // switchCamera() {
   // const videoTracks = this.videoElementTarget.srcObject.getVideoTracks();
   // if (videoTracks.length === 0) return;

   // const currentFacingMode = videoTracks[0].getSettings().facingMode;
   // const newFacingMode = currentFacingMode === 'user' ? 'environment' : 'user';

   // const videoConstraints = {
     // video: { facingMode: { exact: newFacingMode } },
     // audio: true
   // };

   // navigator.mediaDevices.getUserMedia(videoConstraints)
     // .then((stream) => {
       // this.videoElementTarget.srcObject = stream;
     // })
     // .catch((error) => {
      //  console.error('Error switching camera:', error);
     // });
  //}
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
