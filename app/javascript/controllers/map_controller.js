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
  
    this.addMarkersToMap()
    this.#fitMapToMarkers()
  }  

  addMarkersToMap() {
    this.markersValue.forEach((marker) => {
      const popup = new mapboxgl.Popup().setHTML(marker.info_window_html) // Add this
      new mapboxgl.Marker()
      .setLngLat([ marker.lng, marker.lat ])
      .setPopup(popup) // Add this
      .addTo(this.map)
    })
  }
  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach(marker => bounds.extend([ marker.lng, marker.lat ]))
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 0 })
  }
}
