#!/bin/bash

script_dir=""$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )""
sdcore_path="$script_dir/sd-core"
dir="holder"
one='$1'
two='$2'

if [ -d "$sdcore_path" ]; then 
	echo "Found sd-core at $script_dir/sd-core"
else	
	echo "Must run script from sd-core parent directory."
	exit
fi

if ! command -v govers &> /dev/null; then
	echo "Installing govers tool..."
	command go install github.com/rogpeppe/govers@latest
fi

# cd $sdcore_path/webconsole
# echo "Entering $(pwd)"


# # Get deps of top level free5gc
# command go mod vendor
# command cp -rT vendor/ .
# command rm -rf vendor/

# Get deps of all NFs
cd $sdcore_path/
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
	command cp -rT vendor/ .
	command rm -rf vendor/
	# remove go.mod and go.sum from internals
	for subdir in */; do
		command cd $subdir > /dev/null
		echo "Removing go.mod and go.sum from $subdir"
		command find . -name go.mod -type f -delete
		command find . -name go.sum -type f -delete
		command cd .. > /dev/null
	done
	command cd .. > /dev/null
done

# Return to free5gc root to do perl replace
command cd $sdcore_path/

# Replace all imports except github.com/golang and github.com/free5gc/<current nf>
for d in */; do
	echo "Replacing Imports in $d"
	cd $d
	dir=${d%/}
	if [ $dir == "upf" ] ; then 
		dir="upf-epc" 
	fi 
	find_pregex="([[:blank:]]|import[[:blank:]])\"(github.com|google.golang.org|git.cs.nctu.edu.tw)\/(?!omec-project\/$dir)"
	perl_replace="$one\"github.com\/omec-project\/$dir\/$two\/"
	full_replace="'s/$find_pregex/$perl_replace/g'"
	for f in $(find . -name '*.go'); do
		eval perl -pi -e "$full_replace" $f
		#echo $f
	done
	echo "Updating go.mod"
	command sed -i 's/go 1.16/go 1.19/g' go.mod
	command go mod tidy
	echo "Leaving $d"
	cd ..
done


command cd $sdcore_path
if [ -d "sd_core_w_deps/" ]; then
  echo "Removing old database..."
  rm -rf sd_core_w_deps/
fi
echo "Making new database"
codeql database create sd_core_w_deps --overwrite --db-cluster --language=go,cpp --command=build_all_sd_core.sh

