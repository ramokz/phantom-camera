import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Phantom Camera",
  description: "A dynamic 2D & 3D camera plugin for Godot 4",
  head: [['link', {rel: 'icon', href: '/favicon.png'}]],
  appearance: 'force-dark',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: '/assets/phantom-camera.svg',
    
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Examples', link: '/markdown-examples' },
    ],
    
    outline: {
      label: "This page",
      level: [1,4]
    },

    sidebar: [
      {
        text: 'Introduction',
        items: [
          { text: 'Getting Started', link: '/introduction/getting-started' },
          { text: 'Phantom Camera 2D', link: '/introduction/phantom-camera-2d' },
          { text: 'Phantom Camera 3D', link: '/introduction/phantom-camera-3d' },
          { text: 'Phantom Camera Host', link: '/introduction/phantom-camera-host' },
        ]
      },
      {
        text: 'Follow Modes',
        items: [
          {text: 'Overview', link: "/follow-modes/overview"},
          {text: 'None', link: '/follow-modes/none'},
          {text: 'Glued', link: '/follow-modes/glued'},
          {text: 'Simple', link: '/follow-modes/simple'},
          {text: 'Group', link: '/follow-modes/group'},
          {text: 'Path', link: '/follow-modes/path'},
          {text: 'Framed', link: '/follow-modes/framed'},
          {text: 'Third Person', link: '/follow-modes/third-person'},
        ]
      },
      {
        text: 'Look At Modes',
        items: [
          {text: 'Overview', link: "/look-at-modes/overview"},
          {text: 'None', link: '/look-at-modes/none'},
          {text: 'Mimic', link: '/look-at-modes/mimic'},
          {text: 'Simple', link: '/look-at-modes/simple'},
          {text: 'Group', link: '/look-at-modes/group'},
        ]
      },
      {
        text: 'Tween',
        items: [
          {text: 'Overview', link: "/follow-modes/overview"},
        ]
      },
    ],
    
    search: {
      provider: "local"
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/ramokz/phantom-camera' }
    ]
  }
})
