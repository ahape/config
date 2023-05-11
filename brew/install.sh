cat $1 | while read thing; do
    brew install "$thing"
done
