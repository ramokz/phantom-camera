import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Phantom Camera",
  description: "A dynamic 2D & 3D camera plugin for Godot 4",
  head: [
      ['link', {rel: 'icon', type: 'image/svg+xml', href: '/assets/icons/phantom-camera.svg'}],
      ['link', {rel: 'icon', type: 'image/png', href: '/favicon.png'}],
  ],
  appearance: 'force-dark',
  transformHead({ assets }) {
    const fontFile = assets.find(file => /Nunito\.\w+\.ttf/)
    const codeFontFile = assets.find(file => /JetBrainsMono\.\w+\.ttf/)
    if (fontFile) {
      return [
          [
            'link',
            {
              rel: 'preload',
              href: fontFile,
              as: 'font',
              type: 'font/ttf',
              crossorigin: '',
            }
          ]
      ]
    }
    if (codeFontFile) {
      return [
        [
          'link',
          {
            rel: 'preload',
            href: codeFontFile,
            as: 'font',
            type: 'font/ttf',
            crossorigin: '',
          }
        ]
      ]
    }
  },
  srcExclude: [
    '**/parts/*.md'  
  ],
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: '/assets/phantom-camera.svg',
    
    nav: [
      {
        text: 'Home', link: '/'
      },
      {
        text: 'Docs', link: '/introduction/getting-started'
      },
    ],
    
    outline: {
      label: "This page",
      level: [1,4]
    },

    sidebar: [
      {
        text: 'Introduction',
        items: [
          {
            text: 'What is this Addon?', link: '/introduction/what-is-this-addon'
          },
          {
            text: 'Installation', link: '/introduction/installation'
          },
          {
            text: 'Scene Requirements', link: '/introduction/scene-requirements'
          },
          {
            text: 'Multiple Phantom Cameras', link: '/introduction/multiple-phantom-cameras'
          },
        ]
      },
      {
        text: 'Core Nodes',
        items: [
          {
            text: 'Overview', link: '/core-nodes/overview'
          },
          {
            text: 'PhantomCamera2D', link: '/core-nodes/phantom-camera-2d'
          },
          {
            text: 'PhantomCamera3D', link: '/core-nodes/phantom-camera-3d'
          },
          {
            text: 'PhantomCameraHost', link: '/core-nodes/phantom-camera-host'
          },
        ]
      },
      {
        text: 'Priority', link: "/priority",
      },
      {
        text: 'Follow Modes',
        items: [
          {
            text: 'Overview', link: "/follow-modes/overview"
          },
          {
            text: 'Glued', link: '/follow-modes/glued'
          },
          {
            text: 'Simple', link: '/follow-modes/simple'
          },
          {
            text: 'Group', link: '/follow-modes/group'
          },
          {
            text: 'Path', link: '/follow-modes/path'
          },
          {
            text: 'Framed', link: '/follow-modes/framed'
          },
          {
            text: 'Third Person (3D)', link: '/follow-modes/third-person'
          },
        ]
      },
      {
        text: 'Look At Modes (3D)',
        items: [
          {
            text: 'Overview', link: "/look-at-modes/overview"
          },
          {
            text: 'Mimic', link: '/look-at-modes/mimic'
          },
          {
            text: 'Simple', link: '/look-at-modes/simple'
          },
          {
            text: 'Group', link: '/look-at-modes/group'
          },
        ]
      },
      {
        text: 'Tween', link: "/tween",
      },
      {
        text: 'Viewfinder', link: "/viewfinder",
      },
      {
        text: 'Timeline Animation', link: "/timeline-animation",
      },
      {
        text: 'Support',
        items: [
          {
            text: 'How To Contribute', link: "/support/how-to-contribute"
          },
          {
            text: 'FAQ', link: "/support/faq"
          },
          {
            text: 'Questions & Help', link: "/support/questions-help"
          },
        ]
      },
      {
        text: 'Roadmap', link: "/roadmap"
      },
    ],
    
    search: {
      provider: "local"
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/ramokz/phantom-camera' },
      { icon: 'mastodon', link: 'https://mastodon.gamedev.place/@marcusskov' },
      { icon: 'twitter', link: 'https://twitter.com/marcusskov' }
    ],
    
    editLink: {
      pattern: 'https://github.com/ramokz/phantom-camera/edit/main/documentation/docs/:path'
    }
  }
})
