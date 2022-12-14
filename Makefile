# Go parameters
GOCMD=GO111MODULE=on go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test

all: test build
build:
	rm -rf target/
	mkdir target/
	cp cmd/comet/comet-example.toml target/comet.toml
	cp cmd/logic/logic-example.toml target/logic.toml
	cp cmd/job/job-example.toml target/job.toml
	$(GOBUILD) -o target/comet cmd/comet/main.go
	$(GOBUILD) -o target/logic cmd/logic/main.go
	$(GOBUILD) -o target/job cmd/job/main.go

test:
	$(GOTEST) -v ./...

clean:
	rm -rf target/

run:
	nohup target/logic -conf=target/logic.toml -region=sh -zone=sh001 -deploy.env=dev -weight=10 2>&1 > target/logic.log &
	nohup target/comet -conf=target/comet.toml -region=sh -zone=sh001 -deploy.env=dev -weight=10 -addrs=127.0.0.1 -debug=true 2>&1 > target/comet.log &
	nohup target/job -conf=target/job.toml -region=sh -zone=sh001 -deploy.env=dev 2>&1 > target/job.log &

stop:
	pkill -f target/logic
	pkill -f target/job
	pkill -f target/comet

dis:
	cd target && ./discovery -conf=discovery.toml

logic:
	target/logic -conf=target/logic.toml -region=sh -zone=sh001 -deploy.env=dev -weight=10

comet:
	target/comet -conf=target/comet.toml -region=sh -zone=sh001 -deploy.env=dev -weight=10 -addrs=127.0.0.1 -debug=true

job:
	target/job -conf=target/job.toml -region=sh -zone=sh001 -deploy.env=dev

demo:
	echo "127.0.0.1:1999" && cd examples/javascript && go run main.go

zoo:
	# wsl: /root/download/kafka_2.12-2.6.0/bin/zookeeper-server-start.sh /root/download/kafka_2.12-2.6.0/config/zookeeper.properties
	target/kafka_2.13-3.2.1/bin/zookeeper-server-start.sh target/kafka_2.13-3.2.1/config/zookeeper.properties

kafka:
	# wsl: /root/download/kafka_2.12-2.6.0/bin/kafka-server-start.sh /root/download/kafka_2.12-2.6.0/config/server.properties
	rm -rf target/kafka_2.13-3.2.1/logs && \
	target/kafka_2.13-3.2.1/bin/kafka-server-start.sh target/kafka_2.13-3.2.1/config/server.properties

curl:
	curl -d 'mid message' 'http://127.0.0.1:3111/goim/push/mids?operation=1000&mids=123' \
	&& curl -d 'room message' 'http://127.0.0.1:3111/goim/push/room?operation=1000&type=live&room=1000'\
	&& curl -d 'broadcast message' 'http://127.0.0.1:3111/goim/push/all?operation=1000' \
	&& curl 'http://127.0.0.1:3111/goim/online/room?type=live&rooms=1000&rooms=1001' \
	&& curl 'http://127.0.0.1:3111/goim/online/top?type=live&limit=10' \
	&& curl 'http://127.0.0.1:3111/goim/online/total'\
	&& curl 'http://127.0.0.1:3111/goim/nodes/weighted' \
	&& curl 'http://127.0.0.1:3111/goim/nodes/instances'



