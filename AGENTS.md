# DDS — Termux + Apache + MariaDB + PHP

Android local web server provisioning tool (formerly TAMP). Manages a full LAMP-like stack within Termux.

## Permanent Directives

- **Auto-load skills:** Whenever a task matches a skill's description, load that skill automatically without being asked. This is a permanent rule — do not wait for the user to request it.

## Tech Stack

| Concern | Choice |
|---|---|
| Runtime | Termux / Android |
| Web Server | Apache httpd (port 8080, SSL on 8443) |
| Database | MariaDB (MySQL-compatible) |
| Language | PHP (FPM via proxy_fcgi), Bash |
| CLI | Bash scripts (dds, setup, update) |
| Config | Apache httpd.conf, phpMyAdmin config.inc.php |
| SSL | OpenSSL self-signed cert |

## Installed Skills (150 total)

### Infrastructure & Core
| Skill | Purpose |
|---|---|
| `php-pro` | PHP 8.3+ development, modern patterns, PSR standards, Laravel/Symfony |
| `terminalskills-mysql` | MySQL/MariaDB database design, queries, optimization |
| `implementing-cli-patterns` | CLI tool architecture, argument parsing, output formatting |
| `linux-commands-guide` | Linux/Unix command reference, shell scripting |
| `bash-script-helper` | Bash scripting patterns, error handling, portability |
| `pandelisz-shell` | Shell command execution and automation patterns |
| `security-reviewer` | Security audit patterns for web servers and PHP apps |
| `terminalskills-nginx` | Nginx web server configuration and optimization |
| `terminalskills-caddy` | Caddy web server setup, Caddyfile configuration |
| `terminalskills-apache-arrow` | Apache Arrow columnar data format |
| `terminalskills-ssh` | SSH configuration, key management, secure tunnels |
| `terminalskills-iptables` | Linux firewall rules, NAT, port forwarding |
| `terminalskills-fail2ban` | Brute-force protection, jail configuration |
| `terminalskills-letsencrypt` | Free SSL certificate provisioning and renewal |
| `terminalskills-cert-manager` | Kubernetes certificate management |
| `terminalskills-systemd` | Systemd service management and unit files |
| `terminalskills-ssl` | SSL/TLS configuration and certificate management |
| `terminalskills-https-certificate-checker` | HTTPS certificate inspection and validation |

### CLI & Terminal Design
| Skill | Purpose |
|---|---|
| `ultimate-cli` | Ultimate CLI development patterns and best practices |
| `better-cli` | Better CLI UX patterns and implementation |
| `cli-developer` | CLI application development framework |
| `create-cli` | CLI project scaffolding and generation |
| `cli-ascii-logo` | ASCII logo generation for CLIs |
| `ascii-cli-logo-banner` | ASCII banner generation for terminal apps |
| `ascii-cli-logo-banner-figletjs` | Figlet-based ASCII banner generation |
| `ascii-terminal-animation-pack` | Terminal animations and effects |
| `cli-progress` | Progress bars and progress indicators |
| `cli-spinners` | Terminal spinner animations |
| `cli-table3` | Terminal table rendering |
| `cli-truncate` | Text truncation for terminal output |
| `cli-prompts-clack` | Interactive CLI prompts and forms |
| `ora` | Elegant terminal spinners |
| `wrap-ansi` | ANSI-aware terminal text wrapping |
| `strip-ansi` | Strip ANSI escape codes |
| `slice-ansi` | Slice ANSI-colored strings correctly |
| `string-width` | Compute visual width of strings |
| `has-ansi` | Check if string has ANSI codes |
| `is-unicode-supported` | Detect Unicode terminal support |
| `log-symbols` | Colored symbols for log messages |
| `log-update` | Update log output in place |
| `marked-terminal` | Terminal renderer for marked markdown |
| `terminal-image` | Display images in terminal |
| `terminal-link` | Create clickable terminal links |
| `inquirer` | Interactive CLI prompts and forms (Inquirer.js) |

### Design Theory & UI/UX Core
| Skill | Purpose |
|---|---|
| `high-end-visual-design` | Premium agency-level visual design (Awwwards-tier) |
| `interface-design` | Interface design patterns, user flows, state analysis |
| `redesign-existing-projects` | Methodology for redesigning existing projects |
| `frontend-design` | Frontend UI architecture and design systems |
| `design-system-starter` | Design system scaffolding and foundations |
| `design-system-spec` | Design system specification documentation |
| `design-first-ui-prompting` | Design-first approach to UI development |
| `design-taste-frontend` | Design taste and aesthetic judgment for frontend |
| `stitch-design-taste` | Design taste calibration and refinement |
| `neo-system-design` | Neomorphic system design patterns |
| `neo-system-design-lite` | Lightweight neomorphic design approach |
| `opentui` | Open Terminal UI design system |
| `awesome-opentui` | Curated OpenTUI resources and patterns |
| `anthropics-frontend-design` | Anthropic's frontend design principles |
| `anthropics-canvas-design` | Canvas-based design patterns |
| `anthropics-theme-factory` | Theme generation and customization |
| `ui-ux-pro-max` | Ultimate UI/UX design intelligence database |

### UX Theory & Frameworks (Wondelai)
| Skill | Purpose |
|---|---|
| `wondelai-refactoring-ui` | UI refactoring methodology, design scoring |
| `wondelai-top-design` | Seven Pillars of 10/10 award-winning design |
| `wondelai-ux-heuristics` | UX heuristics, usability evaluation framework |
| `wondelai-microinteractions` | Micro-interaction design, motion choreography |
| `wondelai-hooked-ux` | Hooked UX model (Trigger → Action → Reward → Investment) |
| `wondelai-design-everyday-things` | Design principles from Don Norman's classic |
| `wondelai-web-typography` | Web typography best practices, font pairing |
| `wondelai-clean-architecture` | Clean Architecture principles and patterns |
| `wondelai-clean-code` | Clean Code practices and refactoring |
| `wondelai-design-sprint` | Google Design Sprint methodology |
| `wondelai-lean-ux` | Lean UX principles for rapid iteration |
| `wondelai-ios-hig-design` | Apple iOS Human Interface Guidelines |
| `wondelai-software-design-philosophy` | Software design philosophy and principles |
| `wondelai-steve-jobs-design-review` | Steve Jobs-style design review framework |
| `wondelai-system-design` | System design patterns and architecture |
| `wondelai-refactoring-patterns` | Code refactoring patterns and techniques |
| `wondelai-domain-driven-design` | Domain-Driven Design principles |
| `wondelai-pragmatic-programmer` | Pragmatic programmer practices |
| `wondelai-ddia-systems` | Designing Data-Intensive Applications patterns |
| `wondelai-working-with-legacy-code` | Legacy code refactoring strategies |
| `wondelai-high-perf-browser` | High-performance browser rendering |

### Visual Style & Theming
| Skill | Purpose |
|---|---|
| `skeuomorphic-ui` | Skeuomorphic design with realistic textures and depth |
| `minimalist-ui` | Minimalist UI design principles and patterns |
| `industrial-brutalist-ui` | Industrial/brutalist aesthetic for bold interfaces |
| `solar-duotone-bold` | Solar duotone color scheme with bold contrast |
| `tech-green-dark-mode-modern` | Tech-green dark mode modern theme |
| `orange-clean-paper-saas` | Orange SaaS theme with clean paper aesthetic |
| `light-mode-paper-technical` | Light mode technical paper style |
| `split-layout-technical` | Split screen technical layout patterns |
| `mesh-gradient-dark-blue-clean` | Mesh gradient blue dark/clean aesthetic |
| `nested-container-clean-agency` | Agency-quality nested container layouts |
| `nested-container-frames` | Nested frame container patterns |
| `agency-grid-layout-minimal` | Minimal agency grid layout system |
| `high-contrast-skeuomorphic-clean` | High contrast skeuomorphic clean style |
| `technical-wireframe-info-layout` | Technical wireframe info layout |
| `image-first-grid-layout` | Image-first grid layout patterns |
| `glass-dark-ui` | Glassmorphism dark UI design |
| `dark-glass-clean-layout` | Dark glass clean layout patterns |
| `clean-minimal-beige-light-mode` | Clean minimal beige light theme |
| `blue-laser-clean-glass-layout` | Blue laser glass aesthetic layout |
| `framed-grid-layout` | Framed grid layout system |
| `background-grid-webgl` | WebGL background grid effects |

### Visual Effects & Animation
| Skill | Purpose |
|---|---|
| `gsap` | GSAP animation library patterns |
| `gsap-scrolltrigger-storytelling` | Scroll-triggered storytelling animations |
| `threejs` | Three.js 3D graphics and WebGL |
| `webgl-3d-object` | WebGL 3D object creation and rendering |
| `webgl-landing-steering` | WebGL-powered landing page steering effects |
| `webgl-laser` | WebGL laser beam visual effects |
| `vantajs` | Vanta.js animated 3D backgrounds |
| `marquee-loop` | Infinite marquee/scroll animations |
| `masked-reveal` | Mask-based reveal animations |
| `progressive-blur` | Progressive blur visual effects |
| `staggered-word-reveal` | Staggered word reveal animations |
| `matterjs` | Matter.js 2D physics engine |
| `web-animation-css-animations` | CSS animation patterns and best practices |
| `web-animation-framer-motion` | Framer Motion animation library |
| `web-animation-view-transitions` | View Transition API patterns |
| `lottie` | Lottie animation search and embedding |
| `motion` | Framer Motion / Motion React animation library |
| `pixijs` | PixiJS v8 2D WebGL/WebGPU rendering engine |
| `babylonjs` | Babylon.js 3D game engine and rendering |
| `spline-3d-integration` | Spline 3D scene embedding and interaction |

### Web Technologies
| Skill | Purpose |
|---|---|
| `html` | HTML semantic structure, accessibility |
| `tailwindcss` | Tailwind CSS utility-first styling |
| `javascript` | JavaScript patterns, DOM manipulation |
| `landing-page` | Landing page design and development |
| `responsive-breakpoint-analyzer` | Responsive design breakpoint strategies |
| `web-styling-tailwind` | Tailwind CSS advanced styling patterns |
| `web-styling-scss-modules` | SCSS modules and component styling |
| `web-styling-cva` | Class Variance Authority patterns |
| `web-accessibility-web-accessibility` | Web accessibility (a11y) best practices |
| `web-performance` | Web performance optimization |
| `web-seo` | Search engine optimization patterns |
| `tailwindcss-fundamentals-v4` | Tailwind CSS v4 fundamentals |
| `tailwindcss-advanced-design-systems` | Advanced design systems with Tailwind |
| `tailwindcss-advanced-layouts` | Advanced Tailwind layout patterns |
| `tailwindcss-animations` | Tailwind CSS animation utilities |
| `tailwindcss-development` | Tailwind CSS development workflow |
| `tailwindcss-framework-integration` | Tailwind integration with frameworks |
| `tailwindcss-mobile-first` | Mobile-first Tailwind patterns |
| `tailwindcss-responsive-darkmode` | Responsive dark mode with Tailwind |
| `tailwindcss-accessibility` | Accessible Tailwind CSS patterns |
| `tailwind-class-optimizer` | Tailwind class organization and optimization |

### Mobile UI
| Skill | Purpose |
|---|---|
| `mobile-ui-components-react-native-paper` | React Native Paper UI components |
| `mobile-ui-components-tamagui` | Tamagui universal UI framework |
| `mobile-styling-nativewind` | NativeWind Tailwind for React Native |
| `mobile-styling-unistyles` | Unistyles cross-platform styling |
| `mobile-navigation-expo-router` | Expo Router navigation patterns |
| `mobile-navigation-react-navigation` | React Navigation setup and patterns |

## Project Structure

```
dds/
├── dds             # CLI entry point (start/stop/restart/status/update/uninstall)
├── setup           # One-shot installer
├── update          # Config re-apply after git pull
├── httpd.conf      # Apache configuration (port 8080)
├── httpd-ssl.conf  # Apache SSL configuration (port 8443)
├── config.inc.php  # phpMyAdmin configuration
├── .htaccess       # Directory index preference
├── LICENSE         # GPL v3
├── README.md       # Documentation
├── hosts.json      # Virtual host configurations
├── dds-ui/         # Visual CLI interface (Node.js)
│   ├── index.js    # Entry point, menu loop
│   ├── menu.js     # Main menu
│   ├── logo.js     # ASCII logo + animated status badge
│   ├── commands.js # All command implementations
│   ├── hosts.js    # Host data layer (JSON CRUD)
│   ├── vhost.js    # Apache vhost config generator
│   ├── spinner.js  # Spinner utilities
│   └── package.json
├── .openchat/
│   ├── openchat.jsonc  # Agent configuration
│   └── skills/         # 150 AI agent skills (SKILL.md per skill)
│       ├── RULES.md
│       ├── php-pro/
│       ├── terminalskills-mysql/
│       ├── implementing-cli-patterns/
│       ├── high-end-visual-design/
│       ├── wondelai-*/
│       ├── gsap/
│       ├── threejs/
│       ├── tailwindcss/
│       └── ...
