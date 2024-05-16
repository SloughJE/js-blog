# Use the official Ruby image
FROM ruby:3.1.3

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set the working directory
WORKDIR /usr/src/app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile* /usr/src/app/

# Install Bundler
RUN gem install bundler

# Install gems specified in the Gemfile
RUN bundle install

# Copy the rest of the application files
COPY . /usr/src/app

# Expose port 4000 for Jekyll
EXPOSE 4000

# Run Jekyll server by default
CMD ["jekyll", "serve", "--host", "0.0.0.0"]