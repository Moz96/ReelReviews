document.addEventListener('DOMContentLoaded', (event) => {
  document.querySelectorAll('.place').forEach((place) => {
    const placeId = place.id.split('_')[1];
    let posts = Array.from(place.querySelectorAll('.post'));
    let currentIndex = 0;

    const loadMorePosts = () => {
      const lastPostId = posts[posts.length - 1].id.split('_')[1];

      fetch(`/places/${placeId}/posts/next_batch?after_id=${lastPostId}`, {
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
        place.querySelector('.posts-list').innerHTML += data;
        posts = Array.from(place.querySelectorAll('.post'));
      });
    };

    const updatePostVisibility = () => {
      posts.forEach((post, index) => {
        post.style.display = index === currentIndex ? 'block' : 'none';
      });
    };

    place.querySelector('.next').addEventListener('click', function() {
      if (currentIndex < posts.length - 1) {
        currentIndex++;
        updatePostVisibility();

        if (currentIndex === posts.length - 1) {
          loadMorePosts();
        }
      }
    });

    place.querySelector('.prev').addEventListener('click', function() {
      if (currentIndex > 0) {
        currentIndex--;
        updatePostVisibility();
      }
    });
  });
});
