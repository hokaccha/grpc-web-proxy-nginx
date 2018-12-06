#!/bin/bash

protoc -I ./protos helloworld.proto \
  --js_out=import_style=commonjs:./client/src \
  --grpc-web_out=import_style=commonjs,mode=grpcwebtext:./client/src

cd server
bundle check || bundle install
bundle exec grpc_tools_ruby_protoc -I ../protos helloworld.proto \
  --ruby_out=lib \
  --grpc_out=lib
