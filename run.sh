#!/bin/sh

set -e

function upload() {
  filename=$1
  folder=$2
  echo "uploading $folder/$filename..."
  clokta-load bigdata aws s3 cp "$filename" "s3://washpost-perso-1-prod/lambda-compiled-binaries/$folder/"
}

function build() {

  package="$1"
  egg="$2"
  version="$3"
  python_version="$4"
  precommand=${5:-true}

  rm -rf "temp"
  mkdir -p "temp"

  docker run -v $(pwd)/"temp/":/outputs \
  		   lambci/lambda:build-python$python_version \
         sh -c "$precommand && pip install $package==$version -t /outputs/"
  (cd "temp" && tar -czvf "$package-$version.tgz" "$egg")
  mv "temp/$package-$version.tgz" ./
  rm -rf "temp"
}

function build_and_upload() {
  package="$1"
  egg="$2"
  version="$3"
  python_version="$4"
  folder="$5"
  precommand="$6"

  build "$package" "$egg" "$version" "$python_version" "$precommand"
  upload "$package-$version.tgz" "$folder"
}

build_and_upload lxml lxml 4.3.3 3.6 py36
build_and_upload psycopg2 psycopg2 2.8.2 3.6 py36 "yum install -y postgresql-devel"
build_and_upload numpy numpy 1.16.3 3.6 py36

build_and_upload lxml lxml 4.3.3 3.7 py37
build_and_upload psycopg2 psycopg2 2.8.2 3.7 py37 "yum install -y postgresql-devel"
build_and_upload numpy numpy 1.16.3 3.7 py37
