---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Phantom Camera"
  text: "Documentation"
  tagline: 👻🎥 A dynamic 2D & 3D camera addon for Godot 4
  image:
    src: /assets/phantom-camera.svg
    alt: Phantom Camera icon
  actions:
    - theme: brand
      text: Get Started
      link: /introduction/getting-started
    - theme: alt
      text: GitHub Repo
      link: https://github.com/ramokz/phantom-camera

features:
  - icon:
        src: /assets/feature-priority.svg
    title: Priority
    details:  Dynamically switch between camera positions by changing a priority value of a PhantomCamera node.
  - icon:
      src: /assets/feature-follow.svg
    title: Follow
    details: Make the camera follow a specified target using one of the positional logics.
  - icon:
      src: /assets/feature-tween.svg  
    title: Tween
    details: Define duration and ease type when Camera transitions between different PhantomCameras
  - title: And that's not all
    details: Rotate a camera to always point towards a target, preview the camera from the viewfinder and more!
---
