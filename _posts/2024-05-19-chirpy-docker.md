---
title: "Testing Your Chirpy Blog in Docker"
date: 2024-05-19 12:00:00 +0000
categories: [Docker, Chirpy, Web Development, Jekyll]
tags: [Jekyll, Chirpy, blog, GitHub Pages, Submodule, Tutorial, Docker, Git]
---

# How to use a Docker Container to View Chirpy Blog Locally

The Chirpy docs say to test locally the site using:

```bash
bundle exec jekyll serve
```
after you have installed all the necessary dependencies, like [Ruby](https://jekyllrb.com/docs/installation/macos/).

I'm on an ARM MAC. 

I ran into many issues. 

So let's just use a Docker container.


## Docker: Single or Multi-container

When setting up a Jekyll blog with Docker, you have two main options depending on whether you need a single container or multiple containers.

For a single container setup you only need `Dockerfile`.

For a multi-container setup you also need a `docker-compose.yml`.


### Single Container Setup

If you only need a single container for your Jekyll blog, you can use the following commands without needing a `docker-compose.yml` file:

Create the necessary Docker setup file in the `blog` directory.

1. A Dockerfile (ie a file named `Dockerfile`)

#### Dockerfile

```dockerfile
# Dockerfile
FROM ruby:3.3

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

In your `blog` directory:

1. **Build the Docker Image**:
    ```sh
    docker build -t jekyll-container .
    ```

`-t jekyll-container`: The -t flag tags the image with a name, in this case, `jekyll-container`.
`.`: The dot just tells Docker to look for a Docker file in the current directory, `blog`.

2. **Run the Docker Container**:
    ```sh
    docker run -p 4000:4000 -v $(pwd):/usr/src/app jekyll-container
    ```

`-p 4000:4000`: The `-p` flag maps a port on the host to a port in the container. In this case, it maps port 4000 on the host to port 4000 in the container. This allows you to access the Jekyll site running inside the container via http://localhost:4000.

`-v $(pwd):/usr/src/app`: The `-v `flag mounts a volume. Here, it maps the current directory (`$(pwd)`) on the host to `/usr/src/app` in the container. This allows the container to access and serve the files from your current directory.

Now you should be able to access the local Chirpy site at: `http://localhost:4000` or `http://127.0.0.1:4000` in a browser. 


### Multiple Containers Setup

If you anticipate needing multiple containers (e.g., for additional services like a database), Docker Compose simplifies the management of these containers. Here's how you can set it up using a `docker-compose.yml` file:

In the `blog` directory add:

1. **Create a `docker-compose.yml` File**:

    ```yaml
    version: '3.8'

    services:
      jekyll:
        build: .
        ports:
          - "4000:4000"
        volumes:
          - .:/usr/src/app
        command: bundle exec jekyll serve --host 0.0.0.0
        environment:
          - JEKYLL_ENV=development

    ```

2. **Build and Run the Containers**:
    ```sh
    docker-compose build
    docker-compose up
    ```

Now you should be able to access the local Chirpy site at: `http://localhost:4000` or `http://127.0.0.1:4000` in a browser. 

To stop the containers, just `Ctrl+C`.


---

Nice. 
Now we can view our Chirpy blog locally, without needing to install all the dependencies manually. 


JS