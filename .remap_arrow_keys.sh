#!/bin/bash
# arrow keys are borked!
# 1. remap left shift to arrow key 1
# 2. remap left option to arrow key 2
# reference - https://developer.apple.com/library/archive/technotes/tn2450/_index.html

hidutil property --set '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc":0x7000000e5, "HIDKeyboardModifierMappingDst":0x700000052},
{"HIDKeyboardModifierMappingSrc":0x7000000e6, "HIDKeyboardModifierMappingDst":0x700000051}] }'
