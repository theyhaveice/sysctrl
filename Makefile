CXX = clang++
CXXFLAGS = -std=c++11
FRAMEWORKS = -framework ApplicationServices

SRC = $(wildcard native/*.mm)
BIN_DIR = bin
OUT = $(BIN_DIR)/sysctrl-darwin

all: clean $(OUT)

$(OUT): $(SRC)
	$(CXX) $(CXXFLAGS) $(SRC) -o $(OUT) $(FRAMEWORKS)
	chmod +x $(OUT)

clean:
	@mkdir -p $(BIN_DIR)
	@rm -rf $(BIN_DIR)/*

.PHONY: all clean