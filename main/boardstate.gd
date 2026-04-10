class_name BoardState extends Node2D

# 16 tiles, 4 bits each -> 64 bits!
# We could do this in two 64-bit ints.

var board_state: PackedByteArray = []
