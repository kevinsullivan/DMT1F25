# Source and target directories
SRC_DIR := code/DMT1
BUILD_DIR := src/DMT1

# Find all source files recursively
SRC_FILES := $(shell find $(SRC_DIR) -type f -name '*.lean')
# Derive corresponding output files with .md extension
BUILD_FILES := $(patsubst $(SRC_DIR)/%, $(BUILD_DIR)/%.md, $(SRC_FILES))

# Default target: process all files
all: $(BUILD_FILES)

# Rule to process files and maintain directory structure
$(BUILD_DIR)/%.md: $(SRC_DIR)/%
	@mkdir -p $(dir $@)  # Create the directory structure
	echo "Converting $< into $@"
	scripts/convert.hs $< $@

# Clean up the build directory
clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
