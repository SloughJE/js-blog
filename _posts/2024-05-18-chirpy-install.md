---
title: "Chirpy Blog Integration as a Subdirectory"
date: 2024-05-18 12:00:00 +0000
categories: [Github, Web Development, Jekyll]
tags: [Jekyll, Chirpy, blog, GitHub Pages, Submodule, Tutorial, Git]
---

# Integrating Chirpy Jekyll Theme Blog into an Existing GitHub Pages as a Subdirectory

I had already built my static website and deployed it using GitHub Pages. It redirects to [www.jsdatascience.com](http://www.jsdatascience.com).

I wanted to create a blog or similarly structured site to post information about some of the personal data science projects I've been working on and perhaps some related topics. 

Given that I already had a website deployed using GitHub Pages, I wanted to find a tool to create the blog in a similar way. 

I came across the Chirpy theme for Jekyll, a tool that generates static websites from text files. Exactly what I wanted.
The Chirpy theme is minimal, without excessive styling. Good.

Now I just needed to figure out how to get the Chirpy blog theme working as a subdirectory of my home page, ie [www.jsdatascience.com/blog](http://www.jsdatascience.com/blog).


## Guide

This guide details the process of integrating the Chirpy Jekyll static website theme into an existing GitHub Pages site as a subdirectory (`/blog`). 
The setup aims to keep the main site as just a static `index.html` page, while adding a blog powered by Jekyll and the Chirpy theme.


**Starting Point**: An existing GitHub Pages site with `index.html` as the static website
**Goal**: A blog in a subdirectory `/blog` using the Chirpy theme so it is accessible under `yourwebsite.com/blog` 


### Step 1: Initialize the `blog` directory as a Git Submodule and Clone the Chirpy Starter

1. In your terminal navigate to your existing GitHub Pages repository:

    ```sh
    cd /path/to/your_main/repository
    ```
    It is assumed that this is already a git repository with an existing GitHub Pages site. 

2. Go to `https://github.com/cotes2020/chirpy-starter`. Either fork it to your own repo or click on `Use this template`.

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

The `.github/workflows/pages-deploy.yml` is a yaml file that tells GitHub how to deploy your website. This is included by default in the chirpy starter files. 

We need to delete this one and put our own in the main directory.

1. Delete the default one in `blog/.github/workflows/pages-deploy.yml`.
```sh
git rm blog/.github/workflows/pages-deploy.yml
```

2. Create a new one in the main directory `.github/workflows/pages-deploy.yml`. The file should look like this:

```yaml
name: Build and Deploy Site
on:
  push:
    branches:
      - main
      - master # Triggers on push to the main or master branch of your repository. Change if your branch is not one of these
    paths-ignore:
      - .gitignore
      - README.md
      - LICENSE

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

permissions: # set permissions here so we don't have to do it manually
  contents: read
  pages: write
  id-token: write

# Allow one concurrent deployment
concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
      with:
        submodules: true  # Fetch submodules

    - name: Setup Pages
      id: pages
      uses: actions/configure-pages@v4

    - name: Setup Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.3
        bundler-cache: true

    - name: Install dependencies
      run: |
        cd blog
        bundle install
    # Installs everything necessary for Jekyll/Chirpy in the `blog` directory

    - name: Build Blog Site
      run: |
        cd blog
        bundle exec jekyll build -d "../_site/blog"
      # Builds the Jekyll site in the `blog` directory, so it's served as https://yourwebsite.com/blog
      env:
        JEKYLL_ENV: "production"

    - name: Copy Static Site Files
      run: |
        cp index.html _site/
        cp style.css _site/
        cp -r assets _site/
        cp CNAME _site/
      # Copies the necessary static files from the main repo into the _site directory so they are included in deployment.
      # This includes the original website and all necessary files to render it
      # CNAME file is needed if using a custom domain
      # My website uses style.css and files in the `assets` directory. Change per your requirements

    - name: Upload site artifact
      uses: actions/upload-pages-artifact@v3
      with:
        path: "_site${{ steps.pages.outputs.base_path }}"
      # Uploads built site to GitHub Actions, allows next step to access and publish the files

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }} # URL of the deployed site
    runs-on: ubuntu-latest
    needs: build  # Ensures the build job completes before deployment
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4 # deploy

```

Then we need to just update the git repo with our changes.  
```sh
git add .github/workflows/pages-deploy.yml
git add blog
git commit -m "Deleting and Adding new deployment workflow"
git push
```
A quick explanation about the submodule here:

`git rm blog/.github/workflows/pages-deploy.yml`: This command removes the file from the submodule directory and stages the removal.

`git add blog`: This command stages the updated submodule reference in the main repository. It ensures that the main repository knows about the changes made within the submodule.

Now the main repository is aware of the changes made within the submodule, and the updated state of the submodule is correctly reflected in the main repository.


Also note that if you are redirecting to a custom URL, make sure to include the CNAME file (ie a file named "CNAME") in the main directory. The CNAME file specifies the custom domain for your GitHub Pages site. The file would just contain, for example:

```bash
www.jsdatascience.com
```

### Step 3: Configure GitHub Pages
Depending on your previous setup, you may or may not need to do this.

Ensure GitHub Pages is configured to build from the root directory or the `gh-pages` branch, depending on your setup. This should happen automatically but it may have been changed from the previous website deployment. Go to your website repo, click on `Settings`, then `Pages` on the left. It will probably be set to `deploy from a branch`. I just leave it on the default `gh-pages` branch.

### Step 4: Access Your Blog
Push all your changes to your main repo.
Click on `Actions` on your website's repo and watch it being built.
Once GitHub Pages has processed your changes, built and deployed the new build of your website, you should be able to access your blog at `https://yourwebsite.com/blog`.

That's how I was able to do it. Hopefully it will work for you!

JS