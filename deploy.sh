if [ "$TRAVIS_BRANCH" == "staging" ] && [ "$TRAVIS_PULL_REQUEST" == "false"]; then
	openssl aes-256-cbc -k $DEPLOY_KEY -in config/deploy_id_rsa_travis_enc_travis -d -a -out
	bundle exec cap staging deploy
fi
