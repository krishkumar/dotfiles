#!/bin/bash
# touchbar is so dumb sometimes!
# 1. remap escape on touchbar to caps lock key
# reference - https://developer.apple.com/library/archive/technotes/tn2450/_index.html

hidutil property --set '{"UserKeyMapping": [{"HIDKeyboardModifierMappingSrc":0x700000029, "HIDKeyboardModifierMappingDst":0x700000039},
{"HIDKeyboardModifierMappingSrc":0x700000039, "HIDKeyboardModifierMappingDst":0x700000029}] }'
