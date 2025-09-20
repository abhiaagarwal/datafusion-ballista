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

ARG RUST_VERSION=1.89.0
FROM lukemathwalker/cargo-chef:latest-rust-$RUST_VERSION AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
RUN apt-get update && apt-get install -y protobuf-compiler
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --features rest-api

FROM gcr.io/distroless/static-debian12:nonroot AS base

FROM debian:bullseye-slim AS base-shell

FROM base AS scheduler
COPY --from=builder /app/target/release/ballista-scheduler /
ENTRYPOINT ["./ballista-scheduler"]
EXPOSE 50050

FROM base AS executor
COPY --from=builder /app/target/release/ballista-executor /
ENTRYPOINT ["./ballista-executor"]
EXPOSE 50051

FROM base AS cli
COPY --from=builder /app/target/release/ballista-cli /
ENTRYPOINT ["./ballista-cli"]

FROM base-shell AS benchmarks
COPY --from=builder /app/target/release/ballista-scheduler /root/ballista-scheduler
COPY --from=builder /app/target/release/ballista-executor /root/ballista-executor
COPY --from=builder /app/target/release/tpch /root/tpch
COPY benchmarks/run.sh /root/run.sh
COPY benchmarks/queries/ /root/benchmarks/queries
WORKDIR /root
CMD ["/root/run.sh"]

FROM base-shell AS standalone

RUN apt-get -qq update && apt-get install -qq -y wget

COPY --from=builder /app/target/release/ballista-scheduler /root/ballista-scheduler
COPY --from=builder /app/target/release/ballista-executor /root/ballista-executor

RUN chmod a+x /root/ballista-scheduler && \
    chmod a+x /root/ballista-executor

# populate some sample data for ListingSchemaProvider
RUN mkdir -p /data && \
    wget -q https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2022-01.parquet -P /data/
ENV DATAFUSION_CATALOG_LOCATION=/data
ENV DATAFUSION_CATALOG_TYPE=csv

# Expose Ballista Scheduler gRPC port
EXPOSE 50050
# Expose Ballista Executor gRPC port
EXPOSE 50051

COPY dev/standalone-entrypoint.sh /root/standalone-entrypoint.sh
ENTRYPOINT ["/root/standalone-entrypoint.sh"]