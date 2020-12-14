.PHONY: clean
clean:
	@./scripts/clean

.PHONY: certs
certs:
	@./scripts/generate-certs

.PHONY: kube-configs
kube-configs:
	@./scripts/generate-kube-configs
