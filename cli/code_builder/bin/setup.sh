#!/bin/bash

script_version=1.0.1

cd $(dirname $(realpath "$0"))
cd ..

project_root=$(pwd)
pubspec_file=pubspec.yaml

if [[ ! -f "$pubspec_file" ]]; then
  echo "Cannot find pubspec.yaml file in path: $project_root"
  exit 1
fi

app_name=$(grep -E '^name:' "$pubspec_file" | sed 's/name: //')
app_description=$(grep -E '^description:' "$pubspec_file" | sed 's/description: //')
app_version=$(grep -E '^version:' "$pubspec_file" | sed 's/version: //')

echo "Name: $app_name"
echo "Description: $app_description"
echo "Version: $app_version"
echo ""


compilation () {
  dart compile exe \
    "$project_root/lib/main.dart" \
    -D name="$app_name" \
    -D version="$app_version" \
    -D description="$app_description" \
    -o "$project_root/bin/$app_name"
}

installation () {
  #cp $project_root/bin/$app_name ~/.local/bin/
  cp $project_root/bin/$app_name ../../example_project/example_app/bin/
  cp $project_root/bin/$app_name ../../example_project/example_design/bin/
}


if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ -z "$1" ]; then
  echo "Commands:"
  echo ""
  #echo "  build      Run program build"
  echo "  compile    Run program compilation"
  echo "  install    Run program installation"
  echo ""
  echo "  help       Show this help"
  echo "  version    Show script version"
  echo ""
fi

if [ "$1" = "version" ] || [ "$1" = "--version" ] || [ "$1" = "-v" ]; then
  echo "Version: $script_version"
fi

if [ "$1" = "compile" ] || [ "$2" = "compile" ] || [ "$1" = "--compile" ] || [ "$2" = "--compile" ]; then
  compilation
  echo "Success compile"
fi

if [ "$1" = "build" ]  || [ "$2" = "build" ] || [ "$1" = "--build" ]  || [ "$2" = "--build" ]; then
  compilation
  echo "Success build"
fi

if [ "$1" = "install" ] || [ "$2" = "install" ] || [ "$1" = "--install" ] || [ "$2" = "--install" ]; then
  installation
  echo "Success install"
fi

