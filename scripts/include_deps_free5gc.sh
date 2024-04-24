#!/bin/bash

script_dir=""$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )""
free5gc_path="$script_dir/free5gc"
dir="holder"
one='$1'
two='$2'

## Everything below here is specific to free5gc

if [ -d "$free5gc_path" ]; then 
	echo "Found free5gc at $script_dir/free5gc"
else	
	echo "Must run script from free5gc parent directory."
	exit
fi

if ! command -v govers &> /dev/null; then
	echo "Installing govers tool..."
	command go install github.com/rogpeppe/govers@latest
fi

cd $free5gc_path/webconsole
echo "Entering $(pwd)"


# Get deps of top level free5gc (It had a webconsole at top level)
command go mod vendor
command cp -rT vendor/ . # copy all vendor files to top level
command rm -rf vendor/ # remove vendor folder because Go get mad

# Get deps of all NFs
cd $free5gc_path/NFs/
for d in */; do
	command cd $d > /dev/null
	echo "Copying in Deps for $d"
	# remove old folders if we are doing it again
	if [ -d "github.com/" ] || [ -d "golang.org/" ] || [ -d "go.mongodb.org/" ] || [ -d "google.golang.org/" ] ||
	 [ -d "gopkg.in/" ] || [ -d "git.cs.nctu.edu.tw/" ];
	 then
		echo "Removing old dep folders..."
    rm -rf github.com/ golang.org/ go.mongodb.org/ google.golang.org/ gopkg.in/ git.cs.nctu.edu.tw/
 	fi
	command go mod vendor
	command cp -rT vendor/ . # copy all vendor files to relative top level
	command rm -rf vendor/ # Remove vendor folder because Go get mad
	# remove go.mod and go.sum from internals
	for subdir in */; do
		command cd $subdir > /dev/null
		echo "Removing go.mod and go.sum from $subdir"
		command find . -name go.mod -type f -delete # remove go.mod
		command find . -name go.sum -type f -delete # remove go.sum
		command cd .. > /dev/null
	done
	command cd .. > /dev/null
done
# exit 0
# Return to free5gc root to do perl replace
command cd $free5gc_path/NFs

# Replace all imports except github.com/golang and github.com/free5gc/<current nf>
for d in */; do
	echo "Replacing Imports in $d"
	cd $d
	dir=${d%/}
	upf_dir=$dir
	if [ $dir = "upf" ]; then
		upf_dir="go-upf"
	fi
	find_pregex="([[:blank:]]|import[[:blank:]])\"(github.com|google.golang.org|git.cs.nctu.edu.tw)\/(?!free5gc\/$upf_dir)(?!golang)"
	perl_replace="$one\"github.com\/free5gc\/$upf_dir\/$two\/"
	full_replace="'s/$find_pregex/$perl_replace/g'"
	for f in $(find . -name '*.go'); do
		eval perl -pi -e "$full_replace" $f
		#echo $f
	done
	echo "Updating go.mod"
	command go mod tidy # Since we deleted the go.mod and go.sum, go mod tidy regenerates those files with the new imports
	echo "Leaving $d"
	cd ..
done

# # move main.go from cmd to base folder for codeql
# command cd $free5gc_path/NFS
# for d in */; do
# 	echo "Relocating main.go in $d"
# 	cd $d
# 	mv cmd/main.go .
# 	cd ..
# done

# # Fix Makefile
# command cd $free5gc_path
# command sed -i 's/$(GO_SRC_PATH)\/$(@F)\/cmd/$(GO_SRC_PATH)\/$(@F)/g' Makefile

# command cd $free5gc_path
# if [ -d "full_free5gc_with_deps/" ]; then
#   echo "Removing old database..."
#   rm -rf full_free5gc_with_deps/
# fi
# echo "Making new database"
# codeql database create full_free5gc_with_deps --language=go --command=make

