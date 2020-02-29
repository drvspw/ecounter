BASEDIR = $(shell pwd)
APPNAME = $(shell basename $(BASEDIR))
REBAR = rebar3
ELVIS = $(BASEDIR)/elvis

APPVSN = $(shell ./.package.sh version)

LINTERS = elvis xref eunit

REGRESSION_TEST_DIR := test/
REGRESSION_TEST_FILES := $(shell find $(REGRESSION_TEST_DIR) -name '*_SUITE.erl' -exec basename '{}' \;)
REGRESSION_TEST_SUITES := $(shell echo $(REGRESSION_TEST_FILES) | sed -e 's/.erl//g' | sed -e 's/ /,/g')

.PHONY: elvis

compile:
	$(REBAR) compile

eunit:
	$(REBAR) eunit

xref:
	$(REBAR) xref

dialyzer:
	$(REBAR) dialyzer

elvis:
	$(ELVIS) rock -c elvis.config

test: $(LINTERS)
	sudo $(REBAR) ct -v \
		--dir $(REGRESSION_TEST_DIR) \
		--suite=$(REGRESSION_TEST_SUITES) \
		--include $(BASEDIR)/include \
		--sys_config $(BASEDIR)/test/stubs/sys.config

console: test
	$(REBAR) shell

todo:
	$(REBAR) todo

clean:
	$(REBAR) clean
	rm -rf _build

test-coverage-report:
	$(REBAR) cover --verbose
