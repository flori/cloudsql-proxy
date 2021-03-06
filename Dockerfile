# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Use the latest stable golang 1.x to compile to a binary
FROM golang:alpine3.12 as build

ARG VERSION="1.18-bp"

WORKDIR /go/src/cloudsql-proxy
COPY . .

RUN go get ./...
RUN go build -ldflags "-X 'main.versionString=$VERSION'" -o cloud_sql_proxy ./cmd/cloud_sql_proxy

# Final Stage
FROM alpine:3.12.1

RUN apk add --no-cache ca-certificates

RUN apk add --update tzdata; \
  cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime; \
  echo "Europe/Berlin" >/etc/timezone; \
  apk del tzdata

COPY --from=build /go/src/cloudsql-proxy/cloud_sql_proxy /cloud_sql_proxy
