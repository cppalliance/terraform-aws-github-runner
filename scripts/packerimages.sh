#!/bin/bash

imagestobuild="
windows-core-2019-cppal
windows-core-2022-cppal
"

cd ..
mainfolder=$(pwd)

task(){
    echo "Building $1"
    cd $mainfolder/images/$1
    packer build . | tee output.out 2>&1    
}

for image in $imagestobuild; do 
  task "$image" &
done

