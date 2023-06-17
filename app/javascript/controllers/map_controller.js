import { Controller } from "@hotwired/stimulus";
import mapboxgl from "mapbox-gl/dist/mapbox-gl.js";

export default class extends Controller {
  static values = {
    apiKey: String,
    markers:{type: Array, default: []},
  };

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;
  
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v10",
      center: [-0.1276, 51.5074], // London coordinates
      zoom: 10, // Adjust the zoom level as desired
    });
  
    this.addMarkersToMap();

  }  

  addMarkersToMap() {
    console.log(this.markersValue)
    this.markersValue.forEach((marker) => {
      new mapboxgl.Marker()
        .setLngLat([ marker.lng, marker.lat ])
        .addTo(this.map)
    })
  }
}
