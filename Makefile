REPO?=0xe282b0/

build:
	docker build --platform linux/amd64 -f Dockerfile -t $(REPO)spin-openshift-installer:amd64-latest x86_64
	docker build --platform linux/arm64 -f Dockerfile -t $(REPO)spin-openshift-installer:arm64-latest aarch64
push: build
	docker push $(REPO)spin-openshift-installer:amd64-latest
	docker push $(REPO)spin-openshift-installer:arm64-latest
	docker manifest create $(REPO)spin-openshift-installer:latest \
		--amend $(REPO)spin-openshift-installer:amd64-latest \
		--amend $(REPO)spin-openshift-installer:arm64-latest
	docker manifest push -p $(REPO)spin-openshift-installer:latest