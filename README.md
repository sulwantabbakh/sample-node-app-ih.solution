# DevOps Bootcamp Showcase

A modern, responsive static website showcasing a DevOps bootcamp program. Built with Node.js, Express, and vanilla JavaScript following best practices.

## 🚀 Features

- **Modern Design**: Clean, professional design with gradient backgrounds and smooth animations
- **Responsive Layout**: Fully responsive design that works on all devices
- **Interactive Elements**: Smooth scrolling, hover effects, and animated counters
- **Performance Optimized**: Fast loading with optimized assets and minimal dependencies
- **SEO Friendly**: Proper meta tags and semantic HTML structure
- **Error Handling**: Custom 404 page and proper error handling
- **Health Check**: Built-in health check endpoint for monitoring

## 🛠️ Tech Stack

- **Backend**: Node.js with Express.js
- **Frontend**: Vanilla HTML, CSS, and JavaScript
- **Styling**: Custom CSS with CSS Grid and Flexbox
- **Icons**: Font Awesome
- **Fonts**: Google Fonts (Inter)
- **Development**: Nodemon for development
- **Testing**: Jest with Supertest and jsdom

## 📁 Project Structure

```
sample-node-application/
├── public/                 # Static assets
│   ├── index.html         # Main homepage
│   ├── 404.html           # Custom 404 page
│   ├── styles.css         # Main stylesheet
│   └── script.js          # Client-side JavaScript
├── tests/                  # Test suite
│   ├── server.test.js     # Server-side tests
│   ├── client.test.js     # Client-side tests
│   ├── integration.test.js # Integration tests
│   ├── setup.js           # Test setup configuration
│   └── README.md          # Test documentation
├── server.js              # Express server
├── jest.config.js         # Jest configuration
├── package.json           # Dependencies and scripts
└── README.md             # Project documentation
```

## 🚀 Getting Started

### Prerequisites

- Node.js (version 14 or higher)
- npm or yarn

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd sample-node-application
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and visit:
```
http://localhost:3000
```

### Running Tests

The application includes a comprehensive test suite covering server-side, client-side, and integration testing:

```bash
# Run all tests
npm test

# Run tests in watch mode (for development)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

**Test Coverage**: 73.91% code coverage across server and client code.

**Test Types**:
- **Server Tests**: Express routes, middleware, error handling
- **Client Tests**: DOM manipulation, event handling, animations
- **Integration Tests**: End-to-end functionality, security, performance

### Production Deployment

1. Install dependencies:
```bash
npm install --production
```

2. Start the production server:
```bash
npm start
```

## 📋 Available Scripts

- `npm start` - Start the production server
- `npm run dev` - Start the development server with nodemon
- `npm test` - Run all tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage report

## 🌐 API Endpoints

- `GET /` - Serve the main homepage
- `GET /health` - Health check endpoint
- `GET /*` - Serve static files from public directory
- `GET /*` (404) - Custom 404 page for non-existent routes

## 🎨 Design Features

### Responsive Design
- Mobile-first approach
- Breakpoints at 768px and 480px
- Flexible grid layouts using CSS Grid and Flexbox

### Animations
- Smooth scroll behavior
- Fade-in animations on scroll
- Typing effect on hero title
- Counter animations for statistics
- Hover effects on interactive elements

### Color Scheme
- Primary: Blue gradient (#667eea to #764ba2)
- Accent: Yellow (#fbbf24)
- Text: Dark gray (#1f2937)
- Background: Light gray (#f8fafc)

## 🔧 Configuration

The application can be configured using environment variables:

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment mode (development/production)

## 📱 Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers

## 🚀 Deployment Options

### Docker Deployment

The application includes a `Dockerfile` for containerized deployment:
```dockerfile
FROM node:22-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

#### GitHub Actions Docker Workflow

The repository includes a comprehensive GitHub Actions workflow (`docker-build-publish.yml`) that:

1. **Runs Unit Tests**: Executes the full test suite with coverage reporting
2. **Builds Multi-Platform Images**: Creates Docker images for both AMD64 and ARM64 architectures
3. **Publishes to GitHub Container Registry**: Automatically pushes images to `ghcr.io`
4. **Security Scanning**: Performs vulnerability scanning with Trivy
5. **Smart Tagging**: Automatically tags images based on branch, commit SHA, and semantic versioning

**Workflow Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main`
- Manual workflow dispatch

**Image Tags Generated**:
- `latest` (for main branch)
- `develop` (for develop branch)
- `{branch}-{commit-sha}` (for feature branches)
- Semantic version tags (if using git tags)

**Container Registry**: Images are published to `ghcr.io/{owner}/{repository}`

### Static Hosting

The static files in the `public/` directory can be deployed to any static hosting service:
- Netlify
- Vercel
- GitHub Pages
- AWS S3 + CloudFront

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Font Awesome for icons
- Google Fonts for typography
- Express.js community for the excellent framework

## 📞 Support

For support or questions, please contact:
- Email: info@devopsbootcamp.com
- Phone: +1 (555) 123-4567

---

Built with ❤️ for the DevOps community
