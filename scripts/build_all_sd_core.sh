cd sd-core
for d in */; do
    command cd $d > /dev/null
    make
    cd ..
done