NF_FILES := fwd_main.c fwd_config.c loop.c state.c

NF_ARGS := --lan 0 \
           --wan 1 \
           --eth-dest 0,$(or $(TESTER_MAC_EXTERNAL),01:23:45:67:89:00) \
           --eth-dest 1,$(or $(TESTER_MAC_INTERNAL),01:23:45:67:89:01)

NF_LAYER := 4

include $(abspath $(dir $(lastword $(MAKEFILE_LIST))))/../Makefile
