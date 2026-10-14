# Local act helper for this submodule.
ACT ?= act
ACT_WORKFLOW ?= .github/workflows/ci.yml
ACT_IMAGE ?= ghcr.io/catthehacker/ubuntu:act-latest

ACT_HOST_ARCH := $(shell uname -m)
ifeq ($(filter aarch64 arm64,$(ACT_HOST_ARCH)),)
ACT_CONTAINER_ARCH ?= linux/amd64
else
ACT_CONTAINER_ARCH ?= linux/amd64
endif

ACT_JOB ?= build
ACT_EXTRA_FLAGS ?=

ACT_BIND ?= false
ACT_DRYRUN ?= false
ACT_LIST ?= false
ACT_PRIVILEGED ?= false
ACT_QUIET ?= false
ACT_REBUILD ?= false
ACT_REUSE ?= false
ACT_WATCH ?= false
ACT_SHELL ?= bash
ACT_SHELL_WORKDIR ?= /workspace

ACT_PLATFORM_OVERRIDES := -P ubuntu-latest=$(ACT_IMAGE)

ifeq ($(strip $(ACT_CONTAINER_ARCH)),)
ACT_ARCH_FLAG :=
else
ACT_ARCH_FLAG := --container-architecture $(ACT_CONTAINER_ARCH)
endif

ACT_BASE_FLAGS := -v $(ACT_PLATFORM_OVERRIDES) $(ACT_ARCH_FLAG)
ACT_WORKFLOW_FLAGS := -W $(ACT_WORKFLOW)
ACT_OPTIONAL_FLAGS :=

ifeq ($(ACT_BIND),true)
ACT_OPTIONAL_FLAGS += --bind
ACT_EXTRA_FLAGS += --env BIND=true
endif
ifeq ($(ACT_DRYRUN),true)
ACT_OPTIONAL_FLAGS += --dryrun
endif
ifeq ($(ACT_LIST),true)
ACT_OPTIONAL_FLAGS += --list
endif
ifeq ($(ACT_PRIVILEGED),true)
ACT_OPTIONAL_FLAGS += --privileged
endif
ifeq ($(ACT_QUIET),true)
ACT_OPTIONAL_FLAGS += --quiet
endif
ifeq ($(ACT_REBUILD),true)
ACT_OPTIONAL_FLAGS += --rebuild
endif
ifeq ($(ACT_REUSE),true)
ACT_OPTIONAL_FLAGS += --reuse
ACT_EXTRA_FLAGS += --env REUSE=true
endif
ifeq ($(ACT_WATCH),true)
ACT_OPTIONAL_FLAGS += --watch
endif

ACT_RUN_FLAGS := $(ACT_BASE_FLAGS) $(ACT_WORKFLOW_FLAGS) $(ACT_OPTIONAL_FLAGS) $(ACT_EXTRA_FLAGS)

.PHONY: act-build act-list act-watch act-shell act-job

act-build:
	$(ACT) $(ACT_RUN_FLAGS) -j $(ACT_JOB)

act-job:
	$(ACT) $(ACT_RUN_FLAGS) -j $(ACT_JOB)

act-list:
	$(ACT) $(filter-out --list,$(ACT_RUN_FLAGS)) --list

act-watch:
	$(ACT) $(filter-out --watch,$(ACT_RUN_FLAGS)) --watch

act-shell:
	docker run --rm -it --platform $(ACT_CONTAINER_ARCH) \
		-v "$(CURDIR):$(ACT_SHELL_WORKDIR)" \
		-w "$(ACT_SHELL_WORKDIR)" \
		--entrypoint $(ACT_SHELL) \
		$(ACT_IMAGE)
