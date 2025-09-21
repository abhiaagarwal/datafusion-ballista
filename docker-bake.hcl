# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

variable "BALLISTA_VERSION" {
  default = ""
}

variable "REGISTRY" {
  default = "apache"
}

variable "RUST_VERSION" {
  default = "1.89.0"
}

function "tags" {
  params = [name]
  result = [
    "${REGISTRY}/datafusion-ballista-${name}:latest",
    notequal("", BALLISTA_VERSION) ? "${REGISTRY}/datafusion-ballista-${name}:${BALLISTA_VERSION}" : "",
  ]
}

group "default" {
  targets = ["standalone", "scheduler", "executor", "cli", "benchmarks"]
}

target "standalone" {
  dockerfile = "dev/Dockerfile"
  target = "standalone"
  args = {
    RUST_VERSION = RUST_VERSION
  }
  tags = tags("standalone")
  labels = {
    "org.opencontainers.image.source" = "https://github.com/apache/datafusion-ballista"
    "org.opencontainers.image.description" = "Apache Arrow Ballista Distributed SQL Query Engine"
    "org.opencontainers.image.licenses" = "Apache-2.0"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "scheduler" {
  dockerfile = "dev/Dockerfile"
  target = "scheduler"
  args = {
    RUST_VERSION = RUST_VERSION
  }
  tags = tags("scheduler")
  labels = {
    "org.opencontainers.image.source" = "https://github.com/apache/datafusion-ballista"
    "org.opencontainers.image.description" = "Apache Arrow Ballista Scheduler"
    "org.opencontainers.image.licenses" = "Apache-2.0"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "executor" {
  dockerfile = "dev/Dockerfile"
  target = "executor"
  args = {
    RUST_VERSION = RUST_VERSION
  }
  tags = tags("executor")
  labels = {
    "org.opencontainers.image.source" = "https://github.com/apache/datafusion-ballista"
    "org.opencontainers.image.description" = "Apache Arrow Ballista Executor"
    "org.opencontainers.image.licenses" = "Apache-2.0"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "cli" {
  dockerfile = "dev/Dockerfile"
  target = "cli"
  args = {
    RUST_VERSION = RUST_VERSION
  }
  tags = tags("cli")
  labels = {
    "org.opencontainers.image.source" = "https://github.com/apache/datafusion-ballista"
    "org.opencontainers.image.description" = "Apache Arrow Ballista CLI"
    "org.opencontainers.image.licenses" = "Apache-2.0"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}

target "benchmarks" {
  dockerfile = "dev/Dockerfile"
  target = "benchmarks"
  args = {
    RUST_VERSION = RUST_VERSION
  }
  tags = tags("benchmarks")
  labels = {
    "org.opencontainers.image.source" = "https://github.com/apache/datafusion-ballista"
    "org.opencontainers.image.description" = "Apache Arrow Ballista Benchmarks"
    "org.opencontainers.image.licenses" = "Apache-2.0"
  }
  platforms = ["linux/amd64", "linux/arm64"]
}