.PHONY: clean
clean:
	@./scripts/clean

.PHONY: certs
certs:
	@./scripts/generate-certs

.PHONY: kube-configs
kube-configs:
	@./scripts/generate-kube-configs

.PHONY: encryption-config
encryption-config:
	@./scripts/generate-encryption-config
