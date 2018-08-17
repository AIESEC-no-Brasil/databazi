#!/bin/sh
bundle exec rails db:migrate RAILS_ENV=test

if [ "$TRAVIS_PULL_REQUEST" = "true" ]; then
	bundle exec rspec spec/ --flag ~aws:true
else
	bundle exec rspec spec/
fi
