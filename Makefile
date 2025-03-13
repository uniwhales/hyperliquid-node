build:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 609193078125.dkr.ecr.us-east-1.amazonaws.com
	docker build --platform linux/amd64 -t 609193078125.dkr.ecr.us-east-1.amazonaws.com/hyperliquid-node-new .
	docker push 609193078125.dkr.ecr.us-east-1.amazonaws.com/hyperliquid-node-new

deploy:
	-kubectl delete deployment hyperliquid-node -n hyperliquid
	kubectl apply -f pvc.yaml -n hyperliquid
	kubectl apply -f deployment.yaml -n hyperliquid