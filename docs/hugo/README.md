# Hugo Documentation Site

This directory contains the Hugo-based documentation site for the DevContainer Template project.

## Overview

The documentation site is built using:
- **Hugo** - Static site generator
- **Docsy Theme** - Documentation-focused theme
- **GitHub Pages** - Hosting platform
- **GitHub Actions** - Automated deployment

## Features

- 📚 **Comprehensive Documentation** - Complete guides for all features
- 🎨 **Modern Design** - Clean, responsive interface with the Docsy theme
- 🔍 **Search Functionality** - Built-in search across all documentation
- 📱 **Mobile Responsive** - Optimized for all devices
- 🚀 **Fast Loading** - Optimized static site generation
- 🔄 **Auto-Deployment** - Automated publishing to GitHub Pages

## Local Development

### Prerequisites

- **Hugo Extended** (v0.120.4 or later)
- **Go** (for Hugo modules)
- **Node.js** and **npm** (for theme dependencies)
- **Git** (for submodules and version control)

### Setup

1. **Install Hugo Extended**:
   ```bash
   # Windows (using Chocolatey)
   choco install hugo-extended
   
   # macOS (using Homebrew)
   brew install hugo
   
   # Linux (download from GitHub releases)
   wget https://github.com/gohugoio/hugo/releases/download/v0.120.4/hugo_extended_0.120.4_linux-amd64.deb
   sudo dpkg -i hugo_extended_0.120.4_linux-amd64.deb
   ```

2. **Navigate to the Hugo directory**:
   ```bash
   cd docs/hugo
   ```

3. **Initialize Hugo modules**:
   ```bash
   hugo mod init github.com/haflidif/devcontainer-template
   hugo mod get github.com/google/docsy@v0.7.2
   hugo mod get github.com/google/docsy/dependencies@v0.7.2
   ```

4. **Install Node.js dependencies**:
   ```bash
   npm install
   ```

### Development Workflow

#### Start Development Server

```bash
# Start the Hugo development server
hugo server --buildDrafts --buildFuture

# Open browser to http://localhost:1313
```

#### Build for Production

```bash
# Build the site for production
hugo --gc --minify

# Output will be in public/ directory
```

#### Preview Changes

```bash
# Build and serve locally (production-like)
hugo --gc --minify && hugo server --source public --port 1314
```

## Content Organization

### Directory Structure

```
docs/hugo/
├── content/                 # Markdown content files
│   ├── _index.md           # Homepage content
│   └── docs/               # Documentation sections
│       ├── _index.md       # Docs landing page
│       ├── getting-started/
│       ├── configuration/
│       ├── testing/
│       ├── examples/
│       ├── powershell/
│       └── troubleshooting/
├── static/                 # Static assets (images, files)
├── layouts/                # Custom layouts (if needed)
├── assets/                 # Assets to be processed
├── hugo.toml              # Hugo configuration
├── go.mod                 # Hugo modules configuration
└── package.json           # Node.js dependencies
```

### Content Guidelines

#### Front Matter

All content files should include proper front matter:

```yaml
---
title: "Page Title"
linkTitle: "Short Title"
weight: 1
description: >
  Brief description of the page content.
---
```

#### Writing Style

- Use **clear, concise language**
- Include **practical examples**
- Add **code snippets** with syntax highlighting
- Use **callouts** for important information
- Maintain **consistent formatting**

#### Code Blocks

Use fenced code blocks with language specification:

````markdown
```powershell
# PowerShell example
.\Initialize-DevContainer.ps1 -ProjectName "my-project"
```

```terraform
# Terraform example
resource "azurerm_resource_group" "main" {
  name     = "rg-my-project"
  location = "East US"
}
```
````

#### Callouts and Alerts

Use Hugo shortcodes for callouts:

```markdown
{{< alert >}}
This is an important note that users should pay attention to.
{{< /alert >}}

{{< alert title="Warning" color="warning" >}}
This is a warning about potential issues.
{{< /alert >}}
```

## Customization

### Theme Configuration

The site uses the Docsy theme with custom configuration in `hugo.toml`:

```toml
# Site metadata
title = "DevContainer Template for Infrastructure as Code"
description = "A comprehensive DevContainer template documentation"

# Theme configuration
[params]
  version = "v2.0"
  github_repo = "https://github.com/haflidif/devcontainer-template"
  edit_page = true
```

### Custom Styling

Add custom CSS in `assets/scss/_custom.scss`:

```scss
// Custom styles for the documentation site
.custom-class {
  // Your custom styles
}
```

### Adding New Sections

1. **Create content directory**:
   ```bash
   mkdir -p content/docs/new-section
   ```

2. **Add section index**:
   ```bash
   # content/docs/new-section/_index.md
   ---
   title: "New Section"
   linkTitle: "New Section"
   weight: 7
   description: >
     Description of the new section.
   ---
   ```

3. **Add content pages**:
   ```bash
   # content/docs/new-section/page.md
   ---
   title: "Page Title"
   linkTitle: "Page"
   weight: 1
   ---
   
   # Page content here
   ```

## Deployment

### Automatic Deployment

The site is automatically deployed to GitHub Pages when:
- Changes are pushed to the `main` branch
- Changes are made to files in `docs/hugo/`
- The GitHub Action workflow completes successfully

### Manual Deployment

For manual deployment or testing:

```bash
# Build the site
hugo --gc --minify

# Deploy to GitHub Pages (if configured)
# This is handled automatically by GitHub Actions
```

### GitHub Pages Configuration

1. **Enable GitHub Pages** in repository settings
2. **Set source** to "GitHub Actions"
3. **Configure custom domain** (optional)

## Maintenance

### Updating Hugo

```bash
# Check current version
hugo version

# Update Hugo (varies by OS)
# Windows: choco upgrade hugo-extended
# macOS: brew upgrade hugo
# Linux: Download new release
```

### Updating Theme

```bash
# Update Docsy theme
hugo mod get -u github.com/google/docsy@latest
hugo mod tidy
```

### Updating Dependencies

```bash
# Update Node.js dependencies
npm update

# Update Go modules
hugo mod get -u
hugo mod tidy
```

## Troubleshooting

### Common Issues

**Hugo not found:**
```bash
# Verify Hugo installation
hugo version

# Install Hugo Extended (required for Docsy)
# Follow installation instructions above
```

**Theme not loading:**
```bash
# Initialize and download modules
hugo mod init github.com/haflidif/devcontainer-template
hugo mod get github.com/google/docsy@v0.7.2
hugo mod tidy
```

**Build errors:**
```bash
# Clean module cache
hugo mod clean

# Verbose build for debugging
hugo --verbose
```

**Node.js dependency issues:**
```bash
# Clear npm cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Debug Mode

```bash
# Run Hugo in debug mode
hugo server --debug --verbose

# Check for broken links
hugo --gc --minify --printPathWarnings
```

## Contributing

### Documentation Updates

1. **Edit content** in the `content/` directory
2. **Test locally** with `hugo server`
3. **Commit changes** to trigger automatic deployment
4. **Review** the deployed site at the GitHub Pages URL

### Adding Examples

1. **Create example files** in appropriate directories
2. **Reference examples** in documentation
3. **Test all code examples** before publishing

### Improving Navigation

1. **Update weights** in front matter to reorder pages
2. **Add new sections** to the main navigation
3. **Update** `_index.md` files for section overviews

## Resources

- **Hugo Documentation**: https://gohugo.io/documentation/
- **Docsy Theme**: https://www.docsy.dev/
- **GitHub Pages**: https://pages.github.com/
- **Markdown Guide**: https://www.markdownguide.org/

## Support

For documentation-related issues:
1. Check the Hugo build logs in GitHub Actions
2. Test changes locally before pushing
3. Reference the Hugo and Docsy documentation
4. Create an issue in the main repository for help
