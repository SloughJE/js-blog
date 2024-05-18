


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
