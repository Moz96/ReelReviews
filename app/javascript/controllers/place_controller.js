import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="place"
export default class extends Controller {
  static targets = [ "post", "next", "prev" ]

  connect() {
    this.currentIndex = 0;
    this.placeId = this.element.id.split('_')[1];
    this.updatePostVisibility();
  }

  next() {
    if (this.currentIndex < this.postTargets.length - 1) {
      this.currentIndex++;
      this.updatePostVisibility();
      if (this.currentIndex === this.postTargets.length - 1) {
        this.loadMorePosts();
      }
    }
  }

  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.updatePostVisibility();
    }
  }

  updatePostVisibility() {
    this.postTargets.forEach((post, index) => {
      post.style.display = index === this.currentIndex ? 'block' : 'none';
    });
  }

  loadMorePosts() {
    const lastPostId = this.postTargets[this.postTargets.length - 1].id.split('_')[1];

    fetch(`/places/${this.placeId}/posts/next_batch?after_id=${lastPostId}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      credentials: 'same-origin'
    })
    .then(response => response.text())
    .then(data => {
      this.element.querySelector('.posts-list').innerHTML += data;
    });
  }
}
