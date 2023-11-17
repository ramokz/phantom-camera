import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Phantom Camera",
  description: "A dynamic 2D & 3D camera plugin for Godot 4",
  head: [
      ['link', {rel: 'icon', type: 'image/svg+xml', href: '/assets/phantom-camera.svg'}],
      ['link', {rel: 'icon', type: 'image/png', href: '/favicon.png'}],
  ],
  appearance: 'force-dark',
  transformHead({ assets }) {
    const fontFile = assets.find(file => /Nunito-VariableFont\.\w+\.ttf/)
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
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: '/assets/phantom-camera.svg',
    
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Docs', link: '/introduction/getting-started' },
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
          { text: 'PhantomCamera2D', link: '/introduction/phantom-camera-2d' },
          { text: 'PhantomCamera3D', link: '/introduction/phantom-camera-3d' },
          { text: 'PhantomCameraHost', link: '/introduction/phantom-camera-host' },
        ]
      },
      {
        text: 'Priority', link: "/priority",
      },
      {
        text: 'Follow Modes',
        items: [
          {text: 'Overview', link: "/follow-modes/overview"},
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
          {text: 'Mimic', link: '/look-at-modes/mimic'},
          {text: 'Simple', link: '/look-at-modes/simple'},
          {text: 'Group', link: '/look-at-modes/group'},
        ]
      },
      { text: 'Tween', link: "/tween", },
      {
        text: 'Inactive Update Mode', link: "/inactive-update-mode",
      },
      { text: 'Viewfinder', link: "/viewfinder", },
      {
        text: 'Contribute',
        items: [
          { text: 'Feature Proposals', link: "/look-at-modes/feature-proposals" },
          { text: 'Bug reports', link: "/contribute/bug-reports" },
          { text: 'PRs', link: "/contribute/code" },
        ]
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
