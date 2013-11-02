# Troodon SW website

# Setup

Install [rvm](http://beginrescueend.com/rvm/install/)

    gem install jekyll
    gem install s3_website
    s3_website cfg create
    # fill out s3_website.yml (don't commit)
    s3_website cfg apply # Shouldn't be necessary any more

# Building and Deploying

    # Setup paths to ruby and jekyll installs
    rvm use default

    # Test locally
    jekyll serve --watch

    # Deploy
    s3_website push

# Attributions

Note to self: be sure to keep attributions on the website.

The website uses code from [Jekyll Bootstrap](http://jekyllbootstrap.com).
