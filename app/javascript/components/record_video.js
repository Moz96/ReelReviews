const initRecordVideo = () => {
  const start = document.getElementById("start");
  const stop = document.getElementById("stop");
  const live = document.getElementById("live");
  const stopVideo = () => {
    live.srcObject.getTracks().forEach(track => track.stop());
  }
  // stop.addEventListener("click", stopVideo);
  const stopRecording = () => {
    return new Promise(resolve => stop.addEventListener("click",   resolve));
  }
  const startRecording = (stream) => {
    const recorder = new MediaRecorder(stream);
    let data = [];
  recorder.ondataavailable = event => data.push(event.data);
    recorder.start();
  const stopped = new Promise((resolve, reject) => {
      recorder.onstop = resolve;
      recorder.onerror = event => reject(event.name);
    });
  const recorded = stopRecording().then(
      () => {
        stopVideo();
        recorder.state == "recording" && recorder.stop();
      }
    );
  return Promise.all([
      stopped,
      recorded
    ])
    .then(() => data);
  }
  start.addEventListener("click", () => {
    navigator.mediaDevices.getUserMedia({
      video: true,
      audio: true
    })
    .then(stream => {
      live.srcObject = stream;
      live.captureStream = live.captureStream || live.mozCaptureStream;
      return new Promise(resolve => live.onplaying = resolve);
    })
    .then(() => startRecording(live.captureStream()))
    .then (recordedChunks => {
      const recordedBlob = new Blob(recordedChunks, { type: "video/webm" });
      console.log(recordedBlob);
    })
  });
}
export { initRecordVideo };
