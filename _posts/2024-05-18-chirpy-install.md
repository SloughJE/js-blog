---
title: "Chirpy Blog Integration as a Subdirectory"
date: 2024-05-17 12:00:00 +0000
categories: [test, example]
tags: [test, example]
---

# Integrating Chirpy Jekyll Theme into an Existing GitHub Pages Blog Subdirectory

## Introduction

This guide details the process of integrating the Chirpy Jekyll static website theme into an existing GitHub Pages site as a subdirectory (`/blog`). 

The setup aims to maintain the main site on GitHub Pages while adding a blog powered by Jekyll and the Chirpy theme.

**Starting Point**: An existing GitHub Pages site with `index.html` as the static website
**Goal**: Add a blog in a subdirectory `/blog` using Jekyll and the Chirpy theme so it is accessible under `yourwebiste.com/blog`.

## Step-by-Step Guide

### Step 1: Initialize the `blog` directory as a Git Submodule and Clone the Chirpy Starter

1. In your terminal navigate to your existing GitHub Pages repository:

    ```sh
    cd /path/to/your_main/repository
    ```
    It is assumed that this is already a git repository with an existing GitHub Pages site. 

2. Go to `https://github.com/cotes2020/chirpy-starter`. Either fork it to your own repo or `Use this template`.

3. In your terminal, add your forked or template chirpy starter repo as a submodule:

    ```sh
    git submodule add https://github.com/YOUR_CHIRPY_REPO.git blog
    ```

4. Initialize and update the submodule:

    ```sh
    git submodule update --init --recursive
    ```

    This command ensures that the submodule is properly initialized and updated to the correct commit. The `--recursive` option also initializes and updates any nested submodules if they exist.

5. Add and commit the submodule to the main repository:

    ```sh
    git add blog
    git commit -m "Add Chirpy as submodule"
    git push
    ```

### Step 2: Configure GitHub Actions for Deployment

The `.github/workflows/pages-deploy.yml` is a yaml file that tells GitHub how to deploy your website. This is included by default in the chirpy starter files. We need to delete this one and put our own in the main directory.
1. Delete the default one in `blog/.github/workflows/pages-deploy.yml`.
```sh
git rm blog/.github/workflows/pages-deploy.yml
```

2. Create a new one in the main directory. The file should look like this:

```yaml
name: Build and Deploy Site

on:
  push:
    branches:
      - master  # Trigger on the master branch of your main repository. Change per your branch

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        submodules: true  # Fetch submodules

    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.1

    - name: Install dependencies
      run: |
        cd blog
        bundle install 
    # above command installs everything necessary for Jekyll/Chirpy in the `blog` directory

    - name: Build Blog Site
      run: |
        cd blog
        bundle exec jekyll build
        mkdir -p ../_site/blog  # Ensure the destination directory exists
        mv _site/* ../_site/blog/  # Move the built blog site to the main _site/blog directory
    # above command builds the Jekyll site in the `blog` directory, so it's served as https://yourwebsite.com/blog

    - name: Copy Static Site Files
      run: |
        cp index.html _site/
        cp style.css _site/
        cp -r assets _site/
        cp CNAME _site/ 
    # Copies the necessary static files from the main repo into the _site directory so they are included in deployment.
    # CNAME file is needed if using custom domain
    # My webiste uses style.css and files in the `assets` directory

    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v4
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }} # you may need to update your permissions to allow github actions to write in your repo
        publish_dir: ./_site
        publish_branch: gh-pages  # Ensure this is set to gh-pages, (this is the default)
```

```sh
git add .github/workflows/pages-deploy.yml
git commit -m "Deleting and Adding new deployment workflow"
git push
```

#### Notes
If you are redirecting to a custom URL, make sure to include the CNAME file (ie a file named "CNAME") in the main directory. The CNAME file specifies the custom domain for your GitHub Pages site. The file would just contain, for example:

```bash
www.jsdatascience.com
```

### Step 3: Configure GitHub Pages
Ensure GitHub Pages is configured to build from the root directory or the `gh-pages` branch, depending on your setup.
Go to your main repo, click on `Settings` and then `Pages` on the left. It will probably be set to deploy from a branch. I just leave it on default `gh-pages` branch.

### Step 4: Access Your Blog
Push all your changes to your main repo.
Once GitHub Pages has processed your changes and deployed the new build of your website, you should be able to access your blog at `https://yourwebsite.com/blog`.




### Step 4: Docker Setup for Jekyll Development

Create the necessary Docker setup files in the `blog` directory.

#### Dockerfile

    ```dockerfile
    # Dockerfile
    FROM ruby:3.3.1

    # Install Node.js (for Jekyll)
    RUN apt-get update -qq && apt-get install -y nodejs

    # Set working directory
    WORKDIR /usr/src/app

    # Copy Gemfile and Gemfile.lock
    COPY Gemfile Gemfile.lock ./

    # Install dependencies
    RUN gem install bundler && bundle install

    # Copy the rest of the application code
    COPY . .

    # Expose port 4000 for Jekyll
    EXPOSE 4000

    # Default command to run Jekyll server
    CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0"]
    ```

#### docker-compose.yml

    ```yaml
    # docker-compose.yml
    version: '3.7'

    services:
      jekyll:
        build: .
        ports:
          - "4000:4000"
        volumes:
          - .:/usr/src/app
        command: bundle exec jekyll serve --host 0.0.0.0
    ```

### Step 5: Build and Run the Docker Container

1. Build the Docker image:

    ```sh
    docker-compose build
    ```

2. Run the Docker container:

    ```sh
    docker-compose up
    ```



## Conclusion

By following these steps, you can successfully integrate the Chirpy Jekyll theme into your existing GitHub Pages site as a subdirectory. Using Docker for development ensures that your local environment remains clean and consistent, avoiding dependency conflicts.
