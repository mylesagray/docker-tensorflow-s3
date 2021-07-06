#!/bin/bash
# Usage: ./build-tf-serving.sh mylesagray r1.15-cpu-opt r1.15
# https://mux.com/blog/tuning-performance-of-tensorflow-serving-pipeline/
# https://github.com/tensorflow/serving/blob/master/tensorflow_serving/g3doc/setup.md#optimized-build

# Clone TF serving repo
cd ..
USER=$1
TAG=$2
TF_SERVING_VERSION_GIT_BRANCH=$3
git clone --branch="${TF_SERVING_VERSION_GIT_BRANCH}" https://github.com/tensorflow/serving

# Add instruction sets to TF serving compilation explicitly, as most are excluded by default, slowing down inferencing
TF_SERVING_BUILD_OPTIONS="--copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-msse4.1 --copt=-msse4.2"

# Update the pypi script in the Dockerfile to point to py 2.7 as it has moved
sed -i '' 's,https://bootstrap.pypa.io/get-pip.py,https://bootstrap.pypa.io/pip/2.7/get-pip.py,g' serving/tensorflow_serving/tools/docker/Dockerfile.devel

# Build the tf-serving-devel dockerfile
cd serving && \
  docker build --pull -t $USER/tensorflow-serving-devel:$TAG \
  --build-arg TF_SERVING_VERSION_GIT_BRANCH="${TF_SERVING_VERSION_GIT_BRANCH}" \
  --build-arg TF_SERVING_BUILD_OPTIONS="${TF_SERVING_BUILD_OPTIONS}" \
  -f tensorflow_serving/tools/docker/Dockerfile.devel .

# Build the tf-serving container with the devel as a base
docker build -t $USER/tensorflow-serving:$TAG \
  --build-arg TF_SERVING_BUILD_IMAGE=$USER/tensorflow-serving-devel:$TAG \
  -f tensorflow_serving/tools/docker/Dockerfile .

# Build ANPR Serving image with baked in model
cd ../docker-tensorflow-s3 && \
  docker build -t harbor-repo.vmware.com/vspheretmm/anpr-serving:$TAG \
  -t quay.io/mylesagray/anpr-serving:$TAG \
  -t $USER/anpr-serving:$TAG \
  -f Dockerfile .