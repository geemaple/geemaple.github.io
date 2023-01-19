[Personal blog](http://geemaple.github.io/)

## How to run locally:

```sh
git clone git@github.com:geemaple/geemaple.github.io.git
cd geemaple.github.io
bundle update github-pages 
bundle install
bundle exec jekyll serve
```

## Run with Custom Config

```sh
# same as above except last command
bundle exec jekyll serve --drafts --unpublished --future --config _debug_config.yml
```

## Why another _debug_config file?

1. It's more easy to display images with `static` variable poiting to local url
2. Disable google analysis when writing blogs