PROFILE := kanetus2
ACCOUNT := 076279718063
REGION := us-east-2
VERSION := 1-0
LAMBDA_KEY := authorizer
STACK := voy-authorizer

dep:
	# go get -u github.com/CodyPerakslis/kanetus-database-lib/dbupdate
	go get -u github.com/CodyPerakslis/kanetus-database-lib/auth
	# go get -u github.com/CodyPerakslis/kanetus-database-lib/locationdb
	# go get -u github.com/CodyPerakslis/kanetus-database-lib/api

insert:
	cd src/authorizer && GOOS=linux go build authorizer.go
	cd src/authorizer && zip handler.zip authorizer
	aws s3 cp src/authorizer/handler.zip "s3://cf-$(REGION)-$(ACCOUNT)-bucket/$(LAMBDA_KEY)/version-$(VERSION)" --profile $(PROFILE)
	rm src/authorizer/handler.zip
	rm src/authorizer/authorizer

update: insert
	aws lambda update-function-code \
		--function-name arn:aws:lambda:us-east-2:076279718063:function:voy-authorizer-v1-0-AuthorizerLambda-1OBYVKUTTFFQM \
		--s3-bucket "cf-$(REGION)-$(ACCOUNT)-bucket" \
		--s3-key "$(LAMBDA_KEY)/version-$(VERSION)" \
		--profile $(PROFILE)



deploy:
	aws cloudformation deploy \
			--template-file deploy.yml \
			--stack-name "$(STACK)-v$(VERSION)" \
			--s3-bucket "cf-$(REGION)-$(ACCOUNT)-bucket" \
			--s3-prefix upload/ \
			--capabilities CAPABILITY_IAM \
			--parameter-overrides "S3Bucket=cf-$(REGION)-$(ACCOUNT)-bucket" \
				"Version=$(VERSION)" \
				"S3Key=$(LAMBDA_KEY)/version-$(VERSION)" \
			--profile $(PROFILE) \
			--region $(REGION)
