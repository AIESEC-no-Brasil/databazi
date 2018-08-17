#!/bin/sh
bundle exec rails db:migrate RAILS_ENV=test

if [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
	bundle exec rspec spec/
else
	eval "bundle exec rspec spec/ --tag ~aws:true"
fi
